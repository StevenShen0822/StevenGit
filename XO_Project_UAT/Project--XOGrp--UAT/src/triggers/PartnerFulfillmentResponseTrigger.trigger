trigger PartnerFulfillmentResponseTrigger on Partner_Fulfillment_Response__c (after insert) {
	XOTriggerFactory.createAndExecuteHandler(PartnerFulfillmentResponseTriggerHandler.class);
}