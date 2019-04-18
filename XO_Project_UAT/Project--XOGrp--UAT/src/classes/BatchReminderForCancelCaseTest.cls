@isTest
private class BatchReminderForCancelCaseTest {
    static testMethod void testReminderForCancelCase() {
    	Account testAcc = TestClassUtility.createAccount(true);
    	Contact testCont = TestClassUtility.createContact(true, testAcc);

    	case testCase = TestClassUtility.createCase(false, testAcc, testCont);
    	testCase.Save_For_Later__c = true;
    	testCase.Status = 'new';
    	insert testCase;

    	Test.setCreatedDate(testCase.Id, system.now().addDays(-2));   

    	Test.startTest();
      BatchReminderForCancelCase cls = new BatchReminderForCancelCase();
      Database.executeBatch(cls);
      system.assert(Limits.getQueries() > 0);
      Test.stopTest();

    }
}