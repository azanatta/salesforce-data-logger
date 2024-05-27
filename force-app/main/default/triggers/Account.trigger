trigger Account on Account (
    before insert, 
    before update, 
    after update, 
    after insert, 
    before delete, 
    after delete) {
    SObjectType objectName = Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();
    Logger.storeLog(objectName, Trigger.operationType, Trigger.old, Trigger.new);
}
