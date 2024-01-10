global class MailThrowErrorLog implements Messaging.InboundEmailHandler {
    public with sharing class HandleException extends Exception {}

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        if (
            Schema.sObjectType.Mail2XErrorMail__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.Name.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.From__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.To__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.Name__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.Subject__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.TextBody__c.isCreateable() != true ||
            Schema.sObjectType.Mail2XErrorMail__c.fields.HtmlBody__c.isCreateable() != true
        ) {
            return result;
        }

        String subject = email.subject;
        String originalBody = email.plainTextBody;
        String originalHtmlBody = email.htmlBody;
        String eaddr = email.fromAddress;
        String ename = email.fromName;
        List<String> toaddr = email.toAddresses;

        result.message = originalBody;
        result.message += '\n';
        result.success = true;

        Mail2XErrorMail__c errorObject = new Mail2XErrorMail__c(
            Name = 'MailThrowErrorLog',
            From__c = eaddr,
            To__c = String.join(toaddr, ',\n'),
            Name__c = ename,
            Subject__c = subject,
            TextBody__c = originalBody,
            HtmlBody__c = originalHtmlBody
        );

        insert errorObject;
        return result;
    }
}