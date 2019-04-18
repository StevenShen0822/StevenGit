trigger LiveSubscriptionProductChargeTrigger on Live_Subscription_Product_and_Charge__c (before insert, before update, before delete, after insert, after update, after delete) {
    XOTriggerFactory.createAndExecuteHandler(LiveSubscriptionPCTriggerHandler.class);
}