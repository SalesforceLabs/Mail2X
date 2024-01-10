global with sharing class MailMatchingHandler implements Messaging.InboundEmailHandler {
  public with sharing class HandleException extends Exception {
  }

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    String subject           = email.subject;
    String originalBody      = email.plainTextBody;
    String originalHtmlBody  = email.htmlBody;
    String newLineBody       = originalBody.replaceAll('\r\n', '\n');
    String body              = newLineBody.replaceAll('\n', '#n#');
    List<Messaging.InboundEmail.Header> headers = email.headers;
    //List<String> mailReferences  = email.references;
    String eaddr             = email.fromAddress;
    String ename             = email.fromName;
    String received;
    List<String> toaddr      = email.toAddresses;
    String errorTitle        = '';
    String errorResMessage   = 'メールサービス処理でエラーが発生しました。';
    Boolean errorFileSetting = false;
    Boolean saveErrorLog     = false;
    result.success = false;
    List<String> addressKeySet = new List<String>();

    addressKeySet.add(eaddr);
    addressKeySet.addAll(toaddr);

    if (headers != null) {
      String regex = '(?:\\s+)for(?:\\s+)<(.*?)>';
      Pattern regexPattern = Pattern.compile(regex);

      for (Messaging.InboundEmail.Header header : headers) {
        //後勝ち、最後の転送元の情報を拾う
        if ('received'.equalsIgnoreCase(header.name)) {
          Matcher regexMatcher = regexPattern.matcher(header.value);

          if (regexMatcher.find()) {
            received = (String) regexMatcher.group(1);
          }
        }
      }

      if (received != null) {
        addressKeySet.add(received);
      }
    }

    try {
      if (
        Schema.sObjectType.MailMatchingSetting__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.AddressKey__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.ObjectApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.SubjectApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.SettingNameApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.ProviderNameApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.ProviderMailAddressApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.OriginalMessageApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.AttachmentFile__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.ErrorResMessage__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.SaveErrorLog__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.AddressTarget__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingSetting__c.fields.Availability__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.FieldApi__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.StartText1__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.StartText2__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.EndText1__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.ManualMatching__c.isAccessible() != true ||
        Schema.sObjectType.MailMatchingDetail__c.fields.SettingMaster__c.isAccessible() != true
      ) {
        throw new HandleException('Object Access Setting Error');
      }

      //送信元メールから設定情報を取得
      List<mail2x__MailMatchingSetting__c> matchSettings = [
        SELECT
          Name,
          mail2x__AddressKey__c,
          mail2x__ObjectApi__c,
          mail2x__SubjectApi__c,
          mail2x__SettingNameApi__c,
          mail2x__ProviderNameApi__c,
          mail2x__ProviderMailAddressApi__c,
          mail2x__OriginalMessageApi__c,
          mail2x__AttachmentFile__c,
          mail2x__ErrorResMessage__c,
          mail2x__SaveErrorLog__c,
          mail2x__AddressTarget__c
        FROM
          mail2x__MailMatchingSetting__c
        WHERE
          mail2x__Availability__c = true AND mail2x__AddressKey__c IN :addressKeySet
        WITH SECURITY_ENFORCED
      ];

      for (MailMatchingSetting__c matchSetting : matchSettings) {
        List<String> targetCheck = new List<String>();

        if (matchSetting.mail2x__AddressTarget__c.equalsIgnoreCase('from')) {
          targetCheck.add(eaddr);
        } else if (matchSetting.mail2x__AddressTarget__c.equalsIgnoreCase('to')) {
          targetCheck = toaddr;
        } else if (matchSetting.mail2x__AddressTarget__c.equalsIgnoreCase('transfer')) {
          targetCheck.add(received);
        }

        if (!targetCheck.contains(matchSetting.mail2x__AddressKey__c)) {
          System.debug(LoggingLevel.WARN, 'address does not match:' + matchSetting.mail2x__AddressKey__c + ' / ' + targetCheck);
          continue;
        }

        errorTitle       = matchSetting.Name;
        errorFileSetting = matchSetting.mail2x__AttachmentFile__c;
        errorResMessage  = matchSetting.mail2x__ErrorResMessage__c;
        saveErrorLog     = matchSetting.mail2x__SaveErrorLog__c;

        List<MailMatchingDetail__c> matchDetail = [SELECT mail2x__FieldApi__c, mail2x__StartText1__c, mail2x__StartText2__c, mail2x__EndText1__c, mail2x__ManualMatching__c FROM mail2x__MailMatchingDetail__c WHERE mail2x__SettingMaster__c = :matchSetting.Id WITH SECURITY_ENFORCED];

        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(matchSetting.mail2x__ObjectApi__c);

        if (
          objectType.getDescribe().isCreateable() != true
        ) {
          throw new HandleException('Object Access Setting Error');
        }

        if (objectType == null) {
          throw new HandleException('Object Not Found');
        }

        sObject newRecord = objectType.newSObject();
        Map<String, Schema.SObjectField> describeMap = objectType.getDescribe().fields.getMap();

        //固定パラメータ取得
        if (
          matchSetting.mail2x__SubjectApi__c != null &&
          objectType.getDescribe().fields.getMap().get(matchSetting.mail2x__SubjectApi__c).getDescribe().isCreateable() == true
        ) {
          newRecord.put(matchSetting.mail2x__SubjectApi__c, subject);
        }
        if (
          matchSetting.mail2x__SettingNameApi__c != null &&
          objectType.getDescribe().fields.getMap().get(matchSetting.mail2x__SettingNameApi__c).getDescribe().isCreateable() == true
        ) {
          newRecord.put(matchSetting.mail2x__SettingNameApi__c, matchSetting.Name);
        }
        if (
          matchSetting.mail2x__ProviderNameApi__c != null &&
          objectType.getDescribe().fields.getMap().get(matchSetting.mail2x__ProviderNameApi__c).getDescribe().isCreateable() == true
        ) {
          newRecord.put(matchSetting.mail2x__ProviderNameApi__c, ename);
        }
        if (
          matchSetting.mail2x__ProviderMailAddressApi__c != null &&
          objectType.getDescribe().fields.getMap().get(matchSetting.mail2x__ProviderMailAddressApi__c).getDescribe().isCreateable() == true
        ) {
          newRecord.put(matchSetting.mail2x__ProviderMailAddressApi__c, eaddr);
        }
        if (
          matchSetting.mail2x__OriginalMessageApi__c != null &&
          objectType.getDescribe().fields.getMap().get(matchSetting.mail2x__OriginalMessageApi__c).getDescribe().isCreateable() == true
        ) {
          newRecord.put(matchSetting.mail2x__OriginalMessageApi__c, newLineBody);
        }

        //マッチングパラメータ
        for (mail2x__MailMatchingDetail__c matchRule : matchDetail) {
          String start1 = replaceRegString(matchRule.mail2x__StartText1__c);
          String start2 = replaceRegString(matchRule.mail2x__StartText2__c);
          String end1 = replaceRegString(matchRule.mail2x__EndText1__c);
          String matchString = '';
          Boolean check = false;

          Schema.SObjectField field = describeMap.get(matchRule.mail2x__FieldApi__c);
          Schema.DisplayType fldType = field.getDescribe().getType();

          if (
            field.getDescribe().isCreateable() != true
          ) {
            throw new HandleException('Error Object Field Access Setting Error');
          }

          //マニュアルを優先
          if (matchRule.mail2x__ManualMatching__c != null && !String.isBlank(matchRule.mail2x__ManualMatching__c.trim())) {
            matchString = matchRule.mail2x__ManualMatching__c.replaceAll('\\\\n', '#n#');
            setParamater(body, matchString, matchRule.mail2x__FieldApi__c, newRecord, fldType);
          } else {
            matchString = start1;

            if (start2 != null && !String.isBlank(start2)) {
              matchString += '.*?' + start2;
            }

            //開始文字チェック
            Pattern matchPatternFirst = pattern.compile('.*?(' + matchString + '.*)');
            Matcher matchMatcherFirst = matchPatternFirst.matcher(body);
            check = matchMatcherFirst.find();

            if (end1 != null && !String.isBlank(end1)) {
              matchString += ('((.*?))' + end1);
            } else {
              matchString += '((.*?#n#))';
            }

            //終了文字が存在するか
            String checkEndWird;
            if (end1 != null && !String.isBlank(end1)) {
              checkEndWird = '^(.*' + end1 + ').*';
            } else {
              checkEndWird = '((.*?#n#))';
            }
            Pattern matchPatternEnd = pattern.compile(checkEndWird);
            Matcher matchMatcherEnd = matchPatternEnd.matcher(body);
            check = check && matchMatcherEnd.find();

            if (check) {
              setParamater(body, matchString, matchRule.mail2x__FieldApi__c, newRecord, fldType);
            }
          }
        }

        insert newRecord;

        //添付メールの付与
        if (matchSetting.AttachmentFile__c == true && email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
          if (
            Schema.sObjectType.Attachment.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.Name.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.Body.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.ParentId.isCreateable() != true
          ) {
            throw new HandleException('Error Attachment Access Error');
          }

          List<Attachment> attachmentList = new List<Attachment>();

          for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
            Attachment attachment = new Attachment();

            attachment.Name = bAttachment.fileName;
            attachment.Body = bAttachment.body;
            attachment.ParentId = newRecord.Id;
            attachmentList.add(attachment);
          }

          insert attachmentList;
        }

        result.success = true;
      }

      return result;
    } catch (Exception e) {
      if (
        Schema.sObjectType.Mail2XErrorMail__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.Name.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.From__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.To__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.Name__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.Subject__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.TextBody__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.HtmlBody__c.isCreateable() != true ||
        Schema.sObjectType.Mail2XErrorMail__c.fields.ErrorMessage__c.isCreateable() != true
      ) {
        throw new HandleException('Error Object Access Setting Error');
      }

      //何かしら例外発生時の通知文面
      //受信したメールの「reply-to」に指定したアドレスに対して送信される(未指定の場合はfrom)
      result.message = errorResMessage.replace('\\n', '\n');
      result.message += '\n\n';
      result.message += '【元メール】\n';
      result.message += originalBody;
      result.message += '\n';
      result.message += '【エラーメッセージ】\n';
      result.message += e.getMessage();
      result.success = false;

      if (saveErrorLog == true) {
        Mail2XErrorMail__c errorObject = new Mail2XErrorMail__c(
          Name = errorTitle,
          From__c = eaddr,
          To__c = String.join(toaddr, ',\n'),
          Name__c = ename,
          Subject__c = subject,
          TextBody__c = originalBody,
          HtmlBody__c = originalHtmlBody,
          ErrorMessage__c = e.getMessage()
        );

        insert errorObject;

        //添付メールの関連付け
        if (errorFileSetting == true && email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
          if (
            Schema.sObjectType.Attachment.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.Name.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.Body.isCreateable() != true ||
            Schema.sObjectType.Attachment.fields.ParentId.isCreateable() != true
          ) {
            throw new HandleException('Error Attachment Access Error');
          }

          List<Attachment> attachmentList = new List<Attachment>();

          for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
            Attachment attachment = new Attachment();

            attachment.Name = bAttachment.fileName;
            attachment.Body = bAttachment.body;
            attachment.ParentId = errorObject.Id;
            attachmentList.add(attachment);
          }

          insert attachmentList;
        }
      }
    }

    return result;
  }

  private String replaceRegString(String text) {
    String retString;

    try {
      if (text == null || ''.equals(text.trim())) {
        retString = null;
      } else {
        String replaceLine = text.replaceAll('\\\\n', '#n#');
        retString = replaceLine.replaceAll('([\\.|\\*|\\?|\\+|\\-|\\$|\\(|\\)|\\{|\\}|\\[|\\]])', '\\\\' + '$1');
      }
    } catch (Exception e) {
        retString = null;
    }

    return retString;
  }

  private void setParamater(String body, String patternText, String setParamName, sObject newRecord, Schema.DisplayType dataType) {
    if (body != null) {
      Pattern matchPattern = pattern.compile(patternText);
      Matcher matchMatcher = matchPattern.matcher(body);

      if (matchMatcher.find()) {
        String text = (String) matchMatcher.group(1);

        if (Schema.DisplayType.DateTime == dataType) {
          String timeStr = text.replaceAll('#n#', '').replaceAll('/', '-');
          timeStr = timeStr.replace('年', '-').replace('月', '-').replace('日', ' ').replace('時', ':').replace('分', ':').trim();
          List<String> checkList = timeStr.split(':');

          if (checkList.size() == 2) {
            timeStr = timeStr + ':00';
          } else if (checkList.size() == 3 && (checkList[2].equals('') || String.isBlank(checkList[2]))) {
            timeStr = timeStr + '00';
          }

          timeStr = timeStr.replace('::', ':');

          newRecord.put(setParamName, Datetime.valueOf(timeStr));
        } else {
          newRecord.put(setParamName, text.trim().replaceAll('#n#', '\n'));
        }
      }
    }
  }
}