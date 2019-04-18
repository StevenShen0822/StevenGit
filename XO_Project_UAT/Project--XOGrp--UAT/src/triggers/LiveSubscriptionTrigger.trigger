trigger LiveSubscriptionTrigger on Live_Subscription__c (before insert, before update, before delete, after insert, after update, after delete) {
    XOTriggerFactory.createAndExecuteHandler(LiveSubscriptionTriggerHandler.class);
}