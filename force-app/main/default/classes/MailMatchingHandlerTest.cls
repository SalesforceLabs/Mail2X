@isTest
private class MailMatchingHandlerTest {
  static final String subject = 'Dummy';
  static final String senderName = 'Mail2x Taro';
  static final String emailAddress = 'dummy@dummy.com';
  static final String toAddress = 'dummy2@dummy.com';

  @isTest
  private static void sendMailTestNavText() {
    String plainTextBody = 'dummy test sample\ntext\ntext';
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.Header headerItem = new Messaging.InboundEmail.Header();
    headerItem.name = 'received';
    headerItem.value = 'SEND STRAT for <' + emailAddress + '> END';
    List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>{ headerItem };

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.fromName = senderName;
    email.toAddresses = new List<String>{ toAddress };
    email.ccAddresses = new List<String>{};
    email.headers = headers;
    email.subject = subject;

    MailMatchingHandler mmh = new MailMatchingHandler();

    Test.startTest();
    MailMatchingSetting__c mailMatchingSetting = new MailMatchingSetting__c(
      Name = 'TestMail',
      OriginalMessageApi__c = 'mail2x__OriginalMessage__c',
      SubjectApi__c = 'mail2x__Subject__c',
      AddressKey__c = 'dummy@dummy.com',
      ObjectApi__c = 'mail2x__InquiryMail__c',
      AddressTarget__c = 'From',
      Availability__c = true,
      AttachmentFile__c = true,
      SettingNameApi__c = 'mail2x__SettingNameApi__c',
      ProviderNameApi__c = 'mail2x__ProviderName__c',
      ProviderMailAddressApi__c = 'mail2x__ProviderMailAddress__c'
    );
    insert mailMatchingSetting;

    MailMatchingDetail__c mailMatchingDetail = new MailMatchingDetail__c(
      Name = 'mailMatchingDetail',
      FieldApi__c = 'mail2x__detail__c',
      SettingMaster__c = mailMatchingSetting.Id,
      ManualMatching__c = '',
      StartText1__c = 'dummy',
      StartText2__c = 'sample',
      EndText1__c = 'text'
    );
    insert mailMatchingDetail;

    Messaging.InboundEmailResult result = mmh.handleInboundEmail(email, env);
    Test.stopTest();
  }

  @isTest
  private static void sendMailTestNavDateTime() {
    String plainTextBody = 'dummy test sample\n2020年12月12日12時12分\nText\n';

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.Header headerItem = new Messaging.InboundEmail.Header();
    headerItem.name = 'received';
    headerItem.value = 'SEND STRAT for <' + emailAddress + '> END';
    List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>{ headerItem };

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.fromName = senderName;
    email.toAddresses = new List<String>{ toAddress };
    email.ccAddresses = new List<String>{};
    email.headers = headers;
    email.subject = subject;

    MailMatchingHandler mmh = new MailMatchingHandler();

    Test.startTest();
    MailMatchingSetting__c mailMatchingSetting = new MailMatchingSetting__c(
      Name = 'TestMail',
      OriginalMessageApi__c = 'mail2x__OriginalMessage__c',
      SubjectApi__c = 'mail2x__Subject__c',
      AddressKey__c = 'dummy2@dummy.com',
      ObjectApi__c = 'mail2x__InquiryMail__c',
      AddressTarget__c = 'To',
      Availability__c = true,
      AttachmentFile__c = true,
      SettingNameApi__c = 'mail2x__SettingNameApi__c',
      ProviderNameApi__c = 'mail2x__ProviderName__c',
      ProviderMailAddressApi__c = 'mail2x__ProviderMailAddress__c'
    );
    insert mailMatchingSetting;

    MailMatchingDetail__c mailMatchingDetail = new MailMatchingDetail__c(
      Name = 'mailMatchingDetail',
      FieldApi__c = 'mail2x__InquiryDateTime__c',
      SettingMaster__c = mailMatchingSetting.Id,
      ManualMatching__c = '',
      StartText1__c = 'dummy test sample',
      StartText2__c = '',
      EndText1__c = '\n'
    );
    insert mailMatchingDetail;

    Messaging.InboundEmailResult result = mmh.handleInboundEmail(email, env);
    Test.stopTest();
  }

  @isTest
  private static void sendMailTestNavWithAttachment() {
    String plainTextBody = 'dummy test sample\ntext\ntext';

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.Header headerItem = new Messaging.InboundEmail.Header();
    headerItem.name = 'received';
    headerItem.value = 'SEND STRAT for <' + emailAddress + '> END';
    List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>{ headerItem };

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.fromName = senderName;
    email.toAddresses = new List<String>{ toAddress };
    email.ccAddresses = new List<String>{};
    email.headers = headers;
    email.subject = subject;

    MailMatchingHandler mmh = new MailMatchingHandler();

    Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
    attachment.body = blob.valueOf('attachment text');
    attachment.fileName = 'textfileone.txt';
    attachment.mimeTypeSubType = 'text/plain';
    email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{ attachment };

    Test.startTest();
    MailMatchingSetting__c mailMatchingSetting = new MailMatchingSetting__c(
      Name = 'TestMail',
      OriginalMessageApi__c = 'mail2x__OriginalMessage__c',
      SubjectApi__c = 'mail2x__Subject__c',
      AddressKey__c = 'dummy@dummy.com',
      ObjectApi__c = 'mail2x__InquiryMail__c',
      AddressTarget__c = 'From',
      Availability__c = true,
      AttachmentFile__c = true,
      SettingNameApi__c = 'mail2x__SettingNameApi__c',
      ProviderNameApi__c = 'mail2x__ProviderName__c',
      ProviderMailAddressApi__c = 'mail2x__ProviderMailAddress__c'
    );
    insert mailMatchingSetting;

    MailMatchingDetail__c mailMatchingDetail = new MailMatchingDetail__c(
      Name = 'mailMatchingDetail',
      FieldApi__c = 'mail2x__detail__c',
      SettingMaster__c = mailMatchingSetting.Id,
      ManualMatching__c = '',
      StartText1__c = 'dummy',
      StartText2__c = 'sample',
      EndText1__c = ''
    );
    insert mailMatchingDetail;

    Messaging.InboundEmailResult result = mmh.handleInboundEmail(email, env);
    Test.stopTest();
  }

  @isTest
  private static void sendMailTestManual() {
    String plainTextBody = 'dummy test sample\ntext\ntext';

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.Header headerItem = new Messaging.InboundEmail.Header();
    headerItem.name = 'received';
    headerItem.value = 'SEND STRAT for <' + emailAddress + '> END';
    List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>{ headerItem };

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.fromName = senderName;
    email.toAddresses = new List<String>{ toAddress };
    email.ccAddresses = new List<String>{};
    email.headers = headers;
    email.subject = subject;

    MailMatchingHandler mmh = new MailMatchingHandler();

    Test.startTest();
    MailMatchingSetting__c mailMatchingSetting = new MailMatchingSetting__c(
      Name = 'TestMail',
      OriginalMessageApi__c = 'mail2x__OriginalMessage__c',
      SubjectApi__c = 'mail2x__Subject__c',
      AddressKey__c = 'dummy@dummy.com',
      ObjectApi__c = 'mail2x__InquiryMail__c',
      AddressTarget__c = 'transfer',
      Availability__c = true,
      AttachmentFile__c = true,
      SettingNameApi__c = 'mail2x__SettingNameApi__c',
      ProviderNameApi__c = 'mail2x__ProviderName__c',
      ProviderMailAddressApi__c = 'mail2x__ProviderMailAddress__c'
    );
    insert mailMatchingSetting;

    MailMatchingDetail__c mailMatchingDetail = new MailMatchingDetail__c(
      Name = 'mailMatchingDetail',
      FieldApi__c = 'mail2x__detail__c',
      SettingMaster__c = mailMatchingSetting.Id,
      ManualMatching__c = 'dummy.*?\n(.*?)\n',
      StartText1__c = 'dummy',
      StartText2__c = '',
      EndText1__c = ''
    );
    insert mailMatchingDetail;

    Messaging.InboundEmailResult result = mmh.handleInboundEmail(email, env);
    Test.stopTest();
  }

  @isTest
  private static void sendMailTestNavExceptioon() {
    String plainTextBody = 'dummy test sample';

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    Messaging.InboundEmail.Header headerItem = new Messaging.InboundEmail.Header();
    headerItem.name = 'received';
    headerItem.value = 'SEND STRAT for <' + emailAddress + '> END';
    List<Messaging.InboundEmail.Header> headers = new List<Messaging.InboundEmail.Header>{ headerItem };

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.fromName = senderName;
    email.toAddresses = new List<String>{ toAddress };
    email.ccAddresses = new List<String>{};
    email.headers = headers;
    email.subject = subject;

    MailMatchingHandler mmh = new MailMatchingHandler();

    Test.startTest();
    MailMatchingSetting__c mailMatchingSetting = new MailMatchingSetting__c(
      Name = 'TestMail',
      OriginalMessageApi__c = 'mail2x__OriginalMessage__c',
      SubjectApi__c = 'mail2x__Subject__c',
      AddressKey__c = 'dummy@dummy.com',
      ObjectApi__c = 'mail2x__InquiryMail__c',
      AddressTarget__c = 'From',
      Availability__c = true,
      AttachmentFile__c = true,
      SettingNameApi__c = 'mail2x__SettingNameApi__c',
      ProviderNameApi__c = 'mail2x__ProviderName__c',
      ProviderMailAddressApi__c = 'mail2x__ProviderMailAddress__c',
      SaveErrorLog__c = true
    );
    insert mailMatchingSetting;

    MailMatchingDetail__c mailMatchingDetail = new MailMatchingDetail__c(
      Name = 'mailMatchingDetail',
      FieldApi__c = 'mail2x__dummy__c',
      SettingMaster__c = mailMatchingSetting.Id,
      ManualMatching__c = '',
      StartText1__c = 'dummy test sample',
      StartText2__c = '',
      EndText1__c = '\n'
    );
    insert mailMatchingDetail;

    Messaging.InboundEmailResult result = mmh.handleInboundEmail(email, env);
    Test.stopTest();
  }
}