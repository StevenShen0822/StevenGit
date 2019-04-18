/*******************************************************************************
 *  Summary         : Test class for LocalRenewalBook Controller
 *  Refer Object    : 
 *  Author          : Tony
 *  RefactorDate    : 12 Dec 2016
 *  Change Log      : refactoring by SF-2.6 release
 ******************************************************************************/
@isTest//(seeAllData = true)
private class LocalRenewalBookControllerTest{
    @isTest static void test_method_one() {
        
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
        Map<String,SObject> sObjectMap  = TestClassUtility.buildLocalData(FALSE);
        test.stopTest();

        Account testAccount = (Account)sObjectMap.get('Account');
        Market__c testMarket = (Market__c)sObjectMap.get('Market__c');
        Category__c testCategory = (Category__c)sObjectMap.get('Category__c');
        zqu__ZProduct__c testZquZProduct = TestClassUtility.createProduct(TRUE);
        Zuora__Subscription__c testZquSubscription = TestClassUtility.createSubscription(TRUE,testAccount);
        
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        // Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        // Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        // test.startTest();
        // testDataFactoryT tdf = new testDataFactoryT();
        // tdf.CreateLocalTestObjects();
        // test.stopTest();
        // Account testAccount3 = new Account();
        // testAccount3.Name = 'Test Child3 Account ';
        // testAccount3.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        // testAccount3.BU__c = 'Local';
        // testAccount3.Website = 'www.google1.com';
        // testAccount3.Type = 'Advertiser';
        // testAccount3.BillingCountry = 'United States';
        // testAccount3.BillingState = 'Alaska';
        // testAccount3.BillingCity = 'US2';
        // testAccount3.BillingStreet = 'US3';
        // testAccount3.BillingPostalCode = tdf.testZip.zipcode__c;
        // testAccount3.parentId = tdf.testAccount.id;
        // testAccount3.Primary_Brand__c = tdf.testBrand.id;
        // testAccount3.Primary_Category__c = tdf.testCategory.id;
        // testAccount3.Local_Sales_Market__c = tdf.testMarket.id;
        // insert testAccount3;
        
        // zqu__ZProduct__c testZquZProduct = new zqu__ZProduct__c();
        // testZquZProduct.Name = 'Test Storefront'; 
        // testZquZProduct.zqu__Category__c = 'Add On Services'; 
        // testZquZProduct.zqu__SKU__c = 'SKU-00000044'; 
        // testZquZProduct.zqu__ZuoraId__c = '2c92c0f84e4d2c02014e655c22cc548c'; 
        // testZquZProduct.LOB__c = 'The Knot'; 
        // testZquZProduct.ProductType__c = 'Internet'; 
        // testZquZProduct.Ad_Shape__c = 'None'; 
        // testZquZProduct.Job_Type__c = 'The Knot'; 
        // testZquZProduct.MinimumSubscriptionTerm__c ='12';
        // insert testZquZProduct;
        
        // Zuora__Subscription__c testZquSubscription = new Zuora__Subscription__c();
        // testZquSubscription.Name = 'Test Subscription';
        // testZquSubscription.Zuora__SubscriptionStartDate__c = Date.Today();
        // testZquSubscription.Zuora__SubscriptionEndDate__c = Date.Today() + 365;
        // testZquSubscription.Zuora__Status__c = 'Active';
        // testZquSubscription.Zuora__Account__c = tdf.testAccount.Id;
        // testZquSubscription.Sales_Rep__c = userList[0].id;
        
        // insert testZquSubscription;
        // testZquSubscription.Zuora__Zuora_Id__c =testZquSubscription.id;
        // update testZquSubscription;
        test.setCurrentPageReference(Page.LocalRenewalBook);
        ApexPages.StandardController sc = new ApexPages.StandardController(testZquSubscription);
        LocalRenewalBookController testcase = new LocalRenewalBookController(sc); 
        string ownerActiveFilter = testcase.ownerActiveFilter;
        
        testcase.filterObject.brandFilter = testAccount.id;
        
        testcase.filterObject.marketFilter.add(new SelectOption('testMarket', string.valueOf(testMarket.Id)));
        
        testcase.filterObject.categoryFilter.add(new SelectOption('testCategory', string.valueOf(testCategory.Id)));
        testcase.filterObject.postalCodeSelected = '12121';
        testcase.filterObject.subscriptionFilter.Sales_Rep__c = userList[0].id;
        testcase.filterObject.subscriptionFilter.Renewal_Rep__c = userList[0].id;
        testcase.filterObject.productLineFilter.Product_Line__c = 'test';
        testcase.filterResults();
        
        testcase.brandFilterFunction();
        testcase.subSelectedMap.put(testZquSubscription.id,false);
        testcase.populateSubscriptions();
        
        testcase.refresh();
        
        testcase.saveRenewalRep();
        testcase.saveFloaterRep();
        
        testcase.salesRepToAssign = userList[1].id;
        testcase.subSelectedMap.clear();
        testcase.saveRenewalRep();
        testcase.saveFloaterRep();
        
        testcase.subSelectedMap.put(testZquSubscription.id,true);
        testcase.saveRenewalRep();
        testcase.saveFloaterRep();
        
        boolean hasNext = testcase.hasNext;
        boolean hasPrevious = testcase.hasPrevious;
        Integer pageNumber = testcase.pageNumber;
        
        testcase.first();
        testcase.last();
        testcase.previous();
        testcase.next();
        
        List<SelectOption> ResultSizeOptions = testcase.getResultSizeOptions();
        List<SelectOption> BrandOptions = testcase.getBrandOptions();
        List<SelectOption> CategoryOptions = testcase.getCategoryOptions();
        List<SelectOption> MarketOptions = testcase.getMarketOptions();
        List<SelectOption> SortByList = testcase.getSortByList();
        List<SelectOption> getUserList = testcase.getUserList();
        List<SelectOption> getUserRenewalList = testcase.getUserRenewalList();
        List<SelectOption> getLocalSalesRepActive = testcase.getLocalSalesRepActive();
        List<SelectOption> getActiveType = testcase.getActiveType();
        List<SelectOption> getLocalAEOnly = testcase.getLocalAEOnly();
        
        testcase.reRenderPanel();
        
    }
}