public without sharing class CampaignMemberTriggerHandler implements XOTrigger{
    // CSP-3040 | Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
    private Map<Id,Lead> needUpdateLeadMap = new Map<Id,Lead>();
    private Map<Id,Account> needUpdateAccountMap = new Map<Id,Account>();

    private Map<Id,Id> leadIdMatchingCamMemberIdMap = new Map<Id,Id>();
    private Map<Id,Id> accIdmatchingCamMemberIdMap = new Map<Id,Id>();
  
    // CSP-2825 Re-engage an Account
    // Store CampaignMember and parent object info 
    private Map<Id,CampaignMember> camMemberMap = new Map<Id,CampaignMember>();
    private static final Id distactAccountId;
    private static final String dataEnrichmentUserId = Label.DataEnrichmentUserId; 
    private static final Id bridalSalonCategoryId;
    private static final List<String> QUEUE_NAME_LIST = new List<String>{'Data Enrichment', 'Distributable', 'Dead Queue'};
    private List<Lead> leadsToBeUpdatedList = new List<Lead>();
    Map<Id, Lead> idToLeadMap = new Map<Id, Lead>();
    Map<Id, Account> idToAccountMap = new Map<Id, Account>();
    Map<Id, Lead> idToLeadHotProspectMap = new Map<Id, Lead>();
    Map<Id, Account> idToAccountHotProspectMap = new Map<Id, Account>();
    private final Map<String, Group> QUEUE_NAME_MAP; 
    private List<XO_Exception__c> exceptionList; 
    private Map<Id, Campaign> idToCampaignRecordMap;
    private Set<String> hotLeadSourcesSet; 
    private final List<User> USER_OBJ_LIST;
    private final User DISTRIBUTABLE_ACCOUNT_USER; 
    private static final Id callieThomasUserId;

    private static final String LEAD_QUERY = 'SELECT '
                                                  + 'Id, '
                                                  + 'OwnerId, '
                                                  + 'Local_Sales_Market__c, '
                                                  + 'Primary_Category__c, '
                                                  + 'PostalCode, '
                                                  + 'CountryCode, '
                                                  + 'LeadSource, '
                                                  + 'Status, '
                                                  + 'Negative_Disposition_Reason__c, '
                                                  + 'Reason_Details__c '
                                              + ' FROM '
                                                  + ' Lead '
                                              + ' WHERE '
                                                  + ' {WHERECLAUSE} ';

    private static final String ACCOUNT_QUERY = 'SELECT '
                                                  + 'Id, '
                                                  + 'Local_Sales_Market__c, '
                                                  + 'Primary_Category__c, '
                                                  + 'BillingPostalCode, '
                                                  + 'BillingCountryCode, '
                                                  + 'Account_Status__c '
                                            + ' FROM '
                                                  + ' Account '
                                            + ' WHERE '
                                                  + ' {WHERECLAUSE} ';

    private static final String CAMPAIGN_QUERY = 'SELECT '
                                                  + 'Id, '
                                                  + 'Type '
                                              + ' FROM '
                                                  + ' Campaign '
                                              + ' WHERE '
                                                  + ' {WHERECLAUSE} ';   

    static {

        List<XO_Exception__c> exceptionList = new List<XO_Exception__c>();

        try {
            for (User currentUser : [SELECT Id,Name,Alias FROM User WHERE Alias = 'distacts' AND IsActive = true]) {
                distactAccountId = currentUser.Id;
            }
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            xoException.Severity__c = 'Critical';
            xoException.Failure_Area__c = 'Lead Assignment Workflow Exception';
            exceptionList.add(xoException);
        }

        try {
            Category__c bridalSalonCatRec = [SELECT Id FROM Category__c WHERE Name = 'Bridal Salons - BWP' Limit 1];
            if(bridalSalonCatRec != null) {
                bridalSalonCategoryId = bridalSalonCatRec.Id;
            }
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            xoException.Severity__c = 'Critical';
            xoException.Failure_Area__c = 'Lead Assignment Workflow Exception';
            exceptionList.add(xoException);
        }

        try {
          User CALLIE_THOMAS_USER = [Select Id, Profile.Name, Alias From User Where Alias = 'cthomas' Limit 1]; 
          callieThomasUserId = CALLIE_THOMAS_USER.Id;
        } catch (Exception e) {
          XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
          exceptionList.add(xoException);
        }
        insert exceptionList;
    }

    public CampaignMemberTriggerHandler() {
        try {
          this.hotLeadSourcesSet = this.getHotLeadSources();

          List<Group> grplst = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN: QUEUE_NAME_LIST];
          this.QUEUE_NAME_MAP = new Map<String, Group>();
          if(!grplst.isEmpty()) {
              for(Group grp: grplst) {
                  this.QUEUE_NAME_MAP.put(grp.Name, grp);
              }
          }  
        } catch (Exception e) {
          XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }   

        this.USER_OBJ_LIST = [SELECT id, CreatedById, Profile.Name, UserRole.Name, Alias FROM User WHERE id = : UserInfo.getUserId()];
    }
    
    /**
     * Method used to bulkify all data needed in any "before" action of a trigger.
     */
    public void bulkBefore() {
    }

    /**
     *   Method used to bulkify all data needed in any "after" action of a trigger.
     */
    public void bulkAfter() {

        // CSP-2825 Re-engage an Account
        // Merge insert and update for query Campaign Member and parent object info 
        if(trigger.isInsert || trigger.isUpdate) {
            List<Account> accountList = new List<Account>();
            Set<Id> leadIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            List<Lead> leadRecordList = new List<Lead>();
            Set<Id> campaignIdSet = new Set<Id>();
            Set<Id> hotProspectLeadIdSet = new Set<Id>();
            Set<Id> hotProspectAccountIdSet = new Set<Id>();
           
            // CSP-2825 Re-engage an Account
            // CSP-2645 Reassign Existing Paid Media Prospects to Distributable queue
            // CSP-2616 Hot Campaigns & DE
            // Get CampaignMember and parent object info 
            camMemberMap = new map<id,CampaignMember>([SELECT Id, CampaignId, Campaign.IsActive, LeadId, Campaign.Notify_Sales_Team__c, Campaign.Type, ContactId, 
                                                              Lead.RecordType.Name, Lead.Status, HasResponded, Contact.Account.DE_Backlog__c,
                                                              lead.DE_Backlog__c, Lead.Related_to_Paid_Media__c, Lead.IsConverted,  
                                                              Contact.AccountId, Contact.Account.Portfolio__c, Contact.Account.BillingPostalCode,
                                                              Contact.Account.Local_Paid_Status__c, Contact.Account.Related_to_Paid_Media__c, Contact.Name,
                                                              Contact.Account.Zip__r.ZipCode__c, Contact.Account.Local_Sales_Market__c, Contact.Account.Primary_Category__c, 
                                                              Contact.Account.RecordType.Name, Contact.Account.Account_Status__c, Status,Contact.Account.BillingCountryCode  
                                                      FROM CampaignMember 
                                                      WHERE Id IN: trigger.new]);
            
            for(CampaignMember camMember : camMemberMap.values()) {

                campaignIdSet.add(camMember.CampaignId);
                //Get all Local Account list if Campaign Member under contact 
                if(hasLocalAccount(camMember)){
                    Account camMemberAcc = camMember.Contact.Account;
                    accountList.add(camMemberAcc);
                }
                /**
                 *  CSP-3040 | Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
                 *  When Hubspot syncs information with Salesforce and a prospect has newly responded to both a paid media campaign and a hot campaign, 
                 *  the prospect routing logic for the paid media campaign should take precedence.
                 *  We need to update related lead and account when a propect has newly responded a hot campaign.
                 */
                if(hasHotCampaign(camMember)){                  
                  if(hasLocalUnconvertedLead(camMember) && !leadIdMatchingCamMemberIdMap.containsKey(camMember.LeadId)){
                    leadIdMatchingCamMemberIdMap.put(camMember.LeadId, camMember.Id);
                  }
                  
                  if(hasLocalAccount(camMember) && !accIdMatchingCamMemberIdMap.containsKey(camMember.Contact.AccountId)){
                    accIdMatchingCamMemberIdMap.put(camMember.Contact.AccountId, camMember.Id);
                  }
                }
                //A paid media campaign takes precedence over a hot campaign
                if(hasPaidMediaCampaign(camMember)){                  
                  if(hasLocalUnconvertedLead(camMember)){
                    leadIdMatchingCamMemberIdMap.put(camMember.LeadId, camMember.Id);
                  }
                  
                  if(hasLocalAccount(camMember)){
                    accIdMatchingCamMemberIdMap.put(camMember.Contact.AccountId, camMember.Id);
                  }
                }

                if(prospectAssociatedWithPMCampaign(camMember, camMember.Campaign.Type)) {
                  if(String.isNotBlank(camMember.Contact.AccountId)) {
                    accountIdSet.add(camMember.Contact.AccountId);
                  } else if(String.isNotBlank(camMember.LeadId)) {
                    leadIdSet.add(camMember.LeadId);
                  }
                }

                if(checkForHotProspect(camMember, camMember.Campaign.Type)) {
                  if(String.isNotBlank(camMember.Contact.AccountId)) {
                    hotProspectAccountIdSet.add(camMember.Contact.AccountId);
                  } else if(String.isNotBlank(camMember.LeadId)) {
                    hotProspectLeadIdSet.add(camMember.LeadId);
                  }
                }
            }
            
            System.debug(LoggingLevel.INFO, '*** leadIdMatchingCamMemberIdMap: ' + leadIdMatchingCamMemberIdMap);
            //Build Assignment Map
            if(!accountList.isEmpty()) {
              AssignmentRulesUtility.buildAssignmentMap(accountList);
            }

            populateDataForLeadAssignments(leadIdSet, hotProspectLeadIdSet);

            populateDataForAccountAssignments(accountIdSet, hotProspectAccountIdSet);

            if(!campaignIdSet.isEmpty()) {
                idToCampaignRecordMap = new Map<Id, Campaign>((List<Campaign>)Database.query(CAMPAIGN_QUERY.replace('{WHERECLAUSE}', 'Id IN :campaignIdSet')));
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
    public void beforeInsert(SObject so) {}

    /**
    *   All before update logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentially hit limits or is considered bad practice
    *   in the Salesforce environment.
    *
    *   @param  {SObject}   oldSo Single SObject representation of the "old" copy of the current 
    *                             object being acted upon.
    *   @param  {SObject}   so    Single SObject representation of the object being acted upon.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {}

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

        CampaignMember newMember = (CampaignMember)so;

        if(camMemberMap.containsKey(newMember.id)) {
            CampaignMember camMember = camMemberMap.get(newMember.id);

            // Campaign Member under lead
            // CSP-2645 merge the code of CSP-2616, if the a lead or a contact has been associate to a paid media campaign, 
            // Update the Related_to_Paid_Media__c of the lead and account. update the DE_Backlog__c of lead when lead has been associated to 
            // a Campaign need to Notify_Sales_Team 
            if( hasLocalUnconvertedLead(camMember)
              // we do not need to update the lead if leadIdMatchingCamMemberIdMap doesn't contain it 
              && leadIdMatchingCamMemberIdMap.containsKey(camMember.LeadId)
              // needUpdateLeadMap is used to avoid update leads repeatedly
              && !needUpdateLeadMap.containsKey(camMember.LeadId)
              && leadIdMatchingCamMemberIdMap.get(camMember.LeadId) == camMember.Id) {
              
              Lead newLead = new Lead();
              newLead.Id = camMember.LeadId;

              //CSP-3040 - Paid Media Campaign takes precedence over hot campaign
              if(hasPaidMediaCampaign(camMember)){

                //CSP-2645 - Update the Related_to_Paid_Media__c of the lead and account
                newLead.Related_to_Paid_Media__c = true;

                //CSP-2645 - update the DE_Backlog__c of lead when lead has been associated to a Campaign need to Notify_Sales_Team 
                if(camMember.Campaign.Notify_Sales_Team__c == true && camMember.Lead.DE_Backlog__c == true ){
                  newLead.DE_Backlog__c = false;
                }

              }
              // CSP-2851 Hot Prospect Treatments - Fast-Track
              // hot campaign means Campaign.Notify_Sales_Team__c = true or Internal Referral campaigns that a prospect responded 
              else if(hasHotCampaign(camMember)){

                //CSP-2851 - set DE Backlog to false for leads
                newLead.DE_Backlog__c = false;

                //if the record is a Lead whose status is not "Invalid" or "Disqualified"
                if(camMember.Lead.Status != 'Invalid' && camMember.Lead.Status != 'Disqualified'){
                  //CSP-2851 - the Lead Status is updated to "Valid" if it was "New"
                  if(camMember.Lead.Status == 'New'){
                    newLead.Status = 'Valid';
                    if(newLead.Negative_Disposition_Reason__c != null) {
                      newLead.Negative_Disposition_Reason__c = '';
                      newLead.Reason_Details__c = '';
                    }
                  }
                  //newLead.HotCampaign__c = True; // CSP-3042 SIVA VANKADARU 08/10/208
                }
              }
              
              needUpdateLeadMap.put(newLead.Id, newLead);
            }

            // CSP-2836 Hubspot updating owner on paid accounts after lead merge
            // Change the account owner to distact only if the Account Local Paid Status is not "Paid"
            // CSP-2825 Re-engage an Account
            // Change the account owner and Account Status if the Account Status is not "Active"
            // Campaign Member under Contact 
            if( hasLocalAccount(camMember)
              && accIdMatchingCamMemberIdMap.containsKey(camMember.Contact.AccountId)
              && !needUpdateAccountMap.containsKey(camMember.Contact.AccountId)
              && accIdMatchingCamMemberIdMap.get(camMember.Contact.AccountId) == camMember.Id) {

              Account camMemberAcc = camMember.Contact.Account;

              //Paid Media Campaign
              if(hasPaidMediaCampaign(camMember)){
                camMemberAcc.Related_to_Paid_Media__c = true;
                camMemberAcc = setAccountStatus(camMemberAcc);
              }
              // CSP-2851 Hot Prospect Treatments - Fast-Track
              else if(hasHotCampaign(camMember)){

                //CSP-2851,CSP-2872 - the DE Backlog flag is set to "False"
                camMemberAcc.DE_Backlog__c = false;
                camMemberAcc = setAccountStatus(camMemberAcc);
              }
              needUpdateAccountMap.put(camMemberAcc.Id, camMemberAcc);
            }


            this.paidMediaAndHotProspectRouting(camMember);
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
        CampaignMember newMember = (CampaignMember)so;
        CampaignMember oldMember = (CampaignMember)oldSo;

        if(camMemberMap.containsKey(newMember.id)) {
            CampaignMember currentMember = camMemberMap.get(newMember.id);

            if(hasLocalUnconvertedLead(currentMember)) {

              Lead newLead = new Lead();
              newLead.Id = currentMember.LeadId;
              // CSP-2851 Hot Prospect Treatments - Fast-Track
              if(currentMember.Status != oldMember.Status && hasHotCampaign(currentMember)){

                // set DE Backlog to false for leads
                newLead.DE_Backlog__c = false;

                //if the record is a Lead whose status is not "Invalid" or "Disqualified"
                if(currentMember.Lead.Status != 'Invalid' && currentMember.Lead.Status != 'Disqualified'){
                  //the Lead Status is updated to "Valid" if it was "New"
                  if(currentMember.Lead.Status == 'New'){
                    newLead.Status = 'Valid';
                    if(newLead.Negative_Disposition_Reason__c != null) {
                      newLead.Negative_Disposition_Reason__c = '';
                      newLead.Reason_Details__c = '';
                    }
                  }
                }         
              }
              needUpdateLeadMap.put(newLead.Id, newLead);
            }

            if(hasLocalAccount(currentMember)) {

              Account camMemberAcc = currentMember.Contact.Account;

              // CSP-2851 Hot Prospect Treatments - Fast-Track 
              if(currentMember.Status != oldMember.Status && hasHotCampaign(currentMember)){

                //CSP-2851 - the DE Backlog flag is set to "False"
                camMemberAcc.DE_Backlog__c = false;

                // CSP-2825 Re-engage an Account
                // Change the account owner and Account Status by responding to an Internal Referral Campaign 
                if(currentMember.Contact.Account.Account_Status__c != 'Active'){
                  camMemberAcc = setAccountStatus(camMemberAcc);   
                  camMemberAcc = accOwnerAssignment(camMemberAcc);

                }
              }
              needUpdateAccountMap.put(camMemberAcc.Id, camMemberAcc);
            }
            this.paidMediaAndHotProspectRouting(currentMember);  
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
    public void beforeAndFinally() {}


    /**
    *   All final logic in the "after" context should be done at this point such as modification to objects outside of
    *   the current object. At this point all updates to the current trigger transaction should be
    *   complete and all validation done.
    */
    public void afterAndFinally() {
        List<XO_Exception__C> xoExceptionList = new List<XO_Exception__C>();
        
        //CSP-2616 logic End, Update lead DE backlog
        if(!needUpdateLeadMap.isEmpty()){
            List<Database.SaveResult> resultList = Database.update(needUpdateLeadMap.values(), false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
        }

        //CSP-2825 Re-engage an Account 
        //Update Account owner and Account status
        if(!needUpdateAccountMap.isEmpty()){
            List<Database.SaveResult> resultList = Database.update(needUpdateAccountMap.values(), false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
        }

        if(!xoExceptionList.isEmpty()){
          insert xoExceptionList;
        }
    }

    private void paidMediaAndHotProspectRouting(CampaignMember camMember) {
       if(camMember.Contact.Account.Account_Status__c != 'Active' && camMember.Contact.Account.Account_Status__c != 'In Opportunity'){

            if(idToCampaignRecordMap.containsKey(camMember.CampaignId) && idToCampaignRecordMap.get(camMember.CampaignId).Type != null) {

                if(!idToAccountMap.isEmpty()) {
                    if(prospectAssociatedWithPMCampaign(camMember, idToCampaignRecordMap.get(camMember.CampaignId).Type) && idToAccountMap.containsKey(camMember.Contact.AccountId)) {
                        this.paidMediaAssignmentForAccount(camMember, idToAccountMap);                           
                    }                  
                }

                if(!idToAccountHotProspectMap.isEmpty()) {
                    if(checkForHotProspect(camMember, idToCampaignRecordMap.get(camMember.CampaignId).Type) && idToAccountHotProspectMap.containsKey(camMember.Contact.AccountId)) {
                        this.hotProspectAssignmentForAccount(camMember, idToAccountHotProspectMap);                    
                    } 
                }

                if(!idToLeadMap.isEmpty()) {
                    if(prospectAssociatedWithPMCampaign(camMember, idToCampaignRecordMap.get(camMember.CampaignId).Type) && idToLeadMap.containsKey(camMember.LeadId)) {
                        this.paidMediaAssignmentForLead(camMember, idToLeadMap);                           
                    } 
                }

                 if(!idToLeadHotProspectMap.isEmpty()) {
                    if(checkForHotProspect(camMember, idToCampaignRecordMap.get(camMember.CampaignId).Type) && idToLeadHotProspectMap.containsKey(camMember.LeadId)) {
                        this.hotProspectAssignmentForLead(camMember, idToLeadHotProspectMap);                    
                    } 
                }
            }
        }
    }

    private void populateDataForLeadAssignments(Set<Id> leadIdSet, Set<Id> hotProspectLeadIdSet) {
        // csp-3233: preparing data for paid media assignment
        if(!leadIdSet.isEmpty()) {
            idToLeadMap = new Map<Id, Lead>((List<Lead>)Database.query(LEAD_QUERY.replace('{WHERECLAUSE}', 'Id IN :leadIdSet')));
            AssignmentRulesUtility.buildAssignmentMap(idToLeadMap.values());
        }

        if(!hotProspectLeadIdSet.isEmpty()) {
            idToLeadHotProspectMap = new Map<Id, Lead>((List<Lead>)Database.query(LEAD_QUERY.replace('{WHERECLAUSE}', 'Id IN :hotProspectLeadIdSet')));
            AssignmentRulesUtility.buildAssignmentMap(idToLeadHotProspectMap.values());
        }
    }

    private void populateDataForAccountAssignments(Set<Id> accountIdSet, Set<Id> hotProspectAccountIdSet) {
        if(!accountIdSet.isEmpty()) {
            idToAccountMap = new Map<Id, Account>((List<Account>)Database.query(ACCOUNT_QUERY.replace('{WHERECLAUSE}', 'Id IN :accountIdSet')));
            AssignmentRulesUtility.buildAssignmentMap(idToAccountMap.values());
        }

        if(!hotProspectAccountIdSet.isEmpty()) {
            idToAccountHotProspectMap = new Map<Id, Account>((List<Account>)Database.query(ACCOUNT_QUERY.replace('{WHERECLAUSE}', 'Id IN :hotProspectAccountIdSet')));
            AssignmentRulesUtility.buildAssignmentMap(idToAccountHotProspectMap.values());
        }
    }

    // csp-3233
    private void paidMediaAssignmentForLead(CampaignMember currentMember, Map<Id, Lead> idToLeadMap) {
        Lead leadRec = leadFieldAssignments(currentMember, idToLeadMap);

        if(idToLeadMap.get(currentMember.LeadId).Primary_Category__c == bridalSalonCategoryId) {
            paidMediaBridalSalonAssignmentForLead(currentMember, leadRec);            
        } else {
            paidMediaNonBridalSalonAssignmentForLead(leadRec);            
        }
    }

    // csp-3233
    private void paidMediaBridalSalonAssignmentForLead(CampaignMember currentMember, Lead leadRec) {
      AssignmentRulesUtility assgnmentRulesUtil = new AssignmentRulesUtility();

      if(leadRec.Status == 'Working' || leadRec.Status == 'Qualified' || leadRec.Status == 'Valid') {
        return;
      }

      Local_Sales_Rep_Assignment__c localSalesRepAssignmentRecord = assgnmentRulesUtil.getRecordAssignmentForPaidMedia(leadRec);
      
      if(localSalesRepAssignmentRecord != null && localSalesRepAssignmentRecord.Sales_Rep__c != null) {
          leadRec.OwnerId = localSalesRepAssignmentRecord.Sales_Rep__c;
          leadRec.Status = 'Valid';

          if(leadRec.Negative_Disposition_Reason__c != null) {
            leadRec.Negative_Disposition_Reason__c = '';
            leadRec.Reason_Details__c = '';
          }

      } else {
          if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
              leadRec.OwnerId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
          }
          leadRec.Status = 'Invalid';
          leadRec.Negative_Disposition_Reason__c = 'Missing Required Information';
          
      }
      needUpdateLeadMap.put(leadRec.Id, leadRec);   
    }

    private void paidMediaAssignmentForAccount(CampaignMember currentMember, Map<Id, Account> idToAccountMap) {
        String accountStatus = idToAccountMap.get(currentMember.Contact.AccountId).Account_Status__c;
        Account accountRec = accountFieldAssignments(currentMember, idToAccountMap);        
        if(accountStatus == 'Working' || accountStatus == 'Qualified' || accountStatus == 'Disqualified' || accountStatus == 'Dormant') {
            accountRec.Account_Status__c = 'Qualified';
        }

        if(idToAccountMap.get(currentMember.Contact.AccountId).Primary_Category__c == bridalSalonCategoryId) {
            paidMediaBridalSalonAssignmentForAccount(currentMember, accountRec);            
        } else {
            paidMediaNonBridalSalonAssignmentOnAccount(accountRec);            
        }
    }

    // csp-3233
    private void paidMediaNonBridalSalonAssignmentForLead(Lead leadRec) {
      leadRec.DE_Backlog__c = false;
      leadRec.Status = 'Valid';
      leadRec.Related_to_Paid_Media__c = true;
      
      if(leadRec.Negative_Disposition_Reason__c != null) {
            leadRec.Negative_Disposition_Reason__c = '';
            leadRec.Reason_Details__c = '';
          }

      if(QUEUE_NAME_MAP.containsKey('Distributable')) {
          leadRec.OwnerId = QUEUE_NAME_MAP.get('Distributable').Id;
      }
      needUpdateLeadMap.put(leadRec.Id, leadRec);      
    }
    
    // csp-3233
    private void hotProspectAssignmentForLead(CampaignMember currentMember, Map<Id, Lead> idToLeadHotProspectMap) {
      
      if(idToLeadHotProspectMap.containsKey(currentMember.LeadId)) {

        String leadStatus = idToLeadHotProspectMap.get(currentMember.LeadId).Status;
        Id leadOwnerId = idToLeadHotProspectMap.get(currentMember.LeadId).ownerId;

        //if((leadStatus == 'Working' || leadStatus == 'Qualified' || leadStatus == 'Valid') && this.USER_OBJ_LIST[0].Alias != 'hubsvc'){
        if((leadStatus == 'Working' || leadStatus == 'Qualified' || leadStatus == 'Valid') && leadOwnerId != this.USER_OBJ_LIST[0].Id){
          return;
        } 
        Lead leadRec = leadFieldAssignments(currentMember, idToLeadHotProspectMap);        
        leadRec.DE_Backlog__c = false;
        leadRec.Status = 'Valid';

        if(leadRec.Negative_Disposition_Reason__c != null) {
          leadRec.Negative_Disposition_Reason__c = '';
          leadRec.Reason_Details__c = '';
        }
   
        ownerAssignmentForLead(leadRec);
        needUpdateLeadMap.put(leadRec.Id, leadRec);
      }
    }

    private void paidMediaBridalSalonAssignmentForAccount(CampaignMember currentMember, Account accountRec) {
      AssignmentRulesUtility assgnmentRulesUtil = new AssignmentRulesUtility();
      Local_Sales_Rep_Assignment__c localSalesRepAssignmentRecord = assgnmentRulesUtil.getRecAssignmentForPaidMediaOnAccount(accountRec);

      if(localSalesRepAssignmentRecord != null && localSalesRepAssignmentRecord.Sales_Rep__c != null) {
          accountRec.OwnerId = localSalesRepAssignmentRecord.Sales_Rep__c;
      } else {
          accountRec.OwnerId = callieThomasUserId; 
          accountRec.Account_Status__c = 'Dormant';
          accountRec.Negative_Disposition_Reason__c = 'Missing Required Information';          
      }
      needUpdateAccountMap.put(accountRec.Id, accountRec);   
    }

    private void paidMediaNonBridalSalonAssignmentOnAccount(Account accountRec) {
      accountRec.Related_to_Paid_Media__c = true;
      
      if(accountRec.Negative_Disposition_Reason__c != null) {
          accountRec.Negative_Disposition_Reason__c = '';
      }
      accountRec.OwnerId = distactAccountId;
      needUpdateAccountMap.put(accountRec.Id, accountRec);      
    }

    private void hotProspectAssignmentForAccount(CampaignMember currentMember, Map<Id, Account> idToAccountHotProspectMap) {
      
      if(idToAccountHotProspectMap.containsKey(currentMember.Contact.AccountId)) {

        String accountStatus = idToAccountHotProspectMap.get(currentMember.Contact.AccountId).Account_Status__c;
        Account accountRec = accountFieldAssignments(currentMember, idToAccountHotProspectMap);

        accountRec.DE_Backlog__c = false;

        if(accountStatus != 'Working' && accountStatus != 'Qualified') {
            if(accountRec.Negative_Disposition_Reason__c != null) {
                accountRec.Negative_Disposition_Reason__c = '';
            }
            ownerAssignmentForAccount(accountRec);
        }

        if(accountStatus == 'Working' || accountStatus == 'Qualified' || accountStatus == 'Disqualified' || accountStatus == 'Dormant') {
            accountRec.Account_Status__c = 'Qualified';
        }

        needUpdateAccountMap.put(accountRec.Id, accountRec);
      }
    }

    public void ownerAssignmentForLead(Lead leadRec) {
        if(leadRec.Status == 'New' &&  this.getHotLeadSources().contains(leadRec.LeadSource)) {
            leadRec.Status = 'Valid'; 

            if(leadRec.Negative_Disposition_Reason__c != null) {
              leadRec.Negative_Disposition_Reason__c = '';
              leadRec.Reason_Details__c = '';
            }
            
            leadRec.Valid_Status_Time_Stamp__c = System.now();
            leadRec.OwnerId = this.USER_OBJ_LIST[0].Id; // fast path lead
            return;
        }

        if((leadRec.Primary_Category__c == null) && (leadRec.Local_Sales_Market__c == null) && (leadRec.Zip__c == null)) {
            leadRec.OwnerId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
            leadRec.Status = 'Invalid';
            leadRec.Negative_Disposition_Reason__c = 'Missing Required Information';
            return;
        }

        LeadDomain domain = new LeadDomain();
        // if(!domain.validateCatMarketZip(leadRec)) {
        //     return;
        // }

        Local_Sales_Rep_Assignment__c localSalesRepAssignmentRec = AssignmentRulesUtility.getRecordAssignment(leadRec);
        
        if((localSalesRepAssignmentRec  == null) || (localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Sales_Rep__c == null && localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c == null)) {
            if(this.QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                leadRec.OwnerId = this.QUEUE_NAME_MAP.get('Data Enrichment').Id;
            }
        }

        // if Sales Rep on LSRA does exist, update the owner to point to the Sales rep and also create Assignment History records
        if(localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Sales_Rep__c != null) {
            leadRec.OwnerId = localSalesRepAssignmentRec.Sales_Rep__c;
            domain.createAssignmentHistoryRecords(localSalesRepAssignmentRec.Id, leadRec);
        }
        else if(localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c != null) {
            leadRec.OwnerId = localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c;
            domain.createAssignmentHistoryRecords(localSalesRepAssignmentRec.Id, leadRec);
        }

        if(leadRec.Local_Partners_Claiming__c) {
            leadRec.OwnerId = this.DISTRIBUTABLE_ACCOUNT_USER.Id;
        }
    }

    public void ownerAssignmentForAccount(Account accountRec) {
        if(!validateCatMarketZip(accountRec)) {
            return;
        }

        Local_Sales_Rep_Assignment__c localSalesRepAssignmentRec = AssignmentRulesUtility.getRecordAssignment(accountRec);

        // if Sales Rep on LSRA does exist, update the owner to point to the Sales rep and also create Assignment History records
        if(localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Sales_Rep__c != null) {
            accountRec.OwnerId = localSalesRepAssignmentRec.Sales_Rep__c;
        }

        if((localSalesRepAssignmentRec  == null) || (localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Sales_Rep__c == null)) {
            accountRec.OwnerId = distactAccountId; 
        }
    }

    public Boolean validateCatMarketZip(Account accountRec) {
        if((accountRec.Primary_Category__c == null) && (accountRec.Local_Sales_Market__c == null) && (accountRec.Zip__c == null)) {
            accountRec.OwnerId = callieThomasUserId; 
            accountRec.Account_Status__c = 'Dormant';
            accountRec.Negative_Disposition_Reason__c = 'Missing Required Information';
            return false;
        }
        return true;    
    }
    
    private Set<String> getHotLeadSources() {
        // query custom metdata types to retrieve hot lead sources
        List<Hot_Lead_Source__mdt> hotLeadSourcesMDT = [Select MasterLabel from Hot_Lead_Source__mdt];
        Set<String> hotLeadSourcesSet = new Set<String>();

        for(Hot_Lead_Source__mdt currentHotLeadSourceMdt : hotLeadSourcesMDT) {
            hotLeadSourcesSet.add(currentHotLeadSourceMdt.MasterLabel);
        }
        return hotLeadSourcesSet;
    }

     private Lead leadFieldAssignments(CampaignMember currentMember, Map<Id, Lead> idToLeadMap) {        
        Lead leadRecord = idToLeadMap.get(currentMember.LeadId);
        Lead leadRec = new Lead();
        leadRec.Id = currentMember.LeadId;
        leadRec.Primary_Category__c = leadRecord.Primary_Category__c;
        leadRec.Local_Sales_Market__c = leadRecord.Local_Sales_Market__c;
        leadRec.PostalCode = leadRecord.PostalCode;
        leadRec.CountryCode = leadRecord.CountryCode;
        leadRec.Negative_Disposition_Reason__c = leadRecord.Negative_Disposition_Reason__c;
        leadRec.Reason_Details__c = leadRecord.Reason_Details__c;

        return leadRec;
    }

    private Account accountFieldAssignments(CampaignMember currentMember, Map<Id, Account> idToAccountMap) {   
      Account accountRecord = idToAccountMap.get(currentMember.Contact.AccountId);
      Account accountRec = new Account();
      accountRec.Id = currentMember.Contact.AccountId;
      accountRec.Primary_Category__c = accountRecord.Primary_Category__c;
      accountRec.Local_Sales_Market__c = accountRecord.Local_Sales_Market__c;
      accountRec.BillingPostalCode = accountRecord.BillingPostalCode;
      accountRec.BillingCountryCode = accountRecord.BillingCountryCode;
      return accountRec;
    }

    //csp-3233
    private Boolean prospectAssociatedWithPMCampaign(CampaignMember camMember, String campaignType) {
      if(campaignType == 'Paid Media' && camMember.Status == 'Responded') { 
        return true;
      } 
      return false;
    }

    //csp-3233
    private Boolean checkForHotProspect(CampaignMember camMember, String campaignType) {
      if((campaignType == 'Internal Referral' || campaignType == 'Website') && camMember.Status == 'Responded') {
        return true;
      }
      if(camMember.Campaign.Notify_Sales_Team__c == true && camMember.Campaign.IsActive) {
        return true;
      }
      return false;
    }

    /**
     * CSP-3040 Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
     * If the campaignMember has a local unconverted lead, return true
     * 
     * @Author Steven
     * @Date   2018-08-13
     * @param  camMember
     * @return Boolean
     */
    private Boolean hasLocalUnconvertedLead(CampaignMember camMember) {
      Boolean hasLocalUnconvertedLead = false;
      if(camMember != null 
        && String.isNotBlank(camMember.LeadId) 
          && !camMember.Lead.IsConverted 
            && camMember.Lead.RecordType.Name.containsIgnoreCase('Local')){
        hasLocalUnconvertedLead = true;
      }
      return hasLocalUnconvertedLead;
    }

    /**
     * CSP-3040 Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
     * If the campaignMember has a local account, return true
     * 
     * @Author Steven
     * @Date   2018-08-13
     * @param  camMember
     * @return Boolean
     */
    private Boolean hasLocalAccount(CampaignMember camMember) {
      Boolean hasLocalAccount = false;
      if(camMember != null 
        && String.isNotBlank(camMember.ContactId) 
        && String.isNotBlank(camMember.Contact.AccountId) 
        && camMember.Contact.Account.RecordType.Name.equalsIgnoreCase('Local')){

        hasLocalAccount = true;
      }
      return hasLocalAccount;
    }

    /**
     * CSP-3040 Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
     * hot campaign means Campaign.Notify_Sales_Team__c = true or Internal Referral campaigns that a prospect responded
     * If the campaignMember has a hot campaign, return true
     * 
     * @Author Steven
     * @Date   2018-08-13
     * @param  camMember
     * @return Boolean
     */
    private Boolean hasHotCampaign(CampaignMember camMember) {
      Boolean hasHotCampaign = false;
      if(camMember != null && ((camMember.Campaign.Type == 'Internal Referral' && camMember.Status == 'Responded')
        || camMember.Campaign.Notify_Sales_Team__c)){

        hasHotCampaign = true;
      }
      return hasHotCampaign;
    }

    /**
     * CSP-3040 Salesforce Sync Error in Hubspot - paid media and hot campaign conflicting
     * If the campaignMember has a paid media campaign, return true
     * 
     * @Author Steven
     * @Date   2018-08-13
     * @param  camMember
     * @return Boolean
     */
    private Boolean hasPaidMediaCampaign(CampaignMember camMember) {
      Boolean hasPaidMediaCampaign = false;
      if(camMember != null && camMember.Campaign.Type == 'Paid Media'){
        
        hasPaidMediaCampaign = true;
      }
      return hasPaidMediaCampaign;
    }

    /**
     * CSP-2825 Re-engage an Account
     * Set Account Status to Qualified if it was dead or inactive
     * 
     * @Author Mason
     * @Date   2018-05-04
     * @param  acc
     * @return Account
     */
    private Account setAccountStatus(Account acc) {

        String accountStatus = acc.Account_Status__c;
        System.debug(LoggingLevel.INFO, '*** accountStatus: ' + accountStatus);
        //Updated to "Qualified" if it was dead or inactive
        if(String.isBlank(accountStatus) 
            || accountStatus == 'Disqualified'  
            || accountStatus == 'Dormant') {

            acc.Account_Status__c = 'Qualified';
            acc.Negative_Disposition_Reason__c = '';
        }
        return acc;
    }
    
      /**
       * CSP-2825 Re-engage an Account
     * Account owner Assignment
     *
     * * @Author Mason
     *   @Date   2018-05-21
     *   @param  acc
     *   @return Account
     */
    private Account accOwnerAssignment(Account acc) {
      Local_Sales_Rep_Assignment__c localSalesRepAssignmentRecord = AssignmentRulesUtility.getRecordAssignment(acc);

      if(localSalesRepAssignmentRecord != null) {
          // If there is an assignment record found, and have specific sales rep,
          // then will assign the account to this sales rep.
          if(localSalesRepAssignmentRecord.Sales_Rep__c != null) {
            acc.OwnerId = localSalesRepAssignmentRecord.Sales_Rep__c;
          }
          // CSP-3018 Re-engage an Account via DisE (when Sales Rep not assigned)
          // If there is an assignment record found, but the Sales rep is empty,
          // then it should assign out to distributable account.
          else{
            acc.OwnerId = distactAccountId;
          }
      }
      else {
          // If not find local user to do
          acc.OwnerId = dataEnrichmentUserId; 
          acc.Account_Status__c = 'Dormant';
          acc.Negative_Disposition_Reason__c = 'Missing Required Information';
      }
      return acc; 
    }
}