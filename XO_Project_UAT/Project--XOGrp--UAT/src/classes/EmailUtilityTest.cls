@isTest
private class EmailUtilityTest {
	@testSetup static void testSetupData(){
		TestClassUtility.generateQuotePdfConfig(true);
	}

    static testMethod void testCreateTwoDayContractEmail() {
        Opportunity testOpp = TestClassUtility.createOpportunity(true);

        Test.startTest();
		Messaging.SingleEmailMessage emailResponse = EmailUtility.createTwoDayContractEmail(testOpp);
		Test.stopTest();

        System.assert(emailResponse != null);
    }

    static testMethod void testCreateExpiredContractEmail() {
        Opportunity testOpp = TestClassUtility.createOpportunity(true);

        Test.startTest();
        Messaging.SingleEmailMessage emailResponse = EmailUtility.createExpiredContractEmail(testOpp);
        Test.stopTest();

        System.assert(emailResponse != null);
    }

    static testMethod void testCreateWaitListOnDeckEmail() {
		Product2 testProduct = TestClassUtility.createLocalProduct2(true);
    	zqu__ProductRatePlan__c testProductRatePlan = TestClassUtility.createProductRatePlan(true, testProduct);

    	Inventory__c testInventory = TestClassUtility.createInventory(false,testProductRatePlan);
    	testInventory.Inventory_Hold_Expiry_Date__c = Date.today();
    	testInventory.Waitlist_Account__c = TestClassUtility.createAccount(true).Id;
    	Database.insert(testInventory,false);

		Test.startTest();
        Messaging.SingleEmailMessage emailResponse = EmailUtility.createWaitListOnDeckEmail(testInventory);
        Test.stopTest();

        System.assert(emailResponse != null);
    }

    static testMethod void testCreateEmailBody() {
		String title = 'testTitle';
		String bodyText = 'testBodyText';

		Test.startTest();
        String responseString = EmailUtility.createEmailBody(title,bodyText);
        Test.stopTest();

        System.assert(String.isNotBlank(responseString));
    }

    static testMethod void testGenerateEmail() {    
    	Id templateId = [SELECT Id FROM EmailTemplate WHERE isActive = true Limit 1].Id;
    	Id whatId = TestClassUtility.createAccount(true).Id;
    	Id targetObjectId = TestClassUtility.createContact(true).Id;
    	Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
    	String replyToAddress = 'test@test.com'; 
    	String senderDisplayName = 'Test Name';

        Test.startTest();
       	Messaging.SingleEmailMessage newEmail = EmailUtility.generateEmail(templateId, whatId, targetObjectId, false, orgWideEmailAddressId, replyToAddress, senderDisplayName);
        Test.stopTest();

        System.assert(newEmail != null);
    }

    static testMethod void testCreateLiveChargeEmail() {    
        String userId = String.valueOf(UserInfo.getUserId());
        String subZuoraId = 'testsubscriptionZUoraId';

        Account testAccount = TestClassUtility.createAccount(true);
        Live_Subscription__c testLiveSubs = TestClassUtility.createLiveSub(true,testAccount);
        Live_Subscription_Product_and_Charge__c testLSPC = TestClassUtility.createliveCharge(true,testAccount,testLiveSubs);


        List<Live_Subscription_Product_and_Charge__c> listLSPC = new List<Live_Subscription_Product_and_Charge__c>();
        listLSPC.add(testLSPC);

        Map<String,list<Live_Subscription_Product_and_Charge__c>> mapSubZuoraIdLiveCharges = new Map<String,list<Live_Subscription_Product_and_Charge__c>>();
        mapSubZuoraIdLiveCharges.put(subZuoraId,listLSPC);

        Test.startTest();
        List<Messaging.SingleEmailMessage> listNewEmail = EmailUtility.createLiveChargeEmail(userId, mapSubZuoraIdLiveCharges);
        Test.stopTest();

        System.assertEquals(1, listNewEmail.size());
    }

    static testMethod void testSendSalesRepRSDEmail() {    
        String userFullName = String.valueOf(UserInfo.getUserId());

        Account testAccount = TestClassUtility.createAccount(true);
        Set<Id> setAccId = new Set<Id>();
        setAccId.add(testAccount.Id);

        Test.startTest();
        List<XO_Exception__c> xoExceptionList = EmailUtility.sendSalesRepRSDEmail(setAccId, userFullName);
        Test.stopTest();

        System.assertEquals(0, xoExceptionList.size());
    }
}