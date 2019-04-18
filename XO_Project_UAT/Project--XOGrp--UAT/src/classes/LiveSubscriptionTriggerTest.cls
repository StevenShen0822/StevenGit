@isTest
private class LiveSubscriptionTriggerTest {
    @testSetup static void buildTestData() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;
    }

    static testMethod void testLiveSUbscriptionUpdate() {
        

        Live_Subscription__c newLiveSubscription  = [select Id,Subscription_Version__c from Live_Subscription__c limit 1];
        newLiveSubscription.Subscription_Version__c = 2;

        Test.startTest();
        update newLiveSubscription;
        Test.stopTest();

        Live_Subscription__c liveSubscriptionAfterUpdate = [Select id,Pre_Zuora_TermEndDate__c from Live_Subscription__c where id =: newLiveSubscription.Id];
        system.assertNotEquals(liveSubscriptionAfterUpdate.Pre_Zuora_TermEndDate__c, null);
    }

    static testMethod void testLiveSUbscriptionDelete() {

        Live_Subscription__c newLiveSubscription  = [select Id from Live_Subscription__c limit 1];

        Test.startTest();
        delete newLiveSubscription;
        Test.stopTest();

        List<Live_Subscription__c> listliveSubscriptionAfterDelete = [Select id,Pre_Zuora_TermEndDate__c from Live_Subscription__c];
        system.assertEquals(0, listliveSubscriptionAfterDelete.size());
    }
}