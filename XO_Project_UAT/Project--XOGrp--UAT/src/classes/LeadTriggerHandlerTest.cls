@isTest
private class LeadTriggerHandlerTest {
    
    //static testMethod void testMethod1() {    
    //    // Implement test code
        
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    List<Zip__c> zipList = new List<Zip__c>();

    //    Zip__c zip = TestClassUtility.createZip(false);
    //    zip.MetroArea__c = ma.id;
    //    zip.ZipCode__c = '12121';
    //    Zip.name = '12121';
    //    zipList.add(zip);
        
    //    Zip__c zip1 = TestClassUtility.createZip(false);
    //    zip1.MetroArea__c = ma.id;
    //    zip1.ZipCode__c = '12123';
    //    Zip1.name = '12123';
    //    zipList.add(zip1);

    //    insert zipList;
                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Market_ID__c = '222'; //Shashish: Market Id 222 is hardcoded in LeadLocalTriggerhandler
    //    testMarket.Active__c = true;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.RecordTypeId = rtCategoryMapByName.get('Local').getRecordTypeId();
    //    testCategory.Category_Group__c = 'Primary';
    //    testCategory.Active__c = true;
    //    testCategory.Name = 'Reception Venues - REC';

    //    insert testCategory;
            
    //    Test.startTest();
        
    //    List<Local_Sales_Rep_Assignment__c> localSalesRepAssignmentList = new List<Local_Sales_Rep_Assignment__c>();
        
    //    Local_Sales_Rep_Assignment__c lsra = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, testMarket, null);
    //    Local_Sales_Rep_Assignment__c lsra1 = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, null, zipList[0]);
    //    Local_Sales_Rep_Assignment__c  lsra2 = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, testMarket, null);
    //    Local_Sales_Rep_Assignment__c  lsra3 = TestClassUtility.createLocalSalesRepAssignment(false, null, testMarket, null);
    //    Local_Sales_Rep_Assignment__c  lsra4 = TestClassUtility.createLocalSalesRepAssignment(false, null, null, zipList[1]);
    //    Local_Sales_Rep_Assignment__c  lsra5 = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, null, null);
    //    localSalesRepAssignmentList.add(lsra);
    //    localSalesRepAssignmentList.add(lsra1);
    //    localSalesRepAssignmentList.add(lsra2);
    //    localSalesRepAssignmentList.add(lsra3);
    //    lsra4.Sales_Rep__c = null;
    //    lsra4.Lead_Distribution_Queue_Id__c = UserInfo.getUserId();
    //    localSalesRepAssignmentList.add(lsra4);
    //    lsra5.Sales_Rep__c = null;
    //    lsra5.Lead_Distribution_Queue_Id__c = UserInfo.getUserId();
    //    localSalesRepAssignmentList.add(lsra5);
    //    insert localSalesRepAssignmentList;


    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testLead.PostalCode = '90034';
    //    testLead.LeadSource = 'Inbound Phone';
    //    testLead.State = 'California';
    //    testLead.City = 'los angeles';
    //    testLead.Street = 'ssdfgsf';
    //    testLead.Country = 'United States';
    //    testLead.Status = 'New';
    //    testLead.Email = 'abc@xyz.com';
    //    testLead.Website = 'sdfsd.com';
    //    testLead.Phone = '1234567890';
    //    testLead.Company = 'sfsdf';
    //    testLead.FirstName = 'Inbound';
    //    testLead.LastName = 'Phone';
    //    testLead.Primary_Category__c = testCategory.Id;
    //    testLead.Local_Sales_Market__c = testMarket.Id;
    //    insert testLead;
        
    //    delete testLead;

    //    Test.stopTest();
    //}
    
    //@isTest static void testMethod2() {
    //    // Implement test code 
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        

    //    //  if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');         
    //    // }
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);

                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Market__c testMarket2 = New Market__c();
    //    testMarket2.Name = 'TX - Austin - 123';
    //    testMarket2.Short_Description__c = 'TX-Austin';
    //    testMarket2.Market_Id__c = '123';
    //    testMarket2.Active__c = true;
    //    testMarket2.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket2;

    //    Category__c testCategory = TestClassUtility.createCategory(true);
        
    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c testZip = TestClassUtility.createZip(false);
    //    testZip.MetroArea__c = ma.id;
    //    testZip.ZipCode__c = '94230';
    //    testZip.name = '94230';
    //    testZip.Local_Market__c = testMarket.id;
    //    testZip.Portfolio__c = 'Senior Sales Executive';
    //    testZip.City__c = 'AUSTIN';
    //    testZip.State__c = 'Texas';
    //    insert testZip;

    //    Zip__c testZip2 = TestClassUtility.createZip(false);
    //    testZip2.MetroArea__c = ma.id;
    //    testZip2.ZipCode__c = '12580';
    //    testZip2.name = '12580';
    //    testZip2.Local_Market__c = testMarket2.id;
    //    testZip2.Portfolio__c = 'Senior Sales Executive';
    //    testZip2.City__c = 'AUSTIN';
    //    testZip2.State__c = 'Texas';
    //    insert testZip2;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';  
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
                
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.DynamicsLeadID__c = 'testDynamicsLeadID';
    //    testLead.Salesforce_Generated_GUID__c = true;
    //    testLead.Status = 'Qualified';
    //    testLead.Storefront_Status__c = 'Unclaimed';
    //    testLead.Country = 'United States';
    //    //testLead.State  = 'AK';
    //    testLead.City = 'US2';
    //    testLead.Street = 'US3';
    //    testLead.Phone= '1234567895';
    //    testLead.Email='abc@abc.com';
    //    testLead.Website = 'www.abc.com';
    //    testLead.PostalCode = testZip.ZipCode__c;
    //    testLead.CountryCode = 'US';
    //    testLead.Salesforce_Generated_GUID__c = true;
    //    insert testLead;

    //    Test.startTest();

    //    testLead.LocalSalesMarket__c= 'AK - Alaska';
    //    testLead.Status = 'Qualified';
    //    testLead.Storefront_Status__c = 'Claimed';
    //    testLead.DynamicsLeadID__c = 'changeTestDynamicsLeadID';
    //    testLead.PostalCode = testZip2.ZipCode__c;
    //    testLead.Phone_Extension__c = '1234567';
    //    testLead.Website = 'www.123.com';
    //    update testLead;

    //    testLead.DynamicsLeadID__c = '';
    //    testLead.Fulfill_Storefront__c = false;
    //    testLead.PostalCode = '';
    //    update testLead;


    //    Test.stopTest();
        
    //}
    
    //@isTest static void testMethod3(){

    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();

    //    Region__c testRegion = TestClassUtility.createRegion(true);        

    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Market_ID__c = '222';
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(true);
        
    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c zip = TestClassUtility.createZip(false);
    //    zip.MetroArea__c = ma.id;
    //    zip.ZipCode__c = '12121';
    //    Zip.name = '12121';
    //    Zip.Local_Market__c = testMarket.id;
    //    insert zip;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';   
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
            
    //    Test.startTest();
       
    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.DynamicsLeadID__c = 'testDynamicsLeadID';
    //    testLead.Status = 'Valid';
    //    testLead.Salesforce_Generated_GUID__c = true;
    //    testLead.IsConverted = false;
    //    testLead.Storefront_Status__c = 'Claimed';
    //    testLead.LeadSource  = 'Internal Referral';
    //    testLead.PostalCode = '12121';
    //    testLead.Primary_Category__c = testCategory.Id;
    //    testLead.Local_Sales_Market__c = testMarket.Id;
    //    testLead.CountryCode = 'US';
    //    testLead.Country = 'United States';
    //    testLead.State  = 'Alaska';
    //    testLead.City = 'US2';
    //    testLead.Street = 'US3';
    //    testLead.Phone = '1234567895';
    //    testLead.Website  = 'ttt.com';
    //    insert testLead;

    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    FeedItem testFeed = New FeedItem();
    //    testFeed.ParentId = testlead.id;
    //    testFeed.Title = 'test title';
    //    testFeed.Body = 'Hello';
    //    testFeed.LinkUrl = 'www.abc123.com';
    //    insert testFeed;
        
    //    Database.LeadConvert lc = new database.LeadConvert();
    //    lc.setLeadId(testLead.id);
    //    lc.setDoNotCreateOpportunity(false);
    //    lc.setConvertedStatus('Qualified');
    //    lc.setOwnerId(UserInfo.getUserId());
    //    Database.LeadConvertResult lcr = Database.convertLead(lc);
    //    System.assert(lcr.isSuccess());

    //    Endorsement__c testEndorsementObj = new Endorsement__c();
    //    testEndorsementObj.Name = 'TestEndorsement';
    //    testEndorsementObj.Account__c = lcr.getAccountId();
    //    testEndorsementObj.Type__c = 'Internet Endorsement';
    //    testEndorsementObj.Lead__c = testLead.Id;
    //    insert testEndorsementObj;
        


    //    Test.stopTest();
    //}
    
    //@isTest static void testMethod4() {
    //    // Implement test code
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
    //    if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');
    //    }
        
    //    XO_Group_Settings__c xoSetting = XO_Group_Settings__c.getInstance();
    //    xoSetting.Turn_on_Fulfillment_Callouts__c = true;
    //    upsert xoSetting;
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);       
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Market_ID__c = '222';
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;
        
    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Name = 'Bridal Salons - BWP';
    //    insert testCategory;
    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    List<Zip__c> zipList = new List<Zip__c>();
    //    // List<Marketplace_Health__c> MSList = new List<Marketplace_Health__c>();
    //    List<Lead> LeadList = new List<Lead>();
        
    //    Zip__c zip = TestClassUtility.createZip(false);
    //    zip.MetroArea__c = ma.id;
    //    zip.ZipCode__c = '12121';
    //    Zip.name = '12121';
    //    Zip.Local_Market__c = testMarket.id;
    //    zipList.add(zip);
        
    //    Zip__c zip1 = TestClassUtility.createZip(false);
    //    zip1.MetroArea__c = ma.id;
    //    zip1.ZipCode__c = '12122';
    //    Zip1.name = '12122';
    //    Zip1.Local_Market__c = testMarket.id;
    //    zipList.add(zip1);

    //    Zip__c zip2 = TestClassUtility.createzip(false);
    //    zip2.MetroArea__c = ma.id;
    //    zip2.ZipCode__c = '12123';
    //    Zip2.name = '12123';
    //    Zip2.Local_Market__c = testMarket.id;
    //    zip2.Portfolio__c = 'Senior Sales Executive';
    //    zipList.add(zip2);
        
    //    insert zipList;
        
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.DynamicsLeadID__c = 'testDynamicsLeadID';
    //    testLead.Salesforce_Generated_GUID__c = true;
    //    testLead.IsConverted = false;
    //    testLead.Status = 'Qualified';
    //    testLead.Storefront_Status__c = 'Unclaimed';
    //    testLead.PostalCode = '12121';
    //    testLead.Country = null;
    //    testLead.CountryCode = 'US';
    //    testLead.State  = null;
    //    testLead.City = null;
    //    testLead.Street = null;
    //    testLead.Website  = 'ttt.com';
    //    insert testLead;

    //    Category__c masonCategory = TestClassUtility.createCategory(false);
    //    masonCategory.Category_Code__c = 'ACC';
    //    masonCategory.RecordTypeId = rtCategoryMapByName.get('Local').getRecordTypeId();
    //    masonCategory.Category_Group__c = 'Primary';
    //    masonCategory.Active__c = true;
    //    masonCategory.Name = 'Reception Venues - REC';
    //    insert masonCategory;

    //    Test.startTest();

    //    Lead testlead2 = TestClassUtility.createLead(false);
    //    testlead2.Country = 'United States';
    //    testlead2.CountryCode = 'US';
    //    testlead2.PostalCode = '12345';
    //    testlead2.Primary_Category__c = masonCategory.id;
    //    testlead2.LeadSource = 'Inbound Phone';
    //    testlead2.State = 'California';
    //    testlead2.City = 'los angeles';
    //    testlead2.Street = 'ssdfgsf';
    //    testlead2.Status = 'New';
    //    testlead2.Email = 'abc@xyz.com';
    //    testlead2.Website = 'sdfsd.com';
    //    testlead2.Phone = '1234567890';
    //    testlead2.Company = 'sfsdf';
    //    testlead2.FirstName = 'Inbound';
    //    testlead2.LastName = 'Phone';
    //    testlead2.Local_Sales_Market__c = testMarket.Id;
    //    //testlead2.Invalid_Reason__c = 'No contact information';
    //    testlead2.Negative_Disposition_Reason__c = 'No contact information';
    //    insert testLead2;
        
    //    testlead2.PostalCode = zip1.ZipCode__c;
    //    update testlead2;

    //    testlead2.Local_Sales_Market__c = null;
    //    testlead2.PostalCode = '90034';
    //    update testlead2;

    //    testlead2.Status = 'New';
    //    testlead2.LeadSource = 'Other';
    //    update testlead2;

    //    testlead2.Status = 'Invalid';
    //    testlead2.Negative_Disposition_Reason__c = 'Out of Business';
    //    update testlead2;

    //    testlead2.Status = 'New';
    //    update testlead2;

    //    testlead2.Status = 'Qualified';
    //    testlead2.Local_Sales_Market__c = testMarket.Id;
    //    testlead2.Local_Partners_Claiming__c = true;
    //    update testlead2; 

    //    testlead2.Status = 'Disqualified';
    //    testlead2.Negative_Disposition_Reason__c = 'Do Not Contact';
    //    testlead2.Reason_Details__c = 'test reason tedails';
    //    testlead2.Related_to_Paid_Media__c = false;
    //    update testlead2; 

    //    testlead2.Negative_Disposition_Reason__c = 'Bad Contact';
    //    update testlead2; 

    //    testlead2.Status  = 'Valid';
    //    testlead2.Negative_Disposition_Reason__c = null;
    //    testLead2.Reason_Details__c = null;
    //    testLead2.Related_to_Paid_Media__c = true;
    //    update testlead2;

    //    testlead2.Status  = 'Invalid';
    //    testlead2.Negative_Disposition_Reason__c = 'Duplicate';
    //    testlead2.PreviousOwner__c = UserInfo.getUserId();
    //    update testlead2;

    //    Test.stopTest();     
    //}

    //@isTest static void testMethod5(){

    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Category_Code__c = 'ACC';
    //    testCategory.RecordTypeId = rtCategoryMapByName.get('Local').getRecordTypeId();
    //    testCategory.Category_Group__c = 'Primary';
    //    testCategory.Active__c = true;
    //    testCategory.Name = 'Reception Venues - REC';
    //    insert testCategory;

    //    Region__c testRegion = TestClassUtility.createRegion(true); 
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.Country = 'Canada';
    //    testLead.State = 'Alberta';
    //    testLead.Phone_Extension__c = '1234567';
    //    testLead.Invalid_Reason__c = 'No Contact Information';
    //    testLead.Status = 'New';
    //    testLead.City = 'los angeles';
    //    testLead.Street = 'ssdfgsf';
    //    testLead.RecordTypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.Website  = 'ttt.com';
    //    insert testLead; 


    //    Test.startTest();

    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);

    //    Lead testLead2 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead2.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead2.DynamicsLeadID__c = '';
    //    testLead2.Salesforce_Generated_GUID__c = true;
    //    testLead2.IsConverted = false;
    //    testLead2.Status = 'Qualified';
    //    testLead2.Storefront_Status__c = 'Unclaimed';
    //    testLead2.PostalCode = '12321';
    //    testLead2.Country = null;
    //    testLead2.CountryCode = 'US';
    //    testLead2.State  = null;
    //    testLead2.City = null;
    //    testLead2.Street = null;
    //    testlead2.Local_Partners_Claiming__c = true;
    //    testlead2.Potential_Duplicates__c = 'test Potential Duplicates';
    //    testLead2.Website  = 'ttt.com';
    //    insert testLead2;

    //    Lead testlead3 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead3.Status = 'Qualified';  
    //    testLead3.PostalCode = '12322'; 
    //    //testlead3.Negative_Disposition_Reason__c = 'Duplicate';
    //    testLead3.Website  = 'ttt.com';
    //    insert testLead3;

    //    Test.stopTest();  

    //    LeadTriggerHandler lth = new LeadTriggerHandler();
    //    lth.afterDelete(testlead3);
    //    lth.andFinally();


    //}

    //@isTest static void testMethod6() {
    //    // Implement test code
                
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
    //    if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');         
    //    }
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);
                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Category_Group__c = 'Secondary';
    //    insert testCategory;


    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c testzip = TestClassUtility.createZip(false);
    //    testzip.MetroArea__c = ma.id;
    //    testzip.ZipCode__c = '94230';
    //    testzip.name = '94230';
    //    testzip.Local_Market__c = testMarket.id;
    //    testzip.Portfolio__c = 'Senior Sales Executive';
    //    insert testzip;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';  
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
                
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;
 
    //    Test.startTest();

    //    TriggerHandlerAccess__c tha = TestClassUtility.createTriggerHandlerAccessSetting(true, 'Lead', 'LeadTriggerHandler');

    //    User u = [SELECT id FROM user WHERE UserRole.Name LIKE '%Sales Representative%' and isActive = true Limit 1];
    //    System.runAs(u){
    //        Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //        testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //        testLead.Status = 'New';
    //        testLead.LeadSource = 'Self Prospecting';
    //        testLead.Website  = 'ttt.com';
    //        // testLead.OwnerId = groupMenberIDList[0];
    //        insert testLead;
    //    }

    //    testCategory.Category_Group__c = 'Primary';
    //    update testCategory;
    //    User u2 = [SELECT id FROM user WHERE UserRole.Name LIKE '%Sales Representative%' and isActive = true Limit 1];
    //    System.runAs(u2){
    //        Lead testLead2 = TestClassUtility.createLead(false, testMarket, testCategory);
    //        testLead2.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //        testLead2.Status = 'New';
    //        testLead2.LeadSource = 'Self Prospecting';

    //        testLead2.PostalCode = '12123';
    //        // testLead2.Country = 'United States';
    //        // testLead2.LeadSource = 'Website';
    //        testLead2.City = 'test City';
    //        testLead2.State = 'Texas';
    //        testLead2.Phone = '1234569999';
    //        testLead2.Website  = 'ttt.com';
    //        insert testLead2;
    //    }


    //   Test.stopTest();

    //}

    //@isTest static void testMethod7() {
    //    // Implement test code
                
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
    //    if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');         
    //    }
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);
                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Category_Group__c = 'Secondary';
    //    // testCategory.Name = 'Bridal Salons - BWP';
    //    testCategory.Name = 'Beauty - BEA';
    //    insert testCategory;

    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c testzip = TestClassUtility.createZip(false);
    //    testzip.MetroArea__c = ma.id;
    //    testzip.ZipCode__c = '94230';
    //    testzip.name = '94230';
    //    testzip.Local_Market__c = testMarket.id;
    //    testzip.Portfolio__c = 'Senior Sales Executive';
    //    insert testzip;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';  
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
                
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;

    //    Test.startTest();

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.Status = 'New';
    //    testLead.LeadSource = 'Other';
    //    testLead.PostalCode = testZip.ZipCode__c;
    //    testLead.Website  = 'ttt.com';
    //    insert testLead;

    //    Lead testLead2 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead2.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead2.Status = 'New';
    //    testLead2.LeadSource = 'Other';
    //    testLead2.Website  = 'ttt.com';
    //    insert testLead2;

    //    Lead testLead3 = TestClassUtility.createLead(false);
    //    testLead3.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead3.Status = 'Valid';
    //    testLead3.LeadSource = 'Other';
    //    testLead3.Primary_Category__c = testCategory.Id;
    //    testLead3.PostalCode = '12451';
    //    testLead3.Phone = '1239876541';
    //    testLead3.Website  = 'ttt.com';
    //    insert testLead3;

    //    Lead testLead4 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead4.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead4.Status = 'Valid';
    //    testLead4.LeadSource = 'Reviews';
    //    testLead4.PostalCode = testZip.ZipCode__c;
    //    testLead4.Phone = '5432112345';
    //    testLead4.Website  = 'sdkjfsdk.com';
    //    testLead4.FirstName = 'kdjfsdkjfs';
    //    testLead4.LastName = 'sdfsfgs';
    //    insert testLead4;

    //    Lead testLead5 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead5.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead5.Status = 'Valid';
    //    testLead5.LeadSource = 'Other';
    //    testLead5.Phone = '6129873541';
    //    testLead5.PostalCode = '13651';
    //    testLead5.Website  = 'ttt.com';
    //    insert testLead5;

    //    Test.stopTest();

    //}


    //@isTest static void testMethod8() {
    //    // Implement test code
                
    //    SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
    //    if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');         
    //    }
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);
                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Category_Group__c = 'Secondary';
    //    testCategory.Name = 'Bridal Salons - BWP';
    //    insert testCategory;

    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c testzip = TestClassUtility.createZip(false);
    //    testzip.MetroArea__c = ma.id;
    //    testzip.ZipCode__c = '94230';
    //    testzip.name = '94230';
    //    testzip.Local_Market__c = testMarket.id;
    //    testzip.Portfolio__c = 'Senior Sales Executive';
    //    insert testzip;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';  
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
                
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;

    //    Test.startTest();

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.Status = 'New';
    //    testLead.LeadSource = 'Other';
    //    testLead.PostalCode = testZip.ZipCode__c;
    //    testLead.Website  = 'ttt.com';
    //    insert testLead;

    //    Lead testLead2 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead2.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead2.Status = 'New';
    //    testLead2.LeadSource = 'Other';
    //    testLead2.Website  = 'ttt.com';
    //    insert testLead2;

    //    Test.stopTest();

    //}

    //@isTest static void testMethod9() {
    //    // Implement test code
                
    //   List<XO_Exception__c> exceptionList = new List<XO_Exception__c>();
    //   SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
    //                                             'Complete',
    //                                             '{"companyName": "Test Account"}',
    //                                             null);
    //    Test.setMock(HttpCalloutMock.class, fakeResponse);
        
    //    Map<String,Schema.RecordTypeInfo> rtLeadMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtCategoryMapByName = Schema.SObjectType.Category__c.getRecordTypeInfosByName();
        
    //    List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true limit 2];
    //    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //    Map<String,Schema.RecordTypeInfo> rtOppMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
    //    if(CountryZipREGEX__c.getValues('United States') == null){
    //        CountryZipREGEX__c czr = TestClassUtility.createContryZipREGEX(true, 'United States', 'US');         
    //    }
        
    //    Generate_Quote_Pdf_Config__c GQPF = TestClassUtility.generateQuotePdfConfig(false);
    //    GQPF.URL__c = 'www.baidu.com';
    //    insert GQPF;

    //    Region__c testRegion = TestClassUtility.createRegion(true);
                
    //    Market__c testMarket = TestClassUtility.createMarket(false);
    //    testMarket.Active__c = true;
    //    testMarket.Local_Sales_Region__c = testRegion.id;
    //    insert testMarket;

    //    Category__c testCategory = TestClassUtility.createCategory(false);
    //    testCategory.Category_Group__c = 'Secondary';
    //    testCategory.Name = 'Bridal Salons - BWP';
    //    insert testCategory;

    //    MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
    //    Zip__c testzip = TestClassUtility.createZip(false);
    //    testzip.MetroArea__c = ma.id;
    //    testzip.ZipCode__c = 'ABCDEF';
    //    testzip.name = 'ABCDEF';
    //    testzip.Local_Market__c = testMarket.id;
    //    testzip.Portfolio__c = 'Senior Sales Executive';
    //    insert testzip;

    //    Zip__c testzip1 = TestClassUtility.createZip(false);
    //    testzip1.MetroArea__c = ma.id;
    //    testzip1.ZipCode__c = '78757';
    //    testzip1.name = '78757';
    //    testzip1.Local_Market__c = testMarket.id;
    //    testzip1.Portfolio__c = 'Senior Sales Executive';
    //    insert testzip1;

    //    Account testAccount = TestClassUtility.createAccount(false, testCategory, testMarket);
    //    testAccount.RecordTypeId = rtMapByName.get('Local').getRecordTypeId();
    //    testAccount.BU__c = 'Local';
    //    testAccount.Type = 'Agency';
    //    testAccount.Operative_Owner__c = userList[0].Name;
    //    testAccount.Fulfillment_Data__c = '{ "tier" : "Freemium", "reviewId" : "review Id", "parentGUID" : "37e0c6b9-6f4f-4dd4-a3f4-9707e9dc4bbc", "marketCode" : "228", "categoryId" : "8aa9a07b-fcd8-46ed-a98f-8f3e12689dd2" }';  
    //    insert testAccount;
        
    //    Contact testContact = TestClassUtility.createContact(true, testAccount);
                
    //    Campaign testCampaign = new Campaign();
    //    testCampaign.IsActive = true;
    //    testCampaign.Type = 'Bridal Show';
    //    testCampaign.Name = 'XO Group Internal - Hubspot_Paid Advertising-A';
    //    insert testCampaign;

    //    Test.startTest();

    //    Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead.Status = 'New';
    //    testLead.LeadSource = 'Other';
    //    testLead.Website  = 'ttt.com';
    //    testLead.Country = 'United States';
    //    testLead.State  = 'Alaska';
    //    testLead.City = 'US2';
    //    testLead.Street = 'US3';
    //    testLead.Phone= '1234567895';
    //    testLead.Email='abc@abc.com';
    //    testLead.Website = 'www.abc.com';
    //    testLead.PostalCode = testZip.ZipCode__c;
    //    testLead.CountryCode = 'US';
    //    try {
    //        insert testLead;
    //    } catch (Exception e) {
    //        XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
    //        xoException.Severity__c = 'Critical';
    //        xoException.Failure_Area__c = 'Lead Assignment Workflow Exception';
    //        exceptionList.add(xoException);
    //    }
    //    Lead testLead1 = TestClassUtility.createLead(false, testMarket, testCategory);
    //    testLead1.recordtypeId = rtLeadMapByName.get('Local').getRecordTypeId();
    //    testLead1.Status = 'New';
    //    testLead1.LeadSource = 'Other';
    //    testLead1.Website  = 'ttt.com';
    //    testLead1.State  = 'Alaska';
    //    testLead1.City = 'US2';
    //    testLead1.Street = 'US3';
    //    testLead1.Phone= '1234567895';
    //    testLead1.Email='abc@abc.com';
    //    testLead1.Website = 'www.abc.com';
    //    testLead1.PostalCode = testZip1.ZipCode__c;
    //    insert testLead1;
    //    List<CountryZipREGEX__c> countryRegExList11 = [select Id, Name, Active__c, CountryCode__c, RegExPattern__c from CountryZipREGEX__c where Active__c = true];
    //    Test.stopTest();
    //}

}