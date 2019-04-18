public without sharing class CaseTriggerHandler implements XOTrigger{
  
  // Store the cases which need to auto fill up the ID fields from Description 
  private List<Case> caseList = new List<Case>();
  
  // Store the mapping relationship between email content to field api name
  private final String CASE_EMAIL_FIELD_MAPPING = System.Label.CaseEmailFieldMapping.toLowerCase();
  
  // Store the mapping between Priority and account TCV Range
  private final String CASE_PRIORITY_RANGE = System.Label.CasePriorityRange.toLowerCase();
  // delimiter for fieldmapping
  private static final String FIELDDELIM = '\n';
  private static final String VALUEDELIM = '->';
  private static final String DELIMITER = '\r\n';
  private static final String STRDELIM = ',';
  private static final Decimal HOURSRATE = 3600000.0;
  // CSP-2806 Mark Cancel Cases as BoB versus Service  - as default queue id 
  private static final Id DEFAULTQUEUEID;
  // related account map for assign the account to case
  private Set<Id> accountIdSet = new Set<Id>();
  private Map<Id, Account> relatedAccountMap = new Map<Id, Account>();
  // related contact map for assign the account to case
  private Set<Id> contactIdSet = new Set<Id>();
  private Map<Id, Contact> relatedContactMap = new Map<Id, Contact>();

  //get the current user Info and manager Info
  private User currentUser;
  
  // Store the new OwnerId when the case owner changed
  private Set<Id> newOwnerIdSet = new Set<Id>();

  // Store the owner and his manager
  private Map<Id,Id> ownerManagerMap = new Map<Id,Id>();

  // case recordtype map  
  private Map<Id, Schema.RecordTypeInfo> caseRecTypeIDMap = Schema.SObjectType.Case.getRecordTypeInfosById();
  private Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();

  //CSP-2185 Store the email address for the case which not found the contact.
  private Set<String> emailStrSet = new Set<String>();

  // the map to store the email-->account,contact,user
  private Map<String,Account> emailAccountMap = new Map<String,Account>(); 
  private Map<Id,Contact> accountIdContactMap = new Map<Id,Contact>();
  private Map<String,User> emailUserMap = new Map<String,User>();
  // CSP-2591
  private Map<String,User> cancelEmailUserMap = new Map<String,User>();

  // CSP-2261 default queue
  private List<Group> queueList = new List<Group>();
  
  // CSP-2417 get the email address which has created more than 10 cases in last one hour
  private Set<String> endLoopEmailSet = new Set<String>();

  // use a set to store all available profile names for close survey email
  private static Set<String> setProfileNamesForCloseSurveyEmail = new Set<String>();
  //Store the Account Id and Onboarding case Id to sync Asset Collection cases
  private Map<Id,Id> mapAcctIdToOnboardingCaseId = new Map<Id,Id>();
  // the set to store all onboarding case Id for query optimization
  private Set<Id> setOnboardingCaseIdForQuery = new Set<Id>();
  // store the onboarding Case Id to send email to customer
  private Set<Id> setOnboardingCaseIdForWelcomeEmail = new Set<Id>();
  // store the onboarding close complete Case Id to send email to customer
  private Set<Id> setOnboardingCaseIdForCloseSurveyEmail = new Set<Id>();
  // store the onboarding Case Id to generate task
  private Set<Id> setOnboardingCaseIdForFollowUpTask = new Set<Id>();

  // an email is sent to the customer with a link to a survey for the individual Account Strategist who is listed as the Case Owner
  private static final Id onboardCloseCaseSurveyEmailTemplateId; 
  private static final Id onboardWelcomeEmailTemplateId; 
  //onboarding email template for VIP
  private static final Id onboardCloseCaseSurveyVIPEmailTemplateId; 
  private static final Id onboardWelcomeVIPEmailTemplateId; 

  private static final OrgWideEmailAddress orgWideEmailAdd; 
  private Map<String, Schema.RecordTypeInfo> tastkRecTypeNameMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
  private static List<BusinessHours> businessHourList;

  //for CSP-2484, store the caseID and user who need send Email when user close case
  private Map<Id,set<Id>> caseIdEmailListMap = new Map<Id,set<Id>>();  
  private list<Case> closeCaseList = new List<Case>() ;
  private list<Feature_Requested_Cancelled__c> cancelFRCList = new List<Feature_Requested_Cancelled__c>() ;
  private list<Id> closeCaseIdlist = new List<Id>() ;
  private static final Id closeCaseEmailTemplateId; 
  private static final OrgWideEmailAddress orgWideEmailAddForOutcome;

  // csp-2671
  private Set<Id> onboardingAccountIdSet = new Set<Id>();
  private Set<Id> onboardingContactIdSet = new Set<Id>();
  private Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
  private Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>();
  private List<Account> onboardingAccsToBeUpdatedList = new List<Account>();
  private List<Contact> onboardingContactsToBeUpdatedList = new List<Contact>();

 //store the case Id and case owner Id to reassign tasks on case owner update
  private Map<Id,Id> caseIdToCaseOwnerMap = new Map<Id, Id>();

  // CSP-2659 Features Requested Cancelled Reporting
  private Set<Id> notAllowCloseCaseId = new Set<Id>();
  private final String CANCEL_CASE_CLOSE_ERROR_MESSAGE = Label.Cancel_Case_Close_Error_Message;
  
  // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
  // stored the account Id and account info
  private Map<Id,Account> pdbAccountIdMap = new Map<Id,Account>();
  
  // CSP-2806 Mark Cancel Cases as BoB versus Service
  private set<Id> closeCaseAccountIdSet = new set<Id>();
  // stored the account Id and account info
  private Map<Id,Account> closeAcctIdAndAcctMap = new Map<Id,Account>();
  // Stroed system queue id and developerName
  private static Map<Id,String> queueIdNameMap = new Map<Id,String>();
  // Stored case queue developer name and case queue Id
  private static Map<String,Id> mapCaseQueueNameToQueueId = new Map<String,Id>();
  // Title of Case owner to mark Cancel_Case_Type__c
  private static final String CLOSE_CANCEL_CASE_OWNER_TITLE = System.Label.Close_Cancel_Case_Owner_Title;

  // CSP-2808 Cancel case revamp
  private static final Set<String> CANCEL_CASE_OUTCOME_SET = new Set<String>(); 

  // CSP-2750 inbound case
  // use a set to store all available record type
  private static Set<String> recordtypeSet = new Set<String>();
  // store account Id to query most recent opened cases for recent case owner assignment
  private Set<Id> setAccountIdForRecentCase = new Set<Id>();

  // use a set to store all cancel close status for CSP-2806
  private static Set<String> cancelCloseStatusSet = new Set<String>();
  private static Set<String> closeStatusSet = new Set<String>();

  // use a set to store case id when first close case and outcome is saved. 
  private static Map<Id,Id> mapCaseIdAccId = new Map<Id,Id>();
  private static Map<Id, Decimal> mapAccIdSumMRR = new Map<Id, Decimal>();
  private static set<Id> setCloseCaseAccId = new set<Id>();

  //Store the cases to unify owner for the same account
  private List<Case> setCasesToUnifyOwner = new List<Case>();
  //Store Account Id and Oppy Id from Onboarding case to get active TCV for VIP check
  private Map<Id,Id> mapAcctIdToOppyIdForOnboarding = new Map<Id,Id>();
  //Store Account Id and active TCV for VIP check
  private Map<Id,Decimal> mapAccountIdToActiveTCV = new Map<Id,Decimal>();
  //Store VIP queue member Id for VIP check 
  private Set<Id> setVIPQueueMemberIDs;
  
  //query DE out of office record to check if user is OOO
  private static final String DE_OUT_OF_OFFICE_QUERY = 'SELECT '
                                                    + 'n2de__User__c, '
                                                    + 'n2de__Start_datetime__c, '
                                                    + 'n2de__End_datetime__c '
                                                + 'FROM '
                                                    + 'n2de__Out_of_office__c '
                                                + 'WHERE '
                                                    + '{WHERECLAUSE}';

  static {
    try {
      businessHourList = [SELECT id FROM BusinessHours WHERE Name = 'XO Business Hours' LIMIT 1];
      for(OrgWideEmailAddress OWEA : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress 
                                  WHERE Address =: Label.Onboarding_Email_From_Address OR Address =: Label.Case_Outcome_Email_Address ]) {
        
        //CSP-2114 send out Onboarding email need to used system email address
        if(OWEA.Address == Label.Onboarding_Email_From_Address) {
          orgWideEmailAdd = OWEA;
        } 
        
        //csp-2484 send out outcome email need to used system email address
        if(OWEA.Address == Label.Case_Outcome_Email_Address) {
          orgWideEmailAddForOutcome = OWEA;
        }
      }



      for (EmailTemplate currentET: [SELECT Id, Name, DeveloperName FROM EmailTemplate 
                                        WHERE DeveloperName = 'OnBoarding_Welcome_Auto' 
                                        OR DeveloperName = 'Notify_Internal_Case_Team_Cancels_Case'
                                        OR DeveloperName = 'Onboarding_Close_Case_Email_From_Manager'
                                        OR DeveloperName = 'VIP_Welcome_Email' 
                                        OR DeveloperName = 'VIP_Close_Case_Email_from_Manager']) {
        
        if (currentET.DeveloperName == 'OnBoarding_Welcome_Auto') {
          onboardWelcomeEmailTemplateId = currentET.Id;
        }
        else if(currentET.DeveloperName == 'Onboarding_Close_Case_Email_From_Manager'){
          onboardCloseCaseSurveyEmailTemplateId = currentET.Id;
        }
        else if (currentET.DeveloperName == 'VIP_Welcome_Email') {
          onboardWelcomeVIPEmailTemplateId = currentET.Id;
        }
        else if(currentET.DeveloperName == 'VIP_Close_Case_Email_from_Manager'){
          onboardCloseCaseSurveyVIPEmailTemplateId = currentET.Id;
        }
        else{
          closeCaseEmailTemplateId = currentET.Id;
        }
      }

      // CSP-2261 default queue
      // CSP-2806 Mark Cancel Cases as BoB versus Service
      // Get all queue DeveloperName and id to the map
      for(Group currentQueue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
          if(currentQueue.DeveloperName == 'Case_Admin_Queue') {
            DEFAULTQUEUEID = currentQueue.Id;
          }

          mapCaseQueueNameToQueueId.put(currentQueue.DeveloperName,currentQueue.Id);
          queueIdNameMap.put(currentQueue.id,currentQueue.DeveloperName);
      }

      // Send close case survey email when users close onboarding case with Closed Completed status
      for(Miscellaneous_Setting__mdt closeCaseSurveyEmailProfile : [SELECT Miscellaneous_Value__c
                                                                    FROM Miscellaneous_Setting__mdt
                                                                    WHERE DeveloperName = 'Onboarding_Close_Case_Email_Profiles'
                                                                    AND IsActive__c = TRUE]){
        if(String.isNotBlank(closeCaseSurveyEmailProfile.Miscellaneous_Value__c)){
          for(String profile : closeCaseSurveyEmailProfile.Miscellaneous_Value__c.split(STRDELIM)){
            setProfileNamesForCloseSurveyEmail.add(profile.trim());
          }
        }
      }

      // CSP-2750 Inbound Case
      // add all available record types to the set
      if(String.isNotBlank(Label.RecentOpenedCaseRecordType)){
        for(String recType : Label.RecentOpenedCaseRecordType.split(STRDELIM)){
          recordtypeSet.add(recType.trim());
        }
      }

      // CSP-2806 Mark Cancel Cases as BoB versus Service
      // add all Close Status to the set for cancel record type
      if(String.isNotBlank(Label.Cancel_Case_Close_Status)){
         for(String Status : system.label.Cancel_Case_Close_Status.split('\r\n')) {
            cancelCloseStatusSet.add(Status.trim());
          }
      }
      // CSP-2806 Mark Cancel Cases as BoB versus Service
      // add all Close Status to the set for any record type
      if(String.isNotBlank(Label.Case_Close_Status)){
         for(String Status : system.label.Case_Close_Status.split('\r\n')) {
            closeStatusSet.add(Status.trim());
          }
      }

    } catch (Exception e) {
      XO_Exception__c xoException = ExceptionUtility.consumeException(e, true);
    }
  } 

  /**
   * Method used to bulkify all data needed in any "before" action of a trigger.
   */
  public void bulkBefore() {


    Id currentUserId = null;

    // CSP-2261 default queue
    // queueList = [SELECT Id FROM Group WHERE DeveloperName = 'Case_Admin_Queue' AND Type = 'Queue' limit 1];
    
    Set<Id> closeCancelCaseIdSet = new Set<Id>();
        
    // bulk before insert Logic//////////////////////////
    if (Trigger.isInsert) {

      // CSP-2417 get the email address set
      endLoopEmailSet = caseInfiniteLoopKiller();
      Set<String> cancelEmailStrSet = new Set<String>();

      for (Integer i = 0; i< trigger.new.size(); i++) {
        
        Case currentCase = (Case)trigger.new[i];

        // avoid emtpy record type records
        if(String.isBlank(currentCase.RecordTypeId)){
          // CSP-2261 assign to default queue and assign owner to default queue
          currentCase.RecordTypeId = caseRecTypeNameMap.get('Default').getRecordTypeId();
          // CSP-2806 Mark Cancel Cases as BoB versus Service
          // Merge code, get default queue id used DEFAULTQUEUEID 
          currentCase.OwnerId = DEFAULTQUEUEID;
          return;
        }

        // retrieve the record type name
        String rtName = caseRecTypeIDMap.get(currentCase.RecordTypeId).getName();

        // when manual create case, the current user id will assgin to currentUserId
        if (String.isBlank(currentCase.SuppliedEmail)) {
          currentUserId = UserInfo.getUserId();
        }

        //get AccountId and OpportunityId from Onboarding case to calculate TCV to mark "VIP Onboarding Case" flag for email sending
        //User should populate Opportunity__c lookup to calculate TCV value when they manually create Onboarding case
        if(rtName.containsIgnoreCase('2 - Onboarding')
          && String.isNotBlank(currentCase.AccountId)
          && String.isNotBlank(currentCase.Opportunity__c)
          && currentCase.VIP_Onboarding_Case__c == FALSE){

            mapAcctIdToOppyIdForOnboarding.put(currentCase.AccountId, currentCase.Opportunity__c);
        }

        // The Review and cancel logic
        // Get the email address 
        // for CSP-2591 Remove Auto-Contact/Account Population on E2C Cancellation Cases
        // if (rtName != '1 - Cancels') {
        // CSP-3022 Case Fields
        if (rtName != '1 - Cancels' && rtName != 'Rep Billing') {
          if (String.isBlank(currentCase.AccountId) && 
             String.isBlank(currentCase.ContactId) &&
            String.isNotBlank(currentCase.SuppliedEmail)) {

            emailStrSet.add(currentCase.SuppliedEmail);
          }
          else if (String.isBlank(currentCase.AccountId) && 
            String.isNotBlank(currentCase.ContactId)) {

            contactIdSet.add(currentCase.ContactId);
          }
          else if (String.isNotBlank(currentCase.AccountId)) {

            accountIdSet.add(currentCase.AccountId);
          }
        }
        // else if (rtName == '1 - Cancels' && String.isNotBlank(currentCase.SuppliedEmail)) {
        // CSP-3022 Case Fields
        // added the web email of rep billing case to the set, used for populate the Internal Report and Reporter type
        else if ((rtName == '1 - Cancels' || rtName == 'Rep Billing') && String.isNotBlank(currentCase.SuppliedEmail)) {
          cancelEmailStrSet.add(currentCase.SuppliedEmail);
        }
        else if(rtName == '1 - Cancels' && String.isBlank(currentCase.SuppliedEmail)){
          
          if (String.isBlank(currentCase.AccountId) && 
            String.isNotBlank(currentCase.ContactId)) {

            contactIdSet.add(currentCase.ContactId);
          }
          else if (String.isNotBlank(currentCase.AccountId)) {

            accountIdSet.add(currentCase.AccountId);
          }
        }
      }
    
      // Generate the emailAccountMap, accountIdContactMap
      // find the 1:1 contact for the Case Web Email, if found, added the account and contact to the emailAccountMap, accountIdContactMap 
      // and remove the email from emailStrSet 
      try{
        Set<String> emailSet = new Set<String>();//use for checking the contact,account,user is duplicate on email
        String emailStr = '';
        // If there is no 1:1 contact for the Case web Email, we should find the 1:1 account for the Case web Email, 
        // and if the contact has been found, added the account to the emailAccountMap, and remove the email from emailStrSet. 
        // then added the contact to the accountIdContactMap if there is only one contact under the 1:1 account.
        if(emailStrSet.size()>0){
          
          List<Account> accList = [SELECT Id, Name, Email__c, ActiveSubscriptionTCVSummary__c, Strategy_Specialist__r.IsActive, 
                                    Strategy_Specialist__c, Strategy_Specialist__r.ManagerId, (SELECT Id, Email FROM Contacts) 
                                    FROM Account 
                                    WHERE Recordtype.DeveloperName = 'AccConcierge' AND Email__c in: emailStrSet];
          
          if (accList.size()>0) {
            emailSet.clear();
            for (Account currentAccount : accList) {

              emailStr = currentAccount.Email__c.toLowerCase();

              // for 1:1, if there are more than 1 account has the same email, remove the data from the emailAccountMap and accountIdContactMap
              if (!emailSet.contains(emailStr)) {
                accountIdSet.add(currentAccount.Id);
                emailSet.add(emailStr);
                emailAccountMap.put(emailStr, currentAccount);
                //added the email to accountIdContactMap only when there one contact under account
                if (currentAccount.Contacts.size() == 1) {
                  accountIdContactMap.put(currentAccount.Id, currentAccount.Contacts[0]);
                }
                emailStrSet.remove(emailStr);
              }
              else{
                accountIdSet.remove(currentAccount.Id);
                emailAccountMap.remove(emailStr);
                accountIdContactMap.remove(currentAccount.Id);
                emailStrSet.add(emailStr);
              }
            }
          }
        }
        // if there is no 1:1 contact and Account for  the Case Web Email, we should find the 1:1 user for the Case web Email, 
        if(emailStrSet.size()>0){

          //  Generate the emailUserMap
          List<User> userList = [SELECT Id,Email,Name,UserRole.Name FROM User WHERE Email in : emailStrSet AND isActive = TRUE];
          
          if (userList.size()>0) {
            emailSet.clear();
            
            for (User currentUser : userList) {
              
              emailStr = currentUser.Email.toLowerCase();
              // for 1:1, if there are more than 1 account has the same email, remove the data from the emailUserMap
              if (emailSet.contains(emailStr)) {
                emailUserMap.remove(emailStr);
              }
              else{
                emailSet.add(emailStr);
                emailUserMap.put(emailStr, currentUser);
              }
            }
          }
        }

        if (!cancelEmailStrSet.isEmpty()) {
          // CSP-2591 Generate the cancelEmailUserMap 
          List<User> userList = [SELECT Id,Email,Name,UserRole.Name FROM User WHERE Email in : cancelEmailStrSet AND isActive = TRUE];
          if (!userList.isEmpty()) {
            for (User currentUser : userList) {
              cancelEmailUserMap.put(currentUser.Email.toLowerCase(), currentUser);
            }
          }
        }
      }
      catch(Exception e){
        ExceptionUtility.consumeException(e, true);
      }

      if (currentUserId != null) {
        currentUser = [SELECT Id, ManagerId FROM User WHERE id =: currentUserId];
      }
    }

    // bulk before Update Logic//////////////////////////
    else if (Trigger.isUpdate) {


      for (Integer i = 0; i< trigger.new.size(); i++) {
        
        Case currentCase = (Case)trigger.new[i];
        Case oldCase = (Case)trigger.oldMap.get(currentCase.id);

        // if (rtName.containsIgnoreCase('1 - Cancels')) {
        if(String.isNotBlank(currentCase.AccountId) && 
          currentCase.AccountId != oldCase.AccountId){

          accountIdSet.add(currentCase.AccountId);
        }
        else if(String.isBlank(currentCase.AccountId) && 
                String.isNotBlank(currentCase.ContactId) &&
                String.isNotBlank(oldCase.AccountId)
                ){

          contactIdSet.add(currentCase.ContactId);
        }
        else if(String.isNotBlank(currentCase.AccountId) && 
                String.isNotBlank(currentCase.ContactId) && 
                currentCase.ContactId != oldCase.ContactId){

          contactIdSet.add(currentCase.ContactId);
        }
      
        if (currentCase.OwnerId != oldCase.OwnerId) {

          newOwnerIdSet.add(currentCase.OwnerId);
        }

        // CSP-2659 Features Requested Cancelled Reporting
        // get all the cancelled cases Id which need to validate the FRC
        // CSP-2780 Trapped Cases 
        // if the user check the flag Skip_The_Notification_And_Validation__c when close the cancel case
        // we don't need to validate the FRC
        // CSP-2808 Cancel case revamp
        // use a label to store cancel case outcome picklist value
        String rtName = caseRecTypeIDMap.get(currentCase.RecordTypeId).getName();
        for(String outcomeValue : system.label.Cancel_Case_Outcome.split('\r\n') ){
          CANCEL_CASE_OUTCOME_SET.add(outcomeValue.trim());
        }

        if (rtName == '1 - Cancels' 
            && !currentCase.Skip_The_Notification_And_Validation__c 
            && currentCase.Status !=  oldCase.Status
            && (currentCase.Status == 'Closed' || currentCase.Status == 'Closed Duplicate') 
            && (CANCEL_CASE_OUTCOME_SET.contains(String.valueOf(currentCase.Outcome__c)))) {

          closeCancelCaseIdSet.add(currentCase.id);
        }
        // CSP-2806 Mark Cancel Cases as BoB versus Service
        // Get account id when user attempts to close case  
        if (rtName == '1 - Cancels' 
            && !currentCase.Case_Closed_Flag__c
            && cancelCloseStatusSet.contains(currentCase.Status)
            && !cancelCloseStatusSet.contains(oldCase.Status) 
            && String.isNotBlank(currentCase.AccountId)) {

            closeCaseAccountIdSet.add(currentCase.AccountId);
        }
      }
    }

    //build Account Id and active TCV value from Opportunity
    if(!mapAcctIdToOppyIdForOnboarding.isEmpty()){
        //Given that an onboarding case qualifies as VIP (>= $15K TCV on the opportunity) automated VIP onboarding emails should go out
        //Given that an onboarding case does NOT qualify as VIP (<$15K TCV on the opportunity) automated onboarding emails should continue to go out
        mapAccountIdToActiveTCV = CaseService.buildAccountTCVMappping(mapAcctIdToOppyIdForOnboarding);
    }

    // Get Contact info when update case and on Account associated with the case
    if(!contactIdSet.isEmpty()){
      
      for(Contact currentContact : [SELECT Id, Account.Strategy_Specialist__r.IsActive, Account.Strategy_Specialist__c, Account.Strategy_Specialist__r.Manager.IsActive, 
                                    Account.Strategy_Specialist__r.ManagerId, Account.ActiveSubscriptionTCVSummary__c, AccountId, Account.Manual_VIP_Program_Status__c  
                                    FROM Contact 
                                    WHERE Id IN :contactIdSet]){

        relatedContactMap.put(currentContact.Id, currentContact);
      }
    }

    // CSP-2806 Mark Cancel Cases as BoB versus Service
    // Add logic to query Account owner titile info
    // Get Account info when update case Account
    Set<Id> allAccountIdSet = new Set<Id>();
    allAccountIdSet.addAll(accountIdSet);
    allAccountIdSet.addAll(closeCaseAccountIdSet);
    if(!allAccountIdSet.isEmpty()){
      
      for(Account acc : [SELECT Id, Strategy_Specialist__r.IsActive, Strategy_Specialist__c, Strategy_Specialist__r.Manager.IsActive, 
                          Manual_VIP_Program_Status__c, Strategy_Specialist__r.ManagerId, ActiveSubscriptionTCVSummary__c, 
                          Owner.Title, Owner.Name, (SELECT Id, Email FROM Contacts) 
                          FROM Account 
                          WHERE Id IN :allAccountIdSet]){
        //Get Account info when Relate Account has changed 
        if(accountIdSet.contains(acc.Id)){
           relatedAccountMap.put(acc.Id, acc);
        }
        // CSP-2806 Mark Cancel Cases as BoB versus Service
        // Get Account owner title info when close of the case
        if(closeCaseAccountIdSet.contains(acc.Id)){
           closeAcctIdAndAcctMap.put(acc.Id, acc);
        }
      }
    }

    if (!newOwnerIdSet.isEmpty()) {
      
      for(User currentUser : [SELECT Id, ManagerId FROM User WHERE Id IN :newOwnerIdSet]){
        ownerManagerMap.put(currentUser.Id, currentUser.ManagerId);
      }
    }

    // CSP-2659 Features Requested Cancelled Reporting
    // get all the cancelled cases Id which is not allowed to close.
    if (!closeCancelCaseIdSet.isEmpty()) {
      List<Case> caseList = [Select Id, AccountId, 
                            (SELECT Id, Case__c, Status__c, Subscription_Product_Charge__c, UniqueId__c 
                              FROM Feature_Requested_Cancelled__r) FROM Case WHERE id IN: closeCancelCaseIdSet];

      Boolean allowClosed = TRUE;
      for (Case currentRecord : caseList) {
        if (currentRecord.Feature_Requested_Cancelled__r.isEmpty()) {
          allowClosed = FALSE;
        }
        else{
          for (Feature_Requested_Cancelled__c currentFRC : currentRecord.Feature_Requested_Cancelled__r) {
            if (currentFRC.Status__c == 'Requested Cancelled') {
              allowClosed = FALSE;
              break;
            }
            else if (String.isBlank(currentFRC.Subscription_Product_Charge__c)) {
              allowClosed = FALSE;
              break;
            } 
          }
        }

        if (!allowClosed) {
          notAllowCloseCaseId.add(currentRecord.Id);
        }
      }
    }

    // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
    // if the case insert or update accountid, we generated a account map stored the account id and account info
    if (Trigger.isInsert || Trigger.isUpdate) {
      Set<Id> caseAccountIdSet = new Set<Id>();
      for (Integer i = 0; i< trigger.new.size(); i++) {

        Case currentCase = (Case)trigger.new[i];

        if (String.isNotBlank(currentCase.AccountId)) {
          caseAccountIdSet.add(currentCase.AccountId);
        }
      }

      if (!caseAccountIdSet.isEmpty()) {
        pdbAccountIdMap = new map<Id,Account>([select Id,Account.Past_Due_Balance__c from Account where id IN: caseAccountIdSet]);
      }
    }
  }

  /**
   *   Method used to bulkify all data needed in any "after" action of a trigger.
   */
  public void bulkAfter() {

    
    // bulk after Update Logic//////////////////////////
    if (Trigger.isUpdate) {
        for(SObject currentObj : Trigger.new){
            Case currentCase = (Case)currentObj;
            Case oldCase = (Case)trigger.oldMap.get(currentCase.id);

            // retrieve the record type name
            String rtName = caseRecTypeIDMap.get(currentCase.RecordTypeId).getName();

            //CSP-2484 Collecting the case ID when user close case 
            // CSP-2780 Trapped Cases 
            // if the user check the flag Skip_The_Notification_And_Validation__c when close the case
            // the notification will not send out
            if(currentCase.Status != oldCase.Status 
                && !currentCase.Skip_The_Notification_And_Validation__c 
                && (currentCase.Status == 'Closed' || currentCase.Status == 'Closed Duplicate') 
                && rtName.containsIgnoreCase('1 - Cancels')){

                closeCaseIdlist.add(currentCase.Id);
            }
            
            if(rtName.containsIgnoreCase('2 - Onboarding') && currentCase.IsClosed == True){

                if (String.isNotBlank(currentCase.AccountId)) {
                    onboardingAccountIdSet.add(currentCase.AccountId);
                }


                if (String.isNotBlank(currentCase.ContactId)) {
                    onboardingContactIdSet.add(currentCase.ContactId);  
                }
                
            }

            //Collect first close case of Account id
            if (isFirstCloseCancelCase(rtName, currentCase, oldCase)) {
                setCloseCaseAccId.add(currentCase.AccountId);
            }
        }
      


      // csp-2671
      if(!onboardingAccountIdSet.isEmpty()) {
        List<Account> accountsToBeUpdatedList = [SELECT In_Business_Since__c, Website_Grade__c, Segment__c, Beta_Opt_Out__c, Instagram__c
                             FROM Account 
                             WHERE Id IN: onboardingAccountIdSet];
        for(Account currentAcc: accountsToBeUpdatedList) {
          accountIdToAccountMap.put(currentAcc.Id, currentAcc);
        }
      }

      if(!onboardingContactIdSet.isEmpty()) {
        List<Contact> contactsToBeUpdatedList = [SELECT Preferredcontactmethod__c 
                             FROM Contact 
                             WHERE Id IN: onboardingContactIdSet];
        for(Contact currentContact: contactsToBeUpdatedList) {
          contactIdToContactMap.put(currentContact.Id, currentContact);
        }
      }

      //Get sum Monthly Recurring Revenue for each account 
      if(!setCloseCaseAccId.isEmpty()) {
        mapAccIdSumMRR = CaseService.composeAccAndRevenueMapping(setCloseCaseAccId);
      }

      if(!closeCaseIdlist.isEmpty()){
        //CSP-2484 Find ID of the Acount SS, Account Owner and Internal Report 
        closeCaseList = [SELECT id, Reporter_User_Name__r.Id, Account.Owner.Id, Account.Strategy_Specialist__r.Id, Account.VIP_Program__c 
                            FROM Case  WHERE id IN: closeCaseIdlist AND Recordtype.Name = '1 - Cancels'];

        for (case currentCase : closeCaseList) {
            if(!caseIdEmailListMap.containsKey(currentCase.Id)){
                caseIdEmailListMap.put(currentCase.Id, new set<Id>());
            }
            caseIdEmailListMap.get(currentCase.id).add(currentCase.Account.Strategy_Specialist__r.Id);
            caseIdEmailListMap.get(currentCase.id).add(currentCase.Reporter_User_Name__r.Id);
            //CSP-2484 If Account field "VIP Program" = true, no notifications should go to "Account Owner"
            if(!currentCase.Account.VIP_Program__c) {
                caseIdEmailListMap.get(currentCase.id).add(currentCase.Account.Owner.Id);
            }
        }
        //CSP-2484 Find ID of the Sales Rep under Subscription 
        cancelFRCList = [SELECT id, Case__c, Subscription_Product_Charge__r.Zuora__Subscription__r.Sales_Rep__r.Id 
                            FROM Feature_Requested_Cancelled__c 
                            WHERE Case__c IN: closeCaseIdlist 
                            AND Subscription_Product_Charge__r.Zuora__Account__r.VIP_Program__c = false ];
        for(Feature_Requested_Cancelled__c currentFRC : cancelFRCList) {
          if(!caseIdEmailListMap.containsKey(currentFRC.Case__c)){
              //New key within Map Initialize set
              caseIdEmailListMap.put(currentFRC.Case__c, new set<Id>());
          }
          //add id and The corresponding case id. 
          caseIdEmailListMap.get(currentFRC.Case__c).add(currentFRC.Subscription_Product_Charge__r.Zuora__Subscription__r.Sales_Rep__r.Id);
        }
      }
    }

  }

  /**
   *   All before insert logic should be done here. This method is called iteratively and as such
   *   should contain no actions which could potentially hit limits or is considered bad practice 
   *   in the Salesforce environment.
   *   
   *   @param  {SObject}   so Single SObject representation of the object being acted upon.
   */
  public void beforeInsert(SObject so) {
    
    Case caseObj = (Case)so;

    // avoid to empty record type
    if(String.isBlank(caseObj.RecordTypeId)){
      // CSP-2261 assign owner to default queue
      caseObj.RecordTypeId = caseRecTypeNameMap.get('Default').getRecordTypeId();
      // CSP-2806 Mark Cancel Cases as BoB versus Service
      // Merge code, get default queue id used DEFAULTQUEUEID
      caseObj.OwnerId = DEFAULTQUEUEID;
      return;
    }

    String rtName = caseRecTypeIDMap.get(caseObj.RecordTypeId).getName();

    // Added a new field Description(Description_Custom__c) to Store the Ture Description for ticket CSP-2324
    // the custom field can be added or removed from the page layout controlled by record type and profile
    if (String.isNotBlank(caseObj.Description) && String.isBlank(caseObj.Description_Custom__c)) {
      caseObj.Description_Custom__c = caseObj.Description;
    }


    // CSP-2750 Inbound Cases
    // run thru the inbound case logic
    // The review Case logic
    // for ticket CSP-2178
    // if the case Description is not null when case inserted or has been changed when case udpated, 
    // we should Auto fill data from description(email body) into Review Cases
    if (rtName.containsIgnoreCase('3 - Reviews') || rtName.containsIgnoreCase('Inbound')){
      if (String.isNotBlank(caseObj.SuppliedEmail) && endLoopEmailSet.contains(caseObj.SuppliedEmail)) {
        caseObj.Auto_Reply_Flag__c = FALSE;
      }
      else{
        caseObj.Auto_Reply_Flag__c = TRUE;
      }


      String searchKey = CASE_EMAIL_FIELD_MAPPING.split(FIELDDELIM)[0].split(VALUEDELIM)[0].trim();

      if (String.isNotBlank(caseObj.Description_Custom__c) && caseObj.Description_Custom__c.containsIgnoreCase(searchKey)) {
        caseList.add(caseObj);
      }
    }

    // the logic for '3 - Reviews' and '1 - Cancels' record type
    if (rtName.containsIgnoreCase('3 - Reviews') || rtName.containsIgnoreCase('1 - Cancels') || rtName.containsIgnoreCase('Inbound')) {

      // if the Web email in not null, assign the email address to the Reported_by__c
      if (String.isNotBlank(caseObj.SuppliedEmail) && String.isBlank(caseObj.Reported_by__c)) {
        caseObj.Reported_by__c = caseObj.SuppliedEmail;
      }

      // if the SuppliedEmail is not null, indicate the case created by email-to-case
      // we should update the Reporter_Type__c, OwnerId (Only for Cancel), Priority(Only for Cancel),  etc
      // the email can find the 1:1 contact
      if (String.isNotBlank(caseObj.SuppliedEmail) && 
            !rtName.containsIgnoreCase('1 - Cancels') && 
            String.isNotBlank(caseObj.ContactId) && 
            relatedContactMap.containsKey(caseObj.ContactId))  {
        caseObj.Reporter_Type__c = 'Customer';


        
        //CSP-2516 we should check whether the contact has an account
        if (String.isNotBlank(relatedContactMap.get(caseObj.ContactId).AccountId)) {

          Account caseAccount = relatedContactMap.get(caseObj.ContactId).Account; 
          caseObj.Account_SS__c = caseAccount.Strategy_Specialist__c;

        }
      }

      // the email can not find the 1:1 contact but can find 1:1 account
      else if(String.isNotBlank(caseObj.SuppliedEmail) && 
              !rtName.containsIgnoreCase('1 - Cancels') && 
              String.isBlank(caseObj.ContactId) && 
              emailAccountMap.containsKey(caseObj.SuppliedEmail)){
        caseObj.Reporter_Type__c = 'Customer';
        caseObj.AccountId = emailAccountMap.get(caseObj.SuppliedEmail).id;
        caseObj.Account_SS__c = emailAccountMap.get(caseObj.SuppliedEmail).Strategy_Specialist__c;

        // // if the 1:1 account only have one contact, we need to assign the contact to caseObj.ContactId
        if (accountIdContactMap.containsKey(caseObj.AccountId)) {
          caseObj.ContactId = accountIdContactMap.get(caseObj.AccountId).id;
        }
        
      }
      else if (String.isNotBlank(caseObj.SuppliedEmail) && 
               !rtName.containsIgnoreCase('1 - Cancels') && 
               String.isBlank(caseObj.ContactId) && 
              emailUserMap.containsKey(caseObj.SuppliedEmail)) {

          caseObj.Reporter_User_Name__c = emailUserMap.get(caseObj.SuppliedEmail).id; 
          caseObj.Reporter_Type__c = emailUserMap.get(caseObj.SuppliedEmail).UserRole.Name; 
      }

      // if the case created by manual, we only should udpate the Priority field for Cancel record type
      else if(String.isBlank(caseObj.SuppliedEmail) && 
                  String.isNotBlank(caseObj.AccountId) && 
                  relatedAccountMap.containsKey(caseObj.AccountId)) {
        
        caseObj.Account_SS__c = relatedAccountMap.get(caseObj.AccountId).Strategy_Specialist__c;
        
        if (currentUser != null) {
          caseObj.Owner_Manager__c = currentUser.ManagerId;
        }
        
        // record type is '1 - Cancels', we should re-assign Priority base on related account

        if (rtName.containsIgnoreCase('1 - Cancels')) {

          Account caseAccount = relatedAccountMap.get(caseObj.AccountId);
          // update case Priority base on related account
          updateCasePriority(caseAccount.ActiveSubscriptionTCVSummary__c, caseObj, FALSE);
        }
        
      }
      else if (String.isBlank(caseObj.SuppliedEmail) && 
                String.isBlank(caseObj.AccountId) && 
                String.isNotBlank(caseObj.ContactId)) {
        

        if (currentUser != null) {
          caseObj.Owner_Manager__c = currentUser.ManagerId;
        }

        // checking whether the contact has an account
        if (relatedContactMap.containsKey(caseObj.ContactId) && 
              String.isNotBlank(relatedContactMap.get(caseObj.ContactId).AccountId)) {

          Account caseAccount = relatedContactMap.get(caseObj.ContactId).Account;

          caseObj.Account_SS__c = caseAccount.Strategy_Specialist__c;

          // record type is '1 - Cancels', we should re-assign Priority base on related account

          if (rtName.containsIgnoreCase('1 - Cancels')) {

            // update case Priority base on related account
            updateCasePriority(caseAccount.ActiveSubscriptionTCVSummary__c, caseObj, FALSE);
          }
        }
      }
    }

    // CSP-2591 Remove Auto-Contact/Account Population on E2C Cancellation Cases
    // Internal Reporter is still populated 
    if (rtName.containsIgnoreCase('1 - Cancels') && String.isNotBlank(caseObj.SuppliedEmail) ){
      caseObj.AccountId = null;
      caseObj.ContactId = null;

      if (cancelEmailUserMap.containsKey(caseObj.SuppliedEmail)) {

        caseObj.Reporter_User_Name__c = cancelEmailUserMap.get(caseObj.SuppliedEmail).id; 
        caseObj.Reporter_Type__c = cancelEmailUserMap.get(caseObj.SuppliedEmail).UserRole.Name; 
      }
    }

    // CSP-3022 Case Fields
    // Internal Reporter and Reported by is populated for Rep Billing Case
    if (rtName.containsIgnoreCase('Rep Billing') && String.isNotBlank(caseObj.SuppliedEmail) ){
      caseObj.Reported_by__c = caseObj.SuppliedEmail;

      if (cancelEmailUserMap.containsKey(caseObj.SuppliedEmail)) {
        caseObj.Reporter_User_Name__c = cancelEmailUserMap.get(caseObj.SuppliedEmail).id; 
        caseObj.Reporter_Type__c = cancelEmailUserMap.get(caseObj.SuppliedEmail).UserRole.Name; 
      }
    }

    // CSP-2754 Update Cancel Case Assignment for Regional Pooling
    // for Cancel case, will check the case if have account, yes, then check account owner is AM, 
    // yes then assign the case owner to Account owner
    // No then assign the case owner to Account SS
    // else then assign the case owner to default queue
    // CSP-2873 Correct Cancel Case Assignment for Regional Pooling
    if(rtName.containsIgnoreCase('1 - Cancels') && 
      String.isNotBlank(caseObj.AccountId) &&
      relatedAccountMap.containsKey(caseObj.AccountId)){

      Account acc = relatedAccountMap.get(caseObj.AccountId);

      if(String.isNotBlank(acc.owner.title) && 
        acc.owner.title.equalsIgnoreCase('Account Manager')){

        caseObj.OwnerId = acc.OwnerId;
      }
    }

    // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
    // if a cancel case created, we copy the Past_Due_Balance__c to the Past_Due_Potential_Collections__c on case
    if ((rtName.containsIgnoreCase('1 - Cancels')) 
        && String.isNotBlank(caseObj.AccountId) 
        && pdbAccountIdMap.containsKey(caseObj.AccountId)) {

        caseObj.Past_Due_Potential_Collections__c = pdbAccountIdMap.get(caseObj.AccountId).Past_Due_Balance__c;
      
    }

    // CSP-2750 Inbound Case
    // the list stores all cases in the available record type, and also have accountId
    if(rtName.equalsIgnoreCase('Inbound')){

      String accId = getAccountId(caseObj, relatedContactMap);
      if(String.isNotBlank(accId)){

          setAccountIdForRecentCase.add(accId);
      }

    }

   //mark VIP_Onboarding_Case__c
    if(rtName.equalsIgnoreCase('2 - Onboarding') 
      && String.isNotBlank(caseObj.AccountId)
      && caseObj.VIP_Onboarding_Case__c == FALSE){
        //VIP_Onboarding_Case__c is FALSE as default
        //If >= $15K TCV on the opportunity or onboarding case owner is VIP Queue/VIP Queue member,
        //we mark VIP_Onboarding_Case__c as TRUE
        if((mapAccountIdToActiveTCV.containsKey(caseObj.AccountId) 
        && mapAccountIdToActiveTCV.get(caseObj.AccountId) >= Integer.valueOf(Label.VIP_Account_TCV_Value))
        || isVIPAccountStrategist(caseObj.OwnerId)){

            caseObj.VIP_Onboarding_Case__c = TRUE;
        }

    }

  }

  /**
  *   All before update logic should be done here. This method is called iteratively and as such
  *   should contain no actions which could potentially hit limits or is considered bad practice
  *   in the Salesforce environment.
  *
  *   @param  {SObject}   oldSo Single SObject representation of the "old" copy of the current 
  *                             object being acted upon.
  *   @param  {SObject}   so    Single SObject representation of the object being acted upon.
  */
  public void beforeUpdate(SObject oldSo, SObject so) {
    Case caseObj = (Case)so;
    Case oldCase = (Case)oldSo;

    // avoid to empty record type
    if(String.isBlank(caseObj.RecordTypeId)){
      // CSP-2261 assign to default queue and assign owner to default queue
      caseObj.RecordTypeId = caseRecTypeNameMap.get('Default').getRecordTypeId();
      // CSP-2806 Mark Cancel Cases as BoB versus Service
      // Merge code, get default queue id used DEFAULTQUEUEID
      caseObj.OwnerId = DEFAULTQUEUEID;
      return;
    }

    // CSP-2659 Features Requested Cancelled Reporting
    // if the cancelled case need validate the FRC and not passed, the case cannot close.
    if (notAllowCloseCaseId.contains(caseObj.Id)) {
      caseObj.addError(CANCEL_CASE_CLOSE_ERROR_MESSAGE);
    }

    //CSP -2528 Calculated value for response time by calculating time from status "New" to any other status 
    if(caseObj.Response_Times__c == NULL  && oldCase.Status == 'New' 
      && caseObj.Status != 'New' 
      && !businessHourList.isEmpty()){
      
      Datetime createDate = caseObj.CreatedDate;
      Datetime nowTime = system.now();
      //Calculate time from create time of case to now.
      Long diffTime = BusinessHours.diff(businessHourList[0].Id, createDate, nowTime);
      //Keep two decimal places to store value
      caseObj.Response_Times__c = diffTime/HOURSRATE; 
      //Store update status time from New to any other status.
      caseObj.Response_TimeStamp__c = nowTime;

    }

    // CSP-2750 Inbound Case
    // To stamp the case status change from 'New' to closed 
    if(caseObj.Resolution_Times__c == NULL && 
      caseObj.Status.containsIgnoreCase('Closed') && 
      !oldCase.Status.containsIgnoreCase('Closed')){

        Datetime createDate = caseObj.CreatedDate;
        Datetime nowTime = system.now();
        //Calculate time from create time of case to now.
        Long diffTime = BusinessHours.diff(businessHourList[0].Id, createDate, nowTime);
        //Keep two decimal places to store value
        caseObj.Resolution_Times__c = diffTime/HOURSRATE;
        //Store update status time from New to any other status.
        caseObj.Resolution_Timestamp__c = nowTime;

    }

    // CSP-2806 Mark Cancel Cases as BoB versus Service
    // Save the time of the first close case
    if(caseObj.First_Closed_Date__c == NULL 
      && closeStatusSet.contains(caseObj.Status) 
      && !closeStatusSet.contains(oldCase.Status)){
        
        //Store first close time  
        caseObj.First_Closed_Date__c = system.now();
    }

    String rtName = caseRecTypeIDMap.get(caseObj.RecordTypeId).getName();

    // CSP-2750 Inbound Case
    if (rtName.equalsIgnoreCase('Inbound') || rtName.containsIgnoreCase('1 - Cancels') || rtName.containsIgnoreCase('3 - Reviews') ) {
      
      // if the case Account has been updated, we should update the priority base on the new account for cancel record type and update the Account_SS__C
      if (String.isNotBlank(caseObj.AccountId) && 
          caseObj.AccountId != oldCase.AccountId && 
          relatedAccountMap.containsKey(caseObj.AccountId)) {

        Account caseAccount = relatedAccountMap.get(caseObj.AccountId);
        caseObj.Account_SS__C = caseAccount.Strategy_Specialist__c;

        if (rtName.containsIgnoreCase('1 - Cancels')){

          // update case Priority base on related account
          updateCasePriority(caseAccount.ActiveSubscriptionTCVSummary__c, caseObj, TRUE);
        }
        
      }
      // if the case Account has been updated, we should update the priority base on the new account for cancel record type and update the Account_SS__C
      else if (String.isBlank(caseObj.AccountId) && 
              String.isNotBlank(caseObj.ContactId) && 
              (String.isNotBlank(oldCase.AccountId) || 
              caseObj.ContactId != oldCase.ContactId) && 
              relatedContactMap.containsKey(caseObj.ContactId)) {

        // checking whether the contact has an account
        if (String.isNotBlank(relatedContactMap.get(caseObj.ContactId).AccountId)) {

          Account caseAccount = relatedContactMap.get(caseObj.ContactId).Account;
          caseObj.Account_SS__C = caseAccount.Strategy_Specialist__c;
        
          if (rtName.containsIgnoreCase('1 - Cancels')){

            updateCasePriority(caseAccount.ActiveSubscriptionTCVSummary__c, caseObj, TRUE);
          }
        }
        
      }
      // if the case Account has been changed to null, we should update the priority to "Medium" for cancel record type and update the Account_SS__C to null
      else if(caseObj.AccountId == null && caseObj.ContactId == null){
        
        caseObj.Account_SS__C = null;
        if (rtName.containsIgnoreCase('1 - Cancels')){
          caseObj.Priority = 'Medium';
        }
      }


      // if the case owner had been changed, we should update the owner manager
      if (caseObj.OwnerId != oldCase.OwnerId && ownerManagerMap.containsKey(caseObj.OwnerId)) {
        caseObj.Owner_Manager__c = ownerManagerMap.get(caseObj.OwnerId);
      }
    }


    System.debug(LoggingLevel.INFO, '*** caseObj.AccountId: ' + caseObj.AccountId);
    System.debug(LoggingLevel.INFO, '*** : caseObj.ownerid' + caseObj.ownerid);
    
    // CSP-2754 Update Cancel Case Assignment for Regional Pooling
    // for Cancel case, will check the case if have account, yes, then check account owner is AM, 
    // yes then assign the case owner to Account owner
    // No then assign the case owner to Account SS
    // else assign the case owner to default queue
    // CSP-2873 Correct Cancel Case Assignment for Regional Pooling
    if(rtName.containsIgnoreCase('1 - Cancels') && 
      String.isNotBlank(caseObj.AccountId) &&
      relatedAccountMap.containsKey(caseObj.AccountId) &&
      caseObj.AccountId != oldCase.AccountId){

      Account acc = relatedAccountMap.get(caseObj.AccountId);

      if(String.isNotBlank(acc.owner.title) && 
        acc.owner.title.equalsIgnoreCase('Account Manager')){

        caseObj.OwnerId = acc.OwnerId; 
      } 
    }

    // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
    // if the account of a cancel case has been changed, 
    // we copy the new Past_Due_Balance__c of the new account to the Past_Due_Potential_Collections__c on case
    if ((rtName.containsIgnoreCase('1 - Cancels')) 
        && String.isNotBlank(caseObj.AccountId) 
        && caseObj.AccountId != oldCase.AccountId 
        && pdbAccountIdMap.containsKey(caseObj.AccountId)) {

      caseObj.Past_Due_Potential_Collections__c = pdbAccountIdMap.get(caseObj.AccountId).Past_Due_Balance__c;
      
    }

    // CSP-2780 Trapped Cases 
    // if the cancel case reopened, check the flag to skip the validation rule and notification

    if (rtName.containsIgnoreCase('1 - Cancels') 
        && (oldCase.Status == 'Closed' || oldCase.Status == 'Closed Duplicate')
        && caseObj.Status != 'Closed' 
        && caseObj.Status != 'Closed Duplicate'){

      caseObj.Skip_The_Notification_And_Validation__c = true;
      
    }

    // CSP-2806 Mark Cancel Cases as BoB versus Service
    // Update Cancel Case Type and Case Closed Flag to true if frist close of the case
    if (rtName.containsIgnoreCase('1 - Cancels')  
         && !caseObj.Case_Closed_Flag__c
         && cancelCloseStatusSet.contains(caseObj.Status)
         && !cancelCloseStatusSet.contains(oldCase.Status) 
         && String.isNotBlank(caseObj.AccountId)) {

        caseObj.Case_Closed_Flag__c = true;

        if(String.valueOf(caseObj.OwnerId).startsWithIgnoreCase('005')) {
            //Stamp the Case Owner(Close) if Case owner is a user
            caseObj.Case_Owner_Close__c = caseObj.OwnerId;
        }
        else{
            if(queueIdNameMap.containsKey(caseObj.OwnerId)) {
                //Stamp the Case Owner(Close) if Case owner is a queue
                caseObj.Case_Queue_Close__c = queueIdNameMap.get(caseObj.OwnerId);
            }
        }

        if(String.isNotBlank(caseObj.Case_Owner_Title__c) && caseObj.Case_Owner_Title__c.containsIgnoreCase(CLOSE_CANCEL_CASE_OWNER_TITLE)){
            // Update Cance Case Type to Service if case Owner title contains 'Client Solutions' at close of case
            caseObj.Cancel_Case_Type__c = 'Service';
        }else{
            // Update Cance Case Type to BoB when case Owner title does not contain 'Client Solutions' at close of case
            caseObj.Cancel_Case_Type__c = 'BoB';
        }

        if(closeAcctIdAndAcctMap.containsKey(caseObj.AccountId)) {
            caseObj.Account_Owner_Close__c = closeAcctIdAndAcctMap.get(caseObj.AccountId).OwnerId;          
        }
    }

    // CSP-2750 Inbound Case
    // the list stores all cases in the available record type, and also have accountId
    if(rtName.equalsIgnoreCase('Inbound')){

      if(String.isNotBlank(caseObj.AccountId) && caseObj.AccountId != oldCase.AccountId){

          String accId = getAccountId(caseObj, relatedContactMap);
          if(String.isNotBlank(accId)){

              setAccountIdForRecentCase.add(accId);
          }

      }
      
    }

    
    //If Inbound/Asset Collection case owner is changed from queue to user,
    //we need to ensure cases have the same owner under the same account
    if((rtName.equalsIgnoreCase('Inbound') 
      || rtName.equalsIgnoreCase('Asset Collection'))
      && isOwnerFromQueueToUser(caseObj, oldCase)){

        setCasesToUnifyOwner.add(caseObj);
    }

  }

  /**
  *   All before delete logic should be done here. This method is called iteratively and as such
  *   should contain no actions which could potentilly hit limits or is considered bad practice
  *   in the Salesforce environment.
  *
  *   @param  {SObject}   so Single SObject representation of the object being acted upon.
  */
  public void beforeDelete(SObject so) {}

  /**
  *   All after insert logic should be done here. This method is called iteratively and as such
  *   should contain no actions which could potentilly hit limits or is considered bad practice
  *   in the Salesforce environment. 
  *
  *   @param  {SObject}   so Single SObject representation of the object being acted upon.
  */
  public void afterInsert(SObject so) {
    Case caseObj = (Case)so;
    String rtName = caseRecTypeIDMap.get(caseObj.RecordTypeId).getName();

    // for the Onboarding case created, we should auto send email to customer and generate task  
    if (rtName.containsIgnoreCase('2 - Onboarding') ) {

      mapAcctIdToOnboardingCaseId.put(caseObj.AccountId,caseObj.Id);
      // Welcome email should go out immediately after case creation when:
      // Is_Onboarding_Email_Automated__c on Onboarding case is TRUE
      // Onboarding case is VIP and case owner must be User(not local team) 
      // Onboarding case is non-VIP and case owner can be Queue or User(not local team user)
      if(caseObj.Is_Onboarding_Email_Automated__c && caseObj.OwnerId != label.LocalTeamUserId 
      && ((caseObj.VIP_Onboarding_Case__c == TRUE && String.valueOf(caseObj.OwnerId.getSObjectType()) == 'User')
      || caseObj.VIP_Onboarding_Case__c == FALSE)){
         
          setOnboardingCaseIdForWelcomeEmail.add(caseObj.Id);
          setOnboardingCaseIdForQuery.add(caseObj.Id);
      }

      // generate onboarding tasks only
      if(String.valueOf(caseObj.OwnerId.getSObjectType()) == 'User' 
      && caseObj.OwnerId != label.LocalTeamUserId){
        
        setOnboardingCaseIdForFollowUpTask.add(caseObj.Id);
        setOnboardingCaseIdForQuery.add(caseObj.Id);
      }

    }
  }

  /**
  *   All after update logic should be done here. This method is called iteratively and as such
  *   should contain no actions which could potentilly hit limits or is considered bad practice
  *   in the Salesforce environment.
  *   
  *   @param  {SObject}   oldSo Single SObject representation of the "old" copy of the current 
  *                             object being acted upon.
  *   @param  {SObject}   so    Single SObject representation of the object being acted upon.
  */
  public void afterUpdate(SObject oldSo, SObject so) {
    Case caseObj = (Case)so;
    Case oldCase = (Case)oldSo;
    String rtName = caseRecTypeIDMap.get(caseObj.RecordTypeId).getName();

    // For VIP welcome email, we send automated VIP welcome email when
    // Is_Onboarding_Email_Automated__c on Onboarding case is TRUE
    // Onboarding case is VIP and case owner is changed from Queue to VIP AS User(not local team user)
    if (rtName.containsIgnoreCase('2 - Onboarding') 
        && String.isNotBlank(caseObj.OwnerId)
        && caseObj.Is_Onboarding_Email_Automated__c == TRUE
        && caseObj.VIP_Onboarding_Case__c == TRUE
        && String.valueOf(caseObj.OwnerId.getSObjectType()) == 'User'
        && caseObj.OwnerId != label.LocalTeamUserId
        && isVIPAccountStrategist(caseObj.OwnerId)
        && (String.valueOf(oldCase.OwnerId.getSObjectType()) != 'User' || oldCase.OwnerId == label.LocalTeamUserId)) {

        setOnboardingCaseIdForWelcomeEmail.add(caseObj.Id);
        setOnboardingCaseIdForQuery.add(caseObj.Id);
    }

    // for the Onboarding case created, we should auto send email to customer and generate task 
    // CSP-3070 Welcome email timing and template issues
    // if owner change to other user from queue or local user, system will generate task 
    if (rtName.containsIgnoreCase('2 - Onboarding') 
        && String.isNotBlank(caseObj.OwnerId)
        && String.valueOf(caseObj.OwnerId.getSObjectType()) == 'User'
        && caseObj.OwnerId != label.LocalTeamUserId
        && (String.valueOf(oldCase.OwnerId.getSObjectType()) != 'User' || oldCase.OwnerId == label.LocalTeamUserId)) {

        setOnboardingCaseIdForFollowUpTask.add(caseObj.Id);
        setOnboardingCaseIdForQuery.add(caseObj.Id);
    }

    //CSP-2946 Update Onboarding Assignment Logic for Pooling
    //Tasks on Asset Collection cases should reassign automatically with the case when a case is reassigned
    if ((rtName.containsIgnoreCase('2 - Onboarding') || rtName.containsIgnoreCase('Asset Collection'))
      && oldCase.OwnerId != caseObj.OwnerId
      && String.valueOf(caseObj.OwnerId.getSObjectType()) == 'User') {

        caseIdToCaseOwnerMap.put(caseObj.Id, caseObj.OwnerId);
    }

    //When case closes with a status of "Closed - Completed", send onboarding close case email if case owner is AS
    if (rtName.containsIgnoreCase('2 - Onboarding') 
      && !oldCase.IsClosed
      && isClosedCompletedCase(caseObj)
      && caseObj.Is_Onboarding_Email_Automated__c == TRUE 
      && isSpecificUser(caseObj.OwnerId, caseObj.Case_Owner_Profile_Name__c, setProfileNamesForCloseSurveyEmail)) {

        setOnboardingCaseIdForCloseSurveyEmail.add(caseObj.Id);
        setOnboardingCaseIdForQuery.add(caseObj.Id);
    }

    // csp-2671 - Update Account and Contact records based on changes made to case records on case close for '2 - OnBoarding'
    if (rtName.containsIgnoreCase('2 - onboarding')){
      if(accountIdToAccountMap.containsKey(caseObj.AccountId)) {
        Account currentAcc = accountIdToAccountMap.get(caseObj.AccountId);

        // update account data 
        if(currentAcc != null) {

            currentAcc.In_Business_Since__c = caseObj.InBusinessSince__c != null ? caseObj.InBusinessSince__c : currentAcc.In_Business_Since__c;
            currentAcc.Website_Grade__c = caseObj.WebsiteGrade__c != null ? caseObj.WebsiteGrade__c : currentAcc.Website_Grade__c;
            currentAcc.Segment__c = caseObj.Segment__c != null ? caseObj.Segment__c : currentAcc.Segment__c;
            currentAcc.Beta_Opt_Out__c = caseObj.BetaOptOut__c != null ? caseObj.BetaOptOut__c : currentAcc.Beta_Opt_Out__c;
            currentAcc.Instagram__c = caseObj.Instagram__c != null ? caseObj.Instagram__c : currentAcc.Instagram__c;

        }

        onboardingAccsToBeUpdatedList.add(currentAcc);
      }

      if(contactIdToContactMap.containsKey(caseObj.ContactId)) {
        Contact currentContact = contactIdToContactMap.get(caseObj.ContactId);
        
        // update contact data 
        if(currentContact != null) {
          currentContact.Preferredcontactmethod__c = caseObj.PreferredContactMethod__c != null ? caseObj.PreferredContactMethod__c : currentContact.Preferredcontactmethod__c;
        }
        onboardingContactsToBeUpdatedList.add(currentContact);
      } 
    }
    
    //Collect first close case and acc id maping if outcome is 'saved' 
    if (isFirstCloseCancelCase(rtName, caseObj, oldCase) 
      && caseObj.Outcome__c == 'Saved') {

      mapCaseIdAccId.put(caseObj.Id, caseObj.AccountId);
    }
  }

  /**
  *   All after delete logic should be done here. This method is called iteratively and as such
  *   should contain no actions which could potentilly hit limits or is considered bad practice
  *   in the Salesforce environment. 
  *
  *   @param  {SObject}   so Single SObject representation of the object being acted upon.
  */
  public void afterDelete(SObject so) {}

  /**
  *   All final logic in the "before" context should be done at this point such as modification to objects outside of
  *   the current object. At this point all updates to the current trigger transaction should be
  *   complete and all validation done.
  */
  public void beforeAndFinally() {

    // CSP-2750 Inbound Case
    if(Trigger.isInsert || Trigger.isUpdate){

        if(!setAccountIdForRecentCase.isEmpty()){

            assignRecentCaseOwner((List<Case>)Trigger.new, setAccountIdForRecentCase, relatedAccountMap, relatedContactMap);
        }

        if(caseList.size()>0) {
            // CSP-2178 Auto fill data from email into Review Cases, use to update the ID fields from description Strings
            updateFieldFromDescription(caseList);
        }

        if(!setCasesToUnifyOwner.isEmpty()){
            //Unify case owner for the same account after DE if case owner is assigned from a queue to a user
            unifyCaseOwnerForSameAccount(setCasesToUnifyOwner);
        }

        //Sync CurrentCaseOwnerUser Lookup field for DE distributor
        syncCurrentCaseOwnerUserLookup((List<Case>)Trigger.new);
    }
  }

  /**
  *   All final logic in the "after" context should be done at this point such as modification to objects outside of
  *   the current object. At this point all updates to the current trigger transaction should be
  *   complete and all validation done.
  */
  public void afterAndFinally() {
    List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

    if(trigger.isUpdate){
      //Tasks should reassign automatically with the case when a case is reassigned
      if(!caseIdToCaseOwnerMap.isEmpty()){
          List<Task> listTasksToReassign = reassignTasksOnOwnerUpdate(caseIdToCaseOwnerMap);
          if(!listTasksToReassign.isEmpty()){
              List<Database.SaveResult> saveTasksList = Database.update(listTasksToReassign); 
              xoExceptionList.addAll(ExceptionUtility.consumeException(saveTasksList));
          }
      }

      // create 4 records of Account Snapshots for each close case.
      if(!mapCaseIdAccId.isEmpty()) {
        List<Account_Snapshots__c> listInsertAccSnaps = CaseService.createAccountSnapshots(mapCaseIdAccId,mapAccIdSumMRR);
        List<Database.SaveResult> listSaveAccSnaps = Database.insert(listInsertAccSnaps); 
        xoExceptionList.addAll(ExceptionUtility.consumeException(listSaveAccSnaps));
      }
    }

    //Sync Onboarding case lookup field on Asset Collection case when Onboarding case is created on the same account record
    if(!mapAcctIdToOnboardingCaseId.isEmpty()){
        List<Case> listAssetCollectionCasesToUpdate = syncOnboardingCaseLookup(mapAcctIdToOnboardingCaseId);
        if(!listAssetCollectionCasesToUpdate.isEmpty()){
              List<Database.SaveResult> saveTasksList = Database.update(listAssetCollectionCasesToUpdate,FALSE); 
              xoExceptionList.addAll(ExceptionUtility.consumeException(saveTasksList));
        }
    }

    if(!setOnboardingCaseIdForQuery.isEmpty()){
      try{
        List<Task> onboardingTaskList = new List<Task>(); 
        // retrieve the case info which will be used for creating welcome/close completed survey email and follow-up 1 task
        List<Case> caseList = [SELECT Id, CaseNumber, AccountId, ContactId, Contact.MobilePhone, VIP_Onboarding_Case__c, 
                                  OwnerId, Case_Owner_Manager_Name__c, Case_Owner_Manager_Email__c, Owner.Email, Owner.Name,
                                  (SELECT Id FROM Tasks 
                                    WHERE Task.WhatId IN: setOnboardingCaseIdForFollowUpTask 
                                    AND Purpose__c = 'Onboarding' 
                                    AND Subject = 'Onboarding Follow-up 1'
                                    AND Strategy_Specialist_Disposition_Code__c = 'Onboarding Scheduling'
                                    AND Dispostition_Type__c = 'SS Core' 
                                    LIMIT 1)
                                  FROM Case 
                                  WHERE Id IN: setOnboardingCaseIdForQuery];
                       
        for (Case currentCase : caseList) {
          // CSP-3195 Route All Onboarding Cases to Queue
          // Welcome email should go out immediately after case creation
          if(setOnboardingCaseIdForWelcomeEmail.contains(currentCase.Id)){
              Messaging.SingleEmailMessage onboardingWelcomeEmail;
              //use VIP email template for VIP case
              if(currentCase.VIP_Onboarding_Case__c == TRUE){
                  
                  onboardingWelcomeEmail = EmailUtility.generateEmail(onboardWelcomeVIPEmailTemplateId, currentCase.Id, currentCase.ContactId, TRUE, NULL, currentCase.Owner.Email, currentCase.Owner.Name);
              }else{

                  onboardingWelcomeEmail = EmailUtility.generateEmail(onboardWelcomeEmailTemplateId, currentCase.Id, currentCase.ContactId, true, orgWideEmailAdd.Id, null, null);
              }

              emailList.add(onboardingWelcomeEmail);
          }

          // When case closes with a status of "Closed - Completed", an email is sent to the customer with a link to a survey for the individual Account Strategist who is listed as the Case Owner
          if(setOnboardingCaseIdForCloseSurveyEmail.contains(currentCase.Id)){
              //use VIP email template for VIP case
              Id closeSurveyEmailTemplateId = (currentCase.VIP_Onboarding_Case__c)? onboardCloseCaseSurveyVIPEmailTemplateId : onboardCloseCaseSurveyEmailTemplateId;
              // The close survey email from address is the manager of case owner
              Messaging.SingleEmailMessage closeCompletedCaseSurveyEmail = EmailUtility.generateEmail(closeSurveyEmailTemplateId, currentCase.Id, currentCase.ContactId, true, null, currentCase.Case_Owner_Manager_Email__c, currentCase.Case_Owner_Manager_Name__c);
              emailList.add(closeCompletedCaseSurveyEmail);
          }

          // Generate onboarding follow-up 1 task
          // when an oboarding case is redistributed IF a Follow-Up 1 task already exists on the case
          // we should prevent a second Follow-Up 1 task from being created 
          if(setOnboardingCaseIdForFollowUpTask.contains(currentCase.Id) && currentCase.Tasks.size() == 0){

              Task newTask = new Task();
              newTask.RecordTypeId = tastkRecTypeNameMap.get('Standard Task').getRecordTypeId();
              newTask.WhatId = currentCase.Id;
              newTask.WhoId = currentCase.ContactId;
              newTask.Subject = 'Onboarding Follow-up 1';
              newTask.IsReminderSet = true;
              newTask.Purpose__c = 'Onboarding';

              if (!businessHourList.isEmpty()) {
                newTask.ActivityDate = DateUtility.AddBusinessDays(businessHourList[0].Id, Date.today(), 1);
                newTask.ReminderDateTime = Datetime.newInstance(DateUtility.AddBusinessDays(businessHourList[0].Id, Date.today(), 1), Time.newInstance(8, 0, 0, 0)) ;
              }else{
                newTask.ActivityDate = DateUtility.AddBusinessDays(Date.today(),1);
                newTask.ReminderDateTime = Datetime.newInstance(DateUtility.AddBusinessDays(Date.today(),1), Time.newInstance(8, 0, 0, 0)) ;
              }
              newTask.Mobile_Phone__c = currentCase.Contact.MobilePhone;
              newTask.Type = 'Call';
              newTask.Dispostition_Type__c = 'SS Core';
              newTask.Strategy_Specialist_Disposition_Code__c = 'Onboarding Scheduling';
              newTask.Status = 'Not Started';
              newTask.Priority = 'High';
              newTask.OwnerId = currentCase.OwnerId;
              
              onboardingTaskList.add(newTask);
            }
        }
        
        if (!onboardingTaskList.isEmpty()) {
          
          List<Database.SaveResult> taskSaveResultsList = Database.insert(onboardingTaskList); 
          xoExceptionList.addAll(ExceptionUtility.consumeException(taskSaveResultsList));
        }
      }catch(Exception ex){
        ExceptionUtility.consumeException(ex, true);
      }
    }

    // csp-2671
    if (!onboardingAccsToBeUpdatedList.isEmpty()) {
      List<Database.SaveResult> saveAccountsList = Database.update(onboardingAccsToBeUpdatedList); 
      xoExceptionList.addAll(ExceptionUtility.consumeException(saveAccountsList));
    }

    if (!onboardingContactsToBeUpdatedList.isEmpty()) {
      List<Database.SaveResult> saveContactsList = Database.update(onboardingContactsToBeUpdatedList); 
      xoExceptionList.addAll(ExceptionUtility.consumeException(saveContactsList));
    }

    // csp-2484 send email when user close case . 
    if(!caseIdEmailListMap.isEmpty()) {
      for(Id caseId : caseIdEmailListMap.keySet()) {
        if(!caseIdEmailListMap.get(caseId).isEmpty()) {
            for(Id targetId : caseIdEmailListMap.get(caseId)){

              //send email for every Account owner, Subscription sales rep, Account ss, Internal report.
              Messaging.SingleEmailMessage closeCaseEmail = EmailUtility.generateEmail(closeCaseEmailTemplateId, caseId, targetId, false, orgWideEmailAddForOutcome.Id, null, null);
              emailList.add(closeCaseEmail);
            }
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
 * @purpose Check if the case is closed Completed.
 * @author  Steven
 * @date    2018-10-24
 * @param   Case  caseObj              The case record.
 * @return  Boolean
 */
  private Boolean isClosedCompletedCase(Case caseObj){
      Boolean isClosedCompletedCase = false;
      if(caseObj.Status == 'Closed Completed' && caseObj.isClosed ){

        isClosedCompletedCase = true;
      }

      return isClosedCompletedCase;
  }

/**
 * @purpose Check if the user has a specific identifier.
 * @author  Steven
 * @date    2018-10-24
 * @param   Id  userId                                    The user Id
 * @param   String  userIdentifier                       The user identifier.
 * @param   Set<String>  setSpecificUserIdentifier          The collection of specific identifier, such us profile, userRole, name, email.
 * @return  Boolean
 */
  private Boolean isSpecificUser(Id userId, String userIdentifier, Set<String> setSpecificUserIdentifier){
      Boolean isSpecificUser = false;
      if(String.isNotBlank(userId) && String.valueOf(userId.getSObjectType()) == 'User'
      && setSpecificUserIdentifier.contains(userIdentifier)){

        isSpecificUser = true;
      }

      return isSpecificUser;
  }

  /**
  * @purpose Check if the cancel case has first close or not 
  * @author  Mason
  * @date    2018-11-15
  * @param   String  rtName          record type name
  * @param   case  newCase           new case record
  * @param   case  oldCase           old case record
  * @return  Boolean
  */
  private Boolean isFirstCloseCancelCase(String rtName, case newCase, case oldCase){
      Boolean isFirst = false;

      if(rtName.containsIgnoreCase('1 - Cancels')  
         && !oldCase.Case_Closed_Flag__c
         && cancelCloseStatusSet.contains(newCase.Status)
         && !cancelCloseStatusSet.contains(oldCase.Status) 
         && String.isNotBlank(newCase.AccountId)) { 

            isFirst = true;
         }
      
      return isFirst;
  }

/**
 * @purpose Sync Onboarding case lookup field for existing Asset Collection cases
 * @author  Steven
 * @date    2019-03-11
 * @param   Map<Id,Id>   mapAccountIdToOnboardingCaseId         map of account Id and Onboarding case Id
 * @return  List<Case>
 */
  private List<Case> syncOnboardingCaseLookup(Map<Id,Id> mapAccountIdToOnboardingCaseId) {
      List<Case> listAssetCollectionCases = new List<Case>();

      if(!mapAccountIdToOnboardingCaseId.isEmpty()){

          for(Case existingACCase : [SELECT Id, Onboarding_Case__c, AccountId
                                      FROM Case
                                      WHERE RecordTypeId =: caseRecTypeNameMap.get('Asset Collection').getRecordTypeId()
                                      AND Owner.Type != 'User'
                                      AND AccountId IN: mapAccountIdToOnboardingCaseId.keySet()
                                      AND Rate_Plan_Name__c LIKE '%Storefront%'
                                      ]){

              if(String.isNotBlank(existingACCase.AccountId) && mapAccountIdToOnboardingCaseId.containsKey(existingACCase.AccountId)){

                  existingACCase.Onboarding_Case__c = mapAccountIdToOnboardingCaseId.get(existingACCase.AccountId);
                  
              }

              listAssetCollectionCases.add(existingACCase);
          }
      }
      
      return listAssetCollectionCases;
  }
/**
 * @purpose Sync Case_Current_Owner_User__c lookup field if case owner is a user.
 * @author  Steven
 * @date    2018-11-23
 * @param   List<Case>  listCases              case list
 * @return  void
 */
  private void syncCurrentCaseOwnerUserLookup(List<Case> listCases){
      
      for (Case currentCase : listCases) {
          if(currentCase.Case_Current_Owner_User__c != currentCase.OwnerId){
              if(String.valueOf(currentCase.OwnerId.getSObjectType()) == 'User'){
                  //Sync Case_Current_Owner_User__c if case owner is a user
                  currentCase.Case_Current_Owner_User__c = currentCase.OwnerId;
              }else{
                  //Leave Case_Current_Owner_User__c blank if case owner is not a user
                  currentCase.Case_Current_Owner_User__c = NULL;
              }
          }
      }
  }

/**
  * @purpose Tasks should reassign automatically with the case when a case is reassigned
  * @author  Steven
  * @date    2019-01-21
  * @param   Map<Id, Id>  caseIdToCaseOwnerMap            a map of case Id and case owner Id
  * @return  List<Task>
  */
  private List<Task> reassignTasksOnOwnerUpdate(Map<Id, Id> caseIdToCaseOwnerMap) {
     List<Task> listTasksToUpdateOwner = new List<Task>();

     for(Task task : [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId IN: caseIdToCaseOwnerMap.keySet()]){
        
        if(caseIdToCaseOwnerMap.containsKey(task.WhatId)){
            task.OwnerId = caseIdToCaseOwnerMap.get(task.WhatId);
        } 

        listTasksToUpdateOwner.add(task);
    }

    return listTasksToUpdateOwner;
  }

  /**
   *   CSP-2178 | Auto fill data from Description(email body) into Cases fields
   *
   *   @author Tony Liu
   *   @date   2017-06-02
   *   @param  List<Case>
   */
  public void updateFieldFromDescription (List<Case> caseList){
      
    // get the field mapping
    List<String> fieldmaps = CASE_EMAIL_FIELD_MAPPING.split(FIELDDELIM);
    System.debug(LoggingLevel.INFO, '*** fieldmaps: ' + fieldmaps);
    
    // parsing result map
    Map<String,String> resultMap = new Map<String,String>();

    // store the field label and api name in map
    Map<String,String> fieldMap = new Map<String,String>();
    // store field name in order
    List<String> fieldList = new List<String>();

    try {
      // save label and field api name as a map
      for(String str : fieldMaps){
        String strLabel = str.split(VALUEDELIM)[0].trim();
        String strField = str.split(VALUEDELIM)[1].trim();
        fieldMap.put(strLabel, strField);
        fieldList.add(strLabel);
      }

      // parsing the description content in case
      for(Case currentCase : caseList){
        
        String content = currentCase.Description_Custom__c.trim().toLowerCase();
        content = content.substring(content.indexOf(fieldList[0]));
        
        for(Integer i=0;i<fieldList.size();i++){
          
          Integer j = i+1;
          String result = '';
          String startField = fieldList[i];

          // get values
          if(j < fieldList.size()){
              String endField = fieldList[j];
              if(String.isNotBlank(content.substringBetween(startField, endField))){
                  result = content.substringBetween(startField, endField).trim().removeEnd(',');
              }
          }
          // get values from last index
          else if(j == fieldList.size()){
              if(String.isNotBlank(content.substringBetween(startField, '.'))){
                  result = content.substringBetween(startField, '.').trim().removeEnd('.');
              }
          }

          System.debug(LoggingLevel.INFO, '*** result: ' + result);
          
          // if the special field like "StorefrontId__c" have a value, we should keep the field value, 
          if (String.valueOf(currentCase.get(fieldMap.get(startField))) == '' || String.valueOf(currentCase.get(fieldMap.get(startField))) == null) {
            // set object values ahd date value 
            if (startField.equalsIgnoreCase('Date:')) {
              
                if (result.equals('')) {
                    currentCase.put(fieldMap.get(startField), null);
                }
                else{
                    try{

                        currentCase.put(fieldMap.get(startField), DateTime.parse(result));

                    }catch(Exception ex){

                        ExceptionUtility.consumeException(ex, true);
                    }
                }
            }
            // set text field values
            else{
              currentCase.put(fieldMap.get(startField), result);
            }
          }
        }
      }
    }
    catch (Exception ex) {
      ExceptionUtility.consumeException(ex, true);
    }
  }

  /**
     *   CSP-2182 | Cancel Cases TCV Over $5K = High Priority
     *   if the parameter >=5000, return TRUE, else Return FALSE
     *   @author Tony Liu
     *   @date   2017-06-16
     *   @param  List<Case>
     */
  public void updateCasePriority (Decimal accountTCV, Case currentCase, Boolean isUpdate){
    currentCase.Account_TCV__c = accountTCV;

    String ITEM_DELMIN = ';';
    String LINE_DELMIN = '\n';

    /****
      * the label CASEPRIORITYRANGE store the string like follow: 
      * 0;Medium;5000
      * 5000;High
      * if 0<= accountTCV <5000, the priority is Medium, 
      * if 5000<= accountTCV, the priority is High
     *****/
    List<String> priorityList = CASE_PRIORITY_RANGE.split(LINE_DELMIN);
    
    for (Integer i = 0 ; i<priorityList.size(); i++) {
      
      List<String> priorityItemList = priorityList[i].split(ITEM_DELMIN);
      Decimal lowerTCV = Decimal.valueOf(priorityItemList[0].trim());
      
      if (i < priorityList.size()-1) {
        
        Decimal upperTCV = Decimal.valueOf(priorityItemList[2].trim());
        
        if (accountTCV >= lowerTCV && accountTCV < upperTCV) {
          currentCase.Priority = priorityItemList[1].trim();
          break;
        }
      }
      else if (i == priorityList.size()-1) {
        
        if (accountTCV >= lowerTCV) {
          currentCase.Priority = priorityItemList[1].trim();
          break;
        }
      }
    }
  }

  /**
     *   CSP-2417 Cases Loop Breaker -- Try to break the infinite loop for auto response case emails
     *   within "timeLength" and if it contains more than "numOfEmails" same case records
     *   @author Nick Wu
     *   @date   2017-09-18
     *   @lastmodifiedBy Tony Liu
     */ 
  public static Set<String> caseInfiniteLoopKiller(){

    Integer numOfEmails = Integer.valueOf(system.Label.Param_Kill_Case_Reply_Loop.split(VALUEDELIM)[1]);
    Integer timeLength = Integer.valueOf(system.Label.Param_Kill_Case_Reply_Loop.split(VALUEDELIM)[0]);
    Datetime durationTime = System.now().addMinutes(-timeLength);

    List<AggregateResult> subjectCount = [SELECT COUNT(Id) EmailCount, SuppliedEmail FROM Case WHERE 
                                          CreatedDate >: durationTime AND 
                                          SuppliedEmail <> NULL GROUP BY 
                                          SuppliedEmail HAVING COUNT(Id) >: numOfEmails
                                          ];

    // Map<String,Integer> emailLoopMap = new Map<String,Integer>();
    Set<String> emailEndLoopSet = new Set<String>();
    for (AggregateResult agg : subjectCount) {
      emailEndLoopSet.add(String.valueOf(agg.get('SuppliedEmail')));
    }
    return emailEndLoopSet;
  }

/**
 * @purpose Check if the user is Out Of Office.
 * @author  Steven
 * @date    2018-10-24
 * @param   Set<Id>  setUserIds                              set of user Id 
 * @return  Map<Id,Boolean>
 */
  private Map<Id,Boolean> checkOutOfOfficeUsers(Set<Id> setUserIds){
      Map<Id,Boolean> mapUserIdToOutOfOfficeFlag = new Map<Id,Boolean>();
      
      if(!setUserIds.isEmpty()){
          //date range in today in query statement to check if user is Out Of Office
          Datetime currentDatetime = Datetime.now();
          String queryString = DE_OUT_OF_OFFICE_QUERY.replace('{WHERECLAUSE}', 'n2de__User__c IN: setUserIds AND n2de__Start_datetime__c <=: currentDatetime AND n2de__End_datetime__c >=: currentDatetime');
          for(n2de__Out_of_office__c deOutOfOffice : Database.query(queryString)){
              //If user has DE out of office record and today is in range, we mark this user is OOO
              mapUserIdToOutOfOfficeFlag.put(deOutOfOffice.n2de__User__c, TRUE);
          }
      }

      return mapUserIdToOutOfOfficeFlag;
  }

  /**
 * @purpose Check if case owner is changed from a queue to a user.
 * @author  Steven
 * @date    2018-12-03
 * @param   Case  newCase                       current case record
 * @param   Case  oldCase                       old case record
 * @return  Boolean
 */
  private Boolean isOwnerFromQueueToUser(Case newCase, Case oldCase){
      Boolean isOwnedFromQueueToUser = false;

      if(newCase.OwnerId != oldCase.OwnerId
      && String.valueOf(oldCase.OwnerId.getSObjectType()) != 'User'
      && String.valueOf(newCase.OwnerId.getSObjectType()) == 'User'){

          isOwnedFromQueueToUser = true;
      }
      return isOwnedFromQueueToUser;
  }

/**
 * @purpose Unify case owner for the same account after DE if case owner is assigned from a queue to a user
 * @author  Steven
 * @date    2018-11-23
 * @param   List<Case>  listCasesToUnifyOwner              case list to unify same owner for the same account
 * @return  void
 */
  private void unifyCaseOwnerForSameAccount(List<Case> listCasesToUnifyOwner){
      Map<Id,Id> mapAccountIdToUnifiedCaseOwner = new Map<Id,Id>();

      for (Case currentCase : setCasesToUnifyOwner) {

          if(String.isNotBlank(currentCase.AccountId)){

              if(!mapAccountIdToUnifiedCaseOwner.containsKey(currentCase.AccountId)){
                  //We choose the first case owner Id under the same account to unify other cases
                  mapAccountIdToUnifiedCaseOwner.put(currentCase.AccountId, currentCase.OwnerId);
              }
              else if(currentCase.OwnerId != mapAccountIdToUnifiedCaseOwner.get(currentCase.AccountId)){
                  //Makre sure cases under the same account have the same owner
                  currentCase.OwnerId = mapAccountIdToUnifiedCaseOwner.get(currentCase.AccountId);
              }
          }          
      }
  }

/**
 * @purpose Check if a case is under a VIP account 
 * @author  Steven
 * @date    2019-01-15
 * @param   Account account              account to check if it's VIP
 * @return  Boolean
 */
  private Boolean isVIPAccount(Account account){
      Boolean isVIP = FALSE;

      if(account.Manual_VIP_Program_Status__c == 'VIP'){
          isVIP = TRUE;
      }

      return isVIP;
  }

  /**
 * @purpose Check if case owner is VIP Account Strategist 
 * @author  Steven
 * @date    2019-01-15
 * @param   Case  onboardingCase            onboarding case
 * @return  Boolean
 */
  private Boolean isVIPAccountStrategist(Id ownerId){
      Boolean isVIP = FALSE;

      if(setVIPQueueMemberIDs == NULL){
          Id queueIdToVIP = mapCaseQueueNameToQueueId.get('VIP_Queue');
          setVIPQueueMemberIDs = CaseService.getSpecificQueueMember(queueIdToVIP);
      }
      //If case owner Id is in VIP Queue, we consider this owner as VIP Account Strategist
      if(!setVIPQueueMemberIDs.isEmpty() && setVIPQueueMemberIDs.contains(ownerId)){

          isVIP = TRUE;
      }

      return isVIP;
  }

  /**
  * @purpose Get accountId from case record, if accountId is blank, we get contact.AccountId from case
  * @author  Steven
  * @date    2019-01-15
  * @param   Case             currentCase                    current case record to get accountId
  * @param   Map<Id, Contact> relatedContactMap              a map of case contact info to get accountId
  * @return  Id
  */
  private Id getAccountId(Case currentCase, Map<Id, Contact> relatedContactMap){
      Id accountId;

      if(String.isNotBlank(currentCase.AccountId)){
        accountId = currentCase.AccountId;
      }else if(String.isNotBlank(currentCase.ContactId) && relatedContactMap.containsKey(currentCase.ContactId)){
        accountId = relatedContactMap.get(currentCase.ContactId).AccountId;
      }

      return accountId;
  }

  /**
  * @purpose recent opened case owner assignment 
  * @author  Steven
  * @date    2019-01-15
  * @param   List<Case> listCasesToAssign                         list of cases to follow the recent opened case owner assignment
  * @param   Set<Id> setAccountIdForRecentCase                    set of account Id to query recent opened case owner
  * @param   Map<Id, Account> relatedAccountMap                   map of account object
  * @param   Map<Id, Contact> relatedContactMap                   map of contact object
  * @return  void
  */
  private void assignRecentCaseOwner(List<Case> listCasesToAssign, Set<Id> setAccountIdForRecentCase, Map<Id, Account> relatedAccountMap, Map<Id, Contact> relatedContactMap){
      Map<Id,Boolean> mapUserIdToOutOfOffice = new Map<Id,Boolean>();

      Set<Id> setCaseOwnerIDsToCheckOOO = new Set<Id>();

      List<Case> listRecentOpenedCases = new List<Case>();

      List<Case> listInboundCasesToAssign = new List<Case>();
      List<Case> listGenericCasesToAssign = new List<Case>();

      //separate different record type cases to different assignment logic
      for(Case caseObj : listCasesToAssign){
          String rtName = caseRecTypeIDMap.get(caseObj.RecordTypeId).getName();

          if(rtName.containsIgnoreCase('Inbound')){

              Id acctId = getAccountId(caseObj, relatedContactMap);

              if(String.isNotBlank(acctId) && relatedAccountMap.containsKey(acctId)){

                  Account relatedAccount = relatedAccountMap.get(acctId);

                  if(relatedAccount != null && isVIPAccount(relatedAccount)
                    && relatedAccount.Strategy_Specialist__c != null
                    && relatedAccount.Strategy_Specialist__r.IsActive){

                      //We need to check if AS is OOO for VIP account
                      setCaseOwnerIDsToCheckOOO.add(relatedAccount.Strategy_Specialist__c);
                  }
              }

          }
          //Inbound cases run specific recent opened case owner assignment 
          if(rtName.containsIgnoreCase('Inbound')){

              listInboundCasesToAssign.add(caseObj);
          }
          //OnBoarding cases do not need to run recent opened case owner assignment
          //Asset Collection cases run specific recent opened case owner assignment in Distribution Engine
          //Other record type cases run generic recent opened case owner assignment
          else if(!rtName.containsIgnoreCase('Asset Collection') || !rtName.containsIgnoreCase('2 - OnBoarding')){

              listGenericCasesToAssign.add(caseObj);
          }
      }

      /**
       * build rencent opened case list by account Id
       * 1) sepecific account Id
       * 2) case Record Type is Onboarding, Asset Collection, Inbound
       * 3) isClosed = FALSE
       * 4) Owner.Type is User, not Queue
       * 5) Owner.Type is active
       */
      
      for(Case recentOpenedCase : [SELECT Id, RecordType.Name, OwnerId, AccountId, Product_Type__c
                                    FROM Case 
                                    WHERE IsClosed = FALSE AND 
                                    RecordType.Name IN:recordtypeSet AND 
                                    AccountId IN: setAccountIdForRecentCase AND 
                                    Owner.Type = 'User' AND
                                    Owner.IsActive = TRUE
                                    ORDER BY LastModifiedDate DESC]){
          //We need to check if recent opened case owner is OOO
          setCaseOwnerIDsToCheckOOO.add(recentOpenedCase.OwnerId);

          listRecentOpenedCases.add(recentOpenedCase);
      }

      //build out of office user map
      if(!setCaseOwnerIDsToCheckOOO.isEmpty()){

          mapUserIdToOutOfOffice = checkOutOfOfficeUsers(setCaseOwnerIDsToCheckOOO);
      }

      //execute separate recent case owner assignment for different record type cases
      if(!listInboundCasesToAssign.isEmpty()){
        
          assignRecentCaseOwnerForInbound(listInboundCasesToAssign, listRecentOpenedCases, mapUserIdToOutOfOffice, relatedAccountMap, relatedContactMap);
      }

      if(!listGenericCasesToAssign.isEmpty()){

          assignRecentCaseOwnerForGeneric(listGenericCasesToAssign, listRecentOpenedCases, mapUserIdToOutOfOffice, relatedContactMap);
      }
  }


  /**
  * @purpose recent opened case owner assignment for new Inbound cases
  * @author  Steven
  * @date    2019-01-15
  * @param   List<Case> listInboundCasesToAssign             new Inbound cases to assign
  * @param   List<Case> listRecentOpenedCases                list of recent opened cases
  * @param   Map<Id,Boolean> mapUserIdToOutOfOffice          a map of user Id and OoO flag
  * @param   Map<Id, Account> relatedAccountMap              map account info
  * @param   Map<Id, Contact> relatedContactMap              map contact info
  * @return  void
  */
  private void assignRecentCaseOwnerForInbound(List<Case> listInboundCasesToAssign, List<Case> listRecentOpenedCases, Map<Id,Boolean> mapUserIdToOutOfOffice, Map<Id, Account> relatedAccountMap, Map<Id, Contact> relatedContactMap){
      Map<Id,List<Case>> mapNoVIPAcctIdToInboundCaseList = new Map<Id,List<Case>>();

      Map<Id,MostRecentOpenedCaseWrapper> mapAcctIdToMostRecentCaseWrapper = new Map<Id,MostRecentOpenedCaseWrapper>();

      //owner assignment logic for VIP Account
      for(Case inboundCase : listInboundCasesToAssign){
          //We assign all new Inbound cases to Inbound Queue as default
          inboundCase.OwnerId = mapCaseQueueNameToQueueId.get('Inbound_Case_Queue');

          Id acctId = getAccountId(inboundCase, relatedContactMap);
          if(String.isNotBlank(acctId) && relatedAccountMap.containsKey(acctId)){

              Account acct = relatedAccountMap.get(acctId);
              //If it is VIP Account, we assign Inbound case to AS(VIP) on Account object directly
              if(isVIPAccount(acct)){
                  //If AS is blank/OOO/Inactive, we assign Inbound case to VIP queue
                  if(acct.Strategy_Specialist__c != null && acct.Strategy_Specialist__r.IsActive 
                    && !mapUserIdToOutOfOffice.containsKey(acct.Strategy_Specialist__c)){

                      inboundCase.OwnerId = acct.Strategy_Specialist__c;
                  }
                  else{
                      inboundCase.OwnerId = mapCaseQueueNameToQueueId.get('VIP_Queue');
                  }
                  
              }
              else{
                  if(!mapNoVIPAcctIdToInboundCaseList.containsKey(acctId)){

                      mapNoVIPAcctIdToInboundCaseList.put(acctId, new List<Case>());
                  }

                  mapNoVIPAcctIdToInboundCaseList.get(acctId).add(inboundCase);

              }
          }
      }

      if(!mapNoVIPAcctIdToInboundCaseList.isEmpty()){
          //build recent opened case wrapper for non-VIP account
          mapAcctIdToMostRecentCaseWrapper = buildRecentOpenedCaseMapping(mapNoVIPAcctIdToInboundCaseList.keySet(), listRecentOpenedCases, mapUserIdToOutOfOffice);

          //owner assignment logic for non-VIP Account
          for(Id acctId : mapNoVIPAcctIdToInboundCaseList.keySet()){

              if(!mapAcctIdToMostRecentCaseWrapper.isEmpty() && mapAcctIdToMostRecentCaseWrapper.containsKey(acctId)){

                  MostRecentOpenedCaseWrapper wrapper = mapAcctIdToMostRecentCaseWrapper.get(acctId);
                  for(Case inboundCaseToAssign : mapNoVIPAcctIdToInboundCaseList.get(acctId)){
                      /**
                       * If account has opened Onboarding case
                       * If the owner is OoO, assign new Inbound case to Onboarding Queue for distribution
                       * If the owner is not OoO, assign new Inbound case to the owner
                       * If no any opened Onboarding case, check if there is any opened Asset Collection case
                       */
                      if(wrapper.hasOpenedOnboardingCase){

                          inboundCaseToAssign.OwnerId = (wrapper.mostRecentOpenedOnboardingCase == null)? mapCaseQueueNameToQueueId.get('Onboarding_case_queue') : wrapper.mostRecentOpenedOnboardingCase.OwnerId;
                      }
                      /**
                       * If account has opened Asset Collection case and product type is not Direct Mail
                       * If the owner is OoO, check if there is any opened Inbound case
                       * If the owner is not OoO, assign new Inbound case to the owner
                       * If no any opened Asset Collection case, check if there is any opened Inbound case
                       */
                      else if(wrapper.mostRecentOpenedAssetCollectionCase != null){

                          inboundCaseToAssign.OwnerId = wrapper.mostRecentOpenedAssetCollectionCase.OwnerId;
                      }
                      /**
                       * If there any opened Inbound case
                       * If the owner is OoO, new Inbound case should be assigned to Inbound Queue as default
                       * If the owner is not OoO, assign new Inbound case to the owner
                       * If no any opened Inbound case, new Inbound case should be assigned to Inbound Queue as default
                       */
                      else if(wrapper.mostRecentOpenedInboundCase != null){

                          inboundCaseToAssign.OwnerId = wrapper.mostRecentOpenedInboundCase.OwnerId;
                      }
                  }
              }
          }
      }

  }

  /**
  * @purpose recent opened case owner assignment for new generic cases
  * @author  Steven
  * @date    2019-01-15
  * @param   List<Case> listGenericCasesToAssign             new generic cases to assign
  * @param   List<Case> listRecentOpenedCases                list of recent opened cases
  * @param   Map<Id,Boolean> mapUserIdToOutOfOffice          a map of user Id and OoO flag
  * @param   Map<Id, Account> relatedAccountMap              map account info
  * @param   Map<Id, Contact> relatedContactMap              map contact info
  * @return  void
  */
  private void assignRecentCaseOwnerForGeneric(List<Case> listGenericCasesToAssign, List<Case> listRecentOpenedCases, Map<Id,Boolean> mapUserIdToOutOfOffice, Map<Id, Contact> relatedContactMap){
    Map<Id, Case> openedAccountWithCaseOwnerMap = new Map<Id, Case>();

      // put all the accounts and case into a map, Key= account, and value = recently Date/Time Opened (last modified date)
      for(Case recentOpenedCase : listRecentOpenedCases){

          if(String.isNotBlank(recentOpenedCase.AccountId)){
              // owner is not in out of office
              if(!openedAccountWithCaseOwnerMap.containsKey(recentOpenedCase.AccountId) 
                && !mapUserIdToOutOfOffice.containsKey(recentOpenedCase.OwnerId)){

                  openedAccountWithCaseOwnerMap.put(recentOpenedCase.accountId, recentOpenedCase);
              }
          }
      }

      if(!openedAccountWithCaseOwnerMap.isEmpty()){

          for(Case currentCase : listGenericCasesToAssign){
              String accId = getAccountId(currentCase, relatedContactMap);

              if(openedAccountWithCaseOwnerMap.containsKey(accId)){
                  currentCase.OwnerId = openedAccountWithCaseOwnerMap.get(accId).OwnerId;
              }
          }
      }
  }

    /**
    * @purpose build recent opened case mapping for case owner assignment
    * @author  Steven
    * @date    2019-02-02
    * @param   Set<Id>          setAccountIds                    parent account Id of recent opened cases
    * @param   List<Case>       listRecentOpenedCases            list of recent opened cases
    * @param   Map<Id,Boolean>  mapUserIdToOutOfOffice           a map of user Id and OoO flag
    * @return  Map<Id,MostRecentOpenedCaseWrapper>
    */
    private Map<Id,MostRecentOpenedCaseWrapper> buildRecentOpenedCaseMapping(Set<Id> setAccountIds, List<Case> listRecentOpenedCases, Map<Id,Boolean> mapUserIdToOutOfOffice){

        Map<Id,MostRecentOpenedCaseWrapper> mapAcctIdToMostRecentCaseWrapper = new Map<Id,MostRecentOpenedCaseWrapper>();

        if(!listRecentOpenedCases.isEmpty()){
            for(Case recentOpenedCase : listRecentOpenedCases){

                if(!setAccountIds.contains(recentOpenedCase.AccountId)){
                    continue;
                }

                if(!mapAcctIdToMostRecentCaseWrapper.containsKey(recentOpenedCase.AccountId)){

                    MostRecentOpenedCaseWrapper wrapper = new MostRecentOpenedCaseWrapper();
                    mapAcctIdToMostRecentCaseWrapper.put(recentOpenedCase.AccountId, wrapper);
                }

                MostRecentOpenedCaseWrapper wrapper = mapAcctIdToMostRecentCaseWrapper.get(recentOpenedCase.AccountId);
                //onboarding
                if(recentOpenedCase.RecordType.Name.containsIgnoreCase('2 - OnBoarding') 
                && wrapper.mostRecentOpenedOnboardingCase == null){

                    if(wrapper.hasOpenedOnboardingCase == FALSE){
                        wrapper.hasOpenedOnboardingCase = TRUE;
                    }
                  
                    if(!mapUserIdToOutOfOffice.containsKey(recentOpenedCase.OwnerId)){

                        wrapper.mostRecentOpenedOnboardingCase = recentOpenedCase;
                    }

                }
                //asset collection (Product Type on the Case record is not Direct Mail)
                else if(recentOpenedCase.RecordType.Name.containsIgnoreCase('Asset Collection')
                && recentOpenedCase.Product_Type__c != 'Direct Mail'
                && wrapper.mostRecentOpenedAssetCollectionCase == null
                && !mapUserIdToOutOfOffice.containsKey(recentOpenedCase.OwnerId)){

                    wrapper.mostRecentOpenedAssetCollectionCase = recentOpenedCase;

                }
                //inbound
                else if(recentOpenedCase.RecordType.Name.containsIgnoreCase('Inbound') 
                && wrapper.mostRecentOpenedInboundCase == null
                && !mapUserIdToOutOfOffice.containsKey(recentOpenedCase.OwnerId)){

                    wrapper.mostRecentOpenedInboundCase = recentOpenedCase;

                }

            }
        }

        return mapAcctIdToMostRecentCaseWrapper;
    }

  /**
   * Wrap different record type most recent opened cases under the same account record for recent case owner assignment
   */
    public class MostRecentOpenedCaseWrapper {
        public Case mostRecentOpenedOnboardingCase {get; set;}
        public Boolean hasOpenedOnboardingCase {get;set;}
        public Case mostRecentOpenedAssetCollectionCase {get; set;}
        public Case mostRecentOpenedInboundCase {get; set;}

        public MostRecentOpenedCaseWrapper() {
            hasOpenedOnboardingCase = FALSE;
        }
    }

}