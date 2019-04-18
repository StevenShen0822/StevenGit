@isTest
private class EmailMessageTriggerTest {
  	static testMethod void testReopenCase() {
	 	Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
	 	List<Case> testCaseList = new List<Case>();
	 	List<EmailMessage> testEmailMessageList = new List<EmailMessage>();

		Case testCaseWithSentEmail = new Case();
		testCaseWithSentEmail.Description = 'Test case with sent email, its status should be changed to reopened by trigger';
		testCaseWithSentEmail.RecordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
		testCaseWithSentEmail.SuppliedEmail = 'testemail@test.com';
		testCaseList.add(testCaseWithSentEmail);

		Case testCaseWithUnsentEmail = new Case();
		testCaseWithUnsentEmail.Description = 'Test case with sent email, its status remians unchanged';
		testCaseWithUnsentEmail.RecordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
		testCaseWithUnsentEmail.SuppliedEmail = 'testemail@test.com';
		testCaseList.add(testCaseWithUnsentEmail);

		insert testCaseList;

		testCaseWithSentEmail.Status = 'Closed';

		testCaseWithUnsentEmail.Status = 'Closed';

		update testCaseList;

		EmailMessage sentEmail = new EmailMessage();
		sentEmail.RelatedToId = testCaseWithSentEmail.Id;
		sentEmail.Subject = 'Test case with sent email, its status should be changed to reopened by trigger';
		testEmailMessageList.add(sentEmail);
			
		String unsentEmailMessageJsonString =  '{"attributes":{"type":"EmailMessage"},"Status" : "1" ,"RelatedToId" : "'+ testCaseWithUnsentEmail.Id +'","Subject":"Test case with sent email, its status remians unchanged"}';
		EmailMessage unsentEmail = (EmailMessage)JSON.deserialize(unsentEmailMessageJsonString, Type.forName('EmailMessage'));
		testEmailMessageList.add(unsentEmail);

		Test.startTest();

		insert testEmailMessageList;

		Test.stopTest();

		for(Case caseAssert : [SELECT Status,Id FROM Case WHERE Id IN: testCaseList]){
			if(caseAssert.Id == testCaseWithUnsentEmail.Id){
				System.assert(caseAssert.Status == 'Re-Opened');
			}else if(caseAssert.Id == testCaseWithSentEmail.Id){
				System.assert(caseAssert.Status != 'Re-Opened');
			}
		}
  	}
}