@isTest
private class OpportunityServiceTest {

    static testMethod void testValidateOpportunityQuote(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        // for the error message data
        Account testAcc = TestClassUtility.createAccount(false);
        testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        insert testAcc;

        Contact testContact = TestClassUtility.createContact(true, testAcc);
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);
        // closed won error
        Opportunity testOpp1 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp1.StageName = 'Closed Won';
        insert testOpp1;

        // closed lost error
        Opportunity testOpp2 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp2.StageName = 'Closed Lost';
        testOpp2.Lost_Reason__c = 'expired';
        insert testOpp2;

        // locked quote error
        Opportunity testOpp3 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp3.StageName = 'Quoting';
        testOpp3.Lock_Quotes__c = true;
        insert testOpp3;

        // null private contact role error
        Opportunity testOpp4 = TestClassUtility.createOpportunity(false, testAcc, testContact);
        testOpp4.StageName = 'Quoting';
        testOpp4.Lock_Quotes__c = false;
        insert testOpp4;


        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        
        List<String> listErrorMessage = new List<String>();

        Test.startTest();
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(''));
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp1.Id));
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp2.Id));
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp3.Id));
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp4.Id));
        Test.stopTest();

        system.assertEquals('Invalid Opportunity ID Provided', listErrorMessage[0]);
        system.assertEquals(Label.Opportunity_Closed_Won_Reopen_Error, listErrorMessage[1]);
        system.assertEquals(Label.Opportunity_Closed_Lost_Reopen_Error, listErrorMessage[2]);
        system.assertEquals(Label.Opportunity_Locked_Warning_Message, listErrorMessage[3]);
        system.assertEquals(Label.Primary_Account_Contact_Role_Required_Warning_message, listErrorMessage[4]);
    }

    static testMethod void testValidateOpportunityQuoteNullService(){
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        // for the null active subs error
        Account testAcc1 = TestClassUtility.createAccount(false);
        testAcc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
        insert testAcc1;

        Contact testContact1 = TestClassUtility.createContact(true, testAcc1);
        AccountContactRole testAccountContactRole1 = TestClassUtility.createAccountContactRole(true, testAcc1, testContact1);

        Opportunity testOpp5 = TestClassUtility.createOpportunity(false, testAcc1, testContact1);
        testOpp5.StageName = 'Quoting';
        testOpp5.Lock_Quotes__c = false;
        insert testOpp5;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        List<String> listErrorMessage = new List<String>();

        Test.startTest();
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp5.Id));

        Test.stopTest();

        system.assertEquals(Label.Cancel_Reenter_Need_a_Active_Subscription, listErrorMessage[0]);

    }

    static testMethod void testValidateOpportunityQuoteNoError(){
        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        // for the success quote
        Map<String,SObject> testData = TestClassUtility.buildLocalData(true);
        Opportunity testOpp6 = (Opportunity)testData.get('Opportunity');

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        
        List<String> listErrorMessage = new List<String>();

        Test.startTest();
        listErrorMessage.add(OpportunityService.validateOpportunityQuote(testOpp6.Id));
        Test.stopTest();

        system.assertEquals('', listErrorMessage[0]);
    }
}