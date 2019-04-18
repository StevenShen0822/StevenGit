@isTest
private class ZuoraSubscriptionUtilityTest {
	@isTest 
	static void testGenerateRenewalQuoteFromSubcription() {
		/////////////////////
		// BUILD TEST DATA //
		/////////////////////
		Test.startTest();
			Map<String, SObject> subData = TestClassUtility.buildZQUTestObjects(false);
		Test.stopTest();

		subData.putAll(TestClassUtility.buildSubscriptionData((Account)subData.get('Account'), (Contact)subData.get('Contact'), (Opportunity)subData.get('Opportunity'), (Zuora__CustomerAccount__c)subData.get('Zuora__CustomerAccount__c')));

		// Get Subscription to send Id
		Zuora__Subscription__c createdSubscription = (Zuora__Subscription__c)subData.get('Zuora__Subscription__c');

		// Get Opportunity to send Id
		Opportunity createdOpportunity = (Opportunity)subData.get('Opportunity');

		// Call Zuora Subscription Utility class to generate renewal Quote from Subscription
		zqu__Quote__c generatedQuote = ZuoraSubscriptionUtility.generateRenewalQuoteFromSubscription(createdSubscription.Id, createdOpportunity);
	}

	@isTest
	static void testGenerateRenewalQuoteFromSubscriptionBatch() {
		/////////////////////
		// BUILD TEST DATA //
		/////////////////////
		Test.startTest();
			Map<String, SObject> subData = TestClassUtility.buildZQUTestObjects(false);
		Test.stopTest();

		subData.putAll(TestClassUtility.buildSubscriptionData((Account)subData.get('Account'), (Contact)subData.get('Contact'), (Opportunity)subData.get('Opportunity'), (Zuora__CustomerAccount__c)subData.get('Zuora__CustomerAccount__c')));

		// Get Subscription to send Id
		Zuora__Subscription__c createdSubscription = (Zuora__Subscription__c)subData.get('Zuora__Subscription__c');

		// Get Opportunity to send Id
		Opportunity createdOpportunity = (Opportunity)subData.get('Opportunity');

		Database.executeBatch(new BatchGenerateQuoteRatePlans(createdSubscription.Id, createdOpportunity), 1);
	}
}