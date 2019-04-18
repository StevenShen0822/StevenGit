@isTest
private class LiveSubscriptionHandlerTest {
    static testMethod void testCopySubscription() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;
        Test.startTest();
        Live_Subscription__c testLiveSub = LiveSubscriptionHandler.copySubscription(testSubscription);
        Test.stopTest();

        system.assertEquals(testLiveSub.Name, testSubscription.Name);

    }

    static testMethod void testGenerateLiveSubscriptionPCForNewSub() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionPC1 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC1.Zuora__ChargeNumber__c = 'testSubscriptionPC1';
        testSubscriptionPC1.Zuora__Account__c = testAccount.id;
        Zuora__SubscriptionProductCharge__c testSubscriptionPC2 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC2.Zuora__ChargeNumber__c = 'testSubscriptionPC2';
        testSubscriptionPC2.Zuora__Account__c = testAccount.id;

        List<Zuora__SubscriptionProductCharge__c> listSubProductCharge = new List<Zuora__SubscriptionProductCharge__c>();

        listSubProductCharge.add(testSubscriptionPC1);
        listSubProductCharge.add(testSubscriptionPC2);


        Map<String, Map<String,Zuora__SubscriptionProductCharge__c>> mapSubNameToMapChargeNumberToSubCharge = new Map<String, Map<String,Zuora__SubscriptionProductCharge__c>>();
        mapSubNameToMapChargeNumberToSubCharge.put(testSubscription.Name, new Map<String,Zuora__SubscriptionProductCharge__c>());

        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC1.Zuora__ChargeNumber__c,testSubscriptionPC1);
        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC2.Zuora__ChargeNumber__c,testSubscriptionPC2);

        Map<String,Date> subscriptionNameEffectDateMap = new Map<String,Date>();
        subscriptionNameEffectDateMap.put(testSubscription.Name, Date.today());
        Test.startTest();
        List<Live_Subscription_Product_and_Charge__c> testlistLiveSubPC = LiveSubscriptionHandler.generateLiveSubscriptionPC(mapSubNameToMapChargeNumberToSubCharge,subscriptionNameEffectDateMap);
        Test.stopTest();

        system.assertEquals(2, testlistLiveSubPC.size());

    }

    static testMethod void testGenerateLiveSubscriptionPCForAmendSub() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;

        
        Zuora__SubscriptionProductCharge__c testSubscriptionPC = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC.Zuora__ChargeNumber__c = 'testSubscriptionPC';
        testSubscriptionPC.Zuora__Account__c = testAccount.id;
        Zuora__SubscriptionProductCharge__c testSubscriptionPC1 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC1.Zuora__ChargeNumber__c = 'testSubscriptionPC1';
        testSubscriptionPC1.Zuora__Account__c = testAccount.id;
        Zuora__SubscriptionProductCharge__c testSubscriptionPC2 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC2.Zuora__ChargeNumber__c = 'testSubscriptionPC2';
        testSubscriptionPC2.Zuora__Account__c = testAccount.id;
        List<Zuora__SubscriptionProductCharge__c> listSubProductCharge = new List<Zuora__SubscriptionProductCharge__c>();
        listSubProductCharge.add(testSubscriptionPC);
        listSubProductCharge.add(testSubscriptionPC1);
        listSubProductCharge.add(testSubscriptionPC2);
        insert listSubProductCharge;


        Zuora__SubscriptionProductCharge__c testSubscriptionPC3 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC3.Zuora__ChargeNumber__c = 'testSubscriptionPC3';
        testSubscriptionPC3.Zuora__Account__c = testAccount.id;

        testSubscriptionPC.Zuora__EffectiveEndDate__c = Date.today();

        testSubscriptionPC1.Zuora__EffectiveStartDate__c = Date.today();

        Map<String, Map<String,Zuora__SubscriptionProductCharge__c>> mapSubNameToMapChargeNumberToSubCharge = new Map<String, Map<String,Zuora__SubscriptionProductCharge__c>>();
        mapSubNameToMapChargeNumberToSubCharge.put(testSubscription.Name, new Map<String,Zuora__SubscriptionProductCharge__c>());
        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC.Zuora__ChargeNumber__c,testSubscriptionPC);
        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC1.Zuora__ChargeNumber__c,testSubscriptionPC1);
        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC3.Zuora__ChargeNumber__c,testSubscriptionPC3);

        Map<String,Date> subscriptionNameEffectDateMap = new Map<String,Date>();
        subscriptionNameEffectDateMap.put(testSubscription.Name, Date.today());
        
        Map<String,Date> subscriptionNameEffectDateMap1 = new Map<String,Date>();

        Test.startTest();
        List<Live_Subscription_Product_and_Charge__c> testlistLiveSubPC = LiveSubscriptionHandler.generateLiveSubscriptionPC(mapSubNameToMapChargeNumberToSubCharge,subscriptionNameEffectDateMap);

        Test.stopTest();

        system.assertEquals(4, testlistLiveSubPC.size());


    }

    static testMethod void testGenerateLiveSubscriptionPCForAmendSubFromZuora() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(false,testAccount);
        testSubscription.Zuora__Version__c = 1;
        insert testSubscription;

        Zuora__SubscriptionProductCharge__c testSubscriptionPC1 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC1.Zuora__ChargeNumber__c = 'testSubscriptionPC1';
        testSubscriptionPC1.Zuora__Account__c = testAccount.id;
        Zuora__SubscriptionProductCharge__c testSubscriptionPC2 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC2.Zuora__ChargeNumber__c = 'testSubscriptionPC2';
        testSubscriptionPC2.Zuora__Account__c = testAccount.id;
        List<Zuora__SubscriptionProductCharge__c> listSubProductCharge = new List<Zuora__SubscriptionProductCharge__c>();
        listSubProductCharge.add(testSubscriptionPC1);
        listSubProductCharge.add(testSubscriptionPC2);

        insert listSubProductCharge;

        Zuora__SubscriptionProductCharge__c testSubscriptionPC3 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC3.Zuora__ChargeNumber__c = 'testSubscriptionPC3';
        testSubscriptionPC3.Zuora__Account__c = testAccount.id;

        testSubscriptionPC1.Zuora__EffectiveStartDate__c = Date.today();

        Map<String, Map<String,Zuora__SubscriptionProductCharge__c>> mapSubNameToMapChargeNumberToSubCharge = new Map<String, Map<String,Zuora__SubscriptionProductCharge__c>>();
        mapSubNameToMapChargeNumberToSubCharge.put(testSubscription.Name, new Map<String,Zuora__SubscriptionProductCharge__c>());

        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC1.Zuora__ChargeNumber__c,testSubscriptionPC1);
        mapSubNameToMapChargeNumberToSubCharge.get(testSubscription.Name).put(testSubscriptionPC3.Zuora__ChargeNumber__c,testSubscriptionPC3);

        Map<String,Date> subscriptionNameEffectDateMap1 = new Map<String,Date>();

        Test.startTest();
        List<Live_Subscription_Product_and_Charge__c> testlistLiveSubPC1 = LiveSubscriptionHandler.generateLiveSubscriptionPC(mapSubNameToMapChargeNumberToSubCharge,subscriptionNameEffectDateMap1);
        Test.stopTest();

        system.assertEquals(3, testlistLiveSubPC1.size());
    }
}