@isTest
private class LiveSubscriptionPCTriggerTest {
    @testSetup static void buildTestData() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionPC1 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC1.Zuora__ChargeNumber__c = 'testSubscriptionPC1';
        testSubscriptionPC1.Zuora__Account__c = testAccount.id;
        testSubscriptionPC1.RSD_Id__c = '123';
        insert testSubscriptionPC1;

    }

    static testMethod void testLiveSUbscriptionUpdate() {
        

        Live_Subscription_Product_and_Charge__c newLiveSubscriptionPC  = [select Id,Subscription_Version__c from Live_Subscription_Product_and_Charge__c limit 1];
        newLiveSubscriptionPC.Subscription_Version__c = 2;
        
        Test.startTest();
        update newLiveSubscriptionPC;
        Test.stopTest();

        Live_Subscription_Product_and_Charge__c liveSubscriptionPCAfterUpdate = [Select id,Pre_RSD_Id__c from Live_Subscription_Product_and_Charge__c where id =: newLiveSubscriptionPC.Id];
        system.assertNotEquals(liveSubscriptionPCAfterUpdate.Pre_RSD_Id__c, null);
    }

    static testMethod void testLiveSUbscriptionDelete() {

        Live_Subscription_Product_and_Charge__c newLiveSubscriptionPC  = [select Id from Live_Subscription_Product_and_Charge__c limit 1];

        Test.startTest();
        delete newLiveSubscriptionPC;
        Test.stopTest();

        List<Live_Subscription_Product_and_Charge__c> listliveSubscriptionPCAfterDelete = [Select id from Live_Subscription_Product_and_Charge__c];
        system.assertEquals(0, listliveSubscriptionPCAfterDelete.size());
    }
}