@IsTest
private class CancelCaseControllerTest {
  @IsTest
  static void testGetAllPicklistOptionsSuccess() {
    
    Test.startTest();
    Map<String, List<CancelCaseController.PicklistValueWrapper>> options = CancelCaseController.getAllPicklistOptions();
    Test.stopTest();

    System.assert(options != null, 'Should have returned options');
    System.assert(options.get('originOptions').size() >0 , 'Should have 8 options.');
    System.assert(options.get('typeOptions').size() >0, 'Should have 16 options.');
  }

  @IsTest
  static void testGetCaseForAccountSuccess() {
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
    CaseService.CaseInfoWrapper caseDto = CancelCaseController.getCaseForAccount(accountId);
    Test.stopTest();
    System.assert(caseDto != null, 'Should have returned a case dto.');
    System.assertEquals(acc.Name, caseDto.accountName, 'Should have correct account name');
  }

  @IsTest
  static void testSaveCaseSuccess() {
    List<User> u = [SELECT Id FROM User LIMIT 1];

    Account acc = new Account();
    acc.Name = 'Account Temp';
    insert acc;

    Contact cont = new Contact();
    cont.FirstName = 'Test';
    cont.LastName = 'Contact';
    cont.AccountId = acc.Id;
    insert cont;

    Map<String, Object> input = new Map<String, Object> {
        'caseOwnerId' => u.get(0).Id,
        'caseOwnerName' => 'somebody',
        'contactId' => cont.Id,
        'accountId' => acc.Id,
         'outcome'  => 'Cancelled'
    };
   
    String strInput = JSON.serialize(input);
    Test.startTest();
    Map<String, String> result = CancelCaseController.saveCase(strInput, false, 1, false, false, false);
    Map<String, String> result2 = CancelCaseController.saveCase(strInput, true, 3, true, false, false);
    Test.stopTest();
    System.assert(result != null, 'Should have returned a result map.');
  }

  @IsTest
  static void testSaveFileChunkCreateNewFile() {
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
    String parentId = mockCase2.Id;
    String fileName = 'test';
    String contentType = 'contentType';

    Test.startTest();
    String result = CancelCaseController.saveFileChunk(parentId, fileName, base64Data, contentType, attachmentId);
    String result2 = CancelCaseController.saveFileChunk(parentId, fileName, base64Data, contentType, '');
    Test.stopTest();

    System.assert(result != null, 'Should return new attachment id');
  }

  @IsTest
  static void testRemoveAttachmentSuccess() {
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

    Test.startTest();
    Map<String, Boolean> result = CancelCaseController.removeAttachment(testAttachment.Id);
    Test.stopTest();

    System.assert(result != null, 'Should have returned a result map.');
    System.assertEquals(true, result.get('saved'), 'Should have saved');
  }
}