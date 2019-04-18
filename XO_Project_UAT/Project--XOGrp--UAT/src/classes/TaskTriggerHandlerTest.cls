@isTest
public class TaskTriggerHandlerTest {
	@testSetup static void createTestData(){
			TestClassUtility.generateQuotePdfConfig(true);
	}

	private static testmethod void RecordOpportunityStageOnTask() {
		
		SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
												'Complete',
												'{"companyName": "Test Account"}',
												null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
		
		Opportunity testOpportunity = TestClassUtility.createOpportunity(true);
		List<Task> opportunityTasks = new List<Task>();
		
		for (Integer i=0; i < 5; i++) {
			Task t = new Task();
			t.OwnerId = UserInfo.getUserId();
			t.WhatId = testOpportunity.Id;
			t.Subject = 'Call';
			t.CBSS_Disposition_Code__c = 'Payment Information Provided';
			t.Type = 'Call';
			t.Status = 'In Progress';
			t.Priority = 'Normal';
			t.Opportunity_Stage__c = '';
			t.ActivityDate = Date.today();
			opportunityTasks.add(t);
		}

		Out_Of_Office__c testOutOfOffice = new Out_Of_Office__c();
		testOutOfOffice.Assign_From__c = UserInfo.getUserId();
		testOutOfOffice.Start_Date__c = Date.today().addDays(-5);
		testOutOfOffice.End_Date__c = Date.today().addDays(5);
		testOutOfOffice.Assign_Task_To__c = [SELECT Id FROM User LIMIT 1].Id;
		insert testOutOfOffice;

		Test.startTest();
		insert opportunityTasks;

		Test.stopTest();

		Set<Id> opportunityTaskIds = new Set<Id>();
		
		for (Task insertedTask : opportunityTasks) {
			opportunityTaskIds.add(insertedTask.Id);
		}
		
		List<Task> insertedOpportunityTasks = [SELECT Id, Opportunity_Stage__c FROM Task WHERE Id in :opportunityTaskIds];
		
		for (Task insertedTask : insertedOpportunityTasks) {
			System.assert(insertedTask.Opportunity_Stage__c == testOpportunity.StageName);
		}
	}
	
	private static testmethod void RecordThoughtStarterRFPOnTask() {
		User u = [select id from user WHERE UserRole.Name = 'Sales Development' and IsActive = true limit 1];
		System.runAs(u){	
		    GroupMember testGroupMember = new GroupMember();
		    testGroupMember.UserOrGroupId = u.Id;
		    testGroupMember.GroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Sales_Dev_Team'].Id;
		    insert testGroupMember;
		}
		
		SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
			'Complete',
			'{"companyName": "Test Account"}',
			null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		Account testAcc = TestClassUtility.createAccount(true);
		Opportunity testOpportunity = TestClassUtility.createOpportunity(false, testAcc);
		testOpportunity.AccStrategist__c = UserInfo.getUserId();
	    insert testOpportunity;
	    Id pricebookId = Test.getStandardPricebookId();
	    Product2 testProduct2 = TestClassUtility.createProduct2(true);
	    PricebookEntry testPBEntry = TestClassUtility.createPricebookEntry(true,pricebookId, testProduct2);
	    Id thoughtStarterRecordTypeId = Schema.SObjectType.ThoughtStarter_RFP__c.getRecordTypeInfosByName().get('ThoughtStarter').getRecordTypeId();
	    ThoughtStarter_RFP__c TRFP = TestClassUtility.createThoughtStarterRFP(false, testOpportunity, thoughtStarterRecordTypeId, u);
		TRFP.Sales_Developer__c = null;
		insert TRFP;
		Task t = new Task();
		t.OwnerId = u.Id;
		t.WhatId = TRFP.Id;
		t.Subject = 'ThoughtStarter has been submitted';
		t.Purpose__c = 'Other';
		t.Type = 'Call';
		t.Status = 'In Progress';
		t.Priority = 'Normal';
		t.CallObject = 'test';
		Task t2 = new Task();
		t2.OwnerId = u.Id;
		t2.WhatId = TRFP.Id;
		t2.Subject = 'RFP has been approved and ready to be pitched to client!';
		t2.Purpose__c = 'Other';
		t2.Type = 'Call';
		t2.Status = 'In Progress';
		t2.Priority = 'Normal';
		insert new List<Task>{t, t2};

		Test.startTest();
		t.Status = 'Completed';
		t2.Status = 'Completed';
		t.CBSS_Disposition_Code__c = 'Payment Information Provided';
		t2.Strategy_Specialist_Disposition_Code__c = 'Payment Information Provided';
		update new List<Task>{t, t2};

		Test.stopTest();

		t = [select id, CallObject, Task_Completion_Date__c FROM Task WHERE id =: t.Id];
		system.assert(String.isBlank(t.CallObject));
		System.assertEquals(t.Task_Completion_Date__c.date(), system.today());
		
	}

	private static testmethod void RecordAccountOnTask() {
		
		SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
												'Complete',
												'{"companyName": "Test Account"}',
												null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
		Account testAcc = TestClassUtility.createAccount(false);
		testAcc.Past_Due_Balance__c = 1.1;
		insert testAcc;

		List<Task> accountTasks = new List<Task>();
		
		for (Integer i=0; i < 5; i++) {
			Task t = new Task();
			t.OwnerId = UserInfo.getUserId();
			t.WhatId = testAcc.Id;
			t.Subject = 'Call';
			t.Strategy_Specialist_Disposition_Code__c = 'Payment Information Provided';
			t.Type = 'Call';
			t.Status = 'In Progress';
			t.Priority = 'Normal';
			t.Opportunity_Stage__c = '';
			accountTasks.add(t);
		}
		accountTasks[0].CallObject = 'test';
		Test.startTest();
		insert accountTasks;
		Test.stopTest();

		Set<Id> accountTaskIds = new Set<Id>();
		
		for (Task insertedTask : accountTasks) {
			accountTaskIds.add(insertedTask.Id);
		}
		
		List<Task> insertedAccountTasks = [SELECT Id, Account__c FROM Task WHERE Id in :accountTaskIds];
		
		for (Task insertedTask : insertedAccountTasks) {
			System.assert(insertedTask.Account__c == testAcc.Id);
		}
	}
	
	static testMethod void RecordLastResultOnLocalLead() {
		
		// First, insert a Lead and a related Task
		SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200,
												 'Complete',
												 '{"companyName": "Test Account"}',
												 null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);
		
		Test.startTest();
		Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
		
		Market__c testMarket = (Market__c)testObjects.get('Market__c');
		Category__c testCategory = (Category__c)testObjects.get('Category__c');
		Lead testLead = TestClassUtility.createLead(true, testMarket, testCategory);

		Task testTask = new Task(WhoId=testLead.Id,Subject='Call',Type='Call',Status='In Progress',Priority='Normal' );
		insert testTask;
		
		testLead = [SELECT Id, Last_Result__c, Last_Result_Date__c FROM Lead WHERE Id = :testLead.Id];
		
		// Because Task.Status is not 'Completed', Lead.Last_Result__c should not be equal to Task.Subject
		System.assertNotEquals(testLead.Last_Result__c, testTask.Subject);
		
		// Next, update the Task.Status to equal 'Completed'
		testTask.Status = 'Completed';
		testTask = new Task(WhoId=testLead.Id,Subject='Test Complete',Type='Call',Status='Completed',Priority='Normal');
		insert testTask;
		testLead = [SELECT Id, Last_Result__c, Last_Result_Date__c FROM Lead WHERE Id = :testLead.Id];
		//System.assertEquals(testLead.Last_Result__c, testTask.Subject);
		Test.stopTest();
	}

	static testMethod void testSendOnboardEmail(){
		Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
		
		Account testAcct = TestClassUtility.createAccount(false);
      	testAcct.Name = 'testAcct';
      	insert testAcct;

      	Contact testContact = TestClassUtility.createContact(false);
      	testContact.FirstName = 'testContact';
      	testContact.LastName = 'contWithCloseCompletedCase';
      	insert testContact;

      	Case testCase = new Case();
      	testCase.Status = 'new';
      	testCase.AccountId = testAcct.Id;
      	testCase.ContactId = testContact.Id;
      	testCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
      	testCase.VIP_Onboarding_Case__c = TRUE;
      	insert testCase;

      	Messaging.SingleEmailMessage result = NULL;
      	Test.startTest();

      	result = TaskTriggerHandler.sendOnboardEmail(testCase, NULL);

      	Test.stopTest();

      	System.assert(result != NULL);
	}

	static testMethod void testOnboardingCall(){
		insert new Onboarding_Email_Automation_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Is_VIP_Email_Automated__c=true, Is_General_Email_Automated__c=true);

		Id businessHourId = [SELECT Id FROM BusinessHours WHERE Name = 'XO Business Hours' LIMIT 1].Id;
		Date activityDate = System.today();
		Datetime onboardingDate = addBusinessDays(businessHourId, activityDate, 3);
		Date expectedFollowUpActivityDate = addBusinessDays(businessHourId, activityDate, 1).date();

		String content = 'Review Details:\r\n';
			 content += 'Review Id: 1356749,\r\n';
			 content += 'Storefront Id: 6fc9aed0-29c7-4cee-be59-a38f00f7a395,\r\n'; 
			 content += 'Display Id: 665527,\r\n';
			 content += 'Date: 10/3/2016 10:14 AM,\r\n';
			 content += 'Reviewer: 2840263e-d206-4551-bcc5-6818d76772c2.\r\n';


		Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Account account = TestClassUtility.createAccount(false);
		account.Strategy_Specialist__c = UserInfo.getUserId();
		insert account;

		Contact contact = TestClassUtility.createContact(true, account);

		List<Case> caselist = createCases(content, rtMapByName.get('2 - Onboarding').getRecordTypeId(), contact, 12);

		insert caselist;
		Task task1 = createTask(caselist[0], 'Not Started', 'Onboarding Scheduling', 'Immediate Onboard', activityDate, onboardingDate);
		Task task2 = createTask(caselist[1], 'Not Started', 'Onboarding Scheduling', 'Scheduled Onboard', activityDate, onboardingDate);
		Task task3 = createTask(caselist[2], 'Not Started', 'Onboarding Scheduling', 'Declined Onboard', activityDate, onboardingDate);
		Task task4 = createTask(caselist[3], 'Not Started', 'Onboarding Scheduling', 'No Answer', activityDate, onboardingDate);
		Task task5 = createTask(caselist[4], 'Not Started', 'Onboarding Call', 'Rescheduled Onboard', activityDate, onboardingDate);
		Task task6 = createTask(caselist[5], 'Not Started', 'Onboarding Call', 'Cancelled Onboard', activityDate, onboardingDate);
		Task task7 = createTask(caselist[6], 'Not Started', 'Onboarding Call', 'Left Message', activityDate, onboardingDate);
		Task task8 = createTask(caselist[7], 'Not Started', 'Onboarding Call', 'Completed Onboard', activityDate, onboardingDate);
		Task task9 = createTask(caselist[8], 'Not Started', 'Onboarding Call', 'Declined Onboard', activityDate, onboardingDate);
		Task task10 = createTask(caselist[9], 'Not Started', 'Onboarding Scheduling', 'Send Calendar Link', activityDate, onboardingDate);
		Task task11 = createTask(caselist[10], 'Not Started', 'Onboarding Call', 'Send Calendar Link', activityDate, onboardingDate);
		Task task12 = createTask(caselist[11], 'Completed', 'Onboarding Call', '', activityDate, onboardingDate);
		List<Task> tasklist = new List<Task>();

		tasklist.add(task1);
		tasklist.add(task2);
		tasklist.add(task3);
		tasklist.add(task4);
		tasklist.add(task5);
		tasklist.add(task6);
		tasklist.add(task7);
		tasklist.add(task8);
		tasklist.add(task9);
		tasklist.add(task10);
		tasklist.add(task11);
		tasklist.add(task12);
		insert tasklist;
		
		for(Task tempTask : tasklist){
			tempTask.Status = 'Completed';
			if(String.isBlank(tempTask.Onboarding_Task_Outcome__c)){
				tempTask.Onboarding_Task_Outcome__c = 'Completed Onboard';
			}
		}

		Test.startTest();

		update tasklist;

		Integer invocations = Limits.getEmailInvocations();
    	System.assert(invocations > 0);

		Test.stopTest();

		List<Task> TaskListAssert = [select id, Dispostition_Type__c FROM Task WHERE Dispostition_Type__c = 'SS Core'];
		System.assert(TaskListAssert.size() > 10);
		for(Task followupTaskAssert : [SELECT ActivityDate, Strategy_Specialist_Disposition_Code__c 
										FROM Task WHERE Purpose__c = 'Onboarding' 
										AND Status = 'Not Started' 
										AND WhatId IN: caselist]){
			if(followupTaskAssert.Strategy_Specialist_Disposition_Code__c == 'Onboarding Call'){

				System.assert(followupTaskAssert.ActivityDate == onboardingDate.date());
			}else if(followupTaskAssert.Strategy_Specialist_Disposition_Code__c == 'Onboarding Scheduling'){
				
				System.assert(followupTaskAssert.ActivityDate == expectedFollowUpActivityDate);
			}
		}
	}


	public static List<Case> createCases(String content, String recordtypeId, Contact con, Integer newCaseQuantity){

		List<Case> cases = new List<Case>();

		for(Integer i = 0; i < newCaseQuantity; i++){
			Case mockCase = new Case();
			mockCase.Description = content;
			mockCase.recordTypeId = recordtypeId; 
			mockCase.no_show_attempts__c = '0';
			mockCase.follow_up_attempts__c = '0';
			mockCase.attempts__c = '0';
			mockCase.SuppliedEmail = con.Email;
			cases.add(mockCase);
		}
		
		return cases;
	}

	public static Task createTask(Case mockCase, String status, String ssDispositionCode, String outcome, Date activityDate, Datetime onboardingDate){

		Task obTask = new Task();
		obTask.Type = 'Call';
		obTask.Purpose__c = 'Onboarding';
		obTask.Status = status;
		obTask.Dispostition_Type__c= 'SS Core';
		obTask.Strategy_Specialist_Disposition_Code__c = ssDispositionCode;
		obTask.Onboarding_Task_Outcome__c = (String.isBlank(outcome))? null: outcome;
		obTask.Subject ='test Task 001';
		obTask.WhatId = mockCase.Id;
		obTask.Onboard_Automation__c = true;
		obTask.ActivityDate = activityDate;
		obTask.Onboarding_Date__c = onboardingDate;
		return obTask;
	}
	
	private static Datetime addBusinessDays(Id businessHourId, Date startDate, Integer businessDays){
	    Datetime finalDatetime;
	    Datetime startDateTime = Datetime.newInstance(StartDate, Time.newInstance(12, 00, 00, 0000));

	    if(businessDays != 0 && businessHourId != NULL) {
	      Integer milliseconds =  businessDays * 9* 60* 60* 1000;
	      Datetime nextBusinessDateTime = BusinessHours.add(businessHourId, startDateTime, milliseconds);
	      finalDatetime = nextBusinessDateTime;
	    }

	    return finalDatetime;
  	}
}