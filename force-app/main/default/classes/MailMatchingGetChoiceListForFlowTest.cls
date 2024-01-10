@isTest
private class MailMatchingGetChoiceListForFlowTest {
    @isTest
    private static void getFieldNamesTest() {
        String objectName = 'Account';

        Test.startTest();
        MailMatchingGetChoiceListForFlow.getFieldNames(objectName);
        Test.stopTest();
    }
}