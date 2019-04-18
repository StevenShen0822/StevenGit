@isTest
private class ZuoraSubscriptionPCTriggerHandlerTest {

    private static String DUMMY_USER_NAME = System.Label.Dummy_User_Name;
    private static String SPACE_DELIMITER = ' ';

    @testSetup 
    static void createTestData(){

        Group g1 = new Group(Name = 'Asset Collection Queue', type = 'Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;   
    }

    static testMethod void testReleaseCancelledReplaceInventory() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(FALSE);

        Account associatedAccount = (Account)mapLocalData.get('Account');
        Contact associatedContact = (Contact)mapLocalData.get('Contact');
        Opportunity associatedOpportunity = (Opportunity)mapLocalData.get('Opportunity');

        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        Product2 testLocalProduct = TestClassUtility.createLocalProduct2(TRUE);
        zqu__ProductRatePlan__c testProductRatePlan = TestClassUtility.createProductRatePlan(TRUE, testLocalProduct);
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = TestClassUtility.createProductRatePlanCharge(TRUE, testProductRatePlan);

        zqu__Quote__c testQuoteCancel = TestClassUtility.createQuote(TRUE, associatedOpportunity, associatedAccount, associatedContact); 
        zqu__Quote__c testQuoteRenewal = TestClassUtility.createQuote(TRUE, associatedOpportunity, associatedAccount, associatedContact);
        
        zqu__QuoteAmendment__c testQuoteAmmendmentCancel = TestClassUtility.createQuoteAmendment(TRUE, testQuoteCancel);
        zqu__QuoteAmendment__c testQuoteAmmendmentRenewal = TestClassUtility.createQuoteAmendment(TRUE, testQuoteRenewal);

        zqu__QuoteRatePlan__c testQuoteRatePlanCancel = TestClassUtility.createQuoteRatePlan(TRUE, testQuoteCancel, testProductRatePlan, testQuoteAmmendmentCancel);
        zqu__QuoteRatePlan__c testQuoteRatePlanRenewal = TestClassUtility.createQuoteRatePlan(TRUE, testQuoteRenewal, testProductRatePlan, testQuoteAmmendmentRenewal);

        zqu__QuoteRatePlanCharge__c testQuoteRatePlanChargeCancel = TestClassUtility.createQuoteRatePlanCharge(TRUE, testQuoteRatePlanCancel, testProductRatePlanCharge);
        zqu__QuoteRatePlanCharge__c testQuoteRatePlanChargeRenewal = TestClassUtility.createQuoteRatePlanCharge(TRUE, testQuoteRatePlanRenewal, testProductRatePlanCharge);

        zqu__QuoteChargeDetail__c quoteChargeDetailCancel = TestClassUtility.createQuoteChargeDetail(TRUE, testQuoteCancel);
        zqu__QuoteChargeDetail__c quoteChargeDetailRenewal = TestClassUtility.createQuoteChargeDetail(TRUE, testQuoteRenewal);

        Zuora__Subscription__c testSubscriptionCancel = TestClassUtility.createSubscription(FALSE, associatedAccount);
        testSubscriptionCancel.Zuora__Version__c = 2;
        testSubscriptionCancel.Zuora__Status__c = 'Cancelled';
        testSubscriptionCancel.CreatingSalesforceQuoteID__c = testQuoteCancel.Id;
        testSubscriptionCancel.SubscriptionType__c = 'Internet';
        Zuora__Subscription__c testSubscriptionRenewal = TestClassUtility.createSubscription(FALSE, associatedAccount);
        testSubscriptionRenewal.Zuora__Version__c = 1;
        testSubscriptionRenewal.SubscriptionType__c = 'Internet';
        testSubscriptionRenewal.OriginalSalesforceQuoteID__c = testQuoteRenewal.Id;
        testSubscriptionRenewal.CreatingSalesforceQuoteID__c = testQuoteRenewal.Id;
        insert new List<Zuora__Subscription__c>{testSubscriptionCancel, testSubscriptionRenewal};

        testQuoteCancel.zqu__Status__c = 'Sent to Z-Billing';
        testQuoteCancel.zqu__SubscriptionType__c = 'Cancel Subscription';
        testQuoteRenewal.zqu__Status__c = 'Sent to Z-Billing';
        testQuoteRenewal.zqu__SubscriptionType__c = 'New Subscription';
        update new List<zqu__Quote__c>{testQuoteCancel, testQuoteRenewal};
        
        quoteChargeDetailCancel.Inventory_Freed_By_Cancellation__c = TRUE;
        quoteChargeDetailCancel.zqu__ProductRatePlan__c = testProductRatePlan.Id;
        quoteChargeDetailCancel.zqu__ChargeNumber__c = 'C-001';
        quoteChargeDetailRenewal.zqu__ProductRatePlan__c = testProductRatePlan.Id;
        update new List<zqu__QuoteChargeDetail__c>{quoteChargeDetailCancel, quoteChargeDetailRenewal};
        
        Inventory__c testInventoryCancel = TestClassUtility.createInventory(FALSE, testProductRatePlan);
        testInventoryCancel.Quote_Rate_Plan__c = testQuoteRatePlanCancel.Id;
        Inventory__c testInventoryRenewal = TestClassUtility.createInventory(FALSE, testProductRatePlan);
        testInventoryRenewal.Quote_Rate_Plan__c = testQuoteRatePlanRenewal.Id;
        insert new List<Inventory__c>{testInventoryCancel, testInventoryRenewal};

        Zuora__SubscriptionProductCharge__c testSubscriptionProductChargeCancel = TestClassUtility.createSubscriptionProductCharge(FALSE, associatedAccount, testSubscriptionCancel);
        testSubscriptionProductChargeCancel.Name = 'Test Subscription Product Charge Cancel';
        testSubscriptionProductChargeCancel.Zuora__ChargeNumber__c = 'C-001';
        testSubscriptionProductChargeCancel.Quote_Rate_Plan_ID__c = testQuoteRatePlanCancel.Id;
        testSubscriptionProductChargeCancel.Zuora__ProductSKU__c = testLocalProduct.zqu__SKU__c;
        Zuora__SubscriptionProductCharge__c testSubscriptionProductChargeRenewal = TestClassUtility.createSubscriptionProductCharge(FALSE, associatedAccount, testSubscriptionRenewal);
        testSubscriptionProductChargeRenewal.Name = 'Test Subscription Product Charge Renewal';
        testSubscriptionProductChargeRenewal.Quote_Rate_Plan_ID__c = testQuoteRatePlanRenewal.Id;
        testSubscriptionProductChargeRenewal.Zuora__ProductSKU__c = testLocalProduct.zqu__SKU__c;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert new List<Zuora__SubscriptionProductCharge__c>{testSubscriptionProductChargeCancel, testSubscriptionProductChargeRenewal};

        Test.stopTest();

        List<Inventory__c> listCancelReleaseInventory = [SELECT Id FROM Inventory__c WHERE Subscription_Product_Charge__c =: testSubscriptionProductChargeCancel.Id];
        System.assert(listCancelReleaseInventory.isEmpty());
    }
    
    static testMethod void testNewSubWithNoCallBackProduct() {

        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Zuora__Subscription__c testZuoraSubscriptionNew = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionNew.Zuora__Version__c = 1;

        update testZuoraSubscriptionNew;

        Product2 testProduct2 = (Product2)mapLocalData.get('Product2');
        testProduct2.zqu__SKU__c = 'testProductSKU1';
        testProduct2.RequiresCallbackTask__c = 'NO';
        update testProduct2;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew.Zuora__ProductSKU__c = 'testProductSKU1';
        testSubProductChargeNew.Zuora__Account__c = testAccount.Id;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert testSubProductChargeNew;

        Test.stopTest();

        List<Case> listACCasesAssert = new List<Case>();
        for(Case assertCase : [SELECT Id FROM Case
                                WHERE Status = 'New' 
                                AND Reason = 'Asset Collection' 
                                AND Origin = 'Auto-Generated'
                                AND SubscriptionProductCharge__c =: testSubProductChargeNew.Id]){
            listACCasesAssert.add(assertCase);
        }
        System.assert(listACCasesAssert.isEmpty());
    }

    static testMethod void testAssetCollectionCaseWithOnboardingCase() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(TRUE);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Opportunity testOppy = (Opportunity)mapLocalData.get('Opportunity');

        Case testOnboardingCase = new Case();
        testOnboardingCase.AccountId = testAccount.Id;
        testOnboardingCase.Opportunity__c = testOppy.Id;
        testOnboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
        insert testOnboardingCase;

        zqu__Quote__c quote = (zqu__Quote__c)mapLocalData.get('zqu__Quote__c');
        Zuora__Subscription__c testZuoraSubscriptionNew = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionNew.Latest_Quote__c = quote.Id;
        testZuoraSubscriptionNew.CreatingSalesforceQuoteID__c = quote.Id;
        testZuoraSubscriptionNew.Zuora__Version__c = 1;
        update testZuoraSubscriptionNew;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew1 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew1.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew1.Zuora__ProductSKU__c = 'testProductSKU1';
        testSubProductChargeNew1.Zuora__Account__c = testAccount.Id;
        testSubProductChargeNew1.Zuora__RatePlanName__c = 'Storefront';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert new List<Zuora__SubscriptionProductCharge__c>{testSubProductChargeNew1};

        Test.stopTest();

        List<Case> listACCasesAssert = [SELECT Id,Onboarding_Case__c FROM Case
                                        WHERE Status = 'New' 
                                        AND Reason = 'Asset Collection' 
                                        AND Origin = 'Auto-Generated'
                                        AND SubscriptionProductCharge__c =: testSubProductChargeNew1.Id];
 
        System.assert(!listACCasesAssert.isEmpty());
        Case caseAssert = listACCasesAssert.get(0);
        System.assert(caseAssert.Onboarding_Case__c == testOnboardingCase.Id);
    }

    static testMethod void testNewSubWithoutExistingACCase() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Zuora__Subscription__c testZuoraSubscriptionNew = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionNew.Zuora__Version__c = 1;
        update testZuoraSubscriptionNew;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew1 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew1.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew1.Zuora__ProductSKU__c = 'testProductSKU1';
        testSubProductChargeNew1.Zuora__Account__c = testAccount.Id;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew2 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew2.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew2.Zuora__ProductSKU__c = 'testProductSKU2';
        testSubProductChargeNew2.Zuora__Account__c = testAccount.Id;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew3 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew3.Name = 'Test Subscription Product Charge - 20% Down';
        testSubProductChargeNew3.Zuora__ProductSKU__c = 'testProductSKU3';
        testSubProductChargeNew3.Zuora__Account__c = testAccount.Id;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        List<Zuora__SubscriptionProductCharge__c> listSubProductCharges = new List<Zuora__SubscriptionProductCharge__c>{testSubProductChargeNew1, testSubProductChargeNew2, testSubProductChargeNew3};
        insert listSubProductCharges;

        Test.stopTest();

        List<Case> listACCasesAssert = new List<Case>();
        for(Case assertCase : [SELECT Id FROM Case
                                WHERE Status = 'New' 
                                AND Reason = 'Asset Collection' 
                                AND Origin = 'Auto-Generated'
                                AND SubscriptionProductCharge__c IN: listSubProductCharges]){
            listACCasesAssert.add(assertCase);
        }

        System.assert(listACCasesAssert.size() == 2);
    }

    static testMethod void testCancelSubWithExistingACCase() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Zuora__Subscription__c testZuoraSubscriptionCancelled = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionCancelled.Zuora__Version__c = 2;
        testZuoraSubscriptionCancelled.Zuora__Status__c = 'Cancelled';

        update testZuoraSubscriptionCancelled;

        Zuora__SubscriptionProductCharge__c testSubProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

        Zuora__SubscriptionProductCharge__c testSubProductChargeCancelled = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                   testAccount, 
                                                                                                                   testZuoraSubscriptionCancelled);
        testSubProductChargeCancelled.Name = 'Test Subscription Product Charge - Cancelled  - 80% Balance';
        testSubProductChargeCancelled.Zuora__EffectiveStartDate__c = Date.today().addMonths(-5);
        testSubProductChargeCancelled.Zuora__EffectiveEndDate__c = Date.today().addMonths(5);
        testSubProductChargeCancelled.Product_Type__c = 'Direct Mail';
        testSubProductChargeCancelled.Zuora__SubscriptionChargeNumber__c = 'C-01';
        testSubProductChargeCancelled.Zuora__Account__c = testAccount.Id;
        
        Case testExistingACCase = generateAssertCollectionCase(false, testAccount, testZuoraSubscriptionCancelled, testSubProductChargeCancelled);
        Case testExistingACCase2 = generateAssertCollectionCase(false, testAccount, testZuoraSubscriptionCancelled, testSubProductCharge);
        insert new List<Case>{testExistingACCase, testExistingACCase2};

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert testSubProductChargeCancelled;

        Test.stopTest();

        Case caseAssert = [SELECT Status FROM Case WHERE Id =: testExistingACCase.Id Limit 1];
        System.assert(caseAssert.Status == 'Cancelled');
    }

    static testMethod void testAmendSubWithExistingACCase() {  
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Zuora__Subscription__c testZuoraSubscriptionAmend = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionAmend.Zuora__Version__c = 2;

        update testZuoraSubscriptionAmend;


        Zuora__SubscriptionProductCharge__c testSubProductChargeAmend = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionAmend);
        testSubProductChargeAmend.Name = 'Test Subscription Product Charge - Amend1  - 80% Balance';
        testSubProductChargeAmend.Zuora__ProductSKU__c = 'Product SKU1';        
        testSubProductChargeAmend.Zuora__Account__c = testAccount.Id;

        Case testExistingACCase = generateAssertCollectionCase(true, testAccount, testZuoraSubscriptionAmend, testSubProductChargeAmend);

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert testSubProductChargeAmend;

        Test.stopTest();

        List<Case> listACCasesAssert = [SELECT Id FROM Case
                                        WHERE Reason = 'Asset Collection' 
                                        AND Origin = 'Auto-Generated'
                                        AND SubscriptionProductCharge__c =: testSubProductChargeAmend.Id];
        System.assert(listACCasesAssert.size() == 1);
       
    }

    static testMethod void testAmendSubWithoutExistingACCase() {       
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;
        Zuora__Subscription__c testZuoraSubscriptionAmend = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionAmend.Zuora__Version__c = 2;

        update testZuoraSubscriptionAmend;

        Zuora__SubscriptionProductCharge__c testSubProductChargeAmend = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionAmend);
        testSubProductChargeAmend.Name = 'Test Subscription Product Charge - Amend1  - 80% Balance';
        testSubProductChargeAmend.Zuora__ProductSKU__c = 'Product SKU1';
        testSubProductChargeAmend.Zuora__Account__c = testAccount.Id;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert testSubProductChargeAmend;

        Test.stopTest();

        List<Case> listACCasesAssert = [SELECT Id FROM Case
                                WHERE Reason = 'Asset Collection' 
                                AND Origin = 'Auto-Generated'
                                AND SubscriptionProductCharge__c =: testSubProductChargeAmend.Id];
        
        System.assert(listACCasesAssert.size() == 1);
    }

    static testMethod void testUpdateDataToZuora() {
        Map<String, String> zspcZuoraIdMap = new Map<String, String>();
        zspcZuoraIdMap.put('123', 'abc');
        Test.startTest();
        ZuoraSubscriptionPCTriggerHandler.updateDataToZuora(zspcZuoraIdMap);
        Test.stopTest();
    }

    private static User getDummyUser(){
        User dummyUser;
        List<User> listDummyUser = [SELECT Id FROM User WHERE Name =: DUMMY_USER_NAME AND IsActive = TRUE LIMIT 1];
        if(!listDummyUser.isEmpty()){
            dummyUser = listDummyUser[0];
        }
        else{
            Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            dummyUser = TestClassUtility.createUser(FALSE, adminProfile);
            dummyUser.FirstName = DUMMY_USER_NAME.substringBefore(SPACE_DELIMITER);
            dummyUser.LastName = DUMMY_USER_NAME.substringAfter(SPACE_DELIMITER);
            insert dummyUser;
        }
        return dummyUser;
    }

    private static Case generateAssertCollectionCase(Boolean isInsert, Account acct, Zuora__Subscription__c testSubscription, Zuora__SubscriptionProductCharge__c subProductCharge){
        Case existingACCase = new Case();
        existingACCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
        existingACCase.Rate_Plan_Name__c = subProductCharge.Zuora__RatePlanName__c;
        existingACCase.AccountId = acct.Id;
        existingACCase.Status = 'New';
        existingACCase.Reason = 'Asset Collection';
        existingACCase.Origin = 'Auto-Generated';
        existingACCase.Subscription_Charge_Number__c = subProductCharge.Zuora__SubscriptionChargeNumber__c;              
        existingACCase.Subscription_Name__c = testSubscription.Name;
        existingACCase.Possible_Renewal__c = subProductCharge.Is_Possible_Renewal__c;
        existingACCase.Product_Type__c = subProductCharge.Zuora__Subscription__r.Product_Line__c;
        existingACCase.Term_Start_Date__c = subProductCharge.Zuora__EffectiveStartDate__c; 
        existingACCase.Term_End_Date__c = subProductCharge.Zuora__EffectiveEndDate__c; 
        existingACCase.LDE_Launch_Date__c = subProductCharge.LDE_Email_Launch_Date__c;
        if(isInsert){
            insert existingACCase;
        }

        return existingACCase;
    }

     static testMethod void testNewLiveSubscriptionProductCharge() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(true,testAccount);

        Zuora__SubscriptionProductCharge__c testSubscriptionPC1 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC1.Zuora__ChargeNumber__c = 'testSubscriptionPC1';
        testSubscriptionPC1.Zuora__Account__c = testAccount.id;
        Test.startTest();
        insert testSubscriptionPC1;
        Test.stopTest();

        List<Live_Subscription_Product_and_Charge__c> listLiveSPC = [SELECT Id 
                                                                        FROM Live_Subscription_Product_and_Charge__c 
                                                                        WHERE Subscription_Product_And_Charge__r.Zuora__Subscription__c =: testSubscription.Id]; 
        System.assertEquals(listLiveSPC.size(), 1);
    }

    static testMethod void testAmendLiveSubscriptionProductCharge() {
        Account testAccount = TestClassUtility.createAccount(true);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(true,testAccount);

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

        Zuora__SubscriptionProductCharge__c testSubscriptionPC1Clone = testSubscriptionPC1.clone();
        testSubscriptionPC1Clone.Zuora__EffectiveStartDate__c = Date.today().adddays(1);

        Zuora__SubscriptionProductCharge__c testSubscriptionPC3 = TestClassUtility.createSubscriptionProductCharge(false,testAccount,testSubscription);
        testSubscriptionPC3.Zuora__ChargeNumber__c = 'testSubscriptionPC3';
        testSubscriptionPC3.Zuora__Account__c = testAccount.id;
        List<Zuora__SubscriptionProductCharge__c> listNewSubProductCharge = new List<Zuora__SubscriptionProductCharge__c>();
        listNewSubProductCharge.add(testSubscriptionPC1Clone);
        listNewSubProductCharge.add(testSubscriptionPC3);

        List<Live_Subscription_Product_and_Charge__c> listLiveSPC2 = [SELECT Id,Zuora_ChargeNumber__c FROM Live_Subscription_Product_and_Charge__c]; 
        
        delete listSubProductCharge;

        Test.startTest();
        
        upsert listNewSubProductCharge;
        Test.stopTest();

        List<Live_Subscription_Product_and_Charge__c> listLiveSPC = [SELECT Id ,Zuora_ChargeNumber__c,Live_Subscription__r.Original_Subscription__c 
                                                                        FROM Live_Subscription_Product_and_Charge__c 
                                                                        WHERE Subscription_Product_And_Charge__r.Zuora__Subscription__c =: testSubscription.Id]; 

        System.assertEquals(listLiveSPC.size(), 2);

        List<Live_Subscription_Product_and_Charge__c> listLiveSPCAll = [SELECT Id,Zuora_ChargeNumber__c,Live_Subscription__c  
                                                                        FROM Live_Subscription_Product_and_Charge__c 
                                                                        WHERE Live_Subscription__r.Original_Subscription__c =: testSubscription.Id]; 

        System.assertEquals(listLiveSPCAll.size(), 3);

    }

    static testMethod void testStampInfoToQuote(){

        Map<String,SObject> testObject = TestClassUtility.buildLocalData(false);
        TestClassUtility.createQuoteTemplate(true);
        Opportunity testOpp = (Opportunity)testObject.get('Opportunity');
        Account testAcc = (Account)testObject.get('Account');
        Contact testCon = (Contact)testObject.get('Contact');
        Zuora__CustomerAccount__c testCA = (Zuora__CustomerAccount__c)testObject.get('Zuora__CustomerAccount__c');

        zqu__Quote__c testQuote = TestClassUtility.createQuote(true, testOpp, testAcc, testCon);
        Zuora__ZInvoice__c testInvoice = TestClassUtility.createInvoice(true, testAcc, testCA);
        Product2 testLocalProduct = TestClassUtility.createLocalProduct2(true);
        zqu__ProductRatePlan__c testProductRatePlan = TestClassUtility.createProductRatePlan(true, testLocalProduct);
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = TestClassUtility.createProductRatePlanCharge(true, testProductRatePlan);
        zqu__QuoteAmendment__c testQuoteAmmendment = TestClassUtility.createQuoteAmendment(true, testQuote);
        zqu__QuoteRatePlan__c testQuoteRatePlan = TestClassUtility.createQuoteRatePlan(true, testQuote, testProductRatePlan, testQuoteAmmendment);
        zqu__QuoteRatePlanCharge__c testQuoteRatePlanCharge = TestClassUtility.createQuoteRatePlanCharge(true, testQuoteRatePlan, testProductRatePlanCharge);
        Zuora__Subscription__c testSubscription = TestClassUtility.createSubscription(true, testAcc);
        Inventory__c testInventory = TestClassUtility.createInventory(true, testProductRatePlan);
        
        Test.startTest();
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = TestClassUtility.createSubscriptionProductCharge(false, testAcc, testSubscription);
        testSubscriptionProductCharge.Quote_Rate_Plan_Charge_Id__c = testQuoteRatePlanCharge.id;
        insert testSubscriptionProductCharge;
        Test.stopTest();
        
        System.assertEquals(testQuoteRatePlanCharge.Subscription_Charge_Number__c,testSubscriptionProductCharge.Zuora__SubscriptionChargeNumber__c );
    }
              
}