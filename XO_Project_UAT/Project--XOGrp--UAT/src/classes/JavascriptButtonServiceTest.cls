@isTest
private class JavascriptButtonServiceTest {
    
    static testMethod void validateSignature1() {

        List<RecordType> localRecordTypeList = [SELECT Id, Name, SObjectType FROM RecordType WHERE Name LIKE '%local%' AND IsActive = true];
        Map<String, Id> localRecordTypeMap = new Map<String, Id>();
        for(Integer i = 0; i < localRecordTypeList.size(); i++) {
          RecordType currentRecordType = localRecordTypeList[i];
          localRecordTypeMap.put(currentRecordType.SObjectType, currentRecordType.Id);
        }

        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = localRecordTypeMap.get('Account');
        insert testAcc;

        Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);

        test.startTest();
        Opportunity testOpp = TestClassUtility.createOpportunity(true, testAcc, testContact);
 
        zqu__Quote__c testQuote = TestClassUtility.createQuote(false, testOpp, testAcc, testContact);
        testQuote.zqu__SubscriptionType__c= 'Amend Subscription';
        testQuote.zqu__TermStartDate__c = DateUtility.AddBusinessDays(Date.today(), 4);
        insert testQuote;  

        Opportunity testOpp2 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp2.StageName = 'Ready for Echo-Sign';
        insert testOpp2;  

        zqu__Quote__c testQuote2 = TestClassUtility.createQuote(false, testOpp2, testAcc, testContact);
        testQuote2.zqu__SubscriptionType__c= 'Amend Subscription';
        testQuote2.zqu__TermStartDate__c = DateUtility.AddBusinessDays(Date.today(), 4);
        insert testQuote2;  

       
        String eStdTemplateName = 'Local Amendment Agreement Template 20160127';
        echosign_dev1__Agreement_Template__c eStdTemplate = new echosign_dev1__Agreement_Template__c();
        eStdTemplate.Name = eStdTemplateName;
        eStdTemplate.echosign_dev1__Name__c = eStdTemplateName;
        eStdTemplate.echosign_dev1__Active__c = true;
        insert eStdTemplate;

        test.stopTest();

        JavascriptButtonService.validateSignatureProceed(testOpp.Id);
        JavascriptButtonService.validateSignatureProceed(testOpp2.Id);


    }

    static testMethod void validateSignature2() {

        List<RecordType> localRecordTypeList = [SELECT Id, Name, SObjectType FROM RecordType WHERE Name LIKE '%local%' AND IsActive = true];
        Map<String, Id> localRecordTypeMap = new Map<String, Id>();
        for(Integer i = 0; i < localRecordTypeList.size(); i++) {
          RecordType currentRecordType = localRecordTypeList[i];
          localRecordTypeMap.put(currentRecordType.SObjectType, currentRecordType.Id);
        }

        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = localRecordTypeMap.get('Account');
        insert testAcc;

        Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);


        test.startTest();

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp.StageName = 'Ready for Echo-Sign';
        insert testOpp; 
        
        zqu__Quote__c testQuote = TestClassUtility.createQuote(false, testOpp, testAcc, testContact);
        testQuote.zqu__SubscriptionType__c= 'New Subscription';
        testQuote.zqu__TermStartDate__c = DateUtility.AddBusinessDays(Date.today(), 4);
        insert testQuote;      

        Deactivate_Trigger__c dt = TestClassUtility.createAttachmentDeactivateTriggerSetting(true);

        Attachment att = new Attachment();
        att.Name = 'test file preview.pdf';
        att.Body = Blob.valueOf('abc');
        att.ContentType = 'txt';
        att.ParentId = testOpp.id;
        att.OwnerId = UserInfo.getUserId();
        insert att;


        Opportunity testOpp2 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp2.StageName = 'Ready for Echo-Sign';
        insert testOpp2; 
        
        zqu__Quote__c testQuote2 = TestClassUtility.createQuote(false, testOpp2, testAcc, testContact);
        testQuote2.zqu__SubscriptionType__c= 'New Subscription';
        testQuote2.zqu__TermStartDate__c = DateUtility.AddBusinessDays(Date.today(), 7);
        insert testQuote2;   

        Attachment att2 = new Attachment();
        att2.Name = 'test file preview.pdf';
        att2.Body = Blob.valueOf('abc');
        att2.ContentType = 'txt';
        att2.ParentId = testOpp2.id;
        att2.OwnerId = UserInfo.getUserId();
        insert att2;   
        
        String eStdTemplateName = 'Local Standard Agreement Template 20170524';
        echosign_dev1__Agreement_Template__c eStdTemplate = new echosign_dev1__Agreement_Template__c();
        eStdTemplate.Name = eStdTemplateName;
        eStdTemplate.echosign_dev1__Name__c = eStdTemplateName;
        eStdTemplate.echosign_dev1__Active__c = true;
        insert eStdTemplate;

        test.stopTest();
        
        JavascriptButtonService.validateSignatureProceed(testOpp.Id);
        JavascriptButtonService.validateSignatureProceed(testOpp2.Id);
        

    }

    static testMethod void validateSignature3() {

        test.startTest();

        JavascriptButtonService.validateSignatureProceed('');
        JavascriptButtonService.validateSignatureProceed('BAD ID');

        test.stopTest();
    }


    // CSP-1306 Added by Nick Wu
    static testMethod void updateAutoCloseDate() {

        List<RecordType> localRecordTypeList = [SELECT Id, Name, SObjectType FROM RecordType WHERE Name LIKE '%local%' AND IsActive = true];
        Map<String, Id> localRecordTypeMap = new Map<String, Id>();
        for(Integer i = 0; i < localRecordTypeList.size(); i++) {
          RecordType currentRecordType = localRecordTypeList[i];
          localRecordTypeMap.put(currentRecordType.SObjectType, currentRecordType.Id);
        }

        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = localRecordTypeMap.get('Account');
        insert testAcc;

        Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp.Contract_Signer__c = testContact.id;
        insert testOpp;  

        test.startTest();
        JavascriptButtonService.updateAutoCloseDate('');
        JavascriptButtonService.updateAutoCloseDate('BAD ID');    
        JavascriptButtonService.updateAutoCloseDate(testOpp.id);
        test.stopTest();
    }

    static testMethod void updateEchosignExpirationDate(){

        List<RecordType> localRecordTypeList = [SELECT Id, Name, SObjectType FROM RecordType WHERE Name LIKE '%local%' AND IsActive = true];
        Map<String, Id> localRecordTypeMap = new Map<String, Id>();
        for(Integer i = 0; i < localRecordTypeList.size(); i++) {
          RecordType currentRecordType = localRecordTypeList[i];
          localRecordTypeMap.put(currentRecordType.SObjectType, currentRecordType.Id);
        }

        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = localRecordTypeMap.get('Account');
        insert testAcc;

        Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp.Contract_Signer__c = testContact.id;
        insert testOpp;      

        test.startTest();
        JavascriptButtonService.updateEchosignExpirationDate(testOpp.id);
        test.stopTest();
    }

    static testMethod void validLeadFields(){

        test.startTest();
        JavascriptButtonService.validLeadFields('1234567891','123465','www.abc.com');
        JavascriptButtonService.validLeadFields('abc','123465','www.abc.com');
        JavascriptButtonService.validLeadFields('1234567891','abc','www.abc.com');
        JavascriptButtonService.validLeadFields('1234567891','123465','abc');

        test.stopTest();        
    }

    static testMethod void reassignAccountOwner(){

        Account testAcc = TestClassUtility.createAccount(true);

        Test.startTest();

        JavascriptButtonService.reassignAccountOwner(testAcc.Id);
        JavascriptButtonService.reassignAccountOwner('');
        Test.stopTest();
    }
    static testMethod void generateCancelOpp(){

        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        insert testAcc;

        Case testCase = New Case();
        testCase.OwnerId = Userinfo.getUserId();
        testCase.AccountId = testAcc.Id;
        insert testCase;

        Test.startTest();
        JavascriptButtonService.generateCancelOpp(testCase.OwnerId, testCase.CaseNumber, testCase.AccountId, testCase.Id);
        Test.stopTest();   


    }


    static testMethod void testValidateOpportunityQuote(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        // for the error message data
        // Account testAcc = TestClassUtility.createAccount(false);
        // testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        // insert testAcc;

        // Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);
        

        // for the success quote
        Map<String,SObject> testData = TestClassUtility.buildLocalData(true);
        Opportunity testOpp = (Opportunity)testData.get('Opportunity');

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        
        List<String> listErrorMessage = new List<String>();

        Test.startTest();
        listErrorMessage.add(JavascriptButtonService.validateOpportunityQuote(''));
        listErrorMessage.add(JavascriptButtonService.validateOpportunityQuote(testOpp.Id));
        Test.stopTest();

        system.assertEquals(TRUE, listErrorMessage[0].containsIgnoreCase('Invalid Opportunity ID Provided'));
        system.assertEquals(TRUE, String.valueOf(listErrorMessage[1]).containsIgnoreCase('true'));
    }
}