@isTest
private class RESTLocalStorefrontAPITest {

    static testmethod void testNewLocationNoClaimingAccount(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
      
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
        Category__c testCategory = (Category__c)testObjects.get('Category__c');
        Market__c testMkt = (Market__c)testObjects.get('Market__c');

        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();


        reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = false;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = testMkt.Id;
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TXT';
        addressWrapper.country = 'Un';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        JsonMsg=JSON.serialize(reqst);
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();
    }

    static testmethod void testExistingLocationNewClaimingAccount_one(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        Market__c testMkt = TestClassUtility.createMarket(true, testRegion);

        Lead testLead = TestClassUtility.createLead(true, testMkt, testCategory);

        Account acc = TestClassUtility.createAccount(false, testCategory, testMkt);
        acc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        acc.DynamicsAccID__c = 'testdynamicleadid';
        acc.Fulfill_Storefront__c = true;
        insert acc;

        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = acc.DynamicsAccID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        System.debug(LoggingLevel.INFO, '*** reqst: ' + reqst);

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront'; 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();


        Test.stopTest();
    }

    public static List<Lead> testDataSetup(Integer numberOfLeads) {
        
        Market__c testMarket = TestClassUtility.createMarket(false);
        testMarket.Active__c = true;
        insert testMarket;

        Category__c testCategory = TestClassUtility.createCategory(false);
        testCategory.Category_Group__c = 'Primary';
        testCategory.Active__c = true;
        testCategory.Name = 'Reception Venues - REC';
        insert testCategory;

        List<Lead> newLeadsList = new List<Lead>();

        for(Integer index=0; index < numberOfLeads; index++) {
            newLeadsList.add(TestClassUtility.createLead(false, testMarket, testCategory));
        }
        return newLeadsList;
    }

    static testmethod void testExistingLocationNewClaimingAccount_two(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Category__c testCategory = TestClassUtility.createCategory(true);

        List<Lead> testLeadsList = testDataSetup(1);
        Lead leadRec = testLeadsList[0];
        leadRec.Website = 'www.spacexone.com';
        leadRec.Phone = '3453453456';
        leadRec.Email = 'goforit@gmail.com';
        insert leadRec;

        Test.startTest();

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadRec.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());

        Event evnt = new Event(WhoId = leadRec.Id, Subject = 'Test Lead Conversion');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());  

        Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
        GQPF.URL__c = 'www.baidu.com';
        insert GQPF;

        

        Account testAccount02 = [SELECT Id, DynamicsAccID__c FROM Account WHERE id = : lcr.getAccountId()];
        testAccount02.DynamicsAccID__c = 'changeTestDynamicId 01';
        update testAccount02;            

        Test.stopTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = leadRec.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        System.debug(LoggingLevel.INFO, '*** reqst: ' + reqst);

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();
 
        reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = leadRec.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        System.debug(LoggingLevel.INFO, '*** reqst 2: ' + reqst);

        addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg2=JSON.serialize(reqst);

        req.requestBody = Blob.valueOf(JsonMsg2);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();     
    }

    static testmethod void testNewLocationWithClaimingAccount_one(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];

        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
        Category__c testCategory = (Category__c)testObjects.get('Category__c');
        Market__c testMkt = (Market__c)testObjects.get('Market__c');
        Account testAcc = (Account)testObjects.get('Account');

        Test.startTest();

        Lead testLead = TestClassUtility.createLead(true, testMkt, testCategory);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = testAcc.DynamicsAccID__c;//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();
    }

    static testmethod void testExistingLocationWithClaimingAccount_three(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Account testAcc = TestClassUtility.createAccount(false, testCategory, testMkt);
        testAcc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        insert testAcc;

        System.debug(LoggingLevel.INFO, '*** Limits 01: ' + Limits.getQueries());

        Test.startTest();

        Account testAcc2 = TestClassUtility.createAccount(false);
        testAcc2.ParentId = testAcc.Id;
        testAcc2.DynamicsAccID__c = 'testdynamicleadid';
        testAcc2.Fulfill_Storefront__c = true;
        testAcc2.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        testAcc2.Primary_Category__c = testCategory.Id;
        testAcc2.Local_Sales_Market__c = testMkt.Id;
        insert testAcc2;

        Contact testContact = TestClassUtility.createContact(true, testAcc2);
        AccountContactRole acr = TestClassUtility.createAccountContactRole(true, testAcc, testContact);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();


        Test.stopTest();
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = testAcc2.DynamicsAccID__c;
        reqst.locationId = 'testDid01';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = 'Limited';
        reqst.isClaiming = false;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TXX';
        addressWrapper.country = 'US';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();


        reqst.fulfillmentData.tier = 'Standard'; 
        reqst.address.add(AddressWrapper);
        String JsonMsg2=JSON.serialize(reqst); 
        req.requestBody = Blob.valueOf(JsonMsg2);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();        
        
        reqst.fulfillmentData.tier = 'Featured'; 
        reqst.address.add(AddressWrapper);
        String JsonMsg3=JSON.serialize(reqst); 
        req.requestBody = Blob.valueOf(JsonMsg3);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();               

        reqst.fulfillmentData.tier = 'Contact Us'; 
        reqst.address.add(AddressWrapper);
        String JsonMsg4=JSON.serialize(reqst); 
        req.requestBody = Blob.valueOf(JsonMsg4);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();                
    }

    static testmethod void testNewLocationNoClaimingAccount_two(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];

        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
        Category__c testCategory = (Category__c)testObjects.get('Category__c');
        Market__c testMkt = (Market__c)testObjects.get('Market__c');

        Test.startTest();

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.DynamicsLeadID__c = 'testDyId01';
        testLead.Email = 'test@test.com';
        testLead.PostalCode = '85474';
        testLead.Phone = '(123)456-7890';
        insert testLead;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();


        reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = false;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = testMkt.Id;
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TXT';
        addressWrapper.country = 'Un';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        JsonMsg=JSON.serialize(reqst);
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();
    }

    static testmethod void testExistingLocationNewClaimingAccount_three(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        TestClassUtility.DISABLE_TRIGGERS = true;
        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.DynamicsLeadID__c = 'testDyId01';
        testLead.Email = 'abc@test.com';
        testLead.PostalCode = '94104';
        testLead.Company = 'Testing Company';
        testLead.Phone = '(123)456-7890';
        insert testLead;
        
        Account acc = TestClassUtility.createAccount(false, testCategory, testMkt);
        acc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        acc.DynamicsAccID__c = 'testdynamicleadid';
        acc.Fulfill_Storefront__c = true;
        insert acc;
        TestClassUtility.DISABLE_TRIGGERS = false;
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = 'testDyId02';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'abc@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'Testing Company';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        System.debug(LoggingLevel.INFO, '*** reqst: ' + reqst);

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '94104';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront'; 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();
    }

    static testmethod void testExistingLocationNewClaimingAccount_Four(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        TestClassUtility.DISABLE_TRIGGERS = true;
        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.DynamicsLeadID__c = 'testDyId01';
        testLead.Email = 'abc@test.com';
        testLead.PostalCode = '94104';
        testLead.Company = 'Testing Company';
        testLead.Phone = '(123)456-7890';
        insert testLead;
        
        Account acc = TestClassUtility.createAccount(false, testCategory, testMkt);
        acc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        acc.DynamicsAccID__c = 'testdynamicleadid';
        acc.Fulfill_Storefront__c = true;
        insert acc;
        TestClassUtility.DISABLE_TRIGGERS = false;
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';//testLead.DynamicsLeadID__c;
        reqst.locationId = 'testDyId03';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(345)777-7890';
        reqst.email = 'test001@test.com';
        reqst.contact.lastName = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'Testing Company';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        System.debug(LoggingLevel.INFO, '*** reqst: ' + reqst);

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '12345';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg2=JSON.serialize(reqst);


        req.requestBody = Blob.valueOf(JsonMsg2);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();         

        Test.stopTest();
    }

    static testmethod void testNewLocationWithClaimingAccount_two(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];

        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
        Category__c testCategory = (Category__c)testObjects.get('Category__c');
        Market__c testMkt = (Market__c)testObjects.get('Market__c');
        Account testAcc = (Account)testObjects.get('Account');

        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = testAcc.DynamicsAccID__c;//testLead.DynamicsLeadID__c;
        reqst.locationId = '';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        reqst.contact.firstName = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttest';
        String JsonMsg2=JSON.serialize(reqst);
        req.requestBody = Blob.valueOf(JsonMsg2);
        RestContext.request = req;    
        responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();    

        Test.stopTest();
    }

    static testmethod void testExistingLocationWithClaimingAccount_four(){

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Account testAcc = TestClassUtility.createAccount(false, testCategory, testMkt);
        testAcc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        insert testAcc;

        System.debug(LoggingLevel.INFO, '*** Limits 01: ' + Limits.getQueries());

        Test.startTest();

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.PostalCode = '85474';
        testLead.Email = 'test@test.com';
        testLead.Phone = '(123)456-7890';
        insert testLead;

        Account testAcc2 = TestClassUtility.createAccount(false);
        testAcc2.ParentId = testAcc.Id;
        testAcc2.DynamicsAccID__c = 'testdynamicleadid';
        testAcc2.Fulfill_Storefront__c = true;
        testAcc2.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        testAcc2.Primary_Category__c = testCategory.Id;
        testAcc2.Local_Sales_Market__c = testMkt.Id;
        insert testAcc2;

        Contact testContact = TestClassUtility.createContact(true, testAcc2);
        AccountContactRole acr = TestClassUtility.createAccountContactRole(true, testAcc, testContact);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();


        Test.stopTest();
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = testAcc2.DynamicsAccID__c;
        reqst.locationId = 'testdynamicleadid01';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = false;
        reqst.phone = '(123)456-7890';
        reqst.email = 'test@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'testcompanyName';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '85474';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'US';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg=JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront';  //Request URL
        req.httpMethod = 'Post';//HTTP Request Type
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();              
    }

    static testmethod void testPopulateLeadSource_Blank(){
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [SELECT Id, Name FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true LIMIT 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.DynamicsLeadID__c = 'testDyId01';
        testLead.Email = 'abc@test.com';
        testLead.PostalCode = '94104';
        testLead.Company = 'Testing Company';
        testLead.Phone = '(123)456-7890';
        testLead.LeadSource = null;
        testLead.Lead_Sub_Source__c = null;
        insert testLead;
        
        Account acc = TestClassUtility.createAccount(false, testCategory, testMkt);
        acc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        acc.DynamicsAccID__c = 'testdynamicleadid';
        acc.Fulfill_Storefront__c = true;
        insert acc;

        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';
        reqst.locationId = 'testDyId01';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = 'Standard';
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'abc@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'Testing Company';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '94104';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg = JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront'; 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();

        List<Lead> listLeadAssert = [SELECT LeadSource, Lead_Sub_Source__c FROM Lead WHERE DynamicsLeadID__c = 'testDyId01'];
        System.assert(!listLeadAssert.isEmpty());
        System.assertEquals('Website', listLeadAssert[0].LeadSource);
        System.assertEquals('Standard', listLeadAssert[0].Lead_Sub_Source__c);
    }

    static testmethod void testPopulateLeadSource_NotBlank(){
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 '{"companyName": "Test Account"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        List<User> userList = [SELECT Id, Name FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true LIMIT 2];
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Region__c testRegion = TestClassUtility.createRegion(true);
        Category__c testCategory = TestClassUtility.createCategory(true);
        Market__c testMkt = TestClassUtility.createMarket(false, testRegion);
        testMkt.Market_ID__c = '222';
        insert testMkt;

        Lead testLead = TestClassUtility.createLead(false, testMkt, testCategory);
        testLead.DynamicsLeadID__c = 'testDyId01';
        testLead.Email = 'abc@test.com';
        testLead.PostalCode = '94104';
        testLead.Company = 'Testing Company';
        testLead.Phone = '(123)456-7890';
        testLead.LeadSource = 'Screen Scraping';
        testLead.Lead_Sub_Source__c = 'Apple Brides';
        insert testLead;
        
        Account acc = TestClassUtility.createAccount(false, testCategory, testMkt);
        acc.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
        acc.DynamicsAccID__c = 'testdynamicleadid';
        acc.Fulfill_Storefront__c = true;
        insert acc;

        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = '';
        reqst.locationId = 'testDyId01';
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = 'Standard';
        reqst.isClaiming = true;
        reqst.phone = '(123)456-7890';
        reqst.email = 'abc@test.com';
        reqst.contact.lastName = 'test';
        reqst.contact.firstName = 'Lead';
        reqst.companyName = 'Testing Company';
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = testCategory.Taxonomy_Id__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = 'teststreet1';
        addressWrapper.street2 = 'teststreet2';
        addressWrapper.postalCode = '94104';
        addressWrapper.stateOrProvince = 'TX';
        addressWrapper.country = 'United States';
        addressWrapper.city = 'Austin';
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);
        String JsonMsg = JSON.serialize(reqst);

        req.requestURI = '/services/apexrest/LocalStorefront'; 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonMsg);
        RestContext.request = req;
        RESTLocalStorefrontAPI.LeadSubmissionResponse responseMessage = RESTLocalStorefrontAPI.storefrontFromPartner();

        Test.stopTest();

        List<Lead> listLeadAssert = [SELECT LeadSource, Lead_Sub_Source__c FROM Lead WHERE DynamicsLeadID__c = 'testDyId01'];
        System.assert(!listLeadAssert.isEmpty());
        System.assertEquals('Screen Scraping', listLeadAssert[0].LeadSource);
        System.assertEquals('Apple Brides', listLeadAssert[0].Lead_Sub_Source__c);
    }
}