@isTest
private class BatchCalculateAccountValueTest {
    static testMethod void testCalculateAccountValue() {

		Account acc = TestClassUtility.createAccount(true);
		Contact con = TestClassUtility.createContact(true, acc);

		Case mockCase = TestClassUtility.createCase(true, acc, con) ;

        Live_Subscription__c liveSub = TestClassUtility.createLiveSub(true, acc);

        Live_Subscription_Product_and_Charge__c liveCharge = TestClassUtility.createliveCharge(true, acc, liveSub);

        Account_Snapshots__c accSnap = TestClassUtility.createAccSnap(true, mockCase);
	    			 
		Test.startTest();
        BatchCalculateAccountValue cls = new BatchCalculateAccountValue();
        Database.executeBatch(cls);
        Test.stopTest();

        Account_Snapshots__c assertAccSnap = [SELECT id, Account_Value__c FROM Account_Snapshots__c WHERE id =:accSnap.Id];
        system.assert(assertAccSnap.Account_Value__c == liveCharge.Pre_Zuora_MonthlyRecurringRevenue__c);

    }
}