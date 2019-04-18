@isTest
private class TransactionTaggingHandlerTest {


    @testSetup static void buildTestActiveSubData(){
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        List<RecordType> localRecordTypeList = [SELECT Id, Name, SObjectType FROM RecordType WHERE Name LIKE '%local%' AND IsActive = true];
        Map<String, Id> localRecordTypeMap = new Map<String, Id>();
        for(Integer i = 0; i < localRecordTypeList.size(); i++) {
          RecordType currentRecordType = localRecordTypeList[i];
          localRecordTypeMap.put(currentRecordType.SObjectType, currentRecordType.Id);
        }
        Generate_Quote_Pdf_Config__c testGQPdfC = TestClassUtility.generateQuotePdfConfig(true);


        // for active subs data
        Account testAccount = TestClassUtility.createAccount(false);
        testAccount.RecordTypeId = localRecordTypeMap.get('Account');
        testAccount.Name = 'test Account for Active Sub';
        insert testAccount;

        Contact testContact = TestClassUtility.createContact(true, testAccount);

        Opportunity testOpp = TestClassUtility.createOpportunity(false, testAccount, testContact);
        testOpp.StageName = 'Quoting';
        insert testOpp;

        Zuora__Subscription__c testActiveSub = TestClassUtility.createSubscription(false,testAccount);
        testActiveSub.Zuora__External_Id__c = 'subfortestquotetriggerhandler1';
        testActiveSub.Zuora__Zuora_Id__c = 'subfortestquotetriggerhandler1';
        testActiveSub.Product_Line__c = 'Internet';
        testActiveSub.AutoRenewal__c = 'YES';
        testActiveSub.Zuora__TermStartDate__c = Date.today();
        testActiveSub.Zuora__TermEndDate__c = Date.today().adddays(365);
        insert testActiveSub;

        Zuora__Subscription__c testActiveSub1 = TestClassUtility.createSubscription(false,testAccount);
        testActiveSub1.Zuora__External_Id__c = 'subfortestquotetriggerhandler2';
        testActiveSub1.Zuora__Zuora_Id__c = 'subfortestquotetriggerhandler2';
        testActiveSub1.Product_Line__c = 'Print';
        testActiveSub1.AutoRenewal__c = 'YES';
        testActiveSub1.Zuora__TermStartDate__c = Date.today();
        testActiveSub1.Zuora__TermEndDate__c = Date.today().adddays(365);
        insert testActiveSub1;

        Live_Subscription__c testActiveLiveSub = TestClassUtility.createLiveSub(false,testAccount);
        testActiveLiveSub.Post_Is_Valid_Subscription__c = true;
        testActiveLiveSub.Switch_Date__c = Date.today();
        testActiveLiveSub.Post_Zuora_TermEndDate__c = Date.today().adddays(100);
        testActiveLiveSub.Product_Line__c = 'Internet';
        insert testActiveLiveSub;

        Live_Subscription_Product_and_Charge__c testAcitveLiveCharge = TestClassUtility.createliveCharge(true,testAccount,testActiveLiveSub);

        Live_Subscription__c testActiveLiveSub1 = TestClassUtility.createLiveSub(false,testAccount);
        testActiveLiveSub1.Post_Is_Valid_Subscription__c = true;
        testActiveLiveSub1.Subscription_Name__c = 's-000002';
        testActiveLiveSub1.Switch_Date__c = Date.today();
        testActiveLiveSub1.Post_Zuora_TermEndDate__c = Date.today().adddays(190);
        testActiveLiveSub1.Product_Line__c = 'Print';
        insert testActiveLiveSub1;

        Live_Subscription_Product_and_Charge__c testAcitveLiveCharge1 = TestClassUtility.createliveCharge(false,testAccount,testActiveLiveSub1);
        testAcitveLiveCharge1.Zuora_ChargeNumber__c = 'c-000002';
        testAcitveLiveCharge1.Product_Type__c = 'Print';
        testAcitveLiveCharge1.Market_ID__c = '202';
        testAcitveLiveCharge1.Zuora_EffectiveEndDate__c = Date.today().adddays(190);
        insert testAcitveLiveCharge1;

        Live_Subscription_Product_and_Charge__c testAcitveLiveCharge2 = TestClassUtility.createliveCharge(false,testAccount,testActiveLiveSub1);
        testAcitveLiveCharge2.Zuora_ChargeNumber__c = 'c-000003';
        testAcitveLiveCharge2.Market_ID__c = '202';
        testAcitveLiveCharge2.Zuora_EffectiveEndDate__c = Date.today().adddays(250);
        insert testAcitveLiveCharge2;


        // for expired subs data
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;

        Account testAccount1 = TestClassUtility.createAccount(false);
        testAccount1.RecordTypeId = localRecordTypeMap.get('Account');
        testAccount1.Name = 'test Account for Expired Sub';
        Database.SaveResult srAccount1 = Database.insert(testAccount1, dml);

        Contact testContact1 = TestClassUtility.createContact(false, testAccount1);
        Database.SaveResult srContact1 = Database.insert(testContact1, dml);

        Opportunity testOpp1 = TestClassUtility.createOpportunity(false, testAccount1, testContact1);
        testOpp1.StageName = 'Quoting';
        insert testOpp1;

        Zuora__Subscription__c testExpiredSub = TestClassUtility.createSubscription(false,testAccount1);
        testExpiredSub.Zuora__External_Id__c = 'subfortestquotetriggerhandlere';
        testExpiredSub.Zuora__Zuora_Id__c = 'subfortestquotetriggerhandlere';
        testExpiredSub.Product_Line__c = 'Direct Mail';
        testExpiredSub.AutoRenewal__c = 'YES';
        testExpiredSub.Zuora__TermStartDate__c = Date.today().adddays(-100);
        testExpiredSub.Zuora__TermEndDate__c = Date.today().adddays(-10);
        insert testExpiredSub;

        // for expired than 12 monts subs data
        Account testAccount2 = TestClassUtility.createAccount(false);
        testAccount2.RecordTypeId = localRecordTypeMap.get('Account');
        testAccount2.Name = 'test Account for No Sub';
        Database.SaveResult srAccount2 = Database.insert(testAccount2, dml);

        Contact testContact2 = TestClassUtility.createContact(false, testAccount2);
        Database.SaveResult srContact2 = Database.insert(testContact2, dml);

        Opportunity testOpp2 = TestClassUtility.createOpportunity(false, testAccount2, testContact2);
        testOpp2.StageName = 'Quoting';
        insert testOpp2;

        Zuora__Subscription__c testExpired12Sub = TestClassUtility.createSubscription(false,testAccount2);
        testExpired12Sub.Zuora__External_Id__c = 'subfortestquotetriggerhandler12';
        testExpired12Sub.Zuora__Zuora_Id__c = 'subfortestquotetriggerhandler12';
        testExpired12Sub.Product_Line__c = 'Direct Mail';
        testExpired12Sub.AutoRenewal__c = 'YES';
        testExpired12Sub.Zuora__TermStartDate__c = Date.today().addmonths(-24);
        testExpired12Sub.Zuora__TermEndDate__c = Date.today().addmonths(-13);
        insert testExpired12Sub;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;
    }


    static testMethod void testAssignTransactionTagForNewSubWrapper() {
        Set<Id> accountIdSet = new Set<Id>();

        Account testAccount = [SELECT Id,(SELECT Id FROM Opportunities LIMIT 1), 
                                        (SELECT Id FROM Contacts LIMIT 1),
                                        (SELECT Id FROM Zuora__Subscriptions__r WHERE Product_Line__c = 'Internet' limit 1) 
                                    FROM Account WHERE Name = 'test Account for Active Sub'];

        
        accountIdSet.add(testAccount.Id);
        
        //   for exist market Print
        zqu__Quote__c testZquQuote = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote.Product_Line__c = 'Print';
        testZquQuote.zqu__InitialTerm__c = 12;
        testZquQuote.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote.Original_Subscription_CMRR__c = 10;
        testZquQuote.Order_Type1__c = '';
        testZquQuote.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote;

        zqu__QuoteRatePlanCharge__c testQuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
        testQuoteRatePlanCharge.Market_ID__c = '101';

        List<zqu__QuoteRatePlanCharge__c> listQRPC = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPC.add(testQuoteRatePlanCharge);

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw.quote = testZquQuote;
        qw.quote.zqu__Previewed_MRR__c = 10;
        qw.quoteId = testZquQuote.Id;
        qw.quoteProductLine = 'Print';
        qw.quoteSubscriptionType = 'New Subscription';
        qw.quoteRatePlanChargeListMap.put(testZquQuote.Id,listQRPC);


        //   for new market Print
        zqu__Quote__c testZquQuote1 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote1.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote1.Product_Line__c = 'Print';
        testZquQuote1.zqu__InitialTerm__c = 12;
        testZquQuote1.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote1.Original_Subscription_CMRR__c = 10;
        testZquQuote1.Order_Type1__c = '';
        testZquQuote1.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote1;

        zqu__QuoteRatePlanCharge__c testQuoteRatePlanCharge1 = new zqu__QuoteRatePlanCharge__c();
        testQuoteRatePlanCharge1.Market_ID__c = '202';

        List<zqu__QuoteRatePlanCharge__c> listQRPC1 = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPC1.add(testQuoteRatePlanCharge1);

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw1 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw1.quote = testZquQuote1;
        qw1.quote.zqu__Previewed_MRR__c = 20;
        qw1.quoteId = testZquQuote1.Id;
        qw1.quoteProductLine = 'Print';
        qw1.quoteSubscriptionType = 'New Subscription';
        qw1.quoteRatePlanChargeListMap.put(testZquQuote1.Id,listQRPC1);

        //   for Internet
        zqu__Quote__c testZquQuote2 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote2.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote2.Product_Line__c = 'Internet';
        testZquQuote2.zqu__InitialTerm__c = 12;
        testZquQuote2.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote2.Original_Subscription_CMRR__c = 10;
        testZquQuote2.Order_Type1__c = '';
        testZquQuote2.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote2;

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw2 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw2.quote = testZquQuote2;
        qw2.quote.zqu__Previewed_MRR__c = 20;
        qw2.quoteId = testZquQuote2.Id;
        qw2.quoteProductLine = 'Internet';
        qw2.quoteSubscriptionType = 'New Subscription';



        Test.startTest();
        TransactionTaggingHandler.buildDataMap(accountIdSet);
        qw = TransactionTaggingHandler.assignTransactionTag(qw);
        qw1 = TransactionTaggingHandler.assignTransactionTag(qw1);
        qw2 = TransactionTaggingHandler.assignTransactionTag(qw2);
        Test.stopTest();

        system.assertEquals(1, TransactionTaggingHandler.mapAccountIdToSubEndDate.size());
        system.assertEquals(2, TransactionTaggingHandler.mapKeyStrToEndDate.size());

        system.assertEquals('Upsell',qw2.quote.Order_Type2__c);

        system.assertEquals('First Print Sale',qw.quote.Order_Type1__c);
        system.assertEquals('',qw1.quote.Order_Type1__c);
        system.assertEquals('',qw2.quote.Order_Type1__c);
    }


    static testMethod void testAssignTransactionTagForWrapper() {
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Account testAccount = [SELECT Id,(SELECT Id FROM Opportunities LIMIT 1), (SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE Name = 'test Account for Active Sub'];
        //   for all remove  
        zqu__Quote__c testZquQuote = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote.zqu__SubscriptionType__c = 'Amend Subscription';
        testZquQuote.Product_Line__c = 'Internet';
        testZquQuote.zqu__InitialTerm__c = 12;
        testZquQuote.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote.zqu__Previewed_Delta_MRR__c = 0;
        insert testZquQuote;

        zqu__QuoteChargeDetail__c testQuoteChargeDetail = new zqu__QuoteChargeDetail__c();
        testQuoteChargeDetail.zqu__Quote__c = testZquQuote.id;
        insert testQuoteChargeDetail;

        zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
        testQuoteAmendment.zqu__Quote__c = testZquQuote.id;
        testQuoteAmendment.zqu__Type__c = 'RemoveProduct';
        insert testQuoteAmendment;

        zqu__Quote__c testZquQuoteData = [SELECT Id,Count_of_Quote_Charge_Detail__c,Count_of_Remove_Amendment__c,Order_Type1__c,Order_Type2__c,
                                                    Subscription_Being_Renewed__c,Cancel_Reenter_Original_Subscription__c,Original_Subscription_CMRR__c, 
                                                    Original_Subscription_TCV__c, Count_Of_Not_Remove_Amendment__c,zqu__Previewed_Delta_MRR__c,
                                                    zqu__Previewed_Delta_TCV__c  
                                                FROM zqu__Quote__c 
                                                WHERE Id =: testZquQuote.Id];

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw.quote = testZquQuoteData;
        qw.quote.zqu__Previewed_Delta_MRR__c = 0;
        qw.quoteId = testZquQuoteData.Id;
        qw.quoteProductLine = 'Internet';
        qw.quoteSubscriptionType = 'Amend Subscription';


        // for only remove
        zqu__Quote__c testZquQuote1 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote1.zqu__SubscriptionType__c = 'Amend Subscription';
        testZquQuote1.Product_Line__c = 'Internet';
        testZquQuote1.zqu__InitialTerm__c = 12;
        testZquQuote1.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote1.zqu__Previewed_Delta_MRR__c = -10;
        insert testZquQuote1;

        zqu__QuoteChargeDetail__c testQuoteChargeDetail1 = new zqu__QuoteChargeDetail__c();
        testQuoteChargeDetail1.zqu__Quote__c = testZquQuote1.id;
        insert testQuoteChargeDetail1;

        zqu__QuoteChargeDetail__c testQuoteChargeDetail11 = new zqu__QuoteChargeDetail__c();
        testQuoteChargeDetail11.zqu__Quote__c = testZquQuote1.id;
        insert testQuoteChargeDetail11;

        zqu__QuoteAmendment__c testQuoteAmendment1 = new zqu__QuoteAmendment__c();
        testQuoteAmendment1.zqu__Quote__c = testZquQuote1.id;
        testQuoteAmendment1.zqu__Type__c = 'RemoveProduct';
        insert testQuoteAmendment1;

        zqu__Quote__c testZquQuoteData1 = [SELECT Id,Count_of_Quote_Charge_Detail__c,Count_of_Remove_Amendment__c,Order_Type1__c,Order_Type2__c,
                                                    Subscription_Being_Renewed__c,Cancel_Reenter_Original_Subscription__c,Original_Subscription_CMRR__c, 
                                                    Original_Subscription_TCV__c, Count_Of_Not_Remove_Amendment__c,zqu__Previewed_Delta_MRR__c,
                                                    zqu__Previewed_Delta_TCV__c  
                                                FROM zqu__Quote__c 
                                                WHERE Id =: testZquQuote1.Id];

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw1 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw1.quote = testZquQuoteData1;
        qw1.quote.zqu__Previewed_Delta_MRR__c = -10;
        qw1.quoteId = testZquQuoteData1.Id;
        qw1.quoteProductLine = 'Internet';
        qw1.quoteSubscriptionType = 'Amend Subscription';

        // for update
        zqu__Quote__c testZquQuote2 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote2.zqu__SubscriptionType__c = 'Amend Subscription';
        testZquQuote2.Product_Line__c = 'Internet';
        testZquQuote2.zqu__InitialTerm__c = 12;
        testZquQuote2.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote2.zqu__Previewed_Delta_MRR__c = 10;
        insert testZquQuote2;

        zqu__QuoteChargeDetail__c testQuoteChargeDetail2 = new zqu__QuoteChargeDetail__c();
        testQuoteChargeDetail2.zqu__Quote__c = testZquQuote2.id;
        insert testQuoteChargeDetail2;

        zqu__QuoteChargeDetail__c testQuoteChargeDetail21 = new zqu__QuoteChargeDetail__c();
        testQuoteChargeDetail21.zqu__Quote__c = testZquQuote2.id;
        insert testQuoteChargeDetail21;

        zqu__QuoteAmendment__c testQuoteAmendment2 = new zqu__QuoteAmendment__c();
        testQuoteAmendment2.zqu__Quote__c = testZquQuote2.id;
        testQuoteAmendment2.zqu__Type__c = 'AddProduct';
        insert testQuoteAmendment2;

        zqu__Quote__c testZquQuoteData2 = [SELECT Id,Count_of_Quote_Charge_Detail__c,Count_of_Remove_Amendment__c,Order_Type1__c,Order_Type2__c,
                                                    Subscription_Being_Renewed__c,Cancel_Reenter_Original_Subscription__c,Original_Subscription_CMRR__c, 
                                                    Original_Subscription_TCV__c, Count_Of_Not_Remove_Amendment__c,zqu__Previewed_Delta_MRR__c,
                                                    zqu__Previewed_Delta_TCV__c  
                                                FROM zqu__Quote__c 
                                                WHERE Id =: testZquQuote2.Id];

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw2 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw2.quote = testZquQuoteData2;
        qw2.quote.zqu__Previewed_Delta_MRR__c = 10;
        qw2.quoteId = testZquQuoteData2.Id;
        qw2.quoteProductLine = 'Internet';
        qw2.quoteSubscriptionType = 'Amend Subscription';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        qw = TransactionTaggingHandler.assignTransactionTag(qw);
        qw1 = TransactionTaggingHandler.assignTransactionTag(qw1);
        qw2 = TransactionTaggingHandler.assignTransactionTag(qw2);
        Test.stopTest();

        system.assertEquals('Removal',qw.quote.Order_Type1__c);
        system.assertEquals('Delta Zero',qw.quote.Order_Type2__c);

        system.assertEquals('Amendment(Removal)',qw1.quote.Order_Type1__c);
        system.assertEquals('Downsell',qw1.quote.Order_Type2__c);

        system.assertEquals('Amendment',qw2.quote.Order_Type1__c);
        system.assertEquals('Upsell',qw2.quote.Order_Type2__c);
    }


    static testMethod void testAssignTransactionTagForCancelReenterWrapper() {
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Account testAccount = [SELECT Id,(SELECT Id FROM Opportunities LIMIT 1), 
                                        (SELECT Id FROM Contacts LIMIT 1),
                                        (SELECT Id FROM Zuora__Subscriptions__r WHERE Product_Line__c = 'Internet' limit 1) 
                                    FROM Account WHERE Name = 'test Account for Active Sub'];
        

        //   for cancel reenter delta zero
        zqu__Quote__c testZquQuote = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote.Product_Line__c = 'Internet';
        testZquQuote.zqu__InitialTerm__c = 12;
        testZquQuote.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote.Original_Subscription_CMRR__c = 10;
        testZquQuote.Order_Type1__c = 'Cancel Reenter(New)';
        testZquQuote.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote;

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw.quote = testZquQuote;
        qw.quote.zqu__Previewed_MRR__c = 10;
        qw.quoteId = testZquQuote.Id;
        qw.quoteProductLine = 'Internet';
        qw.quoteSubscriptionType = 'New Subscription';


        //   for cancel reenter upsell
        zqu__Quote__c testZquQuote1 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote1.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote1.Product_Line__c = 'Internet';
        testZquQuote1.zqu__InitialTerm__c = 12;
        testZquQuote1.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote1.Original_Subscription_CMRR__c = 10;
        testZquQuote1.Order_Type1__c = 'Cancel Reenter(New)';
        testZquQuote1.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote1;


        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw1 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw1.quote = testZquQuote1;
        qw1.quote.zqu__Previewed_MRR__c = 20;
        qw1.quoteId = testZquQuote1.Id;
        qw1.quoteProductLine = 'Internet';
        qw1.quoteSubscriptionType = 'Cancel Reenter(New)';

        // for cancel reenter downSell
        zqu__Quote__c testZquQuote2 = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote2.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote2.Product_Line__c = 'Internet';
        testZquQuote2.zqu__InitialTerm__c = 12;
        testZquQuote2.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote2.Original_Subscription_CMRR__c = 20;
        testZquQuote2.Order_Type1__c = 'Cancel Reenter(New)';
        testZquQuote2.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote2;

        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw2 = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw2.quote = testZquQuote2;
        qw2.quote.zqu__Previewed_MRR__c = 10;
        qw2.quoteId = testZquQuote2.Id;
        qw2.quoteProductLine = 'Internet';
        qw2.quoteSubscriptionType = 'Cancel Reenter(New)';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        qw = TransactionTaggingHandler.assignTransactionTag(qw);
        qw1 = TransactionTaggingHandler.assignTransactionTag(qw1);
        qw2 = TransactionTaggingHandler.assignTransactionTag(qw2);
        Test.stopTest();


        system.assertEquals('Delta Zero',qw.quote.Order_Type2__c);

        system.assertEquals('Upsell',qw1.quote.Order_Type2__c);

        system.assertEquals('Downsell',qw2.quote.Order_Type2__c);
    }

    static testMethod void testIsNewSubscription() {
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Account testAccount = [SELECT Id,(SELECT Id FROM Opportunities LIMIT 1), 
                                        (SELECT Id FROM Contacts LIMIT 1),
                                        (SELECT Id FROM Zuora__Subscriptions__r WHERE Product_Line__c = 'Internet' limit 1) 
                                    FROM Account WHERE Name = 'test Account for Active Sub'];
        

        //   for cancel reenter delta zero
        zqu__Quote__c testZquQuote = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote.Product_Line__c = 'Internet';
        testZquQuote.zqu__InitialTerm__c = 12;
        testZquQuote.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote.Original_Subscription_CMRR__c = 10;
        testZquQuote.Order_Type1__c = 'Cancel Reenter(New)';
        testZquQuote.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        Boolean isNewSubscription = TransactionTaggingHandler.isNewSubscription(testZquQuote);

        Test.stopTest();

        system.assertEquals(false,isNewSubscription);
    }
    
    static testMethod void testIsFirstSale(){
        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        Account testAccount = [SELECT Id,(SELECT Id FROM Opportunities LIMIT 1), 
                                        (SELECT Id FROM Contacts LIMIT 1),
                                        (SELECT Id FROM Zuora__Subscriptions__r WHERE Product_Line__c = 'Internet' limit 1) 
                                    FROM Account WHERE Name = 'test Account for Active Sub'];
        

        //   for cancel reenter delta zero
        zqu__Quote__c testZquQuote = TestClassUtility.createQuote(false,testAccount.Opportunities[0],testAccount,testAccount.Contacts[0]);
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote.Product_Line__c = 'Internet';
        testZquQuote.zqu__InitialTerm__c = 11;
        testZquQuote.zqu__TermStartDate__c = Date.today().adddays(1);
        testZquQuote.Original_Subscription_CMRR__c = 10;
        testZquQuote.Order_Type1__c = 'Cancel Reenter(New)';
        testZquQuote.Cancel_Reenter_Original_Subscription__c = testAccount.Zuora__Subscriptions__r[0].Id;
        insert testZquQuote;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        Boolean isFirstSale = TransactionTaggingHandler.isFirstSale(testZquQuote, 'Test String');

        Test.stopTest();

        system.assertEquals(false,isFirstSale);
    }
}