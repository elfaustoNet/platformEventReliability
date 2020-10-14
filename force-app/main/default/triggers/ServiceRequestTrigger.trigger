trigger ServiceRequestTrigger on Service_Request__c (after insert, after update) {
     if (Trigger.isAfter  && (Trigger.isInsert || Trigger.isUpdate)) {
            ServiceRequestTriggerHandler.notifyOnNewServiceRequest(Trigger.new);
     }
}