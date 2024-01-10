@isTest
private class MailThrowErrorLogTest {
  @isTest
  private static void sendMailTest() {
    String subject = 'Dummy';
    String emailAddress = 'dummy@dummy.com';
    List<String> toAddress = new List<String>{'dummy@dummy.com'};
    String plainTextBody = 'dummy test sample\ntext\ntext';

    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    email.plainTextBody = plainTextBody;
    email.fromAddress = emailAddress;
    email.ccAddresses = new List<String>{};
    email.toAddresses = toAddress;
    email.subject = subject;

    MailThrowErrorLog mte = new MailThrowErrorLog();

    Test.startTest();
    Messaging.InboundEmailResult result = mte.handleInboundEmail(email, env);
    Test.stopTest();
  }
}