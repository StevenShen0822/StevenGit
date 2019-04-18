@IsTest
private class CancelCaseModalControllerTest {
  @IsTest
  static void testInitialSearchAccountsSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.initialSearchAccounts(testAcc.Id);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have an Account in results.');
  }

  @IsTest
  static void testSearchAccountsSuccess() {
    Account testAcc = TestClassUtility.createAccount(false);
    testAcc.name = 'Test Account';
    insert testAcc;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = testAcc.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.searchAccounts(testAcc.name);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have an Account in results.');
    System.assertEquals('Test Account', searchResults.get(0).resultName, 'Item 1 should have name Test Account.');

  }

  @IsTest
  static void testInitialSearchContactsSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAcc);

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.initialSearchContacts(testAcc.Id);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have a Contact in results.');
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
    List<CaseService.SearchResultWrapper> dtos = CancelCaseModalController.searchUsers(userName);
    Test.stopTest();

    System.assert(dtos.size() > 0);
  }

  @IsTest
  static void testSearchContactsSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAcc);


    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = testContact.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.searchContacts(testContact.Id, testAcc.Id);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have an Account in results.');


  }

  @IsTest
  static void testInitialSearchTaskssSuccess() {
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
  static void testSearchTasksSuccess() {
    Account testAcc = TestClassUtility.createAccount(true);
    Contact testContact = TestClassUtility.createContact(true, testAcc);
    Task testTask = TestClassUtility.createTask(false);
    testTask.WhoId = testContact.Id;
    testTask.Type = 'Email';
    insert testTask;

    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = testTask.id;
    Test.setFixedSearchResults(fixedSearchResults);

    Test.startTest();
    List<CaseService.SearchResultWrapper> searchResults = CancelCaseModalController.searchTasks(testTask.Type, testAcc.Id);
    Test.stopTest();

    System.assertEquals(1, searchResults.size(), 'Should have a Task in results.');


  }

}