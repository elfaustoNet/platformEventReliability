# Platform Event Reliability Handling

## Overview
Salesforce has an event-driven messaging platform. Platform events are the messages that are published to the event bus in which subscribers can listen for and take action on based on their specific criteria. Platform events simplify the process of communicating changes and responding to them without writing complex logic. 

As noted in the [Platform Events Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_considerations.htm), "Platform events are temporarily persisted to and served from an industry-standard distributed system during the retention period. A distributed system doesn’t have the same semantics or guarantees as a transactional database. As a result, we can’t provide a synchronous response for an event publish request. Events are queued and buffered, and Salesforce attempts to publish the events asynchronously. In rare cases, the event message might not be persisted in the distributed system during the initial or subsequent attempts. This means that the events aren’t delivered to subscribers, and they aren’t recoverable."

The purpose of this repository is to demonstrate one pattern to provide a reliable mechanism to guarantee delivery of Platform Events in case of failure. This pattern does have some trade-offs that need to be taking into consideration which may not make it a viable option for you. You may find that even after implementing this pattern, or a similar one, it may not meet your completes needs if it requires 100% reliability with order of processing.

## Scenario Overview 

To demonstrate the reliability pattern, we are going to pretend we work at a service repair shop. We have a service request object that stores each client's service requests. When a new service request is created, a platform event is published that the external scheduling system subscribers to so it knows it needs to schedule a service rep to visit the customer's location. 

In order to provide reliability, we need to archive events and then reconcile the events received with events sent to the event bus. 

### Archive Events
To accomplish the archival of events, I created a custom object called Event Notification Archive. 
This has the following fields:  
* Event: The name of the platform event
* UUID: The unique identifier created when the platform event is published to the queue
* Status: To denote whether the event was successfully publish
* Payload: JSON representation of the event

The payload field is a long text area. Dependening on the estimated size of event payloads, you may have to break the json payload into multiple long text areas. Instead of using a payload field, you can create the event logging object with each field from the platform event, but if that definition is changing, you'll have to keep the fields in sync. This would also mean additional custom objects to represent each platform event.  

If there are a large volume of events, I recommend creating a batch job that deletes the older events after a certain time frame as this can take up a lot of data storage. You could leverage a big object instead, especially for large volume of platform events, but that has it's own limitations too.

Next, I created a trigger on the service request object. The trigger publishes the platform event, and then calls EventBus.getOperationId(r), where r is the save result, to get the UUID. Once the UUID of the event is retrieved, the event logs are created. The platform event is created programmically instead of declaratively because Apex provides additional methods to get the UUID of the event published to the queue.

### Reconciliation of publication
A trigger on the [PublishStatusEvent (pilot)](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_publish_status.html) matches the response's UUID with the event archive to update the status. You can then used batch apex job to resend any platform events that failed or were not reconciled after a given time frame. This, however, will create duplicate events, so external systems will need to take that into consideration. 

Alternatively, the external subscriber can query the archive object via API and perform a matching on objects to ensure publication and delivery. If there are records that are not found to be delivered, they can then query the item and process the event. If the external subscriber is dependent on order replay, this may not be acceptable unless you hold processing until verify the existance of missing events. 

## Demo Setup

1. This code example is leveraging the PublishStatusEvent [pilot](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_publish_status.html). If you do not have access to the pilot, you'll want to add the following files to your .forceignore file so it does not try to push the code:
    * force-app/main/default/classes/PublishStatusEventHandler.cls
    * force-app/main/default/classes/PublishStatusEventHandler.cls-meta.xml
    * force-app/main/default/triggers/PublishStatusEventTrigger.trigger
    * force-app/main/default/triggers/PublishStatusEventTrigger.trigger-meta.xml
2. Run the orgInit.sh script to create a scratch org, push source code, assign permission sets. 
3. You'll need to manually activate the Account Record Lightning App Page.


## Demo
To see how the pattern works, navigate to an account page. Under the record details component, you'll see a notification listener component which will allow you to subscribe to platform events. Click subscribe to subscribe to the '/event/SR_Notification__e' event. There's a second notification listener to see the results for the PublishStatusEvent event. Change the channel name on the second listener component to '/event/PublishStatusEvent' and click subscribe.

On the right hand side, you'll see a service request component. Some of the data will be prepopulated. Fill out the form and then click submit. You'll be notified that the service request was created and by looking at the notification listener component, that the event was published. 

Now navigate to the Event Notification Archive tab. There you'll see the archived event. 





