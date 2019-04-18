@isTest
private class BatchCalcLiveChargeTCVMonthlyTest {

    static testMethod void testCalcLiveChargeTCV() {
        
        List<User> usrlist = [SELECT Id, title FROM User WHERE isActive = TRUE AND title = 'Account Manager' limit 1];
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        Account testAccount = (Account)testData.get('Account');
        testAccount.ownerid = usrlist[0].id;
        update testAccount;

        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__TermStartDate__c = Date.today();
        insert testSubscription;

        List<Live_Subscription__c> liveSubList = [SELECT Id FROM Live_Subscription__c WHERE Original_Subscription__c =: testSubscription.id];

        Live_Subscription_Product_and_Charge__c lspc1 = TestClassUtility.createLiveSubscriptionPC(TRUE,testAccount, liveSubList[0]);
        
        Live_Subscription_Product_and_Charge__c lspc2 = TestClassUtility.createLiveSubscriptionPC(TRUE,testAccount, liveSubList[0]);
        
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        

        Test.startTest();
        System.schedule('BatchCalcLiveChargeTCVMonthly', '0 50 7 ? * *', new BatchCalcLiveChargeTCVMonthly());
        Database.executeBatch(new BatchCalcLiveChargeTCVMonthly());
        Test.stopTest();
        
        Account finalAccount = [SELECT Id, Live_at_Month_Start__c FROM Account WHERE Id =: testAccount.Id];

        System.assertEquals(40,finalAccount.Live_at_Month_Start__c);
    }

    static testMethod void testCalcNoneLiveChargeTCV() {
        
        List<User> usrlist = [SELECT Id, title FROM User WHERE isActive = TRUE AND title = 'Account Manager' limit 1];
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        Account testAccount = (Account)testData.get('Account');
        testAccount.ownerid = usrlist[0].id;
        update testAccount;

        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__TermStartDate__c = Date.today().adddays(366);
        insert testSubscription;

        List<Live_Subscription__c> liveSubList = [SELECT Id FROM Live_Subscription__c WHERE Original_Subscription__c =: testSubscription.id];

        Live_Subscription_Product_and_Charge__c lspc1 = TestClassUtility.createLiveSubscriptionPC(TRUE,testAccount, liveSubList[0]);
        
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        

        Test.startTest();
        Database.executeBatch(new BatchCalcLiveChargeTCVMonthly());
        Test.stopTest();
        
        Account finalAccount = [SELECT Id, Live_at_Month_Start__c FROM Account WHERE Id =: testAccount.Id];

        System.assertEquals(0,finalAccount.Live_at_Month_Start__c);
    }

}