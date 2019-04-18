/*******************************************************************************
 *  Summary      : Test class for ZuoraTCVAndPaymentSchedule
 *  Refer Object : 
 *  Author       : Nick
 *  RefactorDate : 12 Dec 2016
 *  Change Log   : Refactoring by SF-2.6 release
 ******************************************************************************/
@isTest
private class ZuoraTCVAndPaymentScheduleTest {

    private static void buildCallOutData(zqu__QuoteRatePlanCharge__c testZquQuoteRPC){
        ZuoraSubscriptionPreview testRespond = new ZuoraSubscriptionPreview();
        testRespond.success = true;
        testRespond.amount = 300;

        ZuoraSubscriptionPreview.InvoiceItems testInvoiceItems = new ZuoraSubscriptionPreview.InvoiceItems();
        testInvoiceItems.serviceStartDate = String.valueOf(Date.today());
        testInvoiceItems.serviceEndDate = String.valueOf(Date.today().adddays(30));
        testInvoiceItems.chargeAmount = 200;
        testInvoiceItems.chargeDescription = testZquQuoteRPC.Id;
        testInvoiceItems.productRatePlanChargeId = testZquQuoteRPC.zqu__ProductRatePlanChargeZuoraId__c;
        
        testRespond.invoiceItems = new list<ZuoraSubscriptionPreview.InvoiceItems>();
        testRespond.invoiceItems.add(testInvoiceItems);

        String testBody = JSON.serialize(testRespond);

        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
                                                 'Complete',
                                                 testBody,
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);


        String sfdcEnvironmentBaseURL = URL.getSalesforceBaseUrl().toExternalForm();

        Zuora_Environment_URL__c sandboxDefault = new Zuora_Environment_URL__c();
        sandboxDefault.Name = sfdcEnvironmentBaseURL.substring(15, 25);
        sandboxDefault.Zuora_Base_URL__c = 'https://apisandbox-api.zuora.com';
        sandboxDefault.Zuora_REST_API_Path__c = '/rest';
        insert sandboxDefault;
    }

    @isTest static void testSetQuoteRatePlanChargeTriggerEventCode() {
        String triggerEvent = 'ContractEffective';
        Test.startTest();
        String triggerEvent1 = ZuoraTCVAndPaymentSchedule.setQuoteRatePlanChargeTriggerEventCode('ContractEffective');
        String triggerEvent2 = ZuoraTCVAndPaymentSchedule.setQuoteRatePlanChargeTriggerEventCode('ServiceActivation');
        String triggerEvent3 = ZuoraTCVAndPaymentSchedule.setQuoteRatePlanChargeTriggerEventCode('CustomerAcceptance');
        String triggerEvent4 = ZuoraTCVAndPaymentSchedule.setQuoteRatePlanChargeTriggerEventCode('SpecificDate');
        String triggerEvent5 = ZuoraTCVAndPaymentSchedule.setQuoteRatePlanChargeTriggerEventCode('testOther');
        Test.stopTest();

        system.assertEquals('UCE',triggerEvent1);
        system.assertEquals('USA',triggerEvent2);
        system.assertEquals('UCA',triggerEvent3);
        system.assertEquals('USD',triggerEvent4);
        system.assertEquals('testOther',triggerEvent5);
    }

    @isTest static void testSetTrueForInternetProduct(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 
        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)testDataMap.get('zqu__Quote__c');
        testZquQuote.zqu__BillCycleDay__c = '20';
        testZquQuote.zqu__TermStartDate__c = Date.today();
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        update testZquQuote;

        zqu__QuoteRatePlanCharge__c testZquQuoteRPC = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testZquQuoteRPC.zqu__ProductRatePlanChargeZuoraId__c = 'TestforTest';
        testZquQuoteRPC.zqu__Period__c = 'Month';
        update testZquQuoteRPC;

        Opportunity testOpp = (Opportunity)testDataMap.get('Opportunity');
        testOpp.StageName= 'Calculating TCV';
        update testOpp;
        buildCallOutData(testZquQuoteRPC);
        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();
        Boolean isSuccessed = ZuoraTCVAndPaymentSchedule.setTrueTCV(testOpp.Id);
        Test.stopTest();

        Opportunity testOppResult = [select Id,Potential_Value_Internet__c from Opportunity where id = : testOpp.Id ];
        system.assertEquals(TRUE, isSuccessed);
        system.assertEquals(300, testOppResult.Potential_Value_Internet__c);
        
    }

    @isTest static void testSetTrueForPrintProduct(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 
        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)testDataMap.get('zqu__Quote__c');
        testZquQuote.zqu__BillCycleDay__c = '20';
        testZquQuote.Product_Line__c = 'Print';
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        testZquQuote.zqu__ZuoraAccountID__c = 'testzuoraaccountid';
        testZquQuote.zqu__TermStartDate__c = Date.today();
        update testZquQuote;

        zqu__QuoteRatePlanCharge__c testZquQuoteRPC = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testZquQuoteRPC.zqu__ProductRatePlanChargeZuoraId__c = 'TestforTest';
        testZquQuoteRPC.zqu__Period__c = 'Month';
        update testZquQuoteRPC;

        Opportunity testOpp = (Opportunity)testDataMap.get('Opportunity');
        testOpp.StageName= 'Calculating TCV';
        update testOpp;

        buildCallOutData(testZquQuoteRPC);

        TestClassUtility.createAttachmentDeactivateTriggerSetting(true);

        Attachment testAtt = TestClassUtility.createAttachment(false,'test JSON.txt', 'testatt');
        testAtt.ParentId = testZquQuote.Id;
        insert testAtt;

        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();
        Boolean isSuccessed = ZuoraTCVAndPaymentSchedule.setTrueTCV(testOpp.Id);
        Test.stopTest();

        Opportunity testOppResult = [select Id,Potential_Value_Print__c from Opportunity where id = : testOpp.Id ];
        system.assertEquals(TRUE, isSuccessed);
        system.assertEquals(300, testOppResult.Potential_Value_Print__c);
        
    }

    @isTest static void testSetTrueForLDEProduct(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 
        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)testDataMap.get('zqu__Quote__c');
        testZquQuote.zqu__BillCycleDay__c = '20';
        testZquQuote.Product_Line__c = 'Direct Mail';
        testZquQuote.zqu__TermStartDate__c = Date.today();
        testZquQuote.zqu__SubscriptionType__c = 'New Subscription';
        update testZquQuote;

        zqu__QuoteRatePlanCharge__c testZquQuoteRPC = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testZquQuoteRPC.zqu__ProductRatePlanChargeZuoraId__c = 'TestforTest';
        testZquQuoteRPC.zqu__Period__c = 'Month';
        update testZquQuoteRPC;

        Opportunity testOpp = (Opportunity)testDataMap.get('Opportunity');
        testOpp.StageName= 'Calculating TCV';
        update testOpp;
        
        buildCallOutData(testZquQuoteRPC);

        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();
        Boolean isSuccessed = ZuoraTCVAndPaymentSchedule.setTrueTCV(testOpp.Id);
        Test.stopTest();

        Opportunity testOppResult = [select Id,Potential_Value_Direct_Marketing__c from Opportunity where id = : testOpp.Id ];
        system.assertEquals(TRUE, isSuccessed);
        system.assertEquals(300, testOppResult.Potential_Value_Direct_Marketing__c);
        
    }

    @isTest static void testBuildSTRPListForNewSubs(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 

        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__QuoteRatePlan__c testQRP = (zqu__QuoteRatePlan__c)testDataMap.get('zqu__QuoteRatePlan__c');
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = (zqu__ProductRatePlanCharge__c)testDataMap.get('zqu__ProductRatePlanCharge__c');

        zqu__QuoteRatePlanCharge__c testQRPC1 = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testQRPC1.zqu__ChargeType__c = 'One-Time';
        testQRPC1.zqu__Period__c = 'Semi_Annual';

        
        zqu__QuoteRatePlanCharge__c testQRPC2 = TestClassUtility.createQuoteRatePlanCharge(false,testQRP, testProductRatePlanCharge);
        testQRPC2.zqu__BillingPeriodAlignment__c = 'AlignToCharge';
        testQRPC2.zqu__TriggerEvent__c = 'SpecificDate'; 
        testQRPC2.zqu__SpecificEndDate__c = Date.today().adddays(360); 
        testQRPC2.zqu__TriggerDate__c = Date.today().adddays(30);
        testQRPC2.zqu__Period__c = 'Month';

        zqu__QuoteRatePlanCharge__c testQRPC3 = TestClassUtility.createQuoteRatePlanCharge(false,testQRP, testProductRatePlanCharge);
        testQRPC3.zqu__BillingPeriodAlignment__c = 'AlignToCharge';
        testQRPC3.zqu__Period__c = 'Semi_Annual';

        zqu__QuoteRatePlanCharge__c testQRPC4 = TestClassUtility.createQuoteRatePlanCharge(false,testQRP, testProductRatePlanCharge);
        testQRPC4.zqu__SpecificEndDate__c = Date.today().adddays(360); 
        testQRPC4.zqu__TriggerDate__c = Date.today().adddays(30);
        testQRPC4.zqu__Period__c = 'Semi_Annual';

        List<zqu__QuoteRatePlanCharge__c> listQRPC = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPC.add(testQRPC1);
        listQRPC.add(testQRPC2);
        listQRPC.add(testQRPC3);
        listQRPC.add(testQRPC4);

        
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qw.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPC);

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        List<ZuoraTCVAndPaymentSchedule.SubscribeToRatePlan> testListResultsLDE = ZuoraTCVAndPaymentSchedule.buildSTRPListForNewDirectMailSubs(qw);
        List<ZuoraTCVAndPaymentSchedule.SubscribeToRatePlan> testListResultsInternet = ZuoraTCVAndPaymentSchedule.buildSTRPListForNewInternetSubs(qw);
        List<ZuoraTCVAndPaymentSchedule.SubscribeToRatePlan> testListResultsPrint = ZuoraTCVAndPaymentSchedule.buildSTRPListForNewPrintSubs(qw);
        ZuoraTCVAndPaymentSchedule.Add testAdd = ZuoraTCVAndPaymentSchedule.buildAddWrapper(qw,testQRP);
        ZuoraTCVAndPaymentSchedule.Update_Z testUpdateZ = ZuoraTCVAndPaymentSchedule.buildUpdateWrapper(qw,testQRP);
        ZuoraTCVAndPaymentSchedule.Remove testRemove = ZuoraTCVAndPaymentSchedule.buildRemoveWrapper(qw,testQRP);
        Test.stopTest();

        system.assertEquals(1, testListResultsLDE.size());
        system.assertEquals(4, testListResultsLDE[0].chargeOverrides.size());
        system.assertEquals(testQRPC2.Id, testListResultsLDE[0].chargeOverrides[1].description);

        system.assertEquals(1, testListResultsInternet.size());
        system.assertEquals(4, testListResultsInternet[0].chargeOverrides.size());
        system.assertEquals(testQRPC1.Id, testListResultsInternet[0].chargeOverrides[0].description);

        system.assertEquals(1, testListResultsPrint.size());
        system.assertEquals(4, testListResultsPrint[0].chargeOverrides.size());
        system.assertEquals(testQRPC1.Id, testListResultsPrint[0].chargeOverrides[0].description);
    }

    @isTest static void testBuildNewAccountNewSubWrapper(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 

        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)testDataMap.get('zqu__Quote__c');
        testZquQuote.zqu__BillCycleDay__c = '20';
        testZquQuote.zqu__ZuoraAccountID__c = 'testzuoraaccountid';
        testZquQuote.zqu__Subscription_Term_Type__c = 'termed';

        zqu__QuoteRatePlan__c testQRP = (zqu__QuoteRatePlan__c)testDataMap.get('zqu__QuoteRatePlan__c');
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = (zqu__ProductRatePlanCharge__c)testDataMap.get('zqu__ProductRatePlanCharge__c');

        zqu__QuoteRatePlanCharge__c testQRPC1 = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testQRPC1.zqu__ChargeType__c = 'One-Time';
        testQRPC1.zqu__Period__c = 'Semi_Annual';


        List<zqu__QuoteRatePlanCharge__c> listQRPC = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPC.add(testQRPC1);

        
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qw = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qw.quote = testZquQuote;
        
        qw.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qw.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPC);
        qw.quoteProductLine = 'Print';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        String jsString = ZuoraTCVAndPaymentSchedule.buildNewAccountNewSubWrapper(qw);
        Object testObject = ZuoraTCVAndPaymentSchedule.populateAmendmentBaseClassFields(qw);
        Integer currentTerm = ZuoraTCVAndPaymentSchedule.getSubscriptionCurrentTerm('testZuoraSubId');
        String amendSubWrapperStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qw);
        Test.stopTest();

        ZuoraTCVAndPaymentSchedule.AmendmentBaseClass testABC = (ZuoraTCVAndPaymentSchedule.AmendmentBaseClass)testObject;
        system.assert(jsString.containsIgnoreCase('Fixed_Period'));
        system.assertEquals('TERMED', testABC.termType);
        system.assertEquals(null, currentTerm);
        system.assert(amendSubWrapperStr.containsIgnoreCase('2c92c0f94e4d3a3d014e655c28c50f5f'));

    }

    @isTest static void testBuildAmendmentSubWrapper(){

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 

        Map<String, SObject> testDataMap = TestClassUtility.buildLocalData(true);
        zqu__Quote__c testZquQuote = (zqu__Quote__c)testDataMap.get('zqu__Quote__c');
        testZquQuote.zqu__Subscription_Term_Type__c = 'TERMED';

        zqu__QuoteAmendment__c testQuoteAmendment = (zqu__QuoteAmendment__c)testDataMap.get('zqu__QuoteAmendment__c');
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge = (zqu__ProductRatePlanCharge__c)testDataMap.get('zqu__ProductRatePlanCharge__c');

        // add product
        zqu__QuoteRatePlan__c testQRP = (zqu__QuoteRatePlan__c)testDataMap.get('zqu__QuoteRatePlan__c');
        testQRP.zqu__AmendmentType__c = 'New Product';

        zqu__QuoteRatePlanCharge__c testQRPC = (zqu__QuoteRatePlanCharge__c)testDataMap.get('zqu__QuoteRatePlanCharge__c');
        testQRPC.zqu__ChargeType__c = 'One-Time';
        testQRPC.zqu__Period__c = 'Semi_Annual';

        List<zqu__QuoteRatePlanCharge__c> listQRPCAdd = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPCAdd.add(testQRPC);

        // Update product
        zqu__QuoteRatePlan__c testQRP1 = TestClassUtility.createQuoteRatePlan(false);
        testQRP1.zqu__AmendmentType__c = 'Update Product';
        testQRP1.zqu__QuoteAmendment__c = testQuoteAmendment.id;
        insert testQRP1;

        zqu__QuoteRatePlanCharge__c testQRPC1 = TestClassUtility.createQuoteRatePlanCharge(false,testQRP1, testProductRatePlanCharge);
        testQRPC1.zqu__ChargeType__c = 'One-Time';
        testQRPC1.zqu__Period__c = 'Semi_Annual';

        List<zqu__QuoteRatePlanCharge__c> listQRPCUpdate = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPCUpdate.add(testQRPC1);

        // remove Product
        zqu__QuoteRatePlan__c testQRP2 = TestClassUtility.createQuoteRatePlan(false);
        testQRP2.zqu__AmendmentType__c = 'Remove Product';
        testQRP2.zqu__QuoteAmendment__c = testQuoteAmendment.id;
        insert testQRP2;

        zqu__QuoteRatePlanCharge__c testQRPC2 = TestClassUtility.createQuoteRatePlanCharge(false,testQRP2, testProductRatePlanCharge);
        testQRPC2.zqu__ChargeType__c = 'One-Time';
        testQRPC2.zqu__Period__c = 'Semi_Annual';

        List<zqu__QuoteRatePlanCharge__c> listQRPCRemove = new List<zqu__QuoteRatePlanCharge__c>();
        listQRPCRemove.add(testQRPC2);


        // add
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwAdd = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwAdd.quote = testZquQuote;
        qwAdd.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qwAdd.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPCAdd);


        // Update
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwUpdate = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwUpdate.quote = testZquQuote;
        qwUpdate.quoteRatePlanMap.put(testQRP1.Id,testQRP1);
        qwUpdate.quoteRatePlanChargeListMap.put(testQRP1.Id,listQRPCUpdate);

        
        // remove
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwRemove = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwRemove.quote = testZquQuote;
        qwRemove.quoteRatePlanMap.put(testQRP2.Id,testQRP2);
        qwRemove.quoteRatePlanChargeListMap.put(testQRP2.Id,listQRPCRemove);

        // Add and Update
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwAddUpdate = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwAddUpdate.quote = testZquQuote;
        qwAddUpdate.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qwAddUpdate.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPCAdd);

        qwAddUpdate.quoteRatePlanMap.put(testQRP1.Id,testQRP1);
        qwAddUpdate.quoteRatePlanChargeListMap.put(testQRP1.Id,listQRPCUpdate);


        // add and removed
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwAddRemoved = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwAddRemoved.quote = testZquQuote;
        qwAddRemoved.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qwAddRemoved.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPCAdd);

        qwAddRemoved.quoteRatePlanMap.put(testQRP2.Id,testQRP2);
        qwAddRemoved.quoteRatePlanChargeListMap.put(testQRP2.Id,listQRPCRemove);


        // update and removed
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwUpdateRemoved = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwUpdateRemoved.quote = testZquQuote;
        qwUpdateRemoved.quoteRatePlanMap.put(testQRP1.Id,testQRP1);
        qwUpdateRemoved.quoteRatePlanChargeListMap.put(testQRP1.Id,listQRPCUpdate);

        qwUpdateRemoved.quoteRatePlanMap.put(testQRP2.Id,testQRP2);
        qwUpdateRemoved.quoteRatePlanChargeListMap.put(testQRP2.Id,listQRPCRemove);


        // add and update and remvoed
        ZuoraTCVAndPaymentSchedule.QuotesWrapper qwAddUpdateRemoved = new ZuoraTCVAndPaymentSchedule.QuotesWrapper();
        qwAddUpdateRemoved.quote = testZquQuote;
        qwAddUpdateRemoved.quoteRatePlanMap.put(testQRP.Id,testQRP);
        qwAddUpdateRemoved.quoteRatePlanChargeListMap.put(testQRP.Id,listQRPCAdd);

        qwAddUpdateRemoved.quoteRatePlanMap.put(testQRP1.Id,testQRP1);
        qwAddUpdateRemoved.quoteRatePlanChargeListMap.put(testQRP1.Id,listQRPCUpdate);
        
        qwAddUpdateRemoved.quoteRatePlanMap.put(testQRP2.Id,testQRP2);
        qwAddUpdateRemoved.quoteRatePlanChargeListMap.put(testQRP2.Id,listQRPCRemove);


        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();
        String amendAddStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwAdd);
        String amendUpdateStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwUpdate);
        String amendRemoveStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwRemove);
        String amendAddUpdateStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwAddUpdate);
        String amendAddRemoveStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwAddRemoved);
        String amendUpdateRemoveStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwUpdateRemoved);
        String amendAddUpdateRemoveStr = ZuoraTCVAndPaymentSchedule.buildAmendmentSubWrapper(qwAddUpdateRemoved);
        Test.stopTest();

        
        system.assert(amendAddStr.containsIgnoreCase('2c92c0f94e4d3a3d014e655c28c50f5f'));
        system.assert(amendUpdateStr.containsIgnoreCase('2099-01-01'));
        system.assert(amendRemoveStr.containsIgnoreCase('2099-01-01'));
        system.assert(amendAddUpdateStr.containsIgnoreCase('2099-01-01'));
        system.assert(amendAddRemoveStr.containsIgnoreCase('2099-01-01'));
        system.assert(amendUpdateRemoveStr.containsIgnoreCase('2099-01-01'));
        system.assert(amendAddUpdateRemoveStr.containsIgnoreCase('2099-01-01'));

    }
}