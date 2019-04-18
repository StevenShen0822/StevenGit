public with sharing class CaseService {

  private final static String CANCEL_RECORD_TYPE = '1 - Cancels';
  private static final String STRDELIM = ',';
  private static User currentUser = [SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id =:UserInfo.getUserId()];
  private static CaseService instance;

  //Store Opportunity Id and related Onboarding case Id for creating Asset Collection case
  private static Map<Id,Id> mapOppyIdToOnboardingCaseId = new Map<Id,Id>();
  //Store Account Id and related Onboarding case Id for creating Asset Collection case
  private static Map<Id,Id> mapAcctIdToOnboardingCaseId = new Map<Id,Id>();
  //Stored case queue developer name and case queue Id
  private static Map<String,Id> mapCaseQueueNameToQueueId;
  //Stored case record type name and case record type Id
  private static Map<String, Schema.RecordTypeInfo> mapCaseRecTypeIdByName = Schema.SObjectType.Case.getRecordTypeInfosByName();

   

  public static CaseService getInstance() {
    if (instance == null) {
      instance = new CaseService();
    }
    return instance;
  }

  /**
   * Initial search accounts.
   *
   * @param accountId The search string.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> getAccountsById(String accountId) {
    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();

    Account acc = getAccountById(accountId);

    if (acc != null) {
      listResults.add(new SearchResultWrapper(acc.Id, acc.Name));
    }

    return listResults;
  }

  /**
   * Search accounts.
   *
   * @param searchVal The search string.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> searchAccounts(String searchVal) {

    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();
    List<List<SObject>> listSearchResults = [FIND :searchVal IN ALL FIELDS RETURNING Account(Id, Name)];
    List<Account> listAccounts = listSearchResults.size() == 1 ? listSearchResults.get(0) : null;

    for (Account acc : listAccounts) {
      listResults.add(new SearchResultWrapper(acc.Id, acc.Name));
    }

    return listResults;
  }

  /**
   * Search contacts on account.
   *
   * @param accountId The account id.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> getContactsForAccount(String accountId) {
    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();
    List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE AccountId = :accountId];

    for (Contact con : contacts) {
      listResults.add(new SearchResultWrapper(con.Id, con.Name));
    }
    return listResults;
  }

  /**
   * Search contacts.
   *
   * @param searchVal The search string.
   * @param accountId The account id.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> searchContacts(String searchVal, String accountId) {
    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();

    List<List<SObject>> listSearchResults = [FIND :searchVal IN ALL FIELDS RETURNING Contact(Id, Name WHERE AccountId = :accountId AND Status__c ='Active')];
    List<Contact> listContacts = listSearchResults.size() == 1 ? listSearchResults.get(0) : null;

    for (Contact con : listContacts) {
      listResults.add(new SearchResultWrapper(con.Id, con.Name));
    }
    return listResults;
  }

  /**
   * Search tasks on account.
   *
   * @param accountId The account id.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> getTasksForAccount(String accountId) {
    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();
    List<Task> listTasks = [SELECT Id, WhoId, Subject, Type FROM Task 
                              WHERE AccountId = :accountId
                              ORDER BY LastModifiedDate DESC];

    listResults = getTaskAndContName(listTasks);
    return listResults;
  }

  /**
   * Get task type and contact name mapping 
   *
   * @param listTasks The list of task.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> getTaskAndContName(List<Task> listTasks) {
    List<SearchResultWrapper> listResults = new List<SearchResultWrapper>();
    Map<Id,Id> mapTaskIdContId = New Map<Id,Id>();
    Map<Id,String> mapTaskIdType = New Map<Id,String>();
    Map<Id,String>  mapContIdName = new Map<Id,String>();

    if(!listTasks.isEmpty()) {
      //Get all list task Id and Type mapping 
      for (Task currentTask : listTasks) {
        if (currentTask.WhoId != null) {
          mapTaskIdContId.put(currentTask.Id, currentTask.WhoId);
        }
        mapTaskIdType.put(currentTask.Id,currentTask.Type);
      }

      //Get Contact Id and Name mapping if tasks relate contact 
      for(Contact currentCont : [SELECT Id, Name FROM Contact WHERE Id IN:mapTaskIdContId.values()]) {
        mapContIdName.put(currentCont.Id, currentCont.Name);
      } 

      //Get task.Type - contact.Name if tasks relate contact 
      for(Task currentTask : listTasks) {
        String tempName;
        boolean isHaveContact = !mapTaskIdContId.isEmpty() && !mapContIdName.isEmpty() 
                                && String.isNotBlank(currentTask.WhoId) 
                                && String.isNotBlank(mapTaskIdContId.get(currentTask.Id));

        if (isHaveContact) {
           tempName = currentTask.Type + ' - ' + mapContIdName.get(currentTask.WhoId);
        }
        else {
           tempName = currentTask.Type;
        }
        listResults.add(new SearchResultWrapper(currentTask.Id, tempName));
      }
    }

    return listResults;
  }


  /**
   * Search task.
   *
   * @param searchVal The search string.
   * @param accountId The account id.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> searchTasks(String searchVal, String accountId) {
    List<SearchResultWrapper> listReturnResults = new List<SearchResultWrapper>();
    List<List<SObject>> listSearchResults = [FIND:searchVal
                                   IN ALL FIELDS RETURNING Task(Id, WhoId, Subject, Type 
                                   WHERE AccountId = :accountId ORDER BY LastModifiedDate DESC)];

    List<Task> listTasks = listSearchResults.size() == 1 ? listSearchResults.get(0) : null;
    listReturnResults = getTaskAndContName(listTasks);
    return listReturnResults;
  }

  /**
   * Search Users.
   *
   * @param searchVal The search string.
   * @return List<SearchResultWrapper>.
   */
  public List<SearchResultWrapper> searchUsers(String searchVal) {
    List<SearchResultWrapper> listRetrunResults = new List<SearchResultWrapper>();
    List<List<SObject>> listSearchResults = [FIND :searchVal IN ALL FIELDS RETURNING User(Id, Name WHERE isActive = true)];
    List<User> listUsers = listSearchResults.size() == 1 ? listSearchResults.get(0) : null;

    for (User usr : listUsers) {
      listRetrunResults.add(new SearchResultWrapper(usr.Id, usr.Name));
    }

    return listRetrunResults;
  }

  /**
   * Get the Id of the cancel record type.
   *
   * @return String.
   */
  public String getCancelRecordTypeId() {
    RecordType recordType = [SELECT Id FROM RecordType WHERE Name = :CANCEL_RECORD_TYPE LIMIT 1];
    return (recordType != null) ? recordType.Id : null;
  }

  /**
   * Get or create a case for the account id.
   *
   * @param accountId The account id.
   * @return Case object.
   */
  public CaseInfoWrapper getOrCreateCaseForAccount(String accountId) {
    CaseInfoWrapper caseWrap;
    String caseOwnerId;
    User caseOwner;
    String caseOwnerName;
    User contact;
    Contact contactOnAccount;
    String contactId;
    String contactName;
    Datetime requestDate;
    String cancelRecordTypeId = this.getCancelRecordTypeId();
    List<Contact> listContact;

    if (cancelRecordTypeId == null) {
      throw LightningUtility.createException('Record Type ' + CANCEL_RECORD_TYPE + ' not found.');
    }

    Account acc = getAccountById(accountId);
    String accountName = (acc != null) ? acc.Name : '';

    List<Case> listCases = [SELECT Id, AccountId, Account_Owner__c, CaseNumber, ContactId, Origin, OwnerId,
                              RecordTypeId, Date_and_Time_Request_Received__c,
                              Type, Reason, Cancel_Reason_Notes__c, Outcome__c, Saved_By__c
                              FROM Case WHERE AccountId = :accountId 
                              AND RecordTypeId = :cancelRecordTypeId 
                              AND IsClosed = FALSE LIMIT 1 ];

    Case foundCase = (listCases.size() == 1) ? listCases.get(0) : null;
    //Current account have no open case, initial a new case for account 
    if (foundCase == null) {
      caseOwnerName = currentUser.Name;

      listContact = [SELECT Id, Name FROM Contact WHERE Id IN 
                                    (SELECT ContactId FROM AccountContactRole WHERE AccountId = :accountId AND Role = 'Primary') 
                                    AND Status__c = 'Active' ORDER BY CreatedDate DESC LIMIT 1 ]; 
     
      //When there is contact under current account 
      if(!listContact.isEmpty()){
        contactOnAccount = listContact.get(0);
        contactId = contactOnAccount.Id;
        contactName = contactOnAccount.Name;
      }
      else{
        contactOnAccount = null;
        contactId = null;
        contactName = '';
      }
      requestDate = null;
      caseWrap = new CaseInfoWrapper(UserInfo.getUserId(), caseOwnerName, contactId, contactName, accountId, accountName, requestDate);
    } 
    //Current account have open case, get case info to page.
    else {
      // if case owner is queqe, show queue name to case owner for page.
      if(String.valueOf(foundCase.OwnerId).startsWith('00G')) {
         List<Group> listQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id =: foundCase.OwnerId limit 1];
         caseOwnerName = (listQueue.size() == 1) ? listQueue[0].Name : '';
      }
      // else show user name to case owner for page
      else{
        caseOwner = [SELECT Name FROM User WHERE Id = :foundCase.OwnerId LIMIT 1];
        caseOwnerName = (caseOwner != null ) ? caseOwner.Name : '';
      }

      listContact = [SELECT Id, Name FROM Contact WHERE Id = :foundCase.ContactId LIMIT 1 ];

      if(!listContact.isEmpty()){
        contactOnAccount = listContact.get(0);
        contactName = contactOnAccount.Name;
      }
      else{
        contactOnAccount = null;
        contactName = '';
      }
      
      caseWrap = new CaseInfoWrapper(foundCase, caseOwnerName, contactName, accountName);

      //Get Attachments relate this open case 
      List<Attachment> listCaseAttachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :foundCase.Id];

      List<AttachmentWrapper> listAttachmentDtos = new List<AttachmentWrapper>();
      for (Attachment att : listCaseAttachments) {
        listAttachmentDtos.add(new AttachmentWrapper(att.Id, att.Name));
      }
      caseWrap.attachments = listAttachmentDtos;

      //Get Task relate this open case
      List<Task> listCaseTasks = [SELECT Id, Type, WhoId FROM Task WHERE WhatId = :foundCase.Id];
      List<TaskWrapper> listTaskWrappers = new List<TaskWrapper>();

      for(SearchResultWrapper wrapper : getTaskAndContName(listCaseTasks)) {
        listTaskWrappers.add(new TaskWrapper(wrapper.Id, wrapper.resultName));
      }
      caseWrap.tasks = listTaskWrappers;
    }

    return caseWrap;
  }

  /**
   * Upsert case object.
   *
   * @param Case caseToUpsert The case.
   * @return Case - The upserted case.
   */
  public Case upsertCase(Case caseToUpsert) {
    Database.SaveResult saveCasesResult;
    // insert operate
    if(String.isBlank(caseToUpsert.Id)) {
      saveCasesResult = Database.insert(caseToUpsert); 
    }
    else {
      // Update operate
      Database.DMLOptions options = new Database.DMLOptions();
      options.EmailHeader.triggerUserEmail = true;
      saveCasesResult = Database.update(caseToUpsert, options); 
    }
    // Any exception will throw to component
    if (!saveCasesResult.isSuccess()) {
      String errorMessages = '';
      List<Database.Error> currentSaveErrors = saveCasesResult.getErrors();
      for(Integer i = 0, length = currentSaveErrors.size(); i < length; i++) {
        errorMessages += saveCasesResult.getErrors()[i].getMessage() + '\r\n';
      }
      throw new applicationException(errorMessages);
    } 
    return caseToUpsert;
  }

  /**
   * Save file as attachment
   *
   * @param String parentId The parent the attachment belongs to.
   * @param String fileName The name of the file.
   * @param String base64Data The file contents.
   * @param String contentType The file type.
   * @return String Id of the attachment.
   */
  public String saveFile(String parentId, String fileName, String base64Data, String contentType) {
    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

    Attachment att = new Attachment();
    att.ParentId = parentId;
    att.Body = EncodingUtil.base64Decode(base64Data);
    att.Name = fileName;
    att.ContentType = contentType;
    insert att;

    return att.Id;
  }

  /**
   * Append content to file
   *
   * @param String attachmentId The attachment id.
   * @param String base64Data The file contents.
   * @return void.
   */
  public void appendToFile(String attachmentId, String base64Data) {
    base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
    Attachment att = getAttachmentById(attachmentId);

    if (att != null) {
      String existingBody = EncodingUtil.base64Encode(att.Body);
      att.Body = EncodingUtil.base64Decode(existingBody + base64Data);
      update att;
    }

    return;
  }

  /**
   * Delete attachment
   *
   * @param String attachmentId The attachment id.
   * @return Map<String, Boolean>.
   */
  public Boolean deleteAttachment(String attachmentId) {
    Boolean isDelete = false;

    try {
      Attachment att = getAttachmentById(attachmentId);
      if (att != null) {
        delete att;
      }
      isDelete = true;
    } catch (Exception e) {
      throw e;
    }
    return isDelete;
  }

  /**
   * Get a Case with related Feature_Request_Canceled data.
   *
   * @param caseId The case Id.
   *
   * @return A Case with Feature_Requested_Cancelled__r data.
   */
  public Case getCaseWithFeatureRequestCancelled(Id caseId) {

    List<Case> listCases = [SELECT Id, AccountId,
                        (SELECT Id, Case__c, Status__c, Subscription_Product_Charge__c, 
                          UniqueId__c, Sub_Product_Charge_Number__c FROM Feature_Requested_Cancelled__r) 
                        FROM Case WHERE Id =: caseId LIMIT 1 ];
    Case returnCase = (listCases.size() == 1) ? listCases.get(0) : null;
    return returnCase;
  }

  /*
   * Method to return Case object from dto.
   * 
   * @param caseValues
   * @param currentPage
   * @param isCloseCase
   * @param isAssignOwner
   * @return Case.
  */
  public Case getCaseInfo(Map<String, Object> caseValues, Integer currentPage, Boolean isCloseCase, 
                          Boolean isAssignOwner, Boolean isSaveLater) {
    Case newCase = new Case();
    String accountId;
    Account acc;
   
    if (caseValues.get('id') != null) {
      newCase.Id = String.valueOf(caseValues.get('id'));
    } 
    else {
      // If we have an Id, we know this is an update, so this isn't required
      newCase.RecordTypeId = getCancelRecordTypeId();
    }

    if (caseValues.get('accountId') != null) {
      accountId = String.valueOf(caseValues.get('accountId'));
      newCase.AccountId = accountId;
    }

    if (caseValues.get('caseOwnerId') != null && !isAssignOwner) {
      newCase.OwnerId = String.valueOf(caseValues.get('caseOwnerId'));
    } 
    else if(isAssignOwner) {
      if(String.isNotBlank(accountId)) {
        acc = getAccountById(accountId);
      }
      // Assign Owner by Account Owner is AM or not 
      if(acc != null && acc.Owner.Title == label.Account_Manager){
        newCase.OwnerId = acc.OwnerId;
      }
      else{
        List<Group> listQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'Cancels case queue' limit 1];
        newCase.OwnerId = (listQueue.size() == 1) ? listQueue[0].id : null;
      }
    }

    if (caseValues.get('contactId') != null) {
      newCase.ContactId = String.valueOf(caseValues.get('contactId'));
    }

    if (caseValues.get('initialContact') != null) {
      newCase.Origin = String.valueOf(caseValues.get('initialContact'));
    }

    if (caseValues.get('originalRequestDate') != null) {
      String dt = String.valueOf(caseValues.get('originalRequestDate'));
      newCase.Date_and_Time_Request_Received__c = Datetime.valueOf(dt.left(11)+'00:00:00');
    }

    if (caseValues.get('type') != null) {
      newCase.Type = String.valueOf(caseValues.get('type'));
    }

    // Olny page three we need get Status,Reason,Outcome__c,Saved_By__c,Cancel_Reason_Notes__c information
    if (Integer.valueOf(currentPage) == 3) {
      if(isCloseCase) {
        newCase.Status = 'Closed';
      }
      else {
        newCase.Status = 'New';
      }

      if (caseValues.get('reason') != null) {
        newCase.Reason = String.valueOf(caseValues.get('reason'));
      }

      if (caseValues.get('cancelReasonNotes') != null) {
        newCase.Cancel_Reason_Notes__c = String.valueOf(caseValues.get('cancelReasonNotes'));
      }

      if (caseValues.get('outcome') != null) {
        newCase.Outcome__c = String.valueOf(caseValues.get('outcome'));
      }

      if (caseValues.get('savedBy') != null) {
        newCase.Saved_By__c = String.valueOf(caseValues.get('savedBy'));
      } 
      else {
        newCase.Saved_By__c = null;
      }
    }

    // Auto-populated Reporter Type to current user role Name
    if(String.isBlank(newCase.Reporter_Type__c)) {
     newCase.Reporter_Type__c = currentUser.UserRole.Name;
    }
    // Auto-populated Internal Reporter to current user 
    if(String.isBlank(newCase.Reporter_User_Name__c)) {
      newCase.Reporter_User_Name__c = currentUser.Id;
    }

    // When reps click "Save For Later" button, checked this field for notification to owner
    if(isSaveLater) {
      newCase.Save_For_Later__c = isSaveLater;
    }
   
    return newCase;
  }
 
  /*
   * Method to get Attachment by attachment Id
   * 
   * @param String [attachmentId]   Used to query Attachment
   * @return Attachment [att]
  */
  public Attachment getAttachmentById (Id attachmentId) {
    List<Attachment> listAttachments = [SELECT Id, Body FROM Attachment WHERE Id = :attachmentId LIMIT 1 ];
    Attachment att = listAttachments.size() == 1 ? listAttachments.get(0) : null;
    return att;
  }

  /*
   * Method to get Account by Account Id
   * 
   * @param String [ccountId]   Used to query account
   * @return Account [acc]
  */
  public Account getAccountById (String accountId) {
    List<Account> listAcc = [SELECT Id, Name, Owner.Title FROM Account WHERE Id = :accountId LIMIT 1];
    Account acc = (listAcc.size() == 1) ? listAcc.get(0) : null;
    return acc;
  }

  /**
   * Add case to a task
   *
   * @param String caseId The case id to add.
   * @param String 
   * taskId The task id to add to.
   * @return void.
   */
  public static Boolean addCaseToTask(String caseId, String taskId) {
    Boolean ret = false;

    List<Task> listTasks = [SELECT Id, WhatId FROM Task WHERE Id = :taskId LIMIT 1];
    Task currentTask = listTasks.size() == 1 ? listTasks.get(0) : null;

    if (currentTask != null) {
      currentTask.WhatId = caseId;
      update currentTask;
      ret = true;
    }

    return ret;
  }

  /**
   *   Method to used for validate the Cancel Case Wizard
   *   
   *   @author Mason
   *   @date   2018-11-19
   *   @param  {String}     Account Id
   *   @return String     
   */
    public static String validateCaseWizard(String accId) {

        String errorMessage;
        boolean isOwnCase = false;
        // validate there is active subscription or not
        List<Zuora__Subscription__c> listActiveSub = [SELECT Id FROM Zuora__Subscription__c 
                                                        WHERE True_Subscription_Status__c = 'Active'
                                                        AND  Zuora__Account__c =: accId];
        if(listActiveSub.isEmpty()) {
          errorMessage = Label.Case_Wizard_No_Subscription_Message;
        }

        // validate current open case is olny one.
        List<Case> listCases = [SELECT Id, AccountId, Account_Owner__c, OwnerId, RecordTypeId
                                FROM Case WHERE AccountId = :accId 
                                AND RecordType.Name = '1 - Cancels'
                                AND IsClosed = FALSE];

        if(listCases.size() > 1){
          errorMessage = Label.Case_Wizard_Multiple_Open_Case_Message;
        }
        
        return errorMessage;
    }

   /**
 * @purpose Get acccount and sum effective Revenue Mapping
 * @author  Mason
 * @date    2018-11-08
 * @param   map<Id,Id> mapCaseIdAccId    
 *                              
 * @return  List<Account_Snapshots__c> listAccSnap
 */
  public static Map<Id, Decimal> composeAccAndRevenueMapping(set<Id> setAccId) {
    Map<Id, Decimal> mapAccIdRevenue = new Map<Id, Decimal>();
    for(Live_Subscription_Product_and_Charge__c liveCharge : [SELECT id, Zuora_MonthlyRecurringRevenue__c, Zuora_TotalContractValue__c, 
                                                            Live_Price__c, Zuora_Account__c, Product_Type__c, Commission_Line_Item_Status__c 
                                                            FROM Live_Subscription_Product_and_Charge__c 
                                                            WHERE Zuora_Account__c IN: setAccId 
                                                            AND Commission_Line_Item_Status__c = 'Live' 
                                                            AND Product_Type__c = 'Internet']) {

      //Get current live charge effective revenue. 
      //If product type is Internet, used Monthly Recurring Revenue to calculates account revenue
      Decimal internetMRR = liveCharge.Zuora_MonthlyRecurringRevenue__c != null? liveCharge.Zuora_MonthlyRecurringRevenue__c: 0;
      if(!mapAccIdRevenue.containsKey(liveCharge.Zuora_Account__c)) { 
        mapAccIdRevenue.put(liveCharge.Zuora_Account__c, internetMRR);
      }
      else{
        Decimal tempMRR = mapAccIdRevenue.get(liveCharge.Zuora_Account__c) + internetMRR;
        mapAccIdRevenue.put(liveCharge.Zuora_Account__c, tempMRR);
      }
    }
    System.debug(LoggingLevel.INFO, '*** mapAccIdRevenue: ' + mapAccIdRevenue);
    return mapAccIdRevenue;
  }

/**
 * @purpose create Account Snapshots for first close case
 * @author  Mason
 * @date    2018-11-08
 * @param   map<Id,Id> mapCaseIdAccId    
 *                              
 * @return  List<Account_Snapshots__c> listAccSnap
 */
  public static List<Account_Snapshots__c> createAccountSnapshots(Map<Id,Id> mapCaseIdAccId, Map<Id, Decimal> mapAccIdSumMRR) {
    List<Account_Snapshots__c> listAccSnap = new List<Account_Snapshots__c>();
    Set<String> setSnapshotPeriod = new Set<String>();
    // Get Account Snapshot period setting from Custom Metadata Type 
    for(Commission_Setting__mdt snapshotsSetting : [SELECT Commissions_Value__c
                                                                  FROM Commission_Setting__mdt
                                                                  WHERE DeveloperName = 'Account_Snapshots_Setting'
                                                                  AND IsActive__c = TRUE]){

      if(String.isNotBlank(snapshotsSetting.Commissions_Value__c)) {
        for(String period : snapshotsSetting.Commissions_Value__c.split(STRDELIM)) {
          setSnapshotPeriod.add(period.trim());
        }
      }
    }

    for(Id caseId : mapCaseIdAccId.keySet()) {
      Id accountId = mapCaseIdAccId.get(caseId);

      //Create 4 (0/30/60/90 Day) records for each close case 
      for(String period : setSnapshotPeriod) {
        Account_Snapshots__c newAccSnap = new Account_Snapshots__c();
        newAccSnap.Case__c = caseId;
        newAccSnap.Snapshot_Period__c = period + ' Day';
        if(period == '0') {
          // Create 0 Day Account Snapshot record
          newAccSnap.Snapshot_Date__c = System.today();
          if(mapAccIdSumMRR.containsKey(accountId)) {
            newAccSnap.Account_Value__c = mapAccIdSumMRR.get(accountId);
          }
          else{
            newAccSnap.Account_Value__c = 0;
          }
        }
        else {
          // Create 30/60/90 Day Account Snapshots record
          newAccSnap.Snapshot_Date__c = System.today().addDays(Integer.valueOf(period));
        }
        listAccSnap.add(newAccSnap);
      }
    }
    return listAccSnap;
  }

/**
 * @purpose Send notification to case owner/client solutions team 
 * @author  Mason
 * @date    2019-01-18
 * @param   map<Id,Id> mapCaseIdAccId    
 *                              
 * @return  void
 */
  public static void sendNotifications(list<Case> listCases, List<OrgWideEmailAddress> listOrgWideEmail, list<User> listQueueMembers, 
                                      String emailTemplateId, Integer endDays) {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();

    for(Case currentCase : listCases) {

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
     
        //sender notification to case owner when rep uses "save for later" on days 1 - 3.
        if(currentCase.Num_Of_Days_Since_Created_Day__c < endDays) {
              singleEmail = EmailUtility.generateEmail(emailTemplateId, currentCase.Id, currentCase.OwnerId, false, listOrgWideEmail[0].Id, null, null);
              emailList.add(singleEmail);
        }
        //sender notification to client solutions team for every active members on Day 4 
        else if(currentCase.Num_Of_Days_Since_Created_Day__c == endDays){
            for(user queueMember : listQueueMembers) {
                singleEmail = EmailUtility.generateEmail(emailTemplateId, currentCase.Id, queueMember.Id, false, listOrgWideEmail[0].Id, null, null);
                emailList.add(singleEmail);
            }
        }
    }
    // send email 
    if (!emailList.isEmpty()) {
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList, false);
      System.debug(LoggingLevel.INFO, '***  send email results: ' + results);
      xoExceptionList.addAll(ExceptionUtility.consumeException(results));
    }
    if (!xoExceptionList.isEmpty()) {
      insert xoExceptionList;
    } 
  }

  /**
   * @purpose build Onboarding case map for Opportunity and Account
   * @author  Steven
   * @date    2019-03-11
   * @param   List<Zuora__SubscriptionProductCharge__c> listSubProductCharges    list of Zuora__SubscriptionProductCharge__c
   * @return  
   */
    private static void buildOnboardingCaseMap(List<Zuora__SubscriptionProductCharge__c> listSubProductCharges) {
        
        if(!listSubProductCharges.isEmpty()){

            for (Zuora__SubscriptionProductCharge__c spcRec : listSubProductCharges) {

                Id oppyId = spcRec.Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__c;
                Id acctId = spcRec.Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__r.AccountId;

                if(String.isNotBlank(oppyId)){

                    mapOppyIdToOnboardingCaseId.put(oppyId, NULL);
                }

                if(String.isNotBlank(acctId)){

                    mapAcctIdToOnboardingCaseId.put(acctId, NULL);
                }
            }
            
            if(!mapOppyIdToOnboardingCaseId.isEmpty()){
                //build map of Opportunity/Account to onboarding case
                for(Case onboardingCase : [SELECT Id, Opportunity__c, AccountId, Opportunity__r.Onboarding_Required__c 
                                            FROM Case 
                                            WHERE RecordTypeId =: mapCaseRecTypeIdByName.get('2 - Onboarding').getRecordTypeId()
                                            AND IsClosed = FALSE 
                                            AND (
                                                Opportunity__c IN: mapOppyIdToOnboardingCaseId.keySet()
                                                OR 
                                                AccountId IN: mapAcctIdToOnboardingCaseId.keySet()
                                            )]){

                    if(String.isNotBlank(onboardingCase.Opportunity__c)){

                        mapOppyIdToOnboardingCaseId.put(onboardingCase.Opportunity__c, onboardingCase.Id);
                    }

                    if(String.isNotBlank(onboardingCase.AccountId)){

                        mapAcctIdToOnboardingCaseId.put(onboardingCase.AccountId, onboardingCase.Id);
                    }
                }
            }
        }
    }

/**
 * @purpose create Asset Collection case based on Zuora__SubscriptionProductCharge__c record
 * @author  Steven
 * @date    2019-03-11

 * @param   List<Zuora__SubscriptionProductCharge__c> listSubProductCharge         list of Zuora__SubscriptionProductCharge__c record
 * @param   Map<Id,AccountContactRole>   mapAcctIdToAcctContRole         map of account contact role
 * @return  List<Case>
 */
  public static List<Case> createAssetCollectionCase(List<Zuora__SubscriptionProductCharge__c> listSubProductCharge,
                                                      Map<Id, AccountContactRole> mapAcctIdToAcctContRole) {
      List<Case> listAssetCollectionCase = new List<Case>();

      if(mapCaseQueueNameToQueueId == NULL){
          buildCaseQueueMap();
      }

      //get onboarding case to link with Asset Collection case
      buildOnboardingCaseMap(listSubProductCharge);

      for (Zuora__SubscriptionProductCharge__c spcRec : listSubProductCharge) {

          Case assetCollectionCase = new Case();
          assetCollectionCase.RecordTypeId = mapCaseRecTypeIdByName.get('Asset Collection').getRecordTypeId();
          assetCollectionCase.OwnerId = mapCaseQueueNameToQueueId.get('Asset_Collection_Initiated_Queue');
          assetCollectionCase.Rate_Plan_Name__c = spcRec.Zuora__RatePlanName__c;
          assetCollectionCase.Subject = spcRec.Zuora__RatePlanName__c;
          assetCollectionCase.AccountId = spcRec.Zuora__Account__c;
          assetCollectionCase.Status = 'New';
          assetCollectionCase.Reason = 'Asset Collection';
          assetCollectionCase.Origin = 'Auto-Generated';
          assetCollectionCase.Subscription_Charge_Number__c = spcRec.Zuora__SubscriptionChargeNumber__c;              
          assetCollectionCase.Subscription_Name__c = spcRec.Zuora__Subscription__r.Name;
          assetCollectionCase.SubscriptionProductCharge__c = spcRec.Id;
          assetCollectionCase.Possible_Renewal__c = spcRec.Is_Possible_Renewal__c;
          assetCollectionCase.Asset_Collection_Product_Name__c = spcRec.Product_Name_Text__c;
          assetCollectionCase.Product_Type__c = spcRec.Zuora__Subscription__r.Product_Line__c;
          assetCollectionCase.Term_Start_Date__c = spcRec.Zuora__EffectiveStartDate__c; 
          assetCollectionCase.Term_End_Date__c = spcRec.Zuora__EffectiveEndDate__c; 
          assetCollectionCase.LDE_Launch_Date__c = spcRec.LDE_Email_Launch_Date__c;

          if (mapAcctIdToAcctContRole.containsKey(spcRec.Zuora__Account__c)) {
              AccountContactRole acrRec = mapAcctIdToAcctContRole.get(spcRec.Zuora__Account__c);
              assetCollectionCase.ContactId = acrRec.ContactId;
          }
            
         

          Id oppyId = spcRec.Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__c;
          Id acctId = spcRec.Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__r.AccountId;
          //Assign Onboarding_Case__c lookup field from Opportunity or Account
          if(String.isNotBlank(oppyId) 
            && mapOppyIdToOnboardingCaseId.containsKey(oppyId) 
            && mapOppyIdToOnboardingCaseId.get(oppyId) != NULL){

              assetCollectionCase.Onboarding_Case__c = mapOppyIdToOnboardingCaseId.get(oppyId);
          }
          else if(String.isNotBlank(acctId) 
            && mapAcctIdToOnboardingCaseId.containsKey(acctId) 
            && mapAcctIdToOnboardingCaseId.get(acctId) != NULL){

              assetCollectionCase.Onboarding_Case__c = mapAcctIdToOnboardingCaseId.get(acctId);
          }
          
          assetCollectionCase.Opportunity__c = oppyId;
          

          listAssetCollectionCase.add(assetCollectionCase);
          
      }

      return listAssetCollectionCase;
  }

  /**
   * @purpose create Onboarding case
   * @author  Steven
   * @date    2019-01-29
   * @param   Map<Id,Id>      mapAccountIdToOppyId         map of account Id and opportunity Id to generate Onboarding case
   * @return  List<Case>
   */
  public static List<Case> createOnboardingCase(Map<Id,Id> mapAccountIdToOppyId) {
      List<Case> listOnboardingCases = new List<Case>();
      Map<Id,Decimal> mapAccountIdToActiveTCV = new Map<Id,Decimal>();

      //If there is exsiting open Onboarding case record under the same account, skip the Onboarding case generation
      if(!mapAccountIdToOppyId.isEmpty()){

          if(mapCaseQueueNameToQueueId == NULL){
              buildCaseQueueMap();
          }
          
          for(Case onboardingCase : [SELECT Id,AccountId FROM Case 
                                      WHERE IsClosed = FALSE
                                      AND RecordTypeId =: mapCaseRecTypeIdByName.get('2 - Onboarding').getRecordTypeId()
                                      AND AccountId IN: mapAccountIdToOppyId.keySet()]){

              mapAccountIdToOppyId.remove(onboardingCase.AccountId);
          }
      }

      if(!mapAccountIdToOppyId.isEmpty()){
          //get SUM of True TCV of the quote(s) on the opportunity where status = "Sent to Z-Billing" to check if Account is VIP
          mapAccountIdToActiveTCV = buildAccountTCVMappping(mapAccountIdToOppyId);
            
          for (Account currentAccount : [SELECT Id,  
                                          (
                                            SELECT ContactId, AccountId 
                                             FROM AccountContactRoles 
                                             WHERE Role in ('Primary','Billing') 
                                             AND Contact.Status__c = 'Active' 
                                             ORDER BY Role ASC, CreatedDate DESC 
                                             LIMIT 1
                                           ) 
                                         FROM Account 
                                         WHERE Id IN: mapAccountIdToOppyId.keySet()]) {
              
                Case onboardingCase = new Case();
                onboardingCase.AccountId = currentAccount.Id;
                //link Onboarding case with Opportunity that needs Onboarding case
                onboardingCase.Opportunity__c = mapAccountIdToOppyId.get(currentAccount.Id);
                // if the account have primary contact, assigned the newest contact role's contact to case contact
                if (currentAccount.AccountContactRoles.size() > 0) {
                    onboardingCase.ContactId = currentAccount.AccountContactRoles[0].ContactId;
                }
                onboardingCase.RecordTypeId = mapCaseRecTypeIdByName.get('2 - Onboarding').getRecordTypeId();
                onboardingCase.Origin = 'Auto Generated';
                // if account active TCV is greater than or equal VIP account TCV value, we assign onboarding to VIP queue, 
                if(mapAccountIdToActiveTCV.containsKey(currentAccount.Id) 
                  && mapAccountIdToActiveTCV.get(currentAccount.Id) >= Integer.valueOf(Label.VIP_Account_TCV_Value)){

                    onboardingCase.OwnerId = mapCaseQueueNameToQueueId.get('VIP_Queue');
                    //We mark VIP_Onboarding_Case__c as TRUE so that system will send VIP Onboarding emails automatically
                    onboardingCase.VIP_Onboarding_Case__c = TRUE;
                }
                // else it should go to Onboarding Case Queue
                else{
                    onboardingCase.OwnerId = mapCaseQueueNameToQueueId.get('Onboarding_case_queue');
                }
                onboardingCase.Priority = 'High';
                onboardingCase.Reason = 'Onboarding';
                onboardingCase.Subject = 'Onboarding';
                onboardingCase.Attempts__c = '0';
                onboardingCase.Follow_Up_Attempts__c = '0';
                onboardingCase.No_Show_Attempts__c = '0';

                listOnboardingCases.add(onboardingCase);
          }
          
      }

      return listOnboardingCases;
  }

/**
 * @purpose build case queue developer name and queue Id map
 * @author  Steven
 * @date    2019-03-13
 * @param   
 * @return  
 */
  private static void buildCaseQueueMap(){

      // build a map of case queue developer name and case queue id
      mapCaseQueueNameToQueueId = new Map<String,Id>();

      for(QueueSobject queueObj : [SELECT QueueId, Queue.DeveloperName FROM QueueSobject WHERE SObjectType = 'Case']) {

          mapCaseQueueNameToQueueId.put(queueObj.Queue.DeveloperName, queueObj.QueueId);

      }
      
  }

/**
 * @purpose build a map of account TCV value
 * @author  Steven
 * @date    2019-04-08
 * @param   Map<Id,Id> mapAccountIdToOppyId    map of AccountId to Opportunity Id
 * @return  Map<Id,Decimal>
 */
  public static Map<Id,Decimal> buildAccountTCVMappping(Map<Id,Id> mapAccountIdToOppyId){
      Map<Id,Decimal> mapAccountIdToActiveTCV = new Map<Id,Decimal>();

      //get SUM of True TCV of the quote(s) on the opportunity where status = "Sent to Z-Billing" to check if Account is VIP
      for(zqu__Quote__c zQuote : [SELECT True_TCV__c, zqu__Opportunity__c, zqu__Opportunity__r.AccountId 
                                  FROM zqu__Quote__c 
                                  WHERE zqu__Opportunity__c IN: mapAccountIdToOppyId.values()
                                  AND zqu__Status__c = 'Sent to Z-Billing'
                                  AND zqu__Opportunity__r.AccountId IN: mapAccountIdToOppyId.keySet()]){
        
          if(!mapAccountIdToActiveTCV.containsKey(zQuote.zqu__Opportunity__r.AccountId)){
              mapAccountIdToActiveTCV.put(zQuote.zqu__Opportunity__r.AccountId, 0);
          }
          
          Decimal tempTCV = mapAccountIdToActiveTCV.get(zQuote.zqu__Opportunity__r.AccountId) + zQuote.True_TCV__c;
          mapAccountIdToActiveTCV.put(zQuote.zqu__Opportunity__r.AccountId, tempTCV);
          
      }

      return mapAccountIdToActiveTCV;
  }

  /**
 * @purpose get specific queue member Id
 * @author  Steven
 * @date    2019-04-08
 * @param   Id  specificQueueId    specific queue Id
 * @return  Set<Id>
 */
  public static Set<Id> getSpecificQueueMember(Id specificQueueId){
      Set<Id> setQueueMemberIDs = new Set<Id>();

      if(String.isNotBlank(specificQueueId)){
          for(GroupMember groupMember :  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: specificQueueId]){

              setQueueMemberIDs.add(groupMember.UserOrGroupId);
          }
      }
      
      return setQueueMemberIDs;
  }

  /**
   * Case all field wrapper for save or display to page 
   */
  public class CaseInfoWrapper{

    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String caseOwnerId { get; set; }
    @AuraEnabled public String caseOwnerName { get; set; }
    @AuraEnabled public String contactId { get; set; }
    @AuraEnabled public String contactName { get; set; }
    @AuraEnabled public String accountId { get; set; }
    @AuraEnabled public String accountName { get; set; }
    @AuraEnabled public String initialContact { get; set; }
    @AuraEnabled public String associatedTaskOrEmail { get; set; }
    @AuraEnabled public Datetime originalRequestDate { get; set; }
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String reason { get; set; }
    @AuraEnabled public String cancelReasonNotes { get; set; }
    @AuraEnabled public String outcome { get; set; }
    @AuraEnabled public String savedBy { get; set; }
    @AuraEnabled public List<AttachmentWrapper> attachments { get; set; }
    @AuraEnabled public List<TaskWrapper> tasks { get; set; }

    public CaseInfoWrapper( String caseOwnerId, String caseOwnerName, String contactId,
      String contactName, String accountId, String accountName, Datetime requestDate) {

      this.id = null;
      this.caseOwnerId = caseOwnerId;
      this.caseOwnerName = caseOwnerName;
      this.contactId = contactId;
      this.contactName = contactName;
      this.accountId = accountId;
      this.accountName = accountName;
      this.initialContact = null;
      this.associatedTaskOrEmail = null;
      this.originalRequestDate = requestDate;
      this.type = null;
      this.reason = null;
      this.cancelReasonNotes = null;
      this.outcome = null;
      this.savedBy = null;
      this.attachments = new List<AttachmentWrapper>();
      this.tasks = new List<TaskWrapper>();
    }

    public CaseInfoWrapper(Case caseObj, String caseOwnerName, String contactName, String accountName) {
      this.id = caseObj.Id;
      this.caseOwnerId = caseObj.OwnerId;
      this.caseOwnerName = caseOwnerName;
      this.contactId = caseObj.ContactId;
      this.contactName = contactName;
      this.accountId = caseObj.AccountId;
      this.accountName = accountName;
      this.initialContact = caseObj.Origin;
      this.associatedTaskOrEmail = null;
      this.originalRequestDate = caseObj.Date_and_Time_Request_Received__c;
      this.type = caseObj.Type;
      this.reason = caseObj.Reason;
      this.cancelReasonNotes = caseObj.Cancel_Reason_Notes__c;
      this.outcome = caseObj.Outcome__c;
      this.savedBy = caseObj.Saved_By__c;
      this.attachments = new List<AttachmentWrapper>();
      this.tasks = new List<TaskWrapper>();
    }

  }

  /**
   * Attachment Id and Name wrapper
   */
  public with sharing class AttachmentWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String attachmentName { get; set; }

    public AttachmentWrapper(String id, String name) {
      this.id = id;
      this.attachmentName = name;
    }
  }

  /**
   * Task Id and Name wrapper
   */
  public with sharing class TaskWrapper  {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String taskName { get; set; }

    public TaskWrapper(String id, String name) {
      this.id = id;
      this.taskName = name;
    }
  }

  /**
   * Search Result data transfer object
   */
  public with sharing class SearchResultWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String resultName { get; set; }

    public SearchResultWrapper(String id, String name) {
      this.id = id;
      this.resultName = name;
    }
  }
}