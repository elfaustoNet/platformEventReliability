public with sharing class ServiceRequestTriggerHandler {

    public static void notifyOnNewServiceRequest(List<Service_Request__c> serviceRequests) {
        List<SR_Notification__e> srNotificationList = new List<SR_Notification__e>();
        /* NOTE: This list is used in the big object example */
        //List<SR_Notification_Archive__b> notificationArchive = new List<SR_Notification_Archive__b>();

        /* NOTE: This list is used in the custom object archive example */
        List<Event_Notification_Archive__c> eventNotificationList = new List<Event_Notification_Archive__c>();

        for (Service_Request__c sr : serviceRequests)
        {
            boolean processSR = false;
            system.debug('$$ Order ' + sr.Name + ': ' + sr.Id + ' is ' + sr.Status__c);
            //Only process submitted orders
            if (sr.Status__c == 'New')
            {
                SR_Notification__e srNotification = new SR_Notification__e();
                srNotification.Customer_Name__c = sr.Name;
                srNotification.Service_Request_Details__c = sr.Request_Details__c;
                srNotification.Service_Request_Id__c = sr.Id;
                srNotification.Street__c = sr.Street__c;
                srNotification.City__c = sr.City__c;
                srNotification.State__c = sr.State__c;
                srNotification.Country__c = sr.Country__c;
                srNotification.Postal_Code__c = sr.Postal_Code__c;
                system.debug('srNotification json $$ ' + JSON.serialize(srNotification));
                srNotificationList.add(srNotification); 

                /* NOTE: This section is an example on how to archive to the associated big object.
                 * There are pros and cons to using custom objects to archive
                 */ 
                Event_Notification_Archive__c newArchive = new Event_Notification_Archive__c();
                newArchive.Event__c = 'SR_Notification__e';
                newArchive.Status__c = 'New';
                newArchive.Payload__c = JSON.serialize(srNotification);
                eventNotificationList.add(newArchive);

                /* NOTE: This section is an example on how to archive to the associated big object.
                 * There are pros and cons to using Big Objects 
                 */ 
                /*
                SR_Notification_Archive__b newArchive = new SR_Notification_Archive__b();
                newArchive.event__c = 'SR_Notification__e';
                newArchive.Status__c = 'New';
                newArchive.Payload__c = JSON.serialize(srNotification);
                notificationArchive.add(newArchive);
                */

                
                

                
            }
            
        }
        
        

        if (!srNotificationList.isEmpty())
        {
            List<Database.SaveResult> saveResults = EventBus.publish(srNotificationList);
            for (Integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult r =  saveResults[i];
                if (r.isSuccess())
                {
                    system.debug('Save Result $$ ' + r.getId() + ' is success ');
                    String result = EventBus.getOperationId(r);
                    system.debug('Async result uuid ' + result);

                    /* making the assumption that the event order is same as notification order */
                    /*NOTE: This is used for the archive to big object */
                    //notificationArchive[i].UUID__c = result;

                    /*NOTE: This is used for the archive to custom object */
                    eventNotificationList[i].UUID__c = result;

                    
                }
                else {
                    for (Database.Error err : r.getErrors())
                    {
                        System.debug('Save result ' + r.getId() + ' ' + err.getStatusCode() + ': ' + err.getMessage());

                    }
                    
                }
                
            }
            /* Archive Process for custom object
             * NOTE: This section is an example on how to archive to the associated custom object.
             * There are pros and cons to using custom objects to archive
             */ 
            insert eventNotificationList;


            /* Archive Process for Big Objects
             * NOTE: This section is an example on how to archive to the associated big object.
             * There are pros and cons to using custom objects to archive
             */ 
            /*SRNotificationArchival handler = new SRNotificationArchival(notificationArchive);
            System.enqueueJob(handler);*/



        }

    }
}
