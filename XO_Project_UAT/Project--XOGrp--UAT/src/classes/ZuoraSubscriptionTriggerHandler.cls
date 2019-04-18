public without sharing class ZuoraSubscriptionTriggerHandler implements iTrigger{
  //////////////////
  // STATIC FINAL //
  //////////////////
  // Get the Quote object prefix for use later in code - used to ensure that the Id in the specified field is correct
  private static final String QUOTE_OBJECT_PREFIX = zqu__Quote__c.sObjectType.getDescribe().getKeyPrefix();
  // Quote Database Query
  private static final String QUOTE_QUERY = 'SELECT '
                                            + 'Id, '
                                            + 'zqu__ZuoraSubscriptionID__c '
                                          + ' FROM '
                                            + 'zqu__Quote__c'
                                          + ' WHERE '
                                            + '{WHERECLAUSE}';

  // Subscription Sync Query used in the static final method to sync sub data to Zuora
  private static final String SUB_SYNC_QUERY = 'SELECT '
                                                + 'Id, '
                                                + 'CreatingSalesforceQuoteID__c, '
                                                + 'OriginalSalesforceQuoteID__c, '
                                                + 'Zuora__Zuora_Id__c, '
                                                + 'RenewalRepId__c, '
                                                + 'SalesRepId__c, '
                                                + 'ReportingRepId__c, '
                                                + 'RSD_Id__c, '
                                                + 'AutoRenewal__c '
                                              + ' FROM '
                                                + 'Zuora__Subscription__c'
                                              + ' WHERE '
                                                + '{WHERECLAUSE}';

  /////////////////////
  // CLASS VARIABLES //
  /////////////////////
  private Map<String, zqu__Quote__c> zuoraSubIdToQuoteMap;
  private Set<Id> accountIDSet = new Set<Id>();
  private Map<String, User> userRepIdRSDMap = new Map<String, User>();
  private Set<String> cancelledSubscriptionNameSet = new Set<String>();
  // CSP-2295 - Variable used to hold Zuora Subscription External Ids of Subscriptions which need fields sync'd to Zuora
  private Set<String> subSyncZuoraIdSet = new Set<String>();

  private List<XO_Exception__c> exceptionList = new List<XO_Exception__c>();

  // CSP-2821 Selling to a Prospect
  // store all active subs, then update the related account status to active
  private Set<Id> activeSubAccountSet = new Set<Id>();
  private List<Account> activeAccountUpdateList = new List<Account>();

  // CSP-3199 Add Subscription Name to Quote Object
  // Store need update quote and Subscription Name mapping
  private Map<Id, String> quoteIdSubscriptionNameMap = new Map<Id, String>();
  // Use Map store quote list for update avoid duplicate record 
  private Map<Id, zqu__Quote__c> quoteIdQuoteUpdateMap = new Map<Id, zqu__Quote__c>();

  // CSP-3120 Original Sales Rep
  private Map<Id, Zuora__Subscription__c> accWithSubMap = new Map<Id, Zuora__Subscription__c>();

  private List<Live_Subscription__c> listLiveSubscriptions = new List<Live_Subscription__c>();

  private Map<String, Zuora__Subscription__c> mapNameToSubscription = new Map<String, Zuora__Subscription__c>();
  /**
  * bulkBefore
  *
  * This method is called prior to execution of a BEFORE trigger. Use this to cache
  * any data required into maps prior execution of the trigger.
  */
  public void bulkBefore(){
    // Instantiate Variables for Before Logic
    zuoraSubIdToQuoteMap = new Map<String, zqu__Quote__c>();

    ///////////////////////////
    // INSERT & UPDATE LOGIC //
    ///////////////////////////
    if(trigger.isInsert || trigger.isUpdate){
      Set<String> userIdSet = new Set<String>();
      Set<String> subscriptionZuoraIdSet = new Set<String>();

      for(Integer i = 0; i < Trigger.new.size(); i++) {
        Zuora__Subscription__c currentSubscription = (Zuora__Subscription__c)Trigger.new[i];
        Zuora__Subscription__c previousSubscription;
        
        if(Trigger.isUpdate) {
          previousSubscription = (Zuora__Subscription__c)Trigger.oldMap.get(currentSubscription.Id);

          if(currentSubscription.Zuora__Zuora_Id__c != previousSubscription.Zuora__Zuora_Id__c && String.isNotBlank(currentSubscription.Zuora__Zuora_Id__c)) {
            subscriptionZuoraIdSet.add(currentSubscription.Zuora__Zuora_Id__c);
          }

          // Find any changes made to RenewalRep, ReportRep, or SalesRep Id values
          userIdSet.addAll(findSubRepId(currentSubscription, previousSubscription));

          continue;
        }

        // If the Zuora Id is not blank add the Zuora Id
        if(String.isNotBlank(currentSubscription.Zuora__Zuora_Id__c)) {
          subscriptionZuoraIdSet.add(currentSubscription.Zuora__Zuora_Id__c);
        }
        
        // Find any RenewalRep, ReportRep, or SalesRep Id values
        userIdSet.addAll(findSubRepId(currentSubscription));
      }

      // Create a map that will be used to populate the Quote Id's onto the Subscription
      if(!subscriptionZuoraIdSet.isEmpty()) {
        String quoteQuery = QUOTE_QUERY.replace('{WHERECLAUSE}', 'zqu__ZuoraSubscriptionID__c IN :subscriptionZuoraIdSet');
        List<zqu__Quote__c> matchingQuoteList = Database.query(quoteQuery);

        for(Integer i = 0; i < matchingQuoteList.size(); i++) {
          zqu__Quote__c currentQuote = matchingQuoteList[i];

          zuoraSubIdToQuoteMap.put(currentQuote.zqu__ZuoraSubscriptionID__c, currentQuote);
        }
      }

      if(!userIdSet.isEmpty()){
        for(User record : [select Id, SalesRepID__c, ManagerId, Manager.SalesRepID__c from User where ID IN : userIdSet or SalesRepID__c IN : userIdSet]){
          userRepIdRSDMap.put(record.SalesRepID__c, record);
          if(trigger.isUpdate)
            userRepIdRSDMap.put(record.id, record);
        }
      }
    }
  }

  ////////////////
  // BULK AFTER //
  ////////////////
  public void bulkAfter(){

  }
  
  ///////////////////
  // BEFORE INSERT //
  ///////////////////
  public void beforeInsert(SObject so){
    Zuora__Subscription__c record = (Zuora__Subscription__c)so;

    updateRenewalReportingSalesRep(record);

    // CSP-2293 - Populate the Quote fields
    if(zuoraSubIdToQuoteMap.containsKey(record.Zuora__Zuora_Id__c)) {
      zqu__Quote__c creatingQuote = zuoraSubIdToQuoteMap.get(record.Zuora__Zuora_Id__c);

      // If this is the first version of a Subscription(Version 1) then the Quote that created this Subscription is both
      // the Original Quote AND the Creating Quote
      if(record.Zuora__Version__c == 1) {
        record.OriginalSalesforceQuoteID__c = creatingQuote.Id;
      }

      record.CreatingSalesforceQuoteID__c = creatingQuote.Id;
      subSyncZuoraIdSet.add(record.Zuora__Zuora_Id__c);
    }
    
    // CSP-1257 - Populate lookup field to Quote
    if(String.isNotBlank(record.OriginalSalesforceQuoteID__c) && record.OriginalSalesforceQuoteID__c.substring(0, 3) == QUOTE_OBJECT_PREFIX) {
      try {
        record.Original_Quote__c = record.OriginalSalesforceQuoteID__c; 
      } catch(Exception e) {
        XO_Exception__c currentException = ExceptionUtility.consumeException(e, false);
        currentException.Message__c = currentException.Message__c + '\n\rInvalid quote Id on insert.';
        currentException.Related_Object_Id__c = 'Scription Zuora Id: ' + record.Zuora__Zuora_Id__c;
        exceptionList.add(currentException);
      }
    } else {
      record.Original_Quote__c = null;
    }

    // CSP-1257 - Populate lookup field to Quote
    if(String.isNotBlank(record.CreatingSalesforceQuoteID__c) && record.CreatingSalesforceQuoteID__c.substring(0, 3) == QUOTE_OBJECT_PREFIX) {
      try {
        record.Latest_Quote__c = record.CreatingSalesforceQuoteID__c;
      } catch(Exception e) {
        XO_Exception__c currentException = ExceptionUtility.consumeException(e, false);
        currentException.Message__c = currentException.Message__c + '\n\rInvalid quote Id on insert.';
        currentException.Related_Object_Id__c = 'Scription Zuora Id: ' + record.Zuora__Zuora_Id__c;
        exceptionList.add(currentException);
      }
    } else {
      record.Latest_Quote__c = null;
    }
  }
  
  
  public void beforeUpdate(SObject oldSo, SObject so){
    Zuora__Subscription__c record = (Zuora__Subscription__c)so;
    Zuora__Subscription__c oldRecord = (Zuora__Subscription__c)oldSo;

    // update the Renewal Rep Id/ Renewal Rep/ Sales Rep Id/ Sales Rep/ RSD Id/ RSD/ Reporting Rep ID/ Reporting Rep
    updateRenewalReportingSalesRep(record,oldRecord);

    // for ticket CSP-1969, Only Tonia Haas, Shannon Davis and Carigan Wiegand are the only users that have the ability 
    // to put a subscription that is LESS than 12 months ON auto renew.
    // And if the AutoRenewal__c have been changed, we should auto sync to Zuora.
    if (!String.valueOf(system.Label.UserCanAutoRenewalIncludeLess12Item).contains(userInfo.getName()) 
              && record.AutoRenewal__c == 'YES' 
              && oldRecord.AutoRenewal__c == 'NO'
              && record.IncludeLess12Item__c) {
      record.AutoRenewal__c.adderror(system.Label.UserCanNotAutoRenewalIncludeLess12ItemErrorMessage);  
    }

    // CSP-1257 - Populate lookup field to Quote
    if(String.isNotBlank(record.OriginalSalesforceQuoteID__c) && record.OriginalSalesforceQuoteID__c.substring(0, 3) == QUOTE_OBJECT_PREFIX) {
      try {
        record.Original_Quote__c = record.OriginalSalesforceQuoteID__c; 
      } catch(Exception e) {
        XO_Exception__c currentException = ExceptionUtility.consumeException(e, false);
        currentException.Related_Object_Id__c = record.Id;
        exceptionList.add(currentException);
      }
    } else {
      record.Original_Quote__c = null;
    }

    // CSP-1257 - Populate lookup field to Quote
    if(String.isNotBlank(record.CreatingSalesforceQuoteID__c) && record.CreatingSalesforceQuoteID__c.substring(0, 3) == QUOTE_OBJECT_PREFIX) {
      try {
        record.Latest_Quote__c = record.CreatingSalesforceQuoteID__c;
      } catch(Exception e) {
        XO_Exception__c currentException = ExceptionUtility.consumeException(e, false);
        currentException.Related_Object_Id__c = record.Id;
        exceptionList.add(currentException);
      }
    } else {
      record.Latest_Quote__c = null;
    }
  }
  
  /**
  * beforeDelete
  *
  * This method is called iteratively for each record to be deleted during a BEFORE
  * trigger.
  */ 
  public void beforeDelete(SObject so){

  }
 
  //////////////////
  // AFTER INSERT //
  //////////////////
  public void afterInsert(SObject so){
    Zuora__Subscription__c record = (Zuora__Subscription__c)so;
    accountIDSet.add(record.Zuora__Account__c);
    
    // CSP-1464 | if Status is "Cancelled" add the name to the cancelledSubscriptionNameSet so open Callback__c records can be marked as Cancelled
    if (record.True_Subscription_Status__c == 'Cancelled') {
      cancelledSubscriptionNameSet.add(record.Name);
    }

    // CSP-2821 Selling to a Prospect
    // adding active subs to list
    if(record.Zuora__TermEndDate__c!=NULL && record.Zuora__TermEndDate__c>=Date.today()){
      
      if(!activeSubAccountSet.contains(record.Zuora__Account__c)){
        activeSubAccountSet.add(record.Zuora__Account__c);
      }
    }

    // CSP-3199 Add Subscription Name to Quote Object
    // Put need update quote Id and subscription name to the map 
    if(String.isNotBlank(record.Latest_Quote__c)) {
      quoteIdSubscriptionNameMap.put(record.Latest_Quote__c, record.Name);
    }
    // CSP-3120 Original Sales Rep
    // put the account id with the specific sub into accWithSubMap
    if(!accWithSubMap.containsKey(record.Zuora__Account__c)){
        // Only check for those version 1 subs
        if(record.Zuora__Version__c == 1){
            accWithSubMap.put(record.Zuora__Account__c, record);
        }
    }

    // copy the zuora subs info to the live subscription 
    listLiveSubscriptions.add(LiveSubscriptionHandler.copySubscription(record));
  }
  
  //////////////////
  // AFTER UPDATE //
  //////////////////
  public void afterUpdate(SObject oldSo, SObject so){
    Zuora__Subscription__c record = (Zuora__Subscription__c)so;
    Zuora__Subscription__c oldRecord = (Zuora__Subscription__c)oldSo;

    // CSP-1464 | if Status was updated to "Cancelled" add the name to the cancelledSubscriptionNameSet so open Callback__c records can be marked as Cancelled
    if (record.True_Subscription_Status__c == 'Cancelled' && oldRecord.True_Subscription_Status__c != 'Cancelled') {
      cancelledSubscriptionNameSet.add(record.Name);
    }

    // CSP-1486 | update account values
    if (record.True_Subscription_Status__c != oldRecord.True_Subscription_Status__c || record.Zuora__TCV__c != oldRecord.Zuora__TCV__c) {
      accountIDSet.add(record.Zuora__Account__c);
    }

    if (record.SalesRepId__c != oldRecord.SalesRepId__c || 
        record.RenewalRepId__c != oldRecord.RenewalRepId__c || 
        record.RSD_Id__c != oldRecord.RSD_Id__c ) {
      
      if(!subSyncZuoraIdSet.contains(record.Zuora__Zuora_Id__c)) {
        subSyncZuoraIdSet.add(record.Zuora__Zuora_Id__c);
      }

      mapNameToSubscription.put(record.Name, record);
    }

    if(record.AutoRenewal__c != oldRecord.AutoRenewal__c ){
      if(!subSyncZuoraIdSet.contains(record.Zuora__Zuora_Id__c)) {
        subSyncZuoraIdSet.add(record.Zuora__Zuora_Id__c);
      }
    }
  }
 
  //////////////////
  // AFTER DELETE //
  //////////////////
  public void afterDelete(SObject so){

  }   
  
  /**
  * andFinally
  *
  * This method is called once all records have been processed by the trigger. Use this
  * method to accomplish any final operations such as creation or updates of other records.
  */
  public void andFinally(){
    if(!exceptionList.isEmpty()) {
      insert exceptionList;
    }
    // CSP-2821 Selling to a Prospect
    // update the active account status to active
    if(Trigger.isAfter) {

      List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();

      if(!activeSubAccountSet.isEmpty()){
        for(Id accId : activeSubAccountSet){
          Account acc = new Account();
          acc.Id = accId;
          acc.account_status__c = 'Active';
          activeAccountUpdateList.add(acc);
        }
      }

      // CSP-3199 Add Subscription Name to Quote Object
      // update quote Subscription name 
      if(!quoteIdSubscriptionNameMap.isEmpty()) {
        for(Id quoteId : quoteIdSubscriptionNameMap.keySet()) {
          zqu__Quote__c currentQuote = new zqu__Quote__c();
          currentQuote.Id = quoteId;
          currentQuote.Related_Sub__c = quoteIdSubscriptionNameMap.get(quoteId);
          quoteIdQuoteUpdateMap.put(quoteId, currentQuote);
        }
      }

      // CSP-2821 Selling to a Prospect
      // update the activeAccountUpdateList with error handling
      if(!activeAccountUpdateList.isEmpty()) {
        List<Database.SaveResult> resultList = Database.update(activeAccountUpdateList, false);
        xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
      }

      // CSP-3199 Add Subscription Name to Quote Object
      // update the quoteIdQuoteUpdateMap quote list with error handling
      if(!quoteIdQuoteUpdateMap.isEmpty()) {
        List<Database.SaveResult> updateQuoteresultList = Database.update(quoteIdQuoteUpdateMap.values(), false);
        xoExceptionList.addAll(ExceptionUtility.consumeException(updateQuoteresultList));
      }

      if (!listLiveSubscriptions.isEmpty()) {
        Schema.SObjectField subscriptionName = Live_Subscription__c.Fields.Subscription_Name__c;
        List<Database.UpsertResult> listUpsertResults = Database.upsert(listLiveSubscriptions, subscriptionName, false);
        xoExceptionList.addAll(ExceptionUtility.consumeException(listUpsertResults));
      }

      // insert xoException
      if(!xoExceptionList.isEmpty()){
        Insert xoExceptionList;
      }

      // CSP-3120 Original Sales Rep
      // Original Sales rep logic only work for after insert
      if(Trigger.isInsert) {
        OriginalSalesRepHandler.setMapAccIdtoSub(accWithSubMap);
        OriginalSalesRepHandler.runOriginalSalesRepLogic();
      }
      
      if (!mapNameToSubscription.isEmpty()) {
        LiveSubscriptionHandler.updateRenewalSalesRSDForLiveSub(mapNameToSubscription);
      }
    }



    if(!accountIDSet.isEmpty()){
      updateLocalActiveStatus();
    }

    if(!Test.isRunningTest() && !subSyncZuoraIdSet.isEmpty()) {
      updateSubscription(subSyncZuoraIdSet);
    }

    if (!cancelledSubscriptionNameSet.isEmpty()) {
      closeOpenCallbacksForCancelledSubs(cancelledSubscriptionNameSet);
    }
  }

  /**
   *   FUTURE CALLOUT METHOD
   *    This method is used to make a callout to the Zuora endpoint to update custom Subscription fields. Custom Fields
   *    do not require an amendment so they can be updated directly through the API rather than an amendment. The managed
   *    package is being used to create and send data to their end point.
   *
   *   NOTE
   *    This method is called from Insert to populate the CreatingSalesforceId and called from the Update method to 
   *    populate changes made to RenewalRep, ReportingRep, RSD, and AutoRenewal fields
   *
   *   @author Multiple
   *   @date   2017-08-07
   *   @param  {Set<String>}   subSyncZuoraIdSet This is the set of Zuora External Ids being used to query Subscriptions
   *                                             for data to be sync'd back to Zuora.
   */
  @future(callout=true)
  private static void updateSubscription(Set<String> subSyncZuoraIdSet) {
    List<Zuora.zObject> zuoraZObjectList = new List<Zuora.zObject>();

    List<String> subSyncZuoraIdList = new List<String>(subSyncZuoraIdSet);
    String subSyncQuery = SUB_SYNC_QUERY.replace('{WHERECLAUSE}', 'Zuora__Zuora_Id__c IN :subSyncZuoraIdList');

    List<Zuora__Subscription__c> subList = Database.query(subSyncQuery);
    for(Integer i = 0; i < subList.size(); i++) {
      Zuora__Subscription__c currentSub = subList[i];

      Zuora.zObject zuoraSub = new Zuora.zObject('Subscription');
      zuoraSub.setValue('Id', currentSub.Zuora__Zuora_Id__c);
      zuoraSub.setValue('RenewalRepId__c', currentSub.RenewalRepId__c);
      zuoraSub.setValue('ReportingRepId__c', currentSub.ReportingRepId__c);
      zuoraSub.setValue('RSD_Id__c', currentSub.RSD_Id__c);
      zuoraSub.setValue('SalesRepId__c', currentSub.SalesRepId__c);
      zuoraSub.setValue('AutoRenewal__c', currentSub.AutoRenewal__c);
      zuoraSub.setValue('CreatingSalesforceQuoteID__c', currentSub.CreatingSalesforceQuoteID__c);

      zuoraZObjectList.add(zuoraSub);

      if(zuoraZObjectList.size() == 50){
        Zuora.ZApi zApiInstance = new Zuora.ZApi();
        // skip the login call if this is a test
        if (!Test.isRunningTest()) {
          Zuora.zApi.LoginResult loginResult = zApiInstance.zlogin();
        }

        List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();

        if (!Test.isRunningTest()) {
          // callout method documention is here: https://knowledgecenter.zuora.com/CA_Commerce/E_Development_Resources/B_Order_Builder/D_Programming_with_Order_Builder
          results.addAll(zApiInstance.zupdate(zuoraZObjectList));
        }

        if (Test.isRunningTest()) {
          // test Sucess
          Zuora.zApi.SaveResult testSuccessSalesResult = new Zuora.zApi.SaveResult();
          testSuccessSalesResult.Success = True;
          results.add(testSuccessSalesResult);
          // test Failure
          Zuora.zApi.SaveResult testFailSalesResult = new Zuora.zApi.SaveResult();
          testFailSalesResult.Success = False;
          results.add(testSuccessSalesResult);
        }
         
        for (Zuora.zApi.SaveResult result : results) {
          if (result.Success){
            // if success, clear the "need to update" flag on the Subscription,
            // then add the Subscription to the zuoraSubUpdateList
            system.debug('success');
          }else{
            //failure, get the errors
            System.debug('CALLOUT FAILED');
            Zuora.zObject[] errors = result.errors;
            for (Zuora.zObject error : errors) {
              String errorCode = (String)error.getValue('Code');
              String message = (String)error.getValue('Message');
              System.debug(errorCode + ' ' + message);
            }
            throw new ApplicationException('Callout Failed');
          }
        }
        zuoraZObjectList.clear();
      }
    }

    if(!zuoraZObjectList.isEmpty()){
      Zuora.ZApi zApiInstance = new Zuora.ZApi();
      // skip the login call if this is a test
      if (!Test.isRunningTest()) {
        Zuora.zApi.LoginResult loginResult = zApiInstance.zlogin();
      }

      List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();

      if (!Test.isRunningTest()) {
        // callout method documention is here: https://knowledgecenter.zuora.com/CA_Commerce/E_Development_Resources/B_Order_Builder/D_Programming_with_Order_Builder
        results.addAll(zApiInstance.zupdate(zuoraZObjectList));
      }

      if (Test.isRunningTest()) {
        // test Sucess
        Zuora.zApi.SaveResult testSuccessSalesResult = new Zuora.zApi.SaveResult();
        testSuccessSalesResult.Success = True;
        results.add(testSuccessSalesResult);
        // test Failure
        Zuora.zApi.SaveResult testFailSalesResult = new Zuora.zApi.SaveResult();
        testFailSalesResult.Success = False;
        results.add(testSuccessSalesResult);
      }
       
      for (Zuora.zApi.SaveResult result : results) {
        if (result.Success){
          // if success, clear the "need to update" flag on the Subscription,
          // then add the Subscription to the zuoraSubUpdateList
          system.debug('success');
        }else{
          //failure, get the errors
          System.debug('CALLOUT FAILED');
          Zuora.zObject[] errors = result.errors;
          for (Zuora.zObject error : errors) {
            String errorCode = (String)error.getValue('Code');
            String message = (String)error.getValue('Message');
            System.debug(errorCode + ' ' + message);
          }
          throw new ApplicationException('Callout Failed');
        }
      }
    }
  }

  private void updateLocalActiveStatus(){
    List<Account> accountList = [SELECT Id, Local_Active__c, Active_Status_Change_Date__c, Inactive_Reason__c, 
                                ActiveSubscriptionTCVSummary__c, (SELECT Id, Zuora__Status__c, Is_Expired__c, Zuora__TCV__c 
                                  FROM Zuora__Subscriptions__r) 
                                FROM Account WHERE Id IN :accountIDSet];

    for (Account a : accountList) {
      Integer numberOfActiveSubscriptions = 0;
      Integer numberOfCancelledSubscriptions = 0;
      // CSP-1486 | reset ActiveSubscriptionTCVSummary__c to 0.00
      a.ActiveSubscriptionTCVSummary__c = 0.00;


      for (Zuora__Subscription__c sub : a.Zuora__Subscriptions__r) {
        // "expired" still counts as active, so need to exclude those when adding to numberOfActiveSubscriptions
        if (sub.Zuora__Status__c == 'Active' && sub.Is_Expired__c == False) {
          numberOfActiveSubscriptions++;
          // CSP-1486 | update ActiveSubscriptionTCVSummary__c
          if (sub.Zuora__TCV__c != null) {
            a.ActiveSubscriptionTCVSummary__c += sub.Zuora__TCV__c;
          }
        }
        else if (sub.Zuora__Status__c == 'Cancelled') {
          numberOfCancelledSubscriptions++;
        }

      }
      if (a.Local_Active__c == False && numberOfActiveSubscriptions > 0) {
        a.Local_Active__c = True;
        // Commented by Tony for ticket CSP-1232
        //a.Active_Status_Change_Date__c = Datetime.now();
        a.Inactive_Reason__c = '';
      }
      else if (a.Local_Active__c == True && numberOfActiveSubscriptions == 0 && numberOfCancelledSubscriptions > 0) {
        a.Local_Active__c = False;
        // Commented by Tony for ticket CSP-1232
        //a.Active_Status_Change_Date__c = Datetime.now();
        a.Inactive_Reason__c = 'Cancelled';
      }
    }

    update accountList;
  }
  /**
   * @purpose Assign Renewal Rep/Sales Rep/Reporting Rep/RSD based on RenewalRepId/SalesRepId/ReportingRepId/RSDId
   * @author  Tony
   * @date    2018-12-17
   * @param   the zuora subscription inserted from zuora
   */
  private void updateRenewalReportingSalesRep(Zuora__Subscription__c newSubscription){
    if(String.isNotBlank(newSubscription.RenewalRepId__c) && userRepIdRSDMap.containsKey(newSubscription.RenewalRepId__c)){
      newSubscription.Renewal_Rep__c = userRepIdRSDMap.get(newSubscription.RenewalRepId__c).Id;
    }
    if(String.isNotBlank(newSubscription.ReportingRepId__c) && userRepIdRSDMap.containsKey(newSubscription.ReportingRepId__c)){
      newSubscription.Reporting_Rep__c = userRepIdRSDMap.get(newSubscription.ReportingRepId__c).Id;
    }
    if(String.isNotBlank(newSubscription.SalesRepID__c) && userRepIdRSDMap.containsKey(newSubscription.SalesRepID__c)){
      newSubscription.Sales_Rep__c = userRepIdRSDMap.get(newSubscription.SalesRepID__c).Id;
    }
    if(String.isNotBlank(newSubscription.RSD_ID__c) && userRepIdRSDMap.containsKey(newSubscription.RSD_ID__c)){
      newSubscription.RSD__c = userRepIdRSDMap.get(newSubscription.RSD_ID__c).Id;
    }
  }

  /**
   * @purpose Map the Rep Id with the Rep, updated the Rep Id/Rep when the Rep/Rep Id changed. the Rep has the high priority 
   * @author  Tony
   * @date    2018-12-13
   * @param   newSubscription the new subscription before update
   * @param   oldSubscription the ole subscription before update
   */
  private void updateRenewalReportingSalesRep(Zuora__Subscription__c newSubscription,Zuora__Subscription__c oldSubscription){
    // Update Sales Rep Id when Sales Rep changed, then Update Sales Rep when Sales Rep Id changed and Sales Rep not changed 
    if (String.isNotBlank(newSubscription.Sales_Rep__c) && newSubscription.Sales_Rep__c != oldSubscription.Sales_Rep__c) {

        User userObj = userRepIdRSDMap.containsKey(newSubscription.Sales_Rep__c) ? userRepIdRSDMap.get(newSubscription.Sales_Rep__c) : null;
        if(userObj != null && String.isNotBlank(userObj.SalesRepID__c)){
            newSubscription.SalesRepID__c = userObj.SalesRepID__c;
        }else{
            newSubscription.Sales_Rep__c.addError('Sales Rep does not have a Sales Rep Id assigned!');
        }
    }
    else if(String.isNotBlank(newSubscription.Sales_Rep__c) && newSubscription.SalesRepID__c != oldSubscription.SalesRepID__c ){
        if (userRepIdRSDMap.containsKey(newSubscription.SalesRepID__c)) {
            newSubscription.Sales_Rep__c = userRepIdRSDMap.get(newSubscription.SalesRepID__c).Id;
        }
    }

    // Update Renewal Rep Id when Renewal Rep changed, then Update Renewal Rep when Renewal Rep Id changed and Renewal Rep not changed 
    if(newSubscription.Renewal_Rep__c != oldSubscription.Renewal_Rep__c && String.isNotBlank(newSubscription.Renewal_Rep__c)){
        User userObj = userRepIdRSDMap.containsKey(newSubscription.Renewal_Rep__c) ? userRepIdRSDMap.get(newSubscription.Renewal_Rep__c) : null;
        if(userObj != null && String.isNotBlank(userObj.SalesRepID__c)){
            newSubscription.RenewalRepId__c = userObj.SalesRepID__c;
        }else{
            newSubscription.Renewal_Rep__c.addError('Renewal Rep does not have a Sales Rep Id assigned!');
        }
    }else if(userRepIdRSDMap.containsKey(newSubscription.RenewalRepId__c) && newSubscription.RenewalRepId__c != oldSubscription.RenewalRepId__c){
        newSubscription.Renewal_Rep__c = userRepIdRSDMap.get(newSubscription.RenewalRepId__c).Id;
    }

    // Update Reporting Rep Id, RSD and RSD ID when Reporting Rep changed, 
    // then update Reporting Rep, RSD and RSD ID when Reporting Rep Id changed and Reporting Rep not changed 
    if(newSubscription.Reporting_Rep__c != oldSubscription.Reporting_Rep__c && String.isNotBlank(newSubscription.Reporting_Rep__c)){
        User userObj = userRepIdRSDMap.containsKey(newSubscription.Reporting_Rep__c) ? userRepIdRSDMap.get(newSubscription.Reporting_Rep__c) : null;
        if(userObj != null && String.isNotBlank(userObj.SalesRepID__c)){
            newSubscription.ReportingRepId__c = userObj.SalesRepID__c;

            if(String.isBlank(userObj.ManagerId)){
                newSubscription.Reporting_Rep__c.addError('Reporting Rep does not have an RSD assigned');
            }else if(String.isBlank(userObj.Manager.SalesRepID__c)){
                newSubscription.Reporting_Rep__c.addError('Reporting Rep\'s RSD does not have a Sales Rep Id assigned');
            }else{
                newSubscription.RSD_Id__c = userObj.Manager.SalesRepID__c;
                newSubscription.RSD__c = userObj.ManagerId;
            }
        }else{
            newSubscription.Reporting_Rep__c.addError('Reporting Rep does not have a Sales Rep Id assigned!');
        }
    }else if(userRepIdRSDMap.containsKey(newSubscription.ReportingRepId__c) && newSubscription.ReportingRepId__c != oldSubscription.ReportingRepId__c){
        User userObj = userRepIdRSDMap.get(newSubscription.Reporting_Rep__c);
        newSubscription.Reporting_Rep__c = userObj.Id;
        if(String.isBlank(userObj.ManagerId)){
            newSubscription.Reporting_Rep__c.addError('Reporting Rep does not have an RSD assigned');
        }else if(String.isBlank(userObj.Manager.SalesRepID__c)){
            newSubscription.Reporting_Rep__c.addError('Reporting Rep\'s RSD does not have a Sales Rep Id assigned');
        }else{
            newSubscription.RSD_Id__c = userObj.Manager.SalesRepID__c;
            newSubscription.RSD__c = userObj.ManagerId;
        }
    }
    //If Reporting Rep Id and Reporting Rep not Changed, update RSD Id when RSD changed, then update RSD when RSD Id changed and RSD not changed 
    else if(newSubscription.RSD__c != oldSubscription.RSD__c && String.isNotBlank(newSubscription.RSD__c)){
        User userObj = userRepIdRSDMap.containsKey(newSubscription.RSD__c) ? userRepIdRSDMap.get(newSubscription.RSD__c) : null;
        if(userObj != null && String.isNotBlank(userObj.SalesRepID__c)){
            newSubscription.RSD_Id__c = userObj.SalesRepID__c;
        }else{
            newSubscription.RSD__c.addError('RSD does not have a Sales Rep Id assigned!');
        }
    }else if(userRepIdRSDMap.containsKey(newSubscription.RSD_Id__c) && newSubscription.RSD_Id__c != oldSubscription.RSD_Id__c){
        newSubscription.RSD__c = userRepIdRSDMap.get(newSubscription.RSD_Id__c).Id;
    }

  }

  /**
   *   CSP-1464 | "closeOpenCallbacksForCancelledSubs" does exactly that: closes open Callback__c records for Subscriptions that have been cancelled
   *   This logic could have been part of the ZuoraSubscriptionPCTriggerHandler.createAndUpdateCallbacks method, but for some reason I recall having
   *   seen Zuora perform a Subscription record update during Cancellations rather than the usual delete/replace, although during recent testing it
   *   has been doing delete/replaces. Regardless, better safe than sorry; this method will marked open Callback__c records as "Cancelled" if the
   *   Subscription record is updated or inserted with a True_Subscription_Status__c of "Cancelled".
   *
   *   @author Jonathan Satterfield
   *   @date   2016-09-22
   *   @param  {Set<String> cancelledSubscriptionNameSet}   cancelledSubscriptionNameSet
   */
  public static void closeOpenCallbacksForCancelledSubs(Set<String> cancelledSubscriptionNameSet) {
    List<Callback__c> callbacksToCloseList = [SELECT Id, Subscription_Name__c, Status__c FROM Callback__c WHERE Subscription_Name__c IN :cancelledSubscriptionNameSet AND Status__c != 'Cancelled'];
    if (callbacksToCloseList.isEmpty()) {
      return;
    }
    for (Callback__c callbackRecord : callbacksToCloseList) {
      callbackRecord.Status__c = 'Cancelled';
    }
    Database.SaveResult[] updateResults = Database.update(callbacksToCloseList, false);
    List<XO_Exception__C> callbacksUpdateExceptionList = ExceptionUtility.consumeException(updateResults);
    if (!callbacksUpdateExceptionList.isEmpty()) {
      insert callbacksUpdateExceptionList;
    }
  }

  /**
   *   Method used to find Rep Id values for three specific fields on the Subscription object. These Id values are then
   *   used to find the corresponding User in the system and add that Salesforce ID to the User lookup field corresponding
   *   to the correct Rep Id
   *
   *   NOTE: This is an overloaded method specifically used for INSERT logic
   *   
   *   @author Jusitn
   *   @date   2017-08-04
   *   @param  {Zuora__Subscription__c}      currentSubscription The current subscription that is being used to find the
   *                                                             values
   *   @return {Set<String>}                                     The set of Rep Id values that was found
   */ 
  private static Set<String> findSubRepId(Zuora__Subscription__c currentSubscription) {
    Set<String> repIdSet = new Set<String>();

    // Renewal Rep Change
    if(String.isNotBlank(currentSubscription.RenewalRepId__c)) {
      repIdSet.add(currentSubscription.RenewalRepId__c);
    }

    // Reporting Rep Change
    if(String.isNotBlank(currentSubscription.ReportingRepId__c)) {
      repIdSet.add(currentSubscription.ReportingRepId__c);
    }
    
    // Sales Rep Change
    if(String.isNotBlank(currentSubscription.SalesRepID__c)) {
      repIdSet.add(currentSubscription.SalesRepID__c);
    }

    // Sales Rep Change
    if(String.isNotBlank(currentSubscription.RSD_ID__c)) {
      repIdSet.add(currentSubscription.RSD_ID__c);
    }

    return repIdSet;
  }

  /**
   *   Method used to find Rep Id values for three specific fields on the Subscription object. These Id values are then
   *   used to find the corresponding User in the system and add that Salesforce ID to the User lookup field corresponding
   *   to the correct Rep Id
   *
   *   NOTE: This is an overloaded method specifically used for UPDATE logic
   *
   *   @author Jusitn
   *   @date   2017-08-04
   *   @param  {Zuora__Subscription__c}      currentSubscription The current subscription that is being used to find the
   *                                                             values
   *   @return {Set<String>}                                     The set of Rep Id values that was found
   */ 
  private static Set<String> findSubRepId(Zuora__Subscription__c currentSubscription, Zuora__Subscription__c previousSubscription) {
    Set<String> repIdSet = new Set<String>();

    // Renewal Rep Change
    if(String.isNotBlank(currentSubscription.RenewalRepId__c) && currentSubscription.RenewalRepId__c != previousSubscription.RenewalRepId__c) {
        repIdSet.add(currentSubscription.RenewalRepId__c);
    }

    if(String.isNotBlank(currentSubscription.Renewal_Rep__c) && currentSubscription.Renewal_Rep__c != previousSubscription.Renewal_Rep__c) {
        repIdSet.add(currentSubscription.Renewal_Rep__c);
    }

    // Reporting Rep Change
    if(String.isNotBlank(currentSubscription.ReportingRepId__c) && currentSubscription.ReportingRepId__c != previousSubscription.ReportingRepId__c) {
        repIdSet.add(currentSubscription.ReportingRepId__c);
    }

    if(String.isNotBlank(currentSubscription.Reporting_Rep__c) && currentSubscription.Reporting_Rep__c != previousSubscription.Reporting_Rep__c) {
        repIdSet.add(currentSubscription.Reporting_Rep__c);
    }
    
    // Sales Rep Change
    if(String.isNotBlank(currentSubscription.SalesRepID__c) && currentSubscription.SalesRepID__c != previousSubscription.SalesRepID__c) {
        repIdSet.add(currentSubscription.SalesRepID__c);
    }

    if(String.isNotBlank(currentSubscription.Sales_Rep__c) && currentSubscription.Sales_Rep__c != previousSubscription.Sales_Rep__c) {
        repIdSet.add(currentSubscription.Sales_Rep__c);
    }

    // RSD Change
    if(String.isNotBlank(currentSubscription.RSD_Id__c) && currentSubscription.RSD_Id__c != previousSubscription.RSD_Id__c) {
        repIdSet.add(currentSubscription.RSD_Id__c);
    }

    if(String.isNotBlank(currentSubscription.RSD__c) && currentSubscription.RSD__c != previousSubscription.RSD__c) {
        repIdSet.add(currentSubscription.RSD__c);
    }

    return repIdSet;
  }
}