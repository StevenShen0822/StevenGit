@isTest
private class CancelReenterSubscriptionsControllerTest {
    static testMethod void testInitialMethod() {
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(TRUE);

        Account testAcc = (Account)testObjects.get('Account');
        Contact testCon = (Contact)testObjects.get('Contact');

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAcc, testCon);
        testOpp.AccStrategist__c = UserInfo.getUserId();
        testOpp.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        insert testOpp;

        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();
        CancelReenterSubscriptionsController testcase = new CancelReenterSubscriptionsController();
        List<CancelReenterSubscriptionsController.SubscriptionWrapper> listSubscriptionWrapper = new List<CancelReenterSubscriptionsController.SubscriptionWrapper>();
        listSubscriptionWrapper = CancelReenterSubscriptionsController.getSubscriptionsData(testOpp.Id,testAcc.Id);
        Test.stopTest();
        system.assertEquals(1, listSubscriptionWrapper.size());
    }

    static testMethod void testSaveMethod() {
          
        TestClassUtility.DISABLE_TRIGGERS = TRUE; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(TRUE);

        Account testAcc = (Account)testObjects.get('Account');
        Contact testCon = (Contact)testObjects.get('Contact');

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAcc, testCon);
        testOpp.AccStrategist__c = UserInfo.getUserId();
        testOpp.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        insert testOpp;

        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();
        CancelReenterSubscriptionsController testcase = new CancelReenterSubscriptionsController();
        List<CancelReenterSubscriptionsController.SubscriptionWrapper> listSubscriptionWrapper = new List<CancelReenterSubscriptionsController.SubscriptionWrapper>();
        listSubscriptionWrapper = CancelReenterSubscriptionsController.getSubscriptionsData(testOpp.Id,testAcc.Id);
        listSubscriptionWrapper[0].isSelected = true;
        String subWrappersString = JSON.Serialize(listSubscriptionWrapper); 
        String resultStr = CancelReenterSubscriptionsController.createOpportunitAndQuote(subWrappersString,testOpp.Id,testAcc.Id);
        Test.stopTest();
        
        system.assertEquals('Successed', resultStr.left(9));
        
    }
}