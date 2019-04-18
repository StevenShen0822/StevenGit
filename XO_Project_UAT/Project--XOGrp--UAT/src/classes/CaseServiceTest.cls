@IsTest
private class CaseServiceTest {

    private static String DUMMY_USER_NAME = System.Label.Dummy_User_Name;
    private static String SPACE_DELIMITER = ' ';

  @testSetup static void createTestData(){
    Group testAssetCollectionGroup = new Group(Name = 'Asset Collection Queue', type = 'Queue');
    insert new List<Group>{testAssetCollectionGroup};

    QueuesObject testAssetCollectionQueue = new QueueSObject(QueueID = testAssetCollectionGroup.Id, SobjectType = 'Case');
    insert new List<QueuesObject>{testAssetCollectionQueue};
  }

  @IsTest
  static void testGetOrCreateCaseForAccountWhenCaseFoundSuccess() {

    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = CaseService.getInstance().getCancelRecordTypeId();
    mockCase2.Description = 'test';
    mockCase2.AccountId = acc.id;
    mockCase2.ContactId = con.id;
    insert mockCase2;

    String accountId = acc.Id;

    Test.startTest();
    CaseService.CaseInfoWrapper dto = CaseService.getInstance().getOrCreateCaseForAccount(accountId);
    delete mockCase2;
    CaseService.CaseInfoWrapper dto2 = CaseService.getInstance().getOrCreateCaseForAccount(accountId);
    Test.stopTest();

    System.assert(dto != null, 'Should have returned dto.');
   
  }


  @IsTest
  static void testGetAccountsByIdSuccess() {

    Account acc = TestClassUtility.createAccount(true);
    String accountId = acc.Id;

    Test.startTest();
    List<CaseService.SearchResultWrapper> dtos = CaseService.getInstance().getAccountsById(accountId);
    Test.stopTest();

    System.assertEquals(1, dtos.size(), 'Should have 1 item.');
    System.assertEquals(acc.Name, dtos.get(0).resultName, 'Should have Account name.');
  }

  @IsTest
  static void testSearchAccountsSuccess() {
    Account acc = TestClassUtility.createAccount(true);
    String accountName = acc.Name;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = acc.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> dtos = CaseService.getInstance().searchAccounts(accountName);
    Test.stopTest();

    // System.assertEquals(1, dtos.size(), 'Should have 1 item.');
    System.assertEquals(accountName, dtos.get(0).resultName, 'Should have Account name.');
  }

  @IsTest
  static void testSearchContactsSuccess() {

    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    String contactName = acc.Name;
    String accountId = acc.Id;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = con.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> dtos = CaseService.getInstance().searchContacts(contactName, accountId);
    List<CaseService.SearchResultWrapper> dtos2 =  CaseService.getInstance().getContactsForAccount(accountId);
    Test.stopTest();

    System.assertEquals(1, dtos.size(), 'Should have 1 item.');
    System.assertEquals(1, dtos2.size(), 'Should have 1 item.');
  }

  @IsTest
  static void testSearchTasksSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAcc);
    Task testTask = TestClassUtility.createTask(false);
    testTask.WhoId = testContact.Id;
    insert testTask;

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.initialSearchTasks(testAcc.id);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have a Task in results.');
  }

  @IsTest
  static void testGetTasksForAccountSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAcc);
    Task testTask = TestClassUtility.createTask(false);
    testTask.WhoId = testContact.Id;
    insert testTask;


    String searchVal = 'call';
    String accountId = testAcc.Id;

    Test.startTest();
    List<CaseService.SearchResultWrapper> dtos = CaseService.getInstance().getTasksForAccount(accountId);
    Test.stopTest();

    System.assertEquals(1, dtos.size(), 'Should have 1 item.');
  }

  @IsTest
  static void testSearchUsersSuccess() {

    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    user testUser = TestClassUtility.createUser(true, profileId);
    String userName = testUser.LastName;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = testUser.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> dtos = CaseService.getInstance().searchUsers(userName);
    Test.stopTest();

    System.assert(dtos.size() > 0);
  }


  @IsTest
  static void testUpsertCaseSuccess() {

    Case newCase = new Case();
    newCase.Origin = 'Web';

    Test.startTest();
    Case result = CaseService.getInstance().upsertCase(newCase);
    Test.stopTest();

    System.assert(result != null, 'Should have returned a case object');
    System.assertEquals('Web', result.Origin, 'Should have origin');
  }

  @IsTest
  static void testSaveFile() {
    Deactivate_Trigger__c testAttachment = new Deactivate_Trigger__c();
    testAttachment.Name = 'Attachment';
    insert testAttachment;

    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = CaseService.getInstance().getCancelRecordTypeId();
    mockCase2.Description = 'test';
    mockCase2.AccountId = acc.id;
    mockCase2.ContactId = con.id;
    insert mockCase2;


    String parentId = mockCase2.Id;
    String fileName = 'filename.pdf';
    String base64Data = 'the data';
    String contentType = 'content';


    Test.startTest();
    String result = CaseService.getInstance().saveFile(parentId, fileName, base64Data, contentType);
    Test.stopTest();

    System.assert(result != null, 'Should return new attachment id');
  }

  @IsTest
  static void testAppendToFile() {
    Deactivate_Trigger__c testAttachmentTrigger = new Deactivate_Trigger__c();
    testAttachmentTrigger.Name = 'Attachment';
    insert testAttachmentTrigger;

    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = CaseService.getInstance().getCancelRecordTypeId();
    mockCase2.Description = 'test';
    mockCase2.AccountId = acc.id;
    mockCase2.ContactId = con.id;
    insert mockCase2;

    Attachment testAttachment = TestClassUtility.createAttachment(false,'test','test');
    testAttachment.ParentId = mockCase2.Id;
    insert testAttachment;

    String attachmentId = testAttachment.id;
    String base64Data = 'the data';

    Test.startTest();
    CaseService.getInstance().appendToFile(attachmentId, base64Data);
    Test.stopTest();

    Attachment testAttachment2 = [SELECT id,Body FROM Attachment WHERE id =: attachmentId];

    System.assert(testAttachment2 != null);

  }

  @IsTest
  static void testDeleteAttachmentSuccess() {
    Deactivate_Trigger__c testAttachmentTrigger = new Deactivate_Trigger__c();
    testAttachmentTrigger.Name = 'Attachment';
    insert testAttachmentTrigger;

    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = CaseService.getInstance().getCancelRecordTypeId();
    mockCase2.Description = 'test';
    mockCase2.AccountId = acc.id;
    mockCase2.ContactId = con.id;
    insert mockCase2;

    Attachment testAttachment = TestClassUtility.createAttachment(false,'test','test');
    testAttachment.ParentId = mockCase2.Id;
    insert testAttachment;

    String attachmentId = testAttachment.id;
    String base64Data = 'the data';


    Test.startTest();
    Boolean result = CaseService.getInstance().deleteAttachment(attachmentId);
    Test.stopTest();

    System.assertEquals(true, result, 'Should have saved');
  }

 @IsTest
  static void testgetCaseInfo(){
    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Map<String, Object> caseValues = new Map<String, Object>();
    caseValues.put('accountId',(Object)acc.Id);
    caseValues.put('caseOwnerId',(Object)UserInfo.getUserId());
    caseValues.put('contactId',(Object)con.Id);
    caseValues.put('originalRequestDate',(Object)system.today());
    caseValues.put('type',(Object)'ACH Return');
    caseValues.put('reason',(Object)'Can\'t Afford');
    caseValues.put('cancelReasonNotes',(Object)'test');
    caseValues.put('outcome',(Object)'Saved By');
    caseValues.put('savedBy',(Object)'Value Add');


    Test.startTest();
    Case result = CaseService.getInstance().getCaseInfo(caseValues,1,true,true,true);
    Case result2 = CaseService.getInstance().getCaseInfo(caseValues,3,false,false,true);
    Test.stopTest();
  }
      


  @IsTest
  static void testGetCaseWithFeatureRequestCanceled() {
    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    Case mockCase2 = new Case();
    mockCase2.recordTypeId = CaseService.getInstance().getCancelRecordTypeId();
    mockCase2.Description = 'test';
    mockCase2.AccountId = acc.id;
    mockCase2.ContactId = con.id;
    insert mockCase2;

    Test.startTest();
    Case c = CaseService.getInstance().getCaseWithFeatureRequestCancelled(mockCase2.Id);
    Test.stopTest();

    System.assertNotEquals(null, c, 'Should have returned the case.');
  }

  @IsTest
  static void testSearchTasks(){
    Account acc = TestClassUtility.createAccount(true);
    Contact con = TestClassUtility.createContact(false, acc);
    con.Email = acc.Email__c;
    insert con;

    task testTask = TestClassUtility.createTask(false);
    testTask.WhatId = acc.Id;
    insert testTask;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = testTask.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> result = CaseService.getInstance().searchTasks('Test', acc.Id);
    Test.stopTest();

    System.assert(result.size() > 0, 'Should have returned the task.');  
  }

  @IsTest
  static void testAssetCollectionCaseWithOppy() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(TRUE);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Opportunity testOppy = (Opportunity)mapLocalData.get('Opportunity');

        Case testOnboardingCase = new Case();
        testOnboardingCase.AccountId = testAccount.Id;
        testOnboardingCase.Opportunity__c = testOppy.Id;
        testOnboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
        insert testOnboardingCase;

        zqu__Quote__c quote = (zqu__Quote__c)mapLocalData.get('zqu__Quote__c');
        Zuora__Subscription__c testZuoraSubscriptionNew = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionNew.Latest_Quote__c = quote.Id;
        testZuoraSubscriptionNew.CreatingSalesforceQuoteID__c = quote.Id;
        testZuoraSubscriptionNew.Zuora__Version__c = 1;
        update testZuoraSubscriptionNew;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew1 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew1.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew1.Zuora__ProductSKU__c = 'testProductSKU1';
        testSubProductChargeNew1.Zuora__Account__c = testAccount.Id;
        testSubProductChargeNew1.Zuora__RatePlanName__c = 'Storefront';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert new List<Zuora__SubscriptionProductCharge__c>{testSubProductChargeNew1};

        Test.stopTest();

        List<Case> listACCasesAssert = [SELECT Id,Onboarding_Case__c FROM Case
                                        WHERE Status = 'New' 
                                        AND Reason = 'Asset Collection' 
                                        AND Origin = 'Auto-Generated'
                                        AND SubscriptionProductCharge__c =: testSubProductChargeNew1.Id];
 
        System.assert(!listACCasesAssert.isEmpty());
        Case caseAssert = listACCasesAssert.get(0);
        System.assert(caseAssert.Onboarding_Case__c == testOnboardingCase.Id);
  }

    @IsTest
    static void testAssetCollectionCaseWithAcct() {
        Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(TRUE);

        TestClassUtility.DISABLE_TRIGGERS = TRUE;
        User dummyUser = getDummyUser();

        Account testAccount = (Account)mapLocalData.get('Account');
        testAccount.Strategy_Specialist__c = dummyUser.Id;
        update testAccount;

        Opportunity testOppy = TestClassUtility.createOpportunity(true, testAccount);

        Case testOnboardingCase = new Case();
        testOnboardingCase.AccountId = testAccount.Id;
        testOnboardingCase.Opportunity__c = testOppy.Id;
        testOnboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
        insert testOnboardingCase;

        zqu__Quote__c quote = (zqu__Quote__c)mapLocalData.get('zqu__Quote__c');
        Zuora__Subscription__c testZuoraSubscriptionNew = (Zuora__Subscription__c)mapLocalData.get('Zuora__Subscription__c');
        testZuoraSubscriptionNew.Latest_Quote__c = quote.Id;
        testZuoraSubscriptionNew.CreatingSalesforceQuoteID__c = quote.Id;
        testZuoraSubscriptionNew.Zuora__Version__c = 1;
        update testZuoraSubscriptionNew;

        Zuora__SubscriptionProductCharge__c testSubProductChargeNew1 = TestClassUtility.createSubscriptionProductCharge(false, 
                                                                                                                       testAccount, 
                                                                                                                       testZuoraSubscriptionNew);
        testSubProductChargeNew1.Name = 'Test Subscription Product Charge - 80% Balance';
        testSubProductChargeNew1.Zuora__ProductSKU__c = 'testProductSKU1';
        testSubProductChargeNew1.Zuora__Account__c = testAccount.Id;
        testSubProductChargeNew1.Zuora__RatePlanName__c = 'Storefront';

        TestClassUtility.DISABLE_TRIGGERS = FALSE;

        Test.startTest();

        insert new List<Zuora__SubscriptionProductCharge__c>{testSubProductChargeNew1};

        Test.stopTest();
 
        List<Case> listACCasesAssert = [SELECT Id, Onboarding_Case__c, Subject FROM Case
                                        WHERE Status = 'New' 
                                        AND Reason = 'Asset Collection' 
                                        AND Origin = 'Auto-Generated'
                                        AND SubscriptionProductCharge__c =: testSubProductChargeNew1.Id];
        System.assert(!listACCasesAssert.isEmpty());
        Case caseAssert = listACCasesAssert.get(0);
        System.assert(caseAssert.Onboarding_Case__c == testOnboardingCase.Id);
        System.assert(caseAssert.Subject == testSubProductChargeNew1.Zuora__RatePlanName__c);
    }

    @IsTest
    static void testGetSpecificQueueMember(){
        List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Asset_Collection_Queue'];

        Test.startTest();
        
        Id groupId = listGroup.get(0).Id;
        Set<Id> setQueueMemberIDs = CaseService.getSpecificQueueMember(groupId);

        Test.stopTest();

        System.assert(!setQueueMemberIDs.isEmpty());
      
    }

    @IsTest
    static void testCreateOnboardingCase(){
          List<Group> listGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Asset_Collection_Queue'];

          List<String> onboardingCaseProductNameList = System.Label.OnboardingCaseProductName.split('\n');

          Map<String, SObject> mapLocalData = TestClassUtility.buildLocalData(TRUE);

          Account testAccount = (Account)mapLocalData.get('Account');

          Opportunity testOpportunity = (Opportunity)mapLocalData.get('Opportunity');

          zqu__Quote__c testQuote = (zqu__Quote__c)mapLocalData.get('zqu__Quote__c');
          testQuote.zqu__Status__c = 'Sent to Z-Billing';
          testQuote.True_TCV__c = 119999;
          update testQuote;

          zqu__QuoteRatePlan__c testQuoteRatePlan = (zqu__QuoteRatePlan__c)mapLocalData.get('zqu__QuoteRatePlan__c');
          testQuoteRatePlan.zqu__QuoteProductName__c = onboardingCaseProductNameList.get(0);
          update testQuoteRatePlan;

          Case testACCase = new Case();
          testACCase.AccountId = testAccount.Id;
          testACCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
          testACCase.OwnerId = listGroup.get(0).Id;
          testACCase.Rate_Plan_Name__c = 'Storefront';
          insert testACCase;

          Test.startTest();

          testOpportunity.StageName = 'Closed Won';
          testOpportunity.Onboarding_Required__c = TRUE;
          update testOpportunity;

          Test.stopTest();

          Id onboardingCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
          List<Case> listOnboardingCase = [SELECT Id FROM Case WHERE AccountId =: testAccount.Id AND RecordTypeId =: onboardingCaseRTId];
          System.assert(!listOnboardingCase.isEmpty());
          
      }

    private static User getDummyUser(){
        User dummyUser;
        List<User> listDummyUser = [SELECT Id FROM User WHERE Name =: DUMMY_USER_NAME AND IsActive = TRUE LIMIT 1];
        if(!listDummyUser.isEmpty()){
            dummyUser = listDummyUser[0];
        }
        else{
            Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            dummyUser = TestClassUtility.createUser(FALSE, adminProfile);
            dummyUser.FirstName = DUMMY_USER_NAME.substringBefore(SPACE_DELIMITER);
            dummyUser.LastName = DUMMY_USER_NAME.substringAfter(SPACE_DELIMITER);
            insert dummyUser;
        }
        return dummyUser;
    }
}