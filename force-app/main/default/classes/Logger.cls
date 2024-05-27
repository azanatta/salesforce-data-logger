public with sharing class Logger {

    public static Boolean storeLog(SObjectType objectType, TriggerOperation triggerOperation, List<SObject> dataBefore, List<SObject> dataAfter)
    {
        Log__c log = new Log__c();

        log.Object__c = String.valueOf(objectType);
        log.RecordId__c = findId(dataBefore, dataAfter);
        log.ActionType__c = String.valueOf(triggerOperation);

        String dataChanges = findDataChanges(dataBefore, dataAfter);
        log.DataChanges__c = dataChanges;
        
        Database.SaveResult result = Database.insert(log, true);

        return dataChanges!=null;
    }

    @TestVisible
    private static Id findId(List<SObject> dataBefore, List<SObject> dataAfter)
    {
        List<SObject> objData = dataAfter != null ? dataAfter : (dataBefore != null ? dataBefore : null);
        if(objData != null)
        {
            if(objData[0] != null)
            {
                if(objData[0].Id != null)
                {
                    return objData[0].Id;
                }
            }
        }
        return null;
    }

    @TestVisible
    private static String findDataChanges(List<SObject> dataBefore, List<SObject> dataAfter)
    {
        if(dataBefore != null && dataAfter != null)
        {
            if(dataBefore.size() > 0 && dataAfter.size() > 0)
            {
                List<String> dataChanges = new List<String>();

                SObject recordBefore = dataBefore[0];
                SObject recordAfter = dataAfter[0];

                Map<String, Object> fieldValuesBefore = recordBefore.getPopulatedFieldsAsMap();
                Map<String, Object> fieldValuesAfter = recordAfter.getPopulatedFieldsAsMap();

                for (String fieldName : fieldValuesAfter.keySet())
                {
                    if(fieldName!='LastModifiedDate' && fieldName!='SystemModstamp' && fieldName != 'Id' && (fieldValuesBefore.get(fieldName) != fieldValuesAfter.get(fieldName)))
                    {
                        dataChanges.add(fieldName+': (current: '+ fieldValuesAfter.get(fieldName) +'; previous: '+ fieldValuesBefore.get(fieldName)+')');
                    }
                }
                if(!dataChanges.isEmpty())
                {
                    return JSON.serialize(dataChanges);
                }
            }
        }
        else
        {
            if(dataAfter != null)
            {
                return JSON.serialize(dataAfter);
            }
        }
        return null;
    }
}