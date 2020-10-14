public with sharing class PublishStatusEventHandler {
    
    public static void verifyPublication(List<PublishStatusEvent> notifications) {
        /* NOTE: This is used to reconcile when you archive to big object */
        //List<SR_Notification_Archive__b> archiveList = new List<SR_Notification_Archive__b>();
        //List<SR_Notification_Archive__b> updateArchiveList = new List<SR_Notification_Archive__b>();
        
        /* NOTE: This is used to reconcile when you archive to regular custom object */
        List<Event_Notification_Archive__c> eventArchiveList = new List<Event_Notification_Archive__c>();
        List<Event_Notification_Archive__c> updateEventArchiveList = new List<Event_Notification_Archive__c>();
        
        Map<String, String> statusResponseMap = new Map<String, String>();
        List<String> uuidList = new List<String>();
        
        for (PublishStatusEvent n : notifications)
        {
            system.debug('publis status event $$ ' + n);
            //String updateStatus = n.Status;
            //List<String> tmpList = new List<String>();
            //system.debug('uuid $$ ' + n.PublishStatusDetails.EventUuid);
            for (PublishStatusDetail d : n.publishStatusDetails)
            {
                // uuidList.add(d.EventUuid);
                system.debug('in publiStatus Details ' + d);
                //Added toLowerCase and capitalize as it comes as all caps
                statusResponseMap.put(d.EventUuid, n.Status.toLowerCase().capitalize());
               //statusResponseMap.put(n.PublishStatusDetails.EventUuid, n.Status.toLowerCase().capitalize());
                //tmpList.add(d.EventUuid);
            }
            //uuidList.add(n.requestId);
        }
        
        system.debug('statusResponse map $$ ' + statusResponseMap);
        uuidList.addAll(statusResponseMap.keySet());


        /* NOTE: This is used to reconcile when you archive to regular custom object */
        eventArchiveList = [ select Id, UUID__c, Event__c, Status__c From Event_Notification_Archive__c where Event__c = 'SR_Notification__e' and Status__c = 'New' and UUID__c in :uuidList limit 2000];
        system.debug('eventArchiveList $$ ' + eventArchiveList);
        for (Event_Notification_Archive__c arc : eventArchiveList)
        {
            if (statusResponseMap.containsKey(arc.UUID__c))
            {
                system.debug('found match $$');
                arc.Status__c = statusResponseMap.get(arc.UUID__c);
                updateEventArchiveList.add(arc);
            }
        }

        system.debug('updateEventArchiveList $$ ' + updateEventArchiveList);
        if (!updateEventArchiveList.isEmpty())
        {
            update updateEventArchiveList;
        }

        /* NOTE: This is used to reconcile when you archive to big object */
        /*archiveList = [Select Event__c, Status__c, UUID__c from SR_Notification_Archive__b where Event__c = 'SR_Notification__e' and Status__c = 'New' and UUID__c in :uuidList limit 2000];
        for (SR_Notification_Archive__b ab : archiveList) {
            //ab.Status__c = 'Published';
            if (statusREsponseMap.containsKey(ab.UUID__c))
            {
                ab.Status__c = statusResponseMap.get(ab.UUID__c);
                updateArchiveList.add(ab);
            }
            

        }
        if (!updateArchiveList.isEmpty())
        { 
            SRNotificationArchival handler = new SRNotificationArchival(updateArchiveList);
            System.enqueueJob(handler);
        }*/



    }
}
