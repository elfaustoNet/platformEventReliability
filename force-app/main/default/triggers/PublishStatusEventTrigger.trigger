trigger PublishStatusEventTrigger on PublishStatusEvent (after insert) {

    system.debug('triggerNew $$ ' + Trigger.new);
    PublishStatusEventHandler.verifyPublication(Trigger.new);
}


