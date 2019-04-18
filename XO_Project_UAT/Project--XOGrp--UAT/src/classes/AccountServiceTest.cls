@isTest
private class AccountServiceTest {

    static testMethod void testAssignAccountInfo() {
    	Set<Id> updatedCBSSUserIdSet = new Set<Id>();
    	Set<Id> updatedTitleUserIdSet = new Set<Id>();
  		Account accRec = TestClassUtility.createAccount(true);
  		User testUser = [select Id, Name, ARR__r.Email from User 
														where ARR__c != null
														and isActive = true limit 1];

		updatedCBSSUserIdSet.add(testUser.Id);
		updatedTitleUserIdSet.add(testUser.Id);
		accRec.OwnerId = testUser.Id;
		update accRec;

    	Test.startTest();
     	accRec = AccountService.assignAccountInfo(accRec, updatedCBSSUserIdSet, updatedTitleUserIdSet);
     	Test.stopTest();

        System.assert(accRec.Last_AM_Transfer__c == System.today());
    }
}