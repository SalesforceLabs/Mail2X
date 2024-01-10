public with sharing class MailMatchingGetChoiceListForFlow {
    @AuraEnabled
    public static String getFieldNames(String ObjectName) {

        List<Map<String, String>> retList = new List<Map<String, String>>();

        if (ObjectName != NULL && !''.equals(ObjectName.trim())) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(ObjectName);
            Map<String, Schema.SObjectField> describeMap = objectType.getDescribe().fields.getMap();

            for (String sKey : describeMap.keySet()) {
                Schema.SObjectField sObjfield = describeMap.get(sKey);
                Schema.DescribeFieldResult fieldDesc = sObjfield.getDescribe();
                Map<String, String> retJson = new Map<String, String>();
                retJson.put('label', (String)fieldDesc.getLabel());
                retJson.put('value', (String)sKey);
                retList.add(retJson);
            }
        }

        return JSON.serialize(retList);
    }
}