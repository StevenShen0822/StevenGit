@isTest
private class BatchSendQuotesToZuoraHourlyTest {

    static testMethod void testSendQuotesToZuoraHourly() {
        
      TestClassUtility.DISABLE_TRIGGERS = TRUE;
      Map<String,SObject> testObjects = TestClassUtility.buildLocalData(true);

      Opportunity testOpp = (Opportunity)testObjects.get('Opportunity');
      testOpp.Name = 'Test Opportunity';
      testOpp.StageName = 'Client Approved';
      testOpp.Type= 'New';
      testOpp.Approval_Process_AR_Assignment__c = false;
      testOpp.Approval_Process_Manager_Assignment__c = false;
      testOpp.Opportunity_Expiration_Date__c = Date.today().addDays(14);
      testOpp.CloseDate = testOpp.Opportunity_Expiration_Date__c;
      testOpp.Approval_Process_Flag_Skip_EchoSign__c = false;
      testOpp.OwnerId = userInfo.getUserId();
      
      update testOpp;

      zqu__Quote__c testQuote = (zqu__Quote__c)testObjects.get('zqu__Quote__c');
      testQuote.Name = 'Test Quote';
      testQuote.zqu__Status__c = 'New';
      testQuote.zqu__Account__c = ((Account)testObjects.get('Account')).Id;
      testQuote.Zqu__ValidUntil__c = Date.Today()-1;
      testQuote.SalesRepLookup__c = userInfo.getUserId();
      testQuote.Reporting_Rep__c = userInfo.getUserId();
      testQuote.zqu__Service_Activation_Date__c = system.today();
      //testQuote.zqu__TermStartDate__c= Date.newinstance(2016, 12, 14);
      testQuote.zqu__BillCycleDay__c='1';
      testQuote.zqu__Opportunity__c = testOpp.Id;
      testQuote.Product_Line__c = 'Internet';
      testQuote.zqu__ZuoraAccountID__c = ((Account)testObjects.get('Account')).Id;

      update testQuote;

      
      TestClassUtility.DISABLE_TRIGGERS = FALSE;

      Task_Creation_Settings__c taskCreateSetting = TestClassUtility.createTaskCreationSettings(true,'Error_sending_a_quote_to_Zuora',true);
      BatchSendQuotesToZuoraHourly bat = new BatchSendQuotesToZuoraHourly();
      bat.quoteOwnerIdMap.put(testQuote.id,testOpp.OwnerId);
      bat.successOppIdSet.add(testOpp.id);
      bat.quoteIdToErrorMessageMap.put(testQuote.id,'test menthod');
      bat.sendQuotesToBilling = false ;


      Test.startTest();
      Database.executeBatch(bat,1);
      Test.stopTest();

      System.assert(!bat.successOppIdSet.isEmpty());

    }

}