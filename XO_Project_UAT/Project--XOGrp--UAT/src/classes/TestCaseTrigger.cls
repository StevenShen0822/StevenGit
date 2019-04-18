@isTest
private class TestCaseTrigger {
  @testSetup static void createTestData(){
    Group testAssetCollectionGroup = new Group(Name = 'Asset Collection Queue', type = 'Queue');
    Group testInboundCaseGroup = new Group(Name = 'Inbound Case Queue', type = 'Queue');
    Group testOnboardingCaseGroup = new Group(Name = 'Onboarding case queue', type = 'Queue');
    Group testVIPCaseGroup = new Group(Name = 'VIP Queue', type = 'Queue');
    insert new List<Group>{testAssetCollectionGroup, testInboundCaseGroup, testOnboardingCaseGroup, testVIPCaseGroup};

    QueuesObject testAssetCollectionQueue = new QueueSObject(QueueID = testAssetCollectionGroup.Id, SobjectType = 'Case');
    QueuesObject testInboundCaseQueue = new QueueSObject(QueueID = testInboundCaseGroup.Id, SobjectType = 'Case');
    QueuesObject testOnboardingCaseQueue = new QueueSObject(QueueID = testOnboardingCaseGroup.Id, SobjectType = 'Case');
    QueuesObject testVIPCaseQueue = new QueueSObject(QueueID = testVIPCaseGroup.Id, SobjectType = 'Case');
    insert new List<QueuesObject>{testAssetCollectionQueue, testInboundCaseQueue, testOnboardingCaseQueue, testVIPCaseQueue};
  }

  @isTest static void createCaseWithoutRecordType() {
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
    User user = TestClassUtility.createUser(false, profile);
    System.runAs(user) {
      Case mockCase = new Case();

      Test.startTest();
      insert mockCase;
      Test.stopTest();

      system.assert(mockCase.Id != null); 
    }
  }

  @isTest static void createReviewCase() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
    User u = new User(
      Alias = 'standt', 
      isActive = true,
      title = 'Account Manager',
      Email = 'testEmail@test.com',
      EmailEncodingKey = 'UTF-8', 
      LastName = 'Testing', 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', 
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles', 
      SalesRepID__c = '12345',
      UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
    );
    insert u;

    Test.startTest();

    String content = 'Review Details:\r\n';
           content += 'Review Id: 1356749,\r\n';
           content += 'Storefront Id: 6fc9aed0-29c7-4cee-be59-a38f00f7a395,\r\n'; 
           content += 'Display Id: 665527,\r\n';
           content += 'Date: 10/3/2016 10:14 AM,\r\n';
           content += 'Reviewer: 2840263e-d206-4551-bcc5-6818d76772c2.\r\n';

    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Map<String,Schema.RecordTypeInfo> rtAccMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Account acc = TestClassUtility.createAccount(false);
    acc.RecordTypeId = rtAccMapByName.get('Local').getRecordTypeId();
    acc.Email__c = 'testEmail@test.com';
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    acc.OwnerId = u.Id;
    insert acc;

    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Contact con2 = TestClassUtility.createContact(false, acc);
    Database.DMLOptions newDMLO = new Database.DMLOptions();
    newDMLO.DuplicateRuleHeader.allowSave = true;
    Database.insert(con2, newDMLO);

    Case mockCase0 = new Case();
    mockCase0.Description = content;  
    mockCase0.recordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
    mockCase0.SuppliedEmail = con.Email;
    mockCase0.AccountId = acc.id;

    Case mockCase1 = new Case();
    mockCase1.Description = content;
    mockCase1.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase1.SuppliedEmail = con.Email;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase2.AccountId = acc.id;

    Case mockCase3 = new Case();
    mockCase3.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase3.ContactId = con.id;

    Case mockCase4 = new Case();
    mockCase4.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase4.ContactId = con.id;
    mockCase4.Status = 'new';

    Case mockCase5 = new Case();
    mockCase5.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase5.ContactId = con.id;
    mockCase5.SuppliedEmail = con.Email;

    Case mockCase6 = new Case();
    mockCase6.Description = content;  
    mockCase6.recordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
    mockCase6.SuppliedEmail = con.Email;

    insert new list<Case>{mockCase0, mockCase1, mockCase2, mockCase3, mockCase4, mockCase5, mockCase6};

    mockCase3.ContactId = con2.id;

    mockCase4.Status = 'Waiting on Edit';

    update new List<Case>{mockCase3, mockCase4};

    Test.stopTest();

    for(Case caseAssert : [SELECT Response_TimeStamp__c, Response_Times__c, Reported_by__c, SuppliedEmail, 
                            Auto_Reply_Flag__c, Reporter_User_Name__c, Reporter_Type__c
                            FROM Case]){
      if(caseAssert.Id == mockCase0.Id){
        system.assert(caseAssert.Reported_by__c == caseAssert.SuppliedEmail);
        system.assert(caseAssert.Auto_Reply_Flag__c == true);
      }else if(caseAssert.Id == mockCase4.Id){
        system.assert(caseAssert.Response_TimeStamp__c != null);
        system.assert(caseAssert.Response_Times__c != null);
      }
    }
  }

  @isTest static void createReviewCase2() {  
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
    User u = new User(
      Alias = 'standt', 
      Email = 'abc@abc.com',
      EmailEncodingKey = 'UTF-8', 
      isActive = true,
      LastName = 'Testing', 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', 
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles', 
      SalesRepID__c = '12345',
      UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
    );
    User u2 = new User(
      Alias = 'stand', 
      Email = 'abc@abc.com',
      EmailEncodingKey = 'UTF-8', 
      isActive = true,
      LastName = 'Testing2', 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', 
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles', 
      SalesRepID__c = '54321',
      UserName = 'standarduser2' + DateTime.now().getTime() + '@testorg.com'
    );
    insert new list<User>{u, u2};

    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    List<Account> listAccounts = new list<Account>();
    Account acc = TestClassUtility.createAccount(false);
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    acc.Email__c = 'abc@abc.com';
    listAccounts.add(acc);

    Account acc2 = TestClassUtility.createAccount(false);
    acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local').getRecordTypeId();
    acc2.Strategy_Specialist__c = UserInfo.getUserId();
    acc2.Email__c = 'abc@abc.com';
    listAccounts.add(acc2);
    
    Database.DMLOptions newDMLO = new Database.DMLOptions();
    newDMLO.DuplicateRuleHeader.allowSave = true;
    Database.insert(listAccounts, newDMLO);

    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = 'abc@abc.com';
    insert con;
    
    Case mockCase = new Case();
    
    mockCase.recordTypeId = rtMapByName.get('3 - Reviews').getRecordTypeId();
    mockCase.SuppliedEmail = 'abc@abc.com';

    Test.startTest();

    insert mockCase;

    Test.stopTest();

    Case caseAssert = [SELECT Reporter_User_Name__c,Reporter_Type__c FROM Case WHERE Id =: mockCase.Id Limit 1];
    system.assert(caseAssert.Reporter_User_Name__c == null);
    system.assert(caseAssert.Reporter_Type__c == null);
  }

  @isTest static void createCancelCase() {
    String content = 'Review Details:\r\n';
           content += 'Review Id: 1356749,\r\n';
           content += 'Storefront Id: 6fc9aed0-29c7-4cee-be59-a38f00f7a395,\r\n'; 
           content += 'Display Id: 665527,\r\n';
           content += 'Date: 10/3/2016 10:14 AM,\r\n';
           content += 'Reviewer: 2840263e-d206-4551-bcc5-6818d76772c2.\r\n';

    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

    Account acc = TestClassUtility.createAccount(true);
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    acc.ActiveSubscriptionTCVSummary__c = 5001;
    update acc;

    Account acc2 = TestClassUtility.createAccount(true);
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    acc.ActiveSubscriptionTCVSummary__c = 4500;
    update acc2;

    Contact con = TestClassUtility.createContact(true, acc);
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
    User u = new User(
      Alias = 'standt', 
      Email = con.Email,
      EmailEncodingKey = 'UTF-8', 
      isActive = true,
      LastName = 'Testing', 
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US', 
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles', 
      SalesRepID__c = '12345',
      UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
    );
    insert u;
    
    Case mockCaseWithoutEmail = new Case();
    mockCaseWithoutEmail.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();
    mockCaseWithoutEmail.Description = content;
    mockCaseWithoutEmail.AccountId = acc.id;
    mockCaseWithoutEmail.ContactId = con.id;

    Case mockCaseWithEmail = new Case();
    mockCaseWithEmail.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();
    mockCaseWithEmail.Description = content;
    mockCaseWithEmail.ContactId = con.id;
    mockCaseWithEmail.SuppliedEmail = con.Email;

    Case mockCaseWithoutEmail2 = new Case();
    mockCaseWithoutEmail2.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();
    mockCaseWithoutEmail2.Description = content;
    mockCaseWithoutEmail2.AccountId = acc2.id;
    mockCaseWithoutEmail2.ContactId = con.id;

    Case mockCaseWithoutAccount = new Case();
    mockCaseWithoutAccount.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();
    mockCaseWithoutAccount.Description = content;
    mockCaseWithoutAccount.ContactId = con.id;

    Test.startTest();

    insert new list<Case>{mockCaseWithoutEmail, mockCaseWithEmail, mockCaseWithoutEmail2, mockCaseWithoutAccount};

    Test.stopTest();

    for(Case caseAssert : [SELECT Priority, Reporter_User_Name__c FROM Case]){
      if(caseAssert.Id == mockCaseWithEmail.Id){
        system.assert(caseAssert.Reporter_User_Name__c != null);
      }else if(caseAssert.Id == mockCaseWithoutEmail.Id){
        system.assert(caseAssert.Priority == 'High');
      }else if(caseAssert.Id == mockCaseWithoutEmail2.Id){
        system.assert(caseAssert.Priority == 'Medium');
      }
    }
  }

  @isTest static void updateCancelCase(){
    
    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

    Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);
    Account acct = (Account)mapLocalData.get('Account');
    Contact cont = (Contact)mapLocalData.get('Contact');
    Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

    Case testCaseWithAccId = new Case();
    testCaseWithAccId.Status = 'new';
    testCaseWithAccId.AccountId = acct.Id;
    testCaseWithAccId.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

    Case testCaseWithOwnerId = new Case();
    testCaseWithOwnerId.Status = 'new';
    testCaseWithOwnerId.AccountId = acct.Id;
    testCaseWithOwnerId.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

    Case testCaseWithoutAccId = new Case();
    testCaseWithoutAccId.Status = 'new';
    testCaseWithoutAccId.AccountId = acct.Id;
    testCaseWithoutAccId.ContactId = cont.Id;
    testCaseWithoutAccId.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

    Case testCaseWithAccId2 = new Case();
    testCaseWithAccId2.Status = 'new';
    testCaseWithAccId2.AccountId = acct.Id;
    testCaseWithAccId2.recordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

    insert new List<Case>{testCaseWithAccId, testCaseWithoutAccId, testCaseWithOwnerId, testCaseWithAccId2};

    Feature_Requested_Cancelled__c testCancelledFRC = new Feature_Requested_Cancelled__c();
    testCancelledFRC.Case__c = testCaseWithAccId.Id;
    testCancelledFRC.Status__c = 'Cancelled';
    testCancelledFRC.UniqueId__c = '1234';  

    Feature_Requested_Cancelled__c testNoCancelledFRC = new Feature_Requested_Cancelled__c();
    testNoCancelledFRC.Case__c = testCaseWithAccId2.Id;
    testNoCancelledFRC.Status__c = 'Cancelled';
    testNoCancelledFRC.Subscription_Product_Charge__c = testSubscriptionProductCharge.Id;
    testNoCancelledFRC.UniqueId__c = '123';  
    insert new List<Feature_Requested_Cancelled__c>{testCancelledFRC, testNoCancelledFRC};

    Test.startTest();
    testCaseWithOwnerId.OwnerId = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() LIMIT 1].Id;

    testCaseWithoutAccId.AccountId = null;

    testCaseWithAccId2.Outcome__c = 'Cancelled';
    testCaseWithAccId2.Status = 'Closed';
    testCaseWithAccId2.Case_Closed_Flag__c = false;

    List<Case> caseListToUpdate = new List<Case>{testCaseWithOwnerId, testCaseWithoutAccId, testCaseWithAccId2};
    Database.update(caseListToUpdate, false);

    Integer invocations = Limits.getEmailInvocations();
    system.assert(invocations > 0);
    Test.stopTest();
  }

  @isTest static void updateOnboardingCase(){
    User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
    Group testGroup;
    QueuesObject testQueue;
    System.runAs(u){
      testGroup = new Group(Name = 'test group', type = 'Queue');
      insert testGroup;

      testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
      insert testQueue;
    }
    
    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

    Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);
    Account acct = (Account)mapLocalData.get('Account');
    Contact cont = (Contact)mapLocalData.get('Contact');
   
    Account acct2 = TestClassUtility.createAccount(false);
    acct2.Name = 'testAccount2';
    insert acct2;

    Contact cont2 = TestClassUtility.createContact(false);
    cont2.FirstName = 'Rogers';
    cont2.LastName = 'testContact2';
    insert cont2;

    Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

    Case testNoCancelledCase = new Case();
    testNoCancelledCase.Status = 'new';
    testNoCancelledCase.AccountId = acct.Id;
    testNoCancelledCase.ContactId = cont.Id;
    testNoCancelledCase.recordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();

    Case testCaseWithQueue = new Case();
    testCaseWithQueue.Status = 'new';
    testCaseWithQueue.AccountId = acct2.Id;
    testCaseWithQueue.ContactId = cont2.Id;
    testCaseWithQueue.OwnerId = testGroup.Id;
    testCaseWithQueue.recordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
    Test.startTest();
    insert new List<Case>{testNoCancelledCase, testCaseWithQueue};
    
    Feature_Requested_Cancelled__c testNoCancelledFRC = new Feature_Requested_Cancelled__c();
    testNoCancelledFRC.Case__c = testNoCancelledCase.Id;
    testNoCancelledFRC.Status__c = 'Cancelled';
    testNoCancelledFRC.Subscription_Product_Charge__c = testSubscriptionProductCharge.Id;
    testNoCancelledFRC.UniqueId__c = '123';  
    insert testNoCancelledFRC;

    testCaseWithQueue.OwnerId = UserInfo.getUserId();
    testNoCancelledCase.Outcome__c = 'Cancelled';
    testNoCancelledCase.Status = 'Closed';
    testNoCancelledCase.Case_Closed_Flag__c = false;
    update new List<Case>{testNoCancelledCase, testCaseWithQueue};
   
    Test.stopTest();

    List<Task> onboardingTaskList = [SELECT Id FROM Task WHERE Purpose__c = 'Onboarding'];
    system.assert(onboardingTaskList.size() > 0);
  }

  @isTest static void testCloseCompletedOnboardingCaseEmail_Positive(){
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

      insert new Onboarding_Email_Automation_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Is_VIP_Email_Automated__c=true, Is_General_Email_Automated__c=true);

      Profile profile = [SELECT Id FROM Profile WHERE Name = 'Local Core Strategy Specialist' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, profile);
      testUser.ManagerId = Userinfo.getUserId();
      System.runAs(testUser){
        Account acctWithCloseCompletedCase = TestClassUtility.createAccount(false);
        acctWithCloseCompletedCase.Name = 'acctWithCloseCompletedCase';
        insert acctWithCloseCompletedCase;

        Contact contWithCloseCompletedCase = TestClassUtility.createContact(false);
        contWithCloseCompletedCase.FirstName = 'testContact';
        contWithCloseCompletedCase.LastName = 'contWithCloseCompletedCase';
        insert contWithCloseCompletedCase;

        Case testCloseCompletedCase = new Case();
        testCloseCompletedCase.Status = 'new';
        testCloseCompletedCase.AccountId = acctWithCloseCompletedCase.Id;
        testCloseCompletedCase.ContactId = contWithCloseCompletedCase.Id;
        testCloseCompletedCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
        testCloseCompletedCase.VIP_Onboarding_Case__c = TRUE;
        testCloseCompletedCase.Send_Onboarding_Email_Manually__c = FALSE;
        testCloseCompletedCase.OwnerId = testUser.Id;
        insert testCloseCompletedCase;

        testCloseCompletedCase.Status = 'Closed Completed';

        Test.startTest();

        update testCloseCompletedCase;
        
        Integer invocations = Limits.getEmailInvocations();
        System.assert(invocations > 0);

        Test.stopTest();
      }
      
  }

  @isTest static void testCloseCompletedOnboardingCaseEmail_Negative(){
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

      Profile profile = [SELECT Id FROM Profile WHERE Name = 'Local Core Strategy Specialist' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, profile);
      testUser.ManagerId = Userinfo.getUserId();
      System.runAs(testUser){
        Account acctWithCloseCompletedCase = TestClassUtility.createAccount(false);
        acctWithCloseCompletedCase.Name = 'acctWithCloseCompletedCase';
        insert acctWithCloseCompletedCase;

        Contact contWithCloseCompletedCase = TestClassUtility.createContact(false);
        contWithCloseCompletedCase.FirstName = 'testContact';
        contWithCloseCompletedCase.LastName = 'contWithCloseCompletedCase';
        insert contWithCloseCompletedCase;

        Case testCloseCompletedCase = new Case();
        testCloseCompletedCase.Status = 'new';
        testCloseCompletedCase.AccountId = acctWithCloseCompletedCase.Id;
        testCloseCompletedCase.ContactId = contWithCloseCompletedCase.Id;
        testCloseCompletedCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
        testCloseCompletedCase.OwnerId = testUser.Id;
        testCloseCompletedCase.VIP_Onboarding_Case__c = TRUE;
        insert testCloseCompletedCase;

        testCloseCompletedCase.Status = 'Closed Completed';

        Test.startTest();

        update testCloseCompletedCase;
        
        Integer invocations = Limits.getEmailInvocations();
        System.assert(invocations == 0);

        Test.stopTest();
      }
      
  }

  @isTest static void testCloseDeclinedOnboardingCaseEmail(){
   
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

      Account acctWithCloseDeclinedCase = TestClassUtility.createAccount(false);
      acctWithCloseDeclinedCase.Name = 'acctWithCloseDeclinedCase';
      insert acctWithCloseDeclinedCase;

      Contact contWithCloseDeclinedCase = TestClassUtility.createContact(false);
      contWithCloseDeclinedCase.FirstName = 'testContact';
      contWithCloseDeclinedCase.LastName = 'contWithCloseDeclinedCase';
      insert contWithCloseDeclinedCase;

      Case testCloseDeclinedCase = new Case();
      testCloseDeclinedCase.Status = 'new';
      testCloseDeclinedCase.AccountId = acctWithCloseDeclinedCase.Id;
      testCloseDeclinedCase.ContactId = contWithCloseDeclinedCase.Id;
      testCloseDeclinedCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
      insert testCloseDeclinedCase;
      
      testCloseDeclinedCase.Status = 'Closed Declined';
      
      Test.startTest();

      update testCloseDeclinedCase;
      
      Integer invocations = Limits.getEmailInvocations();
      System.assert(invocations == 0);

      Test.stopTest();
  }
  
  @isTest static void testCloseCancelCaseTypeClientSolutions(){
    
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

        TestClassUtility.DISABLE_TRIGGERS = TRUE; 

        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUserClientSolutions = TestClassUtility.createUser(false, profileRecord);
        testUserClientSolutions.Title = System.Label.Close_Cancel_Case_Owner_Title;
        insert testUserClientSolutions;

        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);
        Account acct = (Account)mapLocalData.get('Account');
        Contact cont = (Contact)mapLocalData.get('Contact');
        Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

        Case testCaseWithAccIdClientSolutions = new Case();
        testCaseWithAccIdClientSolutions.OwnerId = testUserClientSolutions.Id;
        testCaseWithAccIdClientSolutions.Status = 'new';
        testCaseWithAccIdClientSolutions.AccountId = acct.Id;
        testCaseWithAccIdClientSolutions.RecordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

        insert testCaseWithAccIdClientSolutions;

        Feature_Requested_Cancelled__c testClientSolutionsCancelledFRC = new Feature_Requested_Cancelled__c();
        testClientSolutionsCancelledFRC.Case__c = testCaseWithAccIdClientSolutions.Id;
        testClientSolutionsCancelledFRC.Status__c = 'Cancelled';
        testClientSolutionsCancelledFRC.Subscription_Product_Charge__c = testSubscriptionProductCharge.Id;
        testClientSolutionsCancelledFRC.UniqueId__c = '1236';
        insert testClientSolutionsCancelledFRC;

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        testCaseWithAccIdClientSolutions.Outcome__c = 'Cancelled';
        testCaseWithAccIdClientSolutions.Status = 'Closed';
        update testCaseWithAccIdClientSolutions;

        Test.stopTest();
        List<Case> listCaseAssert = [SELECT Case_Closed_Flag__c, Cancel_Case_Type__c, Case_Owner_Close__c, OwnerId 
                                      FROM Case 
                                      WHERE Id =: testCaseWithAccIdClientSolutions.Id 
                                      LIMIT 1];
        System.assert(!listCaseAssert.isEmpty());
        Case caseAssert = listCaseAssert.get(0);
        System.assert(caseAssert.Case_Closed_Flag__c == TRUE);
        System.assert(caseAssert.Cancel_Case_Type__c == 'Service');
        System.assert(caseAssert.Case_Owner_Close__c == caseAssert.OwnerId);
  }

  @isTest static void testCloseCancelCaseTypeNoClientSolutions(){
    
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

      TestClassUtility.DISABLE_TRIGGERS = TRUE; 

      Profile profileRecord = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUserNoClientSolutions = TestClassUtility.createUser(false, profileRecord);
      testUserNoClientSolutions.Title = 'NoCS';
      insert testUserNoClientSolutions;

      Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);
      Account acct = (Account)mapLocalData.get('Account');
      Contact cont = (Contact)mapLocalData.get('Contact');
      Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

      Case testCaseWithAccIdNoClientSolutions = new Case();
      testCaseWithAccIdNoClientSolutions.OwnerId = testUserNoClientSolutions.Id;
      testCaseWithAccIdNoClientSolutions.Status = 'new';
      testCaseWithAccIdNoClientSolutions.AccountId = acct.Id;
      testCaseWithAccIdNoClientSolutions.RecordTypeId = rtMapByName.get('1 - Cancels').getRecordTypeId();

      insert testCaseWithAccIdNoClientSolutions;

      Feature_Requested_Cancelled__c testNoClientSolutionsCancelledFRC = new Feature_Requested_Cancelled__c();
      testNoClientSolutionsCancelledFRC.Case__c = testCaseWithAccIdNoClientSolutions.Id;
      testNoClientSolutionsCancelledFRC.Status__c = 'Cancelled';
      testNoClientSolutionsCancelledFRC.Subscription_Product_Charge__c = testSubscriptionProductCharge.Id;
      testNoClientSolutionsCancelledFRC.UniqueId__c = '1236';
      insert testNoClientSolutionsCancelledFRC;
      
      TestClassUtility.DISABLE_TRIGGERS = FALSE;

      Test.startTest();

      testCaseWithAccIdNoClientSolutions.Outcome__c = 'Cancelled';
      testCaseWithAccIdNoClientSolutions.Status = 'Closed';
      update testCaseWithAccIdNoClientSolutions;

      Test.stopTest();
      
      List<Case> listCaseAssert  = [SELECT Case_Closed_Flag__c, Cancel_Case_Type__c, Case_Owner_Close__c, OwnerId 
                                    FROM Case 
                                    WHERE Id =: testCaseWithAccIdNoClientSolutions.Id 
                                    LIMIT 1];
      System.assert(!listCaseAssert.isEmpty());
      Case caseAssert = listCaseAssert.get(0);
      System.assert(caseAssert.Case_Closed_Flag__c == TRUE);
      System.assert(caseAssert.Cancel_Case_Type__c == 'BoB');
      System.assert(caseAssert.Case_Owner_Close__c == caseAssert.OwnerId);
  }
  
  @isTest static void testCloseCaseWithSaved(){
   
      Account acc = TestClassUtility.createAccount(true);
      Contact con = TestClassUtility.createContact(true, acc);

      Case mockCase = TestClassUtility.createCase(true, acc, con) ;
      
      Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);
      Zuora__SubscriptionProductCharge__c testSubscriptionProductCharge = (Zuora__SubscriptionProductCharge__c)mapLocalData.get('Zuora__SubscriptionProductCharge__c');

      Live_Subscription__c liveSub = TestClassUtility.createLiveSub(true, acc);

      Live_Subscription_Product_and_Charge__c liveCharge = TestClassUtility.createliveCharge(true, acc, liveSub);

      Account_Snapshots__c accSnap = TestClassUtility.createAccSnap(true, mockCase);
      
      Feature_Requested_Cancelled__c testCancelledFRC = new Feature_Requested_Cancelled__c();
      testCancelledFRC.Case__c = mockCase.Id;
      testCancelledFRC.Status__c = 'Cancelled';
      testCancelledFRC.UniqueId__c = '1234'; 
      testCancelledFRC.Subscription_Product_Charge__c = testSubscriptionProductCharge.Id;
      insert testCancelledFRC;

      mockCase.Status = 'Closed';
      mockCase.Outcome__c = 'Saved';

      
      Test.startTest();

      update mockCase;
      
      Test.stopTest();  
      List<Account_Snapshots__c> listAccSnap = [SELECT id, Account_Value__c FROM Account_Snapshots__c];
      
      System.assert(listAccSnap.size() > 0);

  }

  @isTest static void testUpdateFieldFromDescription_Full() {
    Map<String,Schema.RecordTypeInfo> rtCaseMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Map<String,Schema.RecordTypeInfo> rtAccMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

    String fullCustomDescription = 'A custom description.'
                                + 'Review Details:\r\n'
                                + 'Review Id: 1356749,\r\n'
                                + 'Storefront Id: 6fc9aed0-29c7-4cee-be59-a38f00f7a395,\r\n'
                                + 'Display Id: ,\r\n'
                                + 'Date: 201,\r\n'
                                + 'Reviewer: 2840263e-d206-4551-bcc5-6818d76772c2.\r\n';

    Account acc = TestClassUtility.createAccount(false);
    acc.RecordTypeId = rtAccMapByName.get('Local').getRecordTypeId();
    acc.Email__c = 'testEmail@test.com';
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    insert acc;

    Case caseWithFullDescription = new Case();
    caseWithFullDescription.Description_Custom__c = fullCustomDescription;  
    caseWithFullDescription.RecordTypeId = rtCaseMapByName.get('3 - Reviews').getRecordTypeId();
    caseWithFullDescription.AccountId = acc.Id;
    caseWithFullDescription.Review_Id__c = '001';

    Test.startTest();

    insert caseWithFullDescription;

    Test.stopTest();

    List<Case> listCaseAssert = [SELECT review_id__c, storefront_id__c, display_id__c,
                                  date_of_review__c, reviewer_string__c
                                  FROM Case 
                                  WHERE Id =: caseWithFullDescription.Id];

    System.assert(!listCaseAssert.isEmpty());
    Case caseAssert = listCaseAssert.get(0);
    System.assertEquals('001', caseAssert.Review_Id__c);
    System.assertEquals('6fc9aed0-29c7-4cee-be59-a38f00f7a395', caseAssert.Storefront_Id__c);
    System.assertEquals(null, caseAssert.Display_Id__c);
    System.assertEquals(null, caseAssert.Date_Of_Review__c);
    System.assertEquals('2840263e-d206-4551-bcc5-6818d76772c2', caseAssert.Reviewer_String__c);
  }

  @isTest static void testUpdateFieldFromDescription_Blank() {
    Map<String,Schema.RecordTypeInfo> rtCaseMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Map<String,Schema.RecordTypeInfo> rtAccMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

    Account acc = TestClassUtility.createAccount(false);
    acc.RecordTypeId = rtAccMapByName.get('Local').getRecordTypeId();
    acc.Email__c = 'testEmail@test.com';
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    insert acc;

    Case caseWithBlankDescription = new Case();
    caseWithBlankDescription.Description_Custom__c = null;  
    caseWithBlankDescription.RecordTypeId = rtCaseMapByName.get('3 - Reviews').getRecordTypeId();
    caseWithBlankDescription.AccountId = acc.Id;

    Test.startTest();

    insert caseWithBlankDescription;

    Test.stopTest();

    List<Case> listCaseAssert = [SELECT review_id__c, storefront_id__c, display_id__c,
                                  date_of_review__c, reviewer_string__c
                                  FROM Case 
                                  WHERE Id =: caseWithBlankDescription.Id];

    System.assert(!listCaseAssert.isEmpty());
    Case caseAssert = listCaseAssert.get(0);
    System.assertEquals(null, caseAssert.Review_Id__c);
    System.assertEquals(null, caseAssert.Storefront_Id__c);
    System.assertEquals(null, caseAssert.Display_Id__c);
    System.assertEquals(null, caseAssert.Date_Of_Review__c);
    System.assertEquals(null, caseAssert.Reviewer_String__c);
  }

  @isTest static void testUpdateFieldFromDescription_Incomplete() {
    Map<String,Schema.RecordTypeInfo> rtCaseMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Map<String,Schema.RecordTypeInfo> rtAccMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();

    Account acc = TestClassUtility.createAccount(false);
    acc.RecordTypeId = rtAccMapByName.get('Local').getRecordTypeId();
    acc.Email__c = 'testEmail@test.com';
    acc.Strategy_Specialist__c = UserInfo.getUserId();
    insert acc;

    Case caseWithIncompleteDescription = new Case();
    caseWithIncompleteDescription.Description_Custom__c = 'A custom description without any field.';  
    caseWithIncompleteDescription.RecordTypeId = rtCaseMapByName.get('3 - Reviews').getRecordTypeId();
    caseWithIncompleteDescription.AccountId = acc.Id;

    Test.startTest();

    insert caseWithIncompleteDescription;

    Test.stopTest();

    List<Case> listCaseAssert = [SELECT review_id__c, storefront_id__c, display_id__c,
                                  date_of_review__c, reviewer_string__c
                                  FROM Case 
                                  WHERE Id =: caseWithIncompleteDescription.Id];

    System.assert(!listCaseAssert.isEmpty());
    Case caseAssert = listCaseAssert.get(0);
    System.assertEquals(null, caseAssert.Review_Id__c);
    System.assertEquals(null, caseAssert.Storefront_Id__c);
    System.assertEquals(null, caseAssert.Display_Id__c);
    System.assertEquals(null, caseAssert.Date_Of_Review__c);
    System.assertEquals(null, caseAssert.Reviewer_String__c);
  }

  @isTest static void testReassignTaskOnCaseOwnerUpdate() {
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      Account testAccount = TestClassUtility.createAccount(true);
      Contact testContact = TestClassUtility.createContact(true, testAccount);


      Case assetCaseWithAcct = new Case();
      assetCaseWithAcct.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();
      assetCaseWithAcct.AccountId = testAccount.Id;
      assetCaseWithAcct.OwnerId = UserInfo.getUserId();
      insert assetCaseWithAcct;

      Task testTask = TestClassUtility.createTask(false);
      testTask.WhoId = testContact.Id;
      testTask.WhatId = assetCaseWithAcct.Id;
      insert testTask;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;

      Test.startTest();

      assetCaseWithAcct.OwnerId = testUser.Id;
      update assetCaseWithAcct;

      Test.stopTest();

      List<Task> listTaskAssert = [SELECT OwnerId FROM Task WHERE Id =: testTask.Id];
      System.assert(!listTaskAssert.isEmpty());
      System.assert(listTaskAssert[0].OwnerId == testUser.Id);
  }

  @isTest static void testUnifyCaseOwnerForSameAccount() {
    TestClassUtility.DISABLE_TRIGGERS = TRUE;

    List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Asset_Collection_Queue'];
    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
    Account testAccount = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAccount);

    List<Case> ownerAssignmentCaseList = new List<Case>();
    Case assetCaseWithAcct = new Case();
    assetCaseWithAcct.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();
    assetCaseWithAcct.AccountId = testAccount.Id;
    assetCaseWithAcct.OwnerId = listGroup.get(0).Id;
    ownerAssignmentCaseList.add(assetCaseWithAcct);

    Case assetCaseWithAcct2 = new Case();
    assetCaseWithAcct2.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
    assetCaseWithAcct2.AccountId = testAccount.Id;
    assetCaseWithAcct2.OwnerId = listGroup.get(0).Id;
    ownerAssignmentCaseList.add(assetCaseWithAcct2);

    Case assetCaseWithCon = new Case();
    assetCaseWithCon.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();    
    assetCaseWithCon.ContactId = testContact.Id;
    assetCaseWithCon.OwnerId = listGroup.get(0).Id;
    ownerAssignmentCaseList.add(assetCaseWithCon);
    insert ownerAssignmentCaseList;

    TestClassUtility.DISABLE_TRIGGERS = FALSE;
    List<User> listUsers = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 3];

    Test.startTest();
    for(Integer i = 0; i < ownerAssignmentCaseList.size(); i++){
      ownerAssignmentCaseList.get(i).OwnerId = listUsers.get(i).Id;
    }

    update ownerAssignmentCaseList;

    Test.stopTest();

    List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id IN: ownerAssignmentCaseList];
    System.assert(!listCaseAssert.isEmpty());
    Id assertOwnerId = listCaseAssert.get(0).OwnerId;
    for(Case caseAssert : listCaseAssert){
      System.assert(caseAssert.OwnerId == assertOwnerId);
    }
    
  }

  @isTest static void testAssignRecentCaseOwner_VIP_Positive() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];

      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == testAccount.Strategy_Specialist__c);
  }

  @isTest static void testAssignRecentCaseOwner_VIP_Negative() {
      Id inboundCaseQueueId;
      Id vipCaseQueueId;
      for(Group caseQueue : [SELECT Id, DeveloperName FROM Group 
                              WHERE Type = 'Queue' 
                              AND (DeveloperName = 'Inbound_Case_Queue' 
                                OR DeveloperName = 'VIP_Queue')]){

          if(caseQueue.DeveloperName == 'Inbound_Case_Queue'){
              inboundCaseQueueId = caseQueue.Id;
          }else if(caseQueue.DeveloperName == 'VIP_Queue'){
              vipCaseQueueId = caseQueue.Id;
          }
      }

      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'VIP';
      testAccount.Strategy_Specialist__c = null;
      insert testAccount;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = inboundCaseQueueId;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == vipCaseQueueId);
  }

  @isTest static void testAssignRecentCaseOwner_Onboarding_Positive() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testOnboardingCase = new Case();
      testOnboardingCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
      testOnboardingCase.AccountId = testAccount.Id;
      testOnboardingCase.OwnerId = testUser.Id;
      insert testOnboardingCase;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == testOnboardingCase.OwnerId);
  }

    @isTest static void testAssignRecentCaseOwner_Onboarding_Negative() {
      Id inboundCaseQueueId;
      Id onboardingCaseQueueId;
      for(Group caseQueue : [SELECT Id, DeveloperName FROM Group 
                              WHERE Type = 'Queue' 
                              AND (DeveloperName = 'Inbound_Case_Queue' 
                                OR DeveloperName = 'Onboarding_case_queue')]){

          if(caseQueue.DeveloperName == 'Inbound_Case_Queue'){
              inboundCaseQueueId = caseQueue.Id;
          }else if(caseQueue.DeveloperName == 'Onboarding_case_queue'){
              onboardingCaseQueueId = caseQueue.Id;
          }
      }

      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      n2de__Out_of_office__c testOutOfOffice = new n2de__Out_of_office__c();
      testOutOfOffice.n2de__User__c = testUser.Id;
      testOutOfOffice.n2de__Start_datetime__c = Datetime.now().addDays(-1);
      testOutOfOffice.n2de__End_datetime__c = Datetime.now().addDays(1);
      insert testOutOfOffice;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testACCase = new Case();
      testACCase.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
      testACCase.AccountId = testAccount.Id;
      testACCase.OwnerId = testUser.Id;
      insert testACCase;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = inboundCaseQueueId;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == onboardingCaseQueueId);
  }

  @isTest static void testAssignRecentCaseOwner_AssetCollection_Positive() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testACCase = new Case();
      testACCase.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();
      testACCase.AccountId = testAccount.Id;
      testACCase.Product_Type__c = 'Internet';
      testACCase.OwnerId = testUser.Id;
      insert testACCase;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == testUser.Id);
  }

  @isTest static void testAssignRecentCaseOwner_AssetCollection_Negative() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      n2de__Out_of_office__c testOutOfOffice = new n2de__Out_of_office__c();
      testOutOfOffice.n2de__User__c = testUser.Id;
      testOutOfOffice.n2de__Start_datetime__c = Datetime.now().addDays(-1);
      testOutOfOffice.n2de__End_datetime__c = Datetime.now().addDays(1);
      insert testOutOfOffice;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testACCaseOoO = new Case();
      testACCaseOoO.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();
      testACCaseOoO.AccountId = testAccount.Id;
      testACCaseOoO.Product_Type__c = 'Internet';
      testACCaseOoO.OwnerId = testUser.Id;

      Case testACCaseDM = new Case();
      testACCaseDM.RecordTypeId = rtMapByName.get('Asset Collection').getRecordTypeId();
      testACCaseDM.AccountId = testAccount.Id;
      testACCaseDM.Product_Type__c = 'Direct Mail';
      testACCaseDM.OwnerId = UserInfo.getUserId();

      insert new List<Case>{testACCaseOoO, testACCaseDM};

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == listGroup.get(0).Id);
  }

  @isTest static void testAssignRecentCaseOwner_Inbound_Positive() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testExistingInboundCase = new Case();
      testExistingInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testExistingInboundCase.AccountId = testAccount.Id;
      testExistingInboundCase.OwnerId = testUser.Id;
      insert testExistingInboundCase;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == testUser.Id);
  }

  @isTest static void testAssignRecentCaseOwner_Inbound_Negative() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Inbound_Case_Queue'];
      TestClassUtility.DISABLE_TRIGGERS = TRUE;

      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      n2de__Out_of_office__c testOutOfOffice = new n2de__Out_of_office__c();
      testOutOfOffice.n2de__User__c = testUser.Id;
      testOutOfOffice.n2de__Start_datetime__c = Datetime.now().addDays(-1);
      testOutOfOffice.n2de__End_datetime__c = Datetime.now().addDays(1);
      insert testOutOfOffice;

      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Account testAccount = TestClassUtility.createAccount(false);
      testAccount.Manual_VIP_Program_Status__c = 'Not VIP';
      testAccount.Strategy_Specialist__c = UserInfo.getUserId();
      insert testAccount;

      Case testInboundCaseOoO = new Case();
      testInboundCaseOoO.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCaseOoO.AccountId = testAccount.Id;
      testInboundCaseOoO.OwnerId = testUser.Id;
      insert testInboundCaseOoO;

      TestClassUtility.DISABLE_TRIGGERS = FALSE;
      
      Test.startTest();

      Case testInboundCase = new Case();
      testInboundCase.RecordTypeId = rtMapByName.get('Inbound').getRecordTypeId();
      testInboundCase.AccountId = testAccount.Id;
      testInboundCase.OwnerId = listGroup.get(0).Id;
      insert testInboundCase;

      Test.stopTest();

      List<Case> listCaseAssert = [SELECT OwnerId FROM Case WHERE Id =: testInboundCase.Id];
      System.assert(!listCaseAssert.isEmpty());
      System.assert(listCaseAssert[0].OwnerId == listGroup.get(0).Id);
  }

  @isTest static void testOnboardingWelcomeEmail_Negative() {
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
      testCase.OwnerId = UserInfo.getUserId();
      testCase.VIP_Onboarding_Case__c = TRUE;

      Test.startTest();

      insert testCase;
      
      Integer invocations = Limits.getEmailInvocations();
      System.assert(invocations == 0);

      Test.stopTest();
      
  }

  @isTest static void testPreventDuplicateOnboardingTask() {
      List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Onboarding_case_queue'];
      Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
      Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User testUser = TestClassUtility.createUser(false, adminProfile);
      insert testUser;

      Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(true);

      Account acct = (Account)mapLocalData.get('Account');
      Contact cont = (Contact)mapLocalData.get('Contact');

      Case testCaseWithQueue = new Case();
      testCaseWithQueue.Status = 'new';
      testCaseWithQueue.AccountId = acct.Id;
      testCaseWithQueue.ContactId = cont.Id;
      testCaseWithQueue.OwnerId = UserInfo.getUserId();
      testCaseWithQueue.RecordTypeId = rtMapByName.get('2 - Onboarding').getRecordTypeId();
      insert testCaseWithQueue;

      testCaseWithQueue.OwnerId = listGroup[0].Id;
      update testCaseWithQueue;

      Test.startTest();
      
      testCaseWithQueue.OwnerId = testUser.Id;
      update testCaseWithQueue;

      Test.stopTest();

      List<Task> onboardingTaskListAssert = [SELECT Id FROM Task WHERE Purpose__c = 'Onboarding'];
      system.assert(onboardingTaskListAssert.size() == 1);
  }

}