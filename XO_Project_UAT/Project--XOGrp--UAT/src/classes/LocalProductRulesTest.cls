@isTest
private class LocalProductRulesTest{
    
    /**
     *   Used to evaluate print  product line's opportunities
     *
     *   @author Nick
     *   @date   2017-02-04
     *   @return test method
     */
    @isTest static void evaluatePrintOpportunity() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();  
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');

        zqu__Quote__c testQuote =TestClassUtility.createQuote(true, testOpportunity, testAccount, testContact);
        
        Test.startTest();
        LocalProductRules.evaluateOpportunity(testOpportunity.id);
        testQuote.Product_Line__c  = 'Print';  
        update testQuote;
        LocalProductRules.evaluateOpportunity(testOpportunity.id);
        Test.stopTest();

        opportunity assertOpportunity1 = [SELECT id, Approval_Process_Flag_Autoreject__c, Approval_Process_Flag_Manager_Approval__c 
                                    FROM opportunity WHERE id =: testOpportunity.Id];
        system.assert(assertOpportunity1.Approval_Process_Flag_Autoreject__c);
    }

    /**
     *   Used to evaluate direct mail product line's opportunities
     *
     *   @author Mason
     *   @date   2018-10-24
     *   @return test method
     */    
    @isTest static void evaluateDirectMailOpportunity() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();  
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');

        zqu__Quote__c testQuote =TestClassUtility.createQuote(true, testOpportunity, testAccount, testContact);
        
        

        Test.startTest();
        LocalProductRules.evaluateOpportunity(testOpportunity.id);
        testQuote.Product_Line__c  = 'Direct Mail';  
        update testQuote;
        LocalProductRules.evaluateOpportunity(testOpportunity.id);

        Test.stopTest();

        opportunity assertOpportunity1 = [SELECT id, Approval_Process_Flag_Autoreject__c, Approval_Process_Flag_Manager_Approval__c 
                                    FROM opportunity WHERE id =: testOpportunity.Id];
        system.assert(assertOpportunity1.Approval_Process_Flag_Autoreject__c);
    }

    /**
     *   Used to evaluate Migrated Contract product line's opportunities
     *
     *   @author Mason
     *   @date   2018-10-24
     *   @return test method
     */
    @isTest static void evaluateMCOpportunity() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();  
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');

        zqu__Quote__c testQuote =TestClassUtility.createQuote(true, testOpportunity, testAccount, testContact);
        
        LocalProductRules.evaluateOpportunity(testOpportunity.id);

        Test.startTest();
        testQuote.Product_Line__c  = 'Migrated Contract'; 
        testQuote.zqu__SubscriptionType__c = 'Amend Subscription'; 
        update testQuote;
        LocalProductRules.evaluateOpportunity(testOpportunity.id);
        
        Test.stopTest();

        opportunity assertOpportunity1 = [SELECT id, Approval_Process_Flag_Autoreject__c, Approval_Process_Flag_Manager_Approval__c 
                                    FROM opportunity WHERE id =: testOpportunity.Id];
        system.assert(assertOpportunity1.Approval_Process_Flag_Autoreject__c);
        system.assert(assertOpportunity1.Approval_Process_Flag_Manager_Approval__c);
    }

    
    /**
     *   Used to evaluate the opportunity with Cancel Subscription
     *
     *   @author Nick
     *   @date   2017-02-04
     *   @return test method
     */
    @isTest static void printEvaluationTest() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData = TestClassUtility.buildLocalData(false);
       
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');
        Market__c testMarket = (Market__c)testData.get('Market__c');

        Map<String, SObject> localProductDataMap = TestClassUtility.buildLocalProductData(testOpportunity,testAccount, testContact,testMarket);
        zqu__QuoteRatePlanCharge__c testZquQuoteRatePlanCharge = (zqu__QuoteRatePlanCharge__c)localProductDataMap.get('zqu__QuoteRatePlanCharge__c');
        zqu__QuoteRatePlan__c testZquQuoteRatePlan = (zqu__QuoteRatePlan__c)localProductDataMap.get('zqu__QuoteRatePlan__c');
        Product2 testProduct = (Product2)localProductDataMap.get('Product2');
        zqu__Quote__c testQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');

        LocalProductRules.evaluateOpportunity(testOpportunity.id); 

        testZquQuoteRatePlanCharge.Discount_Override__c = 5;
        testZquQuoteRatePlanCharge.Steelbrick_Calculated_Discount__c = 10;
        update testZquQuoteRatePlanCharge;
        
        testQuote.zqu__SubscriptionType__c = 'Cancel Subscription';
        update testQuote;
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
            
        LocalProductRules.evaluateOpportunity(testOpportunity.id); 
        
        LocalProductRules.QuotesWrapper QuotesWrapper1 = new LocalProductRules.QuotesWrapper();
        LocalProductRules.QuotesWrapper QuotesWrapper2 = new LocalProductRules.QuotesWrapper();
        LocalProductRules.QuotesWrapper QuotesWrapper3 = new LocalProductRules.QuotesWrapper();
        LocalProductRules.QuotesWrapper QuotesWrapper4 = new LocalProductRules.QuotesWrapper();

        LocalProductRules.OpportunityQuotesWrapper OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();
        
        QuotesWrapper1.quote = testQuote;
        QuotesWrapper1.quoteProductLine = 'Print';
        QuotesWrapper1.quoteSubscriptionType = 'Cancel Subscription';
        OpportunityQuotesWrapper.quotesWrapperList.add(QuotesWrapper1);

        QuotesWrapper2.quote = testQuote;
        QuotesWrapper2.quoteProductLine = 'Print';
        QuotesWrapper2.quoteSubscriptionType = '';
        QuotesWrapper2.quoteRatePlanMap.put(testZquQuoteRatePlan.id,testZquQuoteRatePlan);
        OpportunityQuotesWrapper.quotesWrapperList.add(QuotesWrapper2);

        List<zqu__QuoteRatePlan__c> qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, 
                                                zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c, zqu__Quote__r.zqu__InitialTerm__c, 
                                                Name, zqu__AmendmentType__c, zqu__Quote__c, zqu__Quote__r.zqu__Opportunity__c, 
                                                Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, RequiresApproval__c, 
                                                RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, 
                                                Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, 
                                                Print_Issue_Previous_Issue_ID__c, Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, 
                                                AvoidDuplicates__c, 
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, 
                                                        Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                        zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, 
                                                        zqu__QuoteRatePlan__r.ZProduct_Name__c, Steelbrick_Calculated_Discount__c, 
                                                        zqu__Discount__c, Discount_Override__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testopportunity.Id];
        
        
        OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();
        QuotesWrapper3.quote = testQuote;
        QuotesWrapper3.quoteProductLine = 'Print';
        QuotesWrapper3.quoteSubscriptionType = '';
        
        for(zqu__QuoteRatePlan__c qrp: qrpList ){
            QuotesWrapper3.quoteRatePlanMap.put(qrp.id,qrp);
        }
        OpportunityQuotesWrapper.quotesWrapperList.add(QuotesWrapper3);


        qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c, 
                            zqu__Quote__r.zqu__InitialTerm__c, Name, zqu__AmendmentType__c, zqu__Quote__c, 
                            zqu__Quote__r.zqu__Opportunity__c, Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, 
                            RequiresApproval__c, RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, 
                            Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, Print_Issue_Previous_Issue_ID__c, 
                            Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, AvoidDuplicates__c, 
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, 
                                                        Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                        zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, 
                                                        zqu__QuoteRatePlan__r.ZProduct_Name__c, Steelbrick_Calculated_Discount__c, 
                                                        zqu__Discount__c, Discount_Override__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testopportunity.Id];
        
        OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();
        QuotesWrapper4 = new LocalProductRules.QuotesWrapper();
        QuotesWrapper4.quote = testQuote;
        QuotesWrapper4.quoteProductLine = 'Print';
        QuotesWrapper4.quoteSubscriptionType = '';
        
        for(zqu__QuoteRatePlan__c qrp: qrpList ){
            QuotesWrapper4.quoteRatePlanMap.put(qrp.id,qrp);
        }
        OpportunityQuotesWrapper.quotesWrapperList.add(QuotesWrapper4);


        Test.startTest();
        OpportunityQuotesWrapper = LocalProductRules.runPrintEvaluation(OpportunityQuotesWrapper);
        OpportunityQuotesWrapper = LocalProductRules.runPrintEvaluation(OpportunityQuotesWrapper);
        testZquQuoteRatePlan.zqu__AmendmentType__c = 'New Product'; 
        update testZquQuoteRatePlan;
        OpportunityQuotesWrapper = LocalProductRules.runPrintEvaluation(OpportunityQuotesWrapper);
        testProduct.CannotBeSoldPast__c = '3 Weeks Before Step 2 Date';
        update testProduct;
        OpportunityQuotesWrapper = LocalProductRules.runPrintEvaluation(OpportunityQuotesWrapper);
        Test.stopTest();

        opportunity assertOpportunity1 = [SELECT id, Approval_Process_Flag_Autoreject__c, Approval_Process_Flag_Manager_Approval__c 
                                        FROM opportunity WHERE id =: testOpportunity.Id];
        system.assert(assertOpportunity1.Approval_Process_Flag_Autoreject__c);
    }

    /**
     *   Used to evaluate Internet
     *
     *   @author Nick
     *   @date   2017-02-04
     *   @return test method
     */
    @isTest static void InternetEvaluationTest() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');
        Market__c testMarket = (Market__c)testData.get('Market__c');
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Map<String, SObject> localProductDataMap = TestClassUtility.buildLocalProductData(testOpportunity,testAccount, testContact,testMarket);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');
        LocalProductRules.QuotesWrapper QuotesWrapper = new LocalProductRules.QuotesWrapper();
        LocalProductRules.OpportunityQuotesWrapper OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();
        QuotesWrapper.quote = testZquQuote;
        QuotesWrapper.quoteProductLine = 'Internet';
        QuotesWrapper.quoteSubscriptionType = 'Cancel Subscription';
        OpportunityQuotesWrapper.quotesWrapperList.add(QuotesWrapper);
        
        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        OpportunityQuotesWrapper = LocalProductRules.runInternetEvaluation(OpportunityQuotesWrapper);
        Test.stopTest();

        System.assert(OpportunityQuotesWrapper.reasonsForCancellationApproval.contains('is for a Subscription Cancellation'));
    }

    /**
     *   Used to evaluate the opporunity with internet quote and new subscription
     *
     *   @author Nick
     *   @date   2017-02-04
     *   @return test method
     */
    @isTest static void evaluateTwoXProductsAndReturnQRPest() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');
        Market__c testMarket = (Market__c)testData.get('Market__c');
        
        Map<String, SObject> localProductDataMap = TestClassUtility.buildLocalProductData(testOpportunity,testAccount, testContact,testMarket);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');
        Product2 testProduct = (Product2)localProductDataMap.get('Product2');    
        zqu__QuoteRatePlan__c testZquQuoteRatePlan = (zqu__QuoteRatePlan__c)localProductDataMap.get('zqu__QuoteRatePlan__c'); 
        zqu__Quote__c testQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');
        zqu__QuoteRatePlanCharge__c testZquQuoteRatePlanCharge = (zqu__QuoteRatePlanCharge__c)localProductDataMap.get('zqu__QuoteRatePlanCharge__c');
        
        testZquQuoteRatePlan.zqu__AmendmentType__c = 'New Product'; 
        update testZquQuoteRatePlan;

        testZquQuote.Product_Line__c = 'Internet';  
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        update testZquQuote;

        testProduct.CannotBeSoldPast__c = 'Step 3 Date';
        testProduct.AvoidDuplicates__c = 'In Same Market/Category';
        testProduct.RequiresPaidStorefront__c = 'In Same Market/Category';
        update testProduct;

        Opportunity opp = [SELECT Id, AccountId, Account.DynamicsAccID__c, Approval_Process_Flag_Manager_Approval__c, Approval_Process_Flag_Autoreject__c, 
                                Approval_Process_Info_For_Approver__c, (SELECT Id, zqu__SubscriptionType__c, zqu__InitialTerm__c, Product_Line__c, Approval_Process_Flag_Discount_Amount__c FROM zqu__Quotes__r) 
                                FROM Opportunity WHERE Id = :testOpportunity.id LIMIT 1];
        List<zqu__QuoteRatePlan__c> qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, zqu__Quote__r.zqu__InitialTerm__c, Name, zqu__AmendmentType__c, 
                                                    zqu__Quote__c, zqu__Quote__r.zqu__Opportunity__c, Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, RequiresApproval__c, 
                                                    RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, 
                                                    Print_Issue_Previous_Issue_ID__c, Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, AvoidDuplicates__c, zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, zqu__QuoteRatePlan__r.ZProduct_Name__c, 
                                                                Steelbrick_Calculated_Discount__c, zqu__Discount__c, Discount_Override__c, LocationVendorDynamicsAccountID__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                    FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testOpportunity.Id];

        RestrictedCategories__c testRestrictedCategories = new RestrictedCategories__c();
        testRestrictedCategories.name = 'SKU-00000044';
        testRestrictedCategories.Category_Taxonomy_Id__c = testZquQuoteRatePlanCharge.Category_Taxonomy_ID__c ;
        insert testRestrictedCategories;
        
        LocalProductRules.OpportunityQuotesWrapper OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();
        OpportunityQuotesWrapper = LocalProductRules.generateOpportunityQuotesWrapper(opp, qrpList);
        OpportunityQuotesWrapper = LocalProductRules.runInternetEvaluation(OpportunityQuotesWrapper);
        
        testProduct.AvoidDuplicates__c = 'In Same Market/Category';
        testProduct.RequiresPaidStorefront__c = 'In Same Market/Category';
        update testProduct;
        qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, zqu__Quote__r.zqu__InitialTerm__c, Name, zqu__AmendmentType__c, 
                                                    zqu__Quote__c, zqu__Quote__r.zqu__Opportunity__c, Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, RequiresApproval__c, 
                                                    RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, 
                                                    Print_Issue_Previous_Issue_ID__c, Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, AvoidDuplicates__c, zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, zqu__QuoteRatePlan__r.ZProduct_Name__c, 
                                                                Steelbrick_Calculated_Discount__c, zqu__Discount__c, Discount_Override__c, LocationVendorDynamicsAccountID__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                    FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testOpportunity.Id];
        OpportunityQuotesWrapper = LocalProductRules.generateOpportunityQuotesWrapper(opp, qrpList);
        OpportunityQuotesWrapper = LocalProductRules.runInternetEvaluation(OpportunityQuotesWrapper);
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        
        List<zqu__QuoteRatePlan__c> quoteSpecificQRPList = new List<zqu__QuoteRatePlan__c>();
        LocalProductRules.TwoXWrapper TwoXWrapper = new LocalProductRules.TwoXWrapper(testZquQuoteRatePlan);
        LocalProductRules.TwoXWrapper TwoXWrapper1 = new LocalProductRules.TwoXWrapper(testZquQuoteRatePlan);
        list<LocalProductRules.TwoXWrapper> TwoXWrapperlist = new list<LocalProductRules.TwoXWrapper>();
        Map<String, List<LocalProductRules.TwoXWrapper>> mainMap = new Map<String, List<LocalProductRules.TwoXWrapper>>();

        Test.startTest();
        TwoXWrapperlist.clear();
        mainMap.clear();
        TwoXWrapperlist.add(TwoXWrapper);
        mainMap.put('test',TwoXWrapperlist);
        quoteSpecificQRPList = LocalProductRules.evaluateTwoXProductsAndReturnQRPWarningList(mainMap );
        
        TwoXWrapperlist.clear();
        mainMap.clear();
        TwoXWrapper.previousWrapperKey = 'test1';
        TwoXWrapperlist.add(TwoXWrapper);
        mainMap.put('test',TwoXWrapperlist);
        mainMap.put('test1',TwoXWrapperlist);
        quoteSpecificQRPList = LocalProductRules.evaluateTwoXProductsAndReturnQRPWarningList(mainMap );
        
        TwoXWrapperlist.clear();
        mainMap.clear();
        TwoXWrapper.nextWrapperKey = 'test1';
        TwoXWrapper.previousWrapperKey = 'test2';
        TwoXWrapperlist.add(TwoXWrapper);
        mainMap.put('test',TwoXWrapperlist);
        mainMap.put('test1',TwoXWrapperlist);
        quoteSpecificQRPList = LocalProductRules.evaluateTwoXProductsAndReturnQRPWarningList(mainMap );
        
        TwoXWrapperlist.clear();
        mainMap.clear();
        TwoXWrapper.nextWrapperKey = 'test1';
        TwoXWrapper.previousWrapperKey = 'test1';
        TwoXWrapperlist.add(TwoXWrapper);
        mainMap.put('test',TwoXWrapperlist);
        mainMap.put('test1',TwoXWrapperlist);
        quoteSpecificQRPList = LocalProductRules.evaluateTwoXProductsAndReturnQRPWarningList(mainMap );
        
        TwoXWrapperlist.clear();
        mainMap.clear();
        TwoXWrapper.nextWrapperKey = 'test1';
        TwoXWrapper.previousWrapperKey = 'test1';
       
        TwoXWrapper1.nextWrapperKey = 'test1';
        TwoXWrapper1.previousWrapperKey = 'test1';
        TwoXWrapperlist.add(TwoXWrapper);
        mainMap.put('test',TwoXWrapperlist);
        TwoXWrapperlist.add(TwoXWrapper1);
        mainMap.put('test1',TwoXWrapperlist);
        quoteSpecificQRPList = LocalProductRules.evaluateTwoXProductsAndReturnQRPWarningList(mainMap ); 
        Test.stopTest();


        system.assert(quoteSpecificQRPList.size() > 0); 
    }

    // ////////////////////////////////////////////////////////////////////////////////////
    @isTest static void LDEEvaluationTest() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        TestClassUtility.generateQuotePdfConfig(true);


        Opportunity testOpportunity = (Opportunity)testData.get('Opportunity');
        Account testAccount = (Account)testData.get('Account');
        Contact testContact = (Contact)testData.get('Contact');
        Market__c testMarket = (Market__c)testData.get('Market__c');

        Map<String, SObject> localProductDataMap = TestClassUtility.buildLocalProductData(testOpportunity,testAccount, testContact,testMarket);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');
        Product2 testProduct = (Product2)localProductDataMap.get('Product2');    
        zqu__QuoteRatePlan__c testZquQuoteRatePlan = (zqu__QuoteRatePlan__c)localProductDataMap.get('zqu__QuoteRatePlan__c'); 
        zqu__Quote__c testQuote = (zqu__Quote__c)localProductDataMap.get('zqu__Quote__c');
        zqu__QuoteRatePlanCharge__c testZquQuoteRatePlanCharge = (zqu__QuoteRatePlanCharge__c)localProductDataMap.get('zqu__QuoteRatePlanCharge__c');
        
        
        testProduct.CannotBeSoldPast__c = 'Step 3 Date';
        update testProduct;

        testZquQuote.Product_Line__c = 'Direct Mail';  
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        update testZquQuote;
        
        testZquQuoteRatePlan.zqu__AmendmentType__c = 'RemoveProduct'; 
        update testZquQuoteRatePlan;
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        
        
        opportunity opp = [SELECT Id, AccountId, Account.DynamicsAccID__c, Approval_Process_Flag_Manager_Approval__c, Approval_Process_Flag_Autoreject__c, 
                                Approval_Process_Info_For_Approver__c, (SELECT Id, zqu__SubscriptionType__c, zqu__InitialTerm__c, Product_Line__c, Approval_Process_Flag_Discount_Amount__c FROM zqu__Quotes__r) 
                                FROM Opportunity WHERE Id = :testOpportunity.id LIMIT 1];
        List<zqu__QuoteRatePlan__c> qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, zqu__Quote__r.zqu__InitialTerm__c, Name, zqu__AmendmentType__c, 
                                                    zqu__Quote__c, zqu__Quote__r.zqu__Opportunity__c, Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, RequiresApproval__c, 
                                                    RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, 
                                                    Print_Issue_Previous_Issue_ID__c, Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, AvoidDuplicates__c, 
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, zqu__QuoteRatePlan__r.ZProduct_Name__c, 
                                                                Steelbrick_Calculated_Discount__c, zqu__Discount__c, Discount_Override__c, LocationVendorDynamicsAccountID__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                    FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testOpportunity.Id];
        LocalProductRules.OpportunityQuotesWrapper OpportunityQuotesWrapper = new LocalProductRules.OpportunityQuotesWrapper();



        Test.startTest();
        OpportunityQuotesWrapper = LocalProductRules.generateOpportunityQuotesWrapper(opp, qrpList);
        OpportunityQuotesWrapper = LocalProductRules.runLDEEvaluation(OpportunityQuotesWrapper);
        
        testZquQuoteRatePlan.zqu__AmendmentType__c = 'New Product'; 
        update testZquQuoteRatePlan;
        qrpList = [SELECT Id, zqu__QuoteProductName__c, ZProduct_Name__c, zqu__Quote__r.zqu__InitialTerm__c, Name, zqu__AmendmentType__c, 
                                                    zqu__Quote__c, zqu__Quote__r.zqu__Opportunity__c, Location_Vendor__c, CannotBeSoldPast__c, NoAutomatedDiscount__c, RequiresApproval__c, 
                                                    RequiresPaidStorefront__c, MaximumSubscriptionTerm__c, MinimumSubscriptionTerm__c, Requires2X__c, Print_Issue__c, Print_Issue_Next_Issue_ID__c, 
                                                    Print_Issue_Previous_Issue_ID__c, Print_Issue_Step_2_Date__c, Print_Issue_Step_3_Date__c, AvoidDuplicates__c, zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                                                    (SELECT Id, Name, Product_Name__c, Print_Issue__c, Location_Vendor__c, Location_Vendor__r.Name, Market_ID__c, Category_Taxonomy_ID__c, 
                                                                zqu__QuoteRatePlan__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c, zqu__QuoteRatePlan__r.ZProduct_Name__c, 
                                                                Steelbrick_Calculated_Discount__c, zqu__Discount__c, Discount_Override__c, LocationVendorDynamicsAccountID__c FROM zqu__Quote_Rate_Plan_Charges__r) 
                                                    FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__r.zqu__Opportunity__c = :testOpportunity.Id];

        OpportunityQuotesWrapper = LocalProductRules.generateOpportunityQuotesWrapper(opp, qrpList);
        OpportunityQuotesWrapper = LocalProductRules.runLDEEvaluation(OpportunityQuotesWrapper);
        Test.stopTest();

        opportunity assertOpportunity1 = [SELECT id, Approval_Process_Flag_Autoreject__c, Approval_Process_Flag_Manager_Approval__c 
                                        FROM opportunity WHERE id =: testOpportunity.Id];
        system.assert(!assertOpportunity1.Approval_Process_Flag_Autoreject__c);
    }
}