@isTest
private class AccountTriggerTest { 
    private static List<User> userList;
    private static Map<String,Schema.RecordTypeInfo> rtAccountMapByName;
    private static Map<String,Schema.RecordTypeInfo> rtLeadMapByName;
    // CSP-1999 private static Map<String,Schema.RecordTypeInfo> rtBrandMapByName;
    private static Deactivate_Trigger__c dtatt;
    private static Generate_Quote_Pdf_Config__c GQPF;
    // CSP-1999 private static Brand__c testBrand;
    private static Region__c testRegion;
    private static Market__c testMarket;
    private static Category__c testCategory;
    private static MetroArea__c ma;
    private static Zip__c zip;

    private static testmethod void test_accountinsertlogic() {
        create_TestData();

        Test.startTest();
        // CSP-1999 
        // Account parentAccount = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Account parentAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
        parentAccount.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        parentAccount.Record_Type_Name__c = 'Local';
        parentAccount.BU__c = 'Local';
        parentAccount.Type = 'Agency';
        parentAccount.Operative_Owner__c = userList[0].Name;
        parentAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';
        parentAccount.Override_Account_CBSS__c = true;
        parentAccount.CBBS__c = userList[1].Id;
        insert parentAccount;
        List<Account> lstacc1 =[select id from Account where id=: parentAccount.id];
        system.assertEquals(1,lstacc1.size());

        
        // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.BillingPostalCode = zip.zipCode__c+'1';
        testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "", "marketCode" : "222", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';
        testAccount1.OwnerId = userList[1].id;
        testAccount1.Fulfill_Storefront__c = true;
        testAccount1.Fulfilled__c = false;
        testAccount1.Override_Account_CBSS__c = true;

        testAccount1.parentId = parentAccount.id;
        try{
            insert testAccount1;
            List<Account> lstacc11 =[select id from Account where id=: testAccount1.id];
            system.assertEquals(1,lstacc11.size());
        }catch(exception e){}
        
        parentAccount.ShippingPostalCode = '';
        parentAccount.BillingPostalCode = zip.Zipcode__c + '1';
        parentAccount.Need_to_Create_CB_Case__c = true;
        try{
            update parentAccount;
        }catch(exception e){}
        
        parentAccount.ShippingPostalCode = zip.Zipcode__c + '1';
        try{
            update parentAccount;
        }catch(exception e){}
        Test.stopTest();
    }

    private static testmethod void test_parentaccountinsertlogic() {
        create_TestData();

        Test.startTest();

        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.BillingPostalCode = zip.zipCode__c+'1';
        testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "", "marketCode" : "222", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';
        testAccount1.OwnerId = userList[1].id;
        testAccount1.Fulfill_Storefront__c = true;
        testAccount1.Fulfilled__c = false;
        testAccount1.Override_Account_CBSS__c = true;        
        testAccount1.ShippingPostalCode = zip.zipCode__c+'1';
        testAccount1.BillingPostalCode = zip.zipCode__c;
        testAccount1.Fulfilled__c = true;
        testAccount1.Need_to_Create_CB_Case__c = false;
        testAccount1.Past_Due_Balance__c = 12.34;
        insert testAccount1;
        List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc1.size());

        testAccount1.Need_to_Create_CB_Case__c = true;
        testAccount1.Past_Due_Balance__c = 123.4;
        update testAccount1;

        testAccount1.Need_to_Create_CB_Case__c = false;
        testAccount1.Past_Due_Balance__c = 288;
        update testAccount1;
        List<Account> lstacc2 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc2.size());

        Test.stopTest();
    }

    private static testmethod void test_GenerateAccountVIPStatusTask() {
        create_TestData();

      Test.startTest();
        // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.BillingPostalCode = zip.zipCode__c + '1';
        testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.OwnerId = userList[0].Id;
        testAccount1.Strategy_Specialist__c = userList[1].Id;
        testAccount1.Manual_VIP_Program_Status__c = 'VIP';
        insert testAccount1;
        List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc1.size());
        
        testAccount1.Manual_VIP_Program_Status__c = 'Not VIP';
        update testAccount1;
        Test.stopTest();
    }

    private static testmethod void test_OverrideAccountCBSS() {
        create_TestData();

      Test.startTest();
        // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.BillingPostalCode = zip.zipCode__c + '1';
        testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.OwnerId = userList[0].Id;
        testAccount1.Fulfill_Storefront__c = false;
        insert testAccount1;
        List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc1.size());

        TestClassUtility.createCustomerAccount(true, testAccount1);

        testAccount1.Override_Account_CBSS__c = true;
        testAccount1.CBBS__c = userList[1].Id;
        //testAccount1.Fulfill_Storefront__c = true;
        update testAccount1;

        testAccount1.Override_Account_CBSS__c = false;
        testAccount1.Fulfill_Storefront__c = false;
        update testAccount1;

        //csp-2618
        Zip__c testZip = TestClassUtility.createzip(true);

        Category__c testCategory = TestClassUtility.createCategory(false);
        testCategory.Category_Code__c = 'ACC';
        insert testCategory;
        List<Category__c> lstcategory1 =[select id from Category__c where id=: testCategory.id];
        system.assertEquals(1,lstcategory1.size());        

        Account testAcct = TestClassUtility.createAccount(false);
        testAcct.BillingPostalCode = testZip.ZipCode__c;
        testAcct.Primary_Category__c = testCategory.id;
        insert testAcct;
        List<Account> lstacc2 =[select id from Account where id=: testAcct.id];
        system.assertEquals(1,lstacc2.size());

        /*Marketplace_Health__c  testMS = new Marketplace_Health__c();
        testMS.Category__c = testCategory.Id;
        testMS.Zip__c = testZip.Id;
        testMS.External_Key__c = testZip.ZipCode__c + testCategory.Category_Code__c;
        insert testMS;*/


        Test.stopTest();
    }

    private static testmethod void test_UpdateBillingAccountNames() {
        create_TestData();

      Test.startTest();
      // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.BillingPostalCode = zip.zipCode__c + '1';
        testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.OwnerId = userList[0].Id;
        testAccount1.Name = 'test name';
        insert testAccount1;
        List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc1.size());
        
        testAccount1.Name = 'some other test name';
        update testAccount1;
        Test.stopTest();
    }

    private static testmethod void test_UpdateContactAddress() {
        create_TestData();

      Test.startTest();
      // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Profile localsalesdatateamProfile = [SELECT Id FROM Profile WHERE Name='Local Sales Data Team'];
        User userTorun = [SELECT Id FROM User WHERE ProfileId = :localsalesdatateamProfile.Id limit 1];


        System.runAs(userTorun) {

            Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
            testAccount1.BillingStreet = '100 Pennock Court';
            testAccount1.BillingCity = 'Folsom';
            testAccount1.BillingState = 'California';
            testAccount1.BillingPostalCode = zip.zipCode__c + '1';
            testAccount1.BillingCountry = 'United States';
            testAccount1.Region__c = 'Austin/Central Texas/Texas Hill Country';
            testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
            testAccount1.OwnerId = userList[0].Id;
            testAccount1.Name = 'testing name';
            testAccount1.Fulfill_Storefront__c = false;
            testAccount1.Past_Due_Balance__c = 12.34;

            insert testAccount1;
            List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
            system.assertEquals(1,lstacc1.size());

            Contact testContact1 = TestClassUtility.createContact(false, testAccount1);
            testContact1.Same_Address_as_Account__c = true;
            testContact1.Email = 'test@test.com';
            testAccount1.Past_Due_Balance__c = 23.45;
            insert testContact1;
            List<Contact> testcon1 =[select id from Contact where id=: testContact1.id];
            system.assertEquals(1,testcon1.size());

            AccountContactRole accConrole = new AccountContactRole();
            accConrole.AccountId = testAccount1.Id;
            accConrole.ContactId = testContact1.Id;
            accConrole.Role = 'Primary';
            Insert accConrole;
            List<AccountContactRole> testaccconrole1 =[select id from AccountContactRole where id=: accConrole.id];
            system.assertEquals(1,testaccconrole1.size());

            testAccount1.BillingStreet = '666 Pennock Court';
            testAccount1.BillingPostalCode = zip.zipCode__c + '11';
            //testAccount1.Fulfill_Storefront__c = true;
            testAccount1.Account_Status__c = 'Qualified';
            testAccount1.Past_Due_Balance__c = 0;
            update testAccount1;
            List<Account> lstacc11 =[select id from Account where id=: testAccount1.id];
            system.assertEquals(1,lstacc11.size());

        }

        Test.stopTest();
    }     

    private static testmethod void test_UpdateContactAddress1() {
        create_TestData();

      Test.startTest();
      // CSP-1999 
        // Account testAccount1 = TestClassUtility.createAccount(false, testBrand, testCategory, testMarket);
        Profile localsalesdatateamProfile = [SELECT Id FROM Profile WHERE Name='Local Sales Data Team'];
        User userTorun = [SELECT Id FROM User WHERE ProfileId = :localsalesdatateamProfile.Id limit 1];

        Account testAccount1 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount1.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount1.Name = 'testing ttesting name name';
        //testAccount1.Account_Status__c = 'New';
        insert testAccount1;
        List<Account> lstacc11 =[select id from Account where id=: testAccount1.id];
        system.assertEquals(1,lstacc11.size());

        System.runAs(userTorun) {

            testAccount1.Account_Status__c = 'Qualified';
            update testAccount1;
            List<Account> lstacc1 =[select id from Account where id=: testAccount1.id];
            system.assertEquals(1,lstacc1.size());

        }

        Test.stopTest();
    }     


    private static testmethod void test_callout() {
        create_TestData();

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account", "companyId" : "testdynamicleadid"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        XO_Group_Settings__c xoSetting = XO_Group_Settings__c.getInstance();
        xoSetting.Turn_on_Fulfillment_Callouts__c = true;
        upsert xoSetting;
        System.debug(LoggingLevel.INFO, '*** limits.getQueries 1: ' + limits.getQueries());


        CountryZipREGEX__c testCzr = TestClassUtility.createContryZipREGEX(true,'United States','US');

        DefaulCBSSValues__c defCBSScustomSetting = new DefaulCBSSValues__c();
        defCBSScustomSetting.Name = 'testInvoiceTemplate';
        defCBSScustomSetting.Phone__c = '(800)843-4983';
        defCBSScustomSetting.Email__c = 'test@xogrp.com';
        insert defCBSScustomSetting;      

        Lead_and_Account_Scoring__c laas = new Lead_and_Account_Scoring__c();
        laas.Name = 'Name Not Blank';
        laas.Apply_to_Lead_Score__c = true;
        laas.Comparison_Type__c = 'Not Blank';
        laas.Points__c = 5;
        laas.Apply_to_Account_Score__c = true;
        laas.Field_API_Name__c = 'Name';
        insert laas; 

        Test.startTest();
        
        Account testAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAcc.BillingStreet = '100 Pennock Court';
        testAcc.BillingCity = 'Folsom';
        testAcc.BillingState = 'California';
        testAcc.BillingPostalCode = zip.zipCode__c + '1';
        testAcc.BillingCountry = 'United States';
        testAcc.Region__c = 'Austin/Central Texas/Texas Hill Country';
        testAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAcc.OwnerId = userList[0].Id;
        testAcc.Name = 'testing name';
        testAcc.Fulfill_Storefront__c = false;
        // testAcc.Past_Due_Balance__c = 12.34;
        insert testAcc;
        List<Account> lstacc1 =[select id from Account where id=: testAcc.id];
        system.assertEquals(1,lstacc1.size());
  
        Account testParentAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testParentAcc.DynamicsAccID__c = 'testParentAccID';
        testParentAcc.Fulfill_Storefront__c = true;
        insert testParentAcc;
        List<Account> lstacc2 =[select id from Account where id=: testParentAcc.id];
        system.assertEquals(1,lstacc2.size());

        Account testParentAcc2 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testParentAcc2.DynamicsAccID__c = 'testParentAccID2';
        insert testParentAcc2;
        List<Account> lstacc3 =[select id from Account where id=: testParentAcc2.id];
        system.assertEquals(1,lstacc3.size());

        Test.stopTest();

        testAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAcc.ParentId = null;
        testAcc.DynamicsAccID__c = testParentAcc.Id;
        //testAcc.Fulfill_Storefront__c = true;
        testAcc.Ignore_Parent_Account__c = false;
        update testAcc;

        testAcc.Ignore_Parent_Account__c = true; 
        update testAcc;

        testAcc.Storefront_Status__c = 'Claimed';
        testAcc.Fulfilled__c = true;
        testAcc.BillingPostalCode = zip.zipCode__c;
        update testAcc;

        testAcc.BillingPostalCode = '12345';
        testAcc.Ignore_Parent_Account__c = false; 
        testAcc.ParentId =testParentAcc2.Id;
        User u =[SELECT id FROM User WHERE Profile.Name = 'Local Sales Data Team' Limit 1];
        testAcc.OwnerId = u.id;
        update testAcc;      

        System.debug(LoggingLevel.INFO, '*** limit.getQueries 4: ' + limits.getQueries());

        Category__C testCategory2 = TestClassUtility.createCategory(true);

        Market__c testMarket2 = new Market__c();
        testMarket.Name = 'TX - Austin - 111';
        testMarket.Short_Description__c = 'TX-Austin';
        testMarket.Market_Id__c = '191';
        // testMarket2.Market_ID__c = '222';
        testMarket2.Active__c = true;
        testMarket2.Local_Sales_Region__c = testRegion.id;
        testMarket2.Short_Description__c = 'abc';
        insert testMarket2;
        List<Market__c> lstmarket1 =[select id from Market__c where id=: testMarket2.id];
        system.assertEquals(1,lstmarket1.size());

        testAcc.Primary_Category__c = testCategory2.Id;
        testAcc.Name = 'test Account';
        testAcc.Local_Sales_Market__c = testMarket2.Id;
        update testAcc;


}

    private static testmethod void test_cfullfillment() {

        create_TestData();




        Account testAccount2 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccount2.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAccount2.Fulfill_Storefront__c = true;
        testAccount2.DynamicsAccID__c = 'testDynamicsAccID';
        testAccount2.Ignore_Parent_Account__c = true;
        testAccount2.Strategy_Specialist__c = userlist[0].id;
        testAccount2.Manual_VIP_Program_Status__c = 'VIP';
        insert testAccount2;
        List<Account> lstacc111 =[select id from Account where id=: testAccount2.id];
        system.assertEquals(1,lstacc111.size());        


        Account testAccParent22 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAccParent22.DynamicsAccID__c = 'testParentAccID22';
        insert testAccParent22;

        Account testAcc3 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAcc3.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAcc3.ParentId = testAccParent22.Id;
        testAcc3.DynamicsAccID__c = testAccParent22.Id;
        testAcc3.Fulfill_Storefront__c = true;
        testAcc3.Ignore_Parent_Account__c = false;
        insert testAcc3;
        List<Account> lstacc1111 =[select id from Account where id=: testAcc3.id];
        system.assertEquals(1,lstacc1111.size());
        
        System.debug(LoggingLevel.INFO, '*** limits.getQueries 4: ' + limits.getQueries());



    }

    private static testmethod void test_accOwnerAssignment() {
        create_TestData();
   
        Account testParentAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testParentAcc.DynamicsAccID__c = 'testParentAccID';
        testParentAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        insert testParentAcc;
        List<Account> lstacc1 =[select id from Account where id=: testParentAcc.id];
        system.assertEquals(1,lstacc1.size());

        Account testAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAcc.ParentId = testParentAcc.Id;
        User u1 =[SELECT id FROM User WHERE Profile.Name = 'Local Sales Data Team' Limit 1];
        testAcc.OwnerId = u1.id;
        insert testAcc;
        List<Account> lstacc2 =[select id from Account where id=: testAcc.id];
        system.assertEquals(1,lstacc2.size());

        Test.startTest();

        Account testAcc2 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAcc2.OwnerId = userList[0].id;
        insert testAcc2;
        List<Account> lstacc3 =[select id from Account where id=: testAcc2.id];
        system.assertEquals(1,lstacc3.size());

        testAcc2.OwnerId = userList[1].Id;
        testAcc2.ParentId = null;
        update testAcc2;

        User u =[SELECT id FROM User WHERE Profile.Name = 'Local Sales Data Team' Limit 1];

        System.runAs(u){
            testAcc2.Account_Status__c = 'Disqualified';
            testAcc2.Negative_Disposition_Reason__c = 'Do Not Contact';
            update testAcc2;

            testAcc2.Account_Status__c = 'Qualified';
            update testAcc2;

            testAcc2.Account_Status__c = 'Disqualified';
            testAcc2.Negative_Disposition_Reason__c = 'Do Not Contact';
            update testAcc2;
            testAcc2.Related_to_Paid_Media__c = true;
            testAcc2.Account_Status__c = 'Qualified';
            update testAcc2;
        }

        Test.stopTest();

        AccountTriggerHandler ath = new AccountTriggerHandler();
        ath.beforeDelete(testParentAcc);
        ath.afterDelete(testParentAcc);
        Set<ID> deleteAccountIdSet = New Set<ID>();
        deleteAccountIdSet.add(testParentAcc.Id);
        ath.beforeAndFinally();
    }

    private static testmethod void test_beforeupdate() {
        create_TestData();
    
        userList[1].Strategy_Specialist__c = userlist[0].Id;
        userList[1].SOR__c = userlist[0].Id;
        userList[1].ARR__c = userlist[0].Id;
        //update userList[1];

        Account testParentAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testParentAcc.DynamicsAccID__c = 'testParentAccID';
        testParentAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testParentAcc.OwnerId = userList[0].Id;
        insert testParentAcc;
        List<Account> lstacc3 =[select id from Account where id=: testParentAcc.id];
        system.assertEquals(1,lstacc3.size());

        Account testAcc = TestClassUtility.createAccount(false, testCategory, testMarket);
        testAcc.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        testAcc.OwnerId = userList[1].Id;
        testAcc.CBBS__c = userList[0].Id;
        insert testAcc;
        List<Account> lstacc2 =[select id from Account where id=: testAcc.id];
        system.assertEquals(1,lstacc2.size());

        Test.startTest();

        Account testParentAcc2 = TestClassUtility.createAccount(false, testCategory, testMarket);
        testParentAcc2.DynamicsAccID__c = 'testParentId abc';
        testParentAcc2.RecordTypeId = rtAccountMapByName.get('Local').getRecordTypeId();
        User u2 =[SELECT id FROM User WHERE Profile.Name = 'Local Sales Data Team' Limit 1];
        testParentAcc2.OwnerId = u2.id;
        insert testParentAcc2;
        List<Account> lstacc1 =[select id from Account where id=: testParentAcc2.id];
        system.assertEquals(1,lstacc1.size());

        testAcc.ParentId = testParentAcc.Id;
        update testAcc;

        testAcc.ParentId = testParentAcc2.Id;
        update testAcc;

        Test.stopTest();

    }

    private static void create_TestData(){
      userList = [select Id, Name, Alias from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        rtAccountMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
        
        if(Deactivate_Trigger__c.getValues('Attachment') == null){
            dtatt = TestClassUtility.createAttachmentDeactivateTriggerSetting(true);
        }
        
        GQPF = TestClassUtility.generateQuotePdfConfig(false);
        GQPF.URL__c = 'www.baidu.com';
        insert GQPF;

        testRegion = TestClassUtility.createRegion(true);
        testMarket = TestClassUtility.createMarket(false);
        testMarket.Market_ID__c = '222';
        testMarket.Active__c = true;
        testMarket.Local_Sales_Region__c = testRegion.id;
        insert testMarket;

        testCategory = TestClassUtility.createCategory(true);
        
        ma = TestClassUtility.createMetroArea(true);
        
        zip = TestClassUtility.createZip(false);
        zip.MetroArea__c = ma.id;
        zip.ZipCode__c = '99999';
        zip.name = '12121';
        zip.Local_Market__c = testMarket.id;
        insert zip;
    }
}