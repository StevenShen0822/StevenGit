public with sharing class LeadDomain extends Domain {

    private final List<String> QUEUE_NAME_LIST;  
    private final Map<String, Group> QUEUE_NAME_MAP; 
    private final List<CountryZipREGEX__c> countryRegExList; 
    private final Map<String, String> COUNTRY_AND_COUNTRYCODE_MAP;  
    private final Map<Id,Schema.RecordTypeInfo> RECORD_TYPE_BY_ID ; 
    private final Set<String> hotLeadSourcesSet; 
    private final Map<String, String> STATE_AND_STATECODE_MAP;
    private final Map<String, String> zipMarketMap; 
    private final List<User> userObjList;
    private final User hubspotUserRecord;
    private Map<String, Id> zipNameToIdMap;
    private List<XO_Exception__c> exceptionList; 
    private User DISTRIBUTABLE_ACCOUNT_USER; 

    public LeadDomain() {}

    public LeadDomain(List<Lead> leadList) {
        this.exceptionList = new List<XO_Exception__c>();
        this.COUNTRY_AND_COUNTRYCODE_MAP = new Map<String, String>(DataUtility.buildPicklistEntryMap('Lead','CountryCode'));
        this.STATE_AND_STATECODE_MAP = new Map<String, String>(DataUtility.buildPicklistEntryMap('Lead','StateCode'));
        this.QUEUE_NAME_LIST = new List<String>{'Data Enrichment', 'Distributable', 'Dead Queue'};
        this.RECORD_TYPE_BY_ID = Schema.SObjectType.Lead.getRecordTypeInfosById();
        this.QUEUE_NAME_MAP = new Map<String, Group>();
        this.zipMarketMap = this.createZipMarketMap();
        this.hotLeadSourcesSet = this.getHotLeadSources();
        this.zipNameToIdMap = new Map<String, Id>();
        this.populateAssignmentMap(Trigger.New);
        this.DISTRIBUTABLE_ACCOUNT_USER = new User();

        try {
            this.DISTRIBUTABLE_ACCOUNT_USER = [SELECT Alias FROM User WHERE Alias = 'distacts' Limit 1];
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }
        
        try {
            this.countryRegExList = [select Id, Name, Active__c, CountryCode__c, RegExPattern__c from CountryZipREGEX__c where Active__c = true];
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }

        try {
            this.userObjList = [SELECT id, CreatedById, Profile.Name, UserRole.Name FROM User WHERE id = : UserInfo.getUserId()];
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }

        try {
            this.hubspotUserRecord = [SELECT id, CreatedById, Profile.Name, UserRole.Name FROM User WHERE Name = 'Hubspot Service Account' Limit 1];
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }

        try {
            List<Group> grplst = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN: QUEUE_NAME_LIST];
            if(!grplst.isEmpty()) {
                for(Group grp: grplst) {
                    QUEUE_NAME_MAP.put(grp.Name, grp);
                }
            }  
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }   
    }

    public override void onBeforeInsert() {

        List<Lead> newLeadsList = (List<Lead>)Trigger.New;

        this.preventEditOnCreation(newLeadsList);

        this.phoneValidation(newLeadsList);
        this.zipValidation(newLeadsList);
        
        this.assignCountryCode(newLeadsList, null);
        this.assignStateCode(newLeadsList, null);
        this.assignCountryAndState(newLeadsList, null);
        this.assignDynamicsleadid(newLeadsList);
        this.assignCountry(newLeadsList);
        this.assignCitystate(newLeadsList, null);
        this.assignLocalSalesMarket(newLeadsList, null);
        this.assignFulfillstorefront(newLeadsList, null);
        this.assignStrategyspecialist(newLeadsList, null);
        
        this.routeLeads(newLeadsList, null);
        this.commitXOExceptions();
    }

    public override void onBeforeUpdate() {

        Map<Id, Lead> idToOldLeadMap = (Map<Id, Lead>)Trigger.oldMap;
        List<Lead> newLeadsList = (List<Lead>)Trigger.New;

        this.assignCountryCode(newLeadsList, idToOldLeadMap);
        this.assignStateCode(newLeadsList, idToOldLeadMap);
        this.assignCountryAndState(newLeadsList, idToOldLeadMap);
        this.assignDynamicsleadid(newLeadsList);
        this.assignCountry(newLeadsList);
        this.assignCitystate(newLeadsList, idToOldLeadMap);
        this.assignLocalSalesMarket(newLeadsList, idToOldLeadMap);
        this.assignFulfillstorefront(newLeadsList, idToOldLeadMap);
        this.assignStrategyspecialist(newLeadsList, idToOldLeadMap);
        
        this.populateSalesforceGeneratedGUID(newLeadsList, idToOldLeadMap);        
        this.routeLeads(newLeadsList, idToOldLeadMap);
        this.invalidLeads(newLeadsList);
        this.disqualifiedLeads(newLeadsList);
        this.populatePreviousOwner(newLeadsList, idToOldLeadMap);
        this.commitXOExceptions();
    }

    public override void onAfterInsert() {
        this.scoringLeads(Trigger.New, null);
        this.commitXOExceptions();      
    }

    public override void onAfterUpdate() {  
        Map<Id, Lead> idToOldLeadMap = (Map<Id, Lead>)Trigger.oldMap;
        List<Lead> newLeadsList = (List<Lead>)Trigger.New;
        
        this.scoringLeads(newLeadsList, idToOldLeadMap);
        this.createAccountContactRole(newLeadsList, idToOldLeadMap);
        this.cloneFeeds(newLeadsList, idToOldLeadMap);
        this.updateEndorsement(newLeadsList);
        this.commitXOExceptions();
    }

    private void populateSalesforceGeneratedGUID(List<Lead> leadsList, Map<Id, Lead> idToOldLeadMap) {
        for(Lead leadRec : leadsList) {
            if(leadRec.DynamicsLeadID__c != idToOldLeadMap.get(leadRec.Id).DynamicsLeadID__c && leadRec.DynamicsLeadID__c != null && idToOldLeadMap.get(leadRec.Id).DynamicsLeadID__c != null 
                && idToOldLeadMap.get(leadRec.Id).Salesforce_Generated_GUID__c){
                leadRec.Salesforce_Generated_GUID__c = false;
            }
        }
    }

    private void assignCountryCode(List<Lead> leadsList, Map<Id, Lead> idToOldLeadMap) {
        for(Lead leadRec : leadsList) {

            if(String.isNotBlank(leadRec.Country) && COUNTRY_AND_COUNTRYCODE_MAP.containsKey(leadRec.Country)) {
                if(idToOldLeadMap == null) {
                    if(String.isBlank(leadRec.CountryCode)) {
                        leadRec.CountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);
                    }
                }
                if(idToOldLeadMap != null) {
                    if(leadRec.Country != idToOldLeadMap.get(leadRec.Id).Country && leadRec.CountryCode == idToOldLeadMap.get(leadRec.Id).CountryCode) {
                        leadRec.CountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);
                    }
                }
            }
        }
    } 

    private void assignStateCode(List<Lead> leadsList, Map<Id, Lead> idToOldLeadMap) {
        for(Lead leadRec : leadsList) {

            if(String.isNotBlank(leadRec.StateCode) && COUNTRY_AND_COUNTRYCODE_MAP.containsKey(leadRec.Country)) {
                if(idToOldLeadMap == null) {
                    if(String.isBlank(leadRec.StateCode)) {
                        leadRec.StateCode = COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);
                    }
                }
                if(idToOldLeadMap != null) {
                    if(leadRec.State != idToOldLeadMap.get(leadRec.Id).State && leadRec.StateCode == idToOldLeadMap.get(leadRec.Id).StateCode) {
                        leadRec.StateCode = COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);
                    }
                }
            }
        }
    }

    private void assignLocalSalesMarket(List<Lead> leadList, Map<Id, Lead> idToOldLeadMap) {

        Map<String, Market__c> marketIdObjMap = new Map<String, Market__c>();

        for(Market__c canadaMarket : [SELECT Id, Name, Market_Id__c, Country__c FROM Market__c where Country__c = 'CA']) {
            marketIdObjMap.put(canadaMarket.Market_ID__c, canadaMarket);
        } 

        Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = new Map<String, Canadian_Postal_Code_Market_Mapping__c>();
        Map<String, String> stateCodeMarketIdMap = new Map<String, String>();

        for(Canadian_Postal_Code_Market_Mapping__c canadaMarket : Canadian_Postal_Code_Market_Mapping__c.getAll().values()) {

            canadaMarketMap.put(canadaMarket.Canadian_Postal_Code__c, canadaMarket);
            //Get default martket id
            if(String.isNotBlank(canadaMarket.Default_State_Code__c)) {
                stateCodeMarketIdMap.put(canadaMarket.Default_State_Code__c, canadaMarket.Market_Id__c);
            }
        }

        for(Lead leadRec : leadList) {
            Lead oldRec = new Lead();
            if(idToOldLeadMap == null) {
                oldRec = null;
            } else if (idToOldLeadMap != null) {
                oldRec = idToOldLeadMap.get(leadRec.Id);
            }
            this.assignLocalSalesMar(leadRec, marketIdObjMap, this.zipMarketMap, oldRec, canadaMarketMap, stateCodeMarketIdMap);
        } 
    }

    public Lead assignLocalSalesMar(Lead record, Map<String, Market__c> marketIdObjMap, Map<String, String> zipMarketMap, 
        Lead oldRecord, Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap, Map<String, String> stateCodeMarketId){

        // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
        // Created lead or update postalCode to assign Zip logic     
        if((oldRecord == null || (oldRecord != null && (record.PostalCode != oldRecord.PostalCode) 
            || (record.StateCode != oldRecord.StateCode)))) {
            
            if(record.CountryCode == 'CA') {
                // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
                // Get sales market base on first 3 digits zip codes
                String zipCode = String.isNotBlank(record.PostalCode) ? record.PostalCode.left(3).toUpperCase() : ''; 
                if(String.isNotBlank(zipCode) 
                    && this.zipMarketMap.containsKey(zipCode) 
                    && this.zipMarketMap.get(zipCode) != record.Local_Sales_Market__c){

                    record.Local_Sales_Market__c = this.zipMarketMap.get(zipCode);
                } 
                // Set default local sales market for Canada
                else{
                    Market__c defaultMarket = DataUtility.getDefaultCanadaMarket(zipCode, record.StateCode, marketIdObjMap, canadaMarketMap, stateCodeMarketId);

                    if(defaultMarket != null && record.Local_Sales_Market__c != defaultMarket.Id) {
                        record.Local_Sales_Market__c = defaultMarket.Id;
                    }
                }
            }
            //CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
            //Arrange assign market logic when Country is US   
            else if (record.CountryCode == 'US'
                    && String.isNotBlank(record.PostalCode) 
                    && this.zipMarketMap.containsKey(record.PostalCode.left(5)) 
                    && this.zipMarketMap.get(record.PostalCode.left(5)) != record.Local_Sales_Market__c) {

                    record.Local_Sales_Market__c = this.zipMarketMap.get(record.PostalCode.left(5));
            }
            // For other country matching local sales market 
            else if(String.isNotBlank(record.PostalCode) 
                && this.zipMarketMap.containsKey(record.PostalCode)
                && this.zipMarketMap.get(record.PostalCode) != record.Local_Sales_Market__c) {

                 record.Local_Sales_Market__c = this.zipMarketMap.get(record.PostalCode);
            }
        }
        return record;
    }

    private void populatePreviousOwner(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap) {
        Map<String,String> leadOwnerNameMap = new Map<String,String>();
        for(Lead leadRec: leadList) {
            if(leadRec.OwnerId != idToLeadOldMap.get(leadRec.Id).OwnerId && !leadRec.IsConverted){
                leadRec.PreviousOwner__c = leadOwnerNameMap.get(idToLeadOldMap.get(leadRec.Id).OwnerID);
                leadRec.Ownership_Changed_Date__c = System.today();
            }
        }       
    }

    // csp-2546
    public void cloneFeeds(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap) {

        Map<Id, List<FeedItem>> feedItemMap = new Map<Id, List<FeedItem>>();
        List<FeedItem> newFeeds = new List<FeedItem>();
        List<FeedItem> itemList = new List<FeedItem>();
        Set<Id> convertedLeadIdSet = this.populateConvertedLeadIdSet((List<Lead>)Trigger.New);

        if(convertedLeadIdSet == null) {
            return;
        }

        Map<Id, List<FeedItem>> idToFieldItemLstMap = this.populateFeedItemMap(convertedLeadIdSet);

        for(Lead leadRec : leadList) {
            
            if(leadRec.IsConverted  && !idToLeadOldMap.get(leadRec.Id).IsConverted){
               if(idToFieldItemLstMap.containsKey(leadRec.Id)){
                   itemList = idToFieldItemLstMap.get(leadRec.Id);
               }

               if(!itemList.isEmpty()) {
                   
                   for(FeedItem item: itemList) {

                       if(String.isNotBlank(leadRec.ConvertedAccountId)){
                           FeedItem newFeedItem = new FeedItem();
                           newFeedItem = createNewFeed(leadRec.ConvertedAccountId, item);

                           if(newFeedItem != null) {
                               newFeeds.add(newFeedItem);
                           }
                       }

                       if(String.isNotBlank(leadRec.ConvertedContactId)){
                           FeedItem newFeedItem = new FeedItem();
                           newFeedItem = createNewFeed(leadRec.ConvertedContactId, item);
                           if(newFeedItem != null) {
                               newFeeds.add(newFeedItem);
                           }
                       }
                   }
               }
            }
        }

        if(!newFeeds.isEmpty()){
            try {
                insert newFeeds;
            }
            catch (Exception ex) {
                XO_Exception__c xoException = ExceptionUtility.consumeException(ex, false);
                xoException.Severity__c = 'Critical';
                xoException.Failure_Area__c = 'Feed clone to Account and Contact failed during convertion';
                this.exceptionList.add(xoException);
            }
        }
    }

    private Set<Id> populateConvertedLeadIdSet(List<Lead> leadList) {
        Set<Id> convertedLeadIdSet = new Set<Id>();
        
        for(Lead leadRec : leadList) {
            if(leadRec.isConverted) {
                convertedLeadIdSet.add(leadRec.Id);
            }
        }

        if(!convertedLeadIdSet.isEmpty()) {
            return convertedLeadIdSet;
        }

        return null;
    }

    private Map<Id, List<FeedItem>> populateFeedItemMap(Set<Id> convertedLeadIdSet) {

        Map<Id, List<FeedItem>> feedItemMap = new Map<Id, List<FeedItem>>();
        List<FeedItem> feedItemList = new List<FeedItem>();
        // CSP-2546 Clone feed from Lead to Account Upon Conversion
        if(!convertedLeadIdSet.isEmpty()){
            try {
                // Query all feed items from converted leads
                feedItemList = FeedItemQueryUtils.retrieveFeedItems(convertedLeadIdSet);
            } catch(Exception e) {
                XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
                this.exceptionList.add(xoException);
            }

            List<FeedItem> itemList = new List<FeedItem>();

            // Stored to a map for each lead with all its feed items
            for(FeedItem fi : feedItemList){
                
                if(!feedItemMap.containsKey(fi.ParentId)){
                    itemList = new List<FeedItem>();
                    itemList.add(fi);
                    feedItemMap.put(fi.ParentId, itemList);
                }
                else{
                    feedItemMap.get(fi.ParentId).add(fi);
                }
            }
        }
        return feedItemMap;
    }

    @TestVisible
    private FeedItem createNewFeed(Id convertedRecId, FeedItem item) {
        
        FeedItem feedItem = new FeedItem();
        feedItem.ParentId = convertedRecId;

        if(String.isNotBlank(item.type)){
            feedItem.type = item.type;
        }

        if(String.isNotBlank(item.Title)){
            feedItem.Title = item.Title;
        }

        if(String.isNotBlank(item.Body)){
            feedItem.IsRichText = item.IsRichText;
            feedItem.Body = item.Body;
        }

        if(String.isNotBlank(item.LinkUrl)){
            feedItem.LinkUrl = item.LinkUrl;
        }

        if(String.isNotBlank(item.RelatedRecordId)){
            feedItem.RelatedRecordId = item.RelatedRecordId;
        }

        // will only insert those have comments or URLs or attachments feeds
        if(String.isNotBlank(item.Body) || String.isNotBlank(feedItem.RelatedRecordId) || String.isNotBlank(feedItem.LinkUrl)){
            return feedItem; 
        }
        return null;
    }

    // csp-2552
    private void updateEndorsement(List<Lead> leadList) {

        Map<Id, Id> leadConvertedAccIdMap = new Map<Id, Id>();
        List<Endorsement__c> updateEndorsementList = new List<Endorsement__c>();
        Set<Id> convertedLeadIdSet = new Set<Id>();

        for(Lead leadRec : leadList) {
            if(leadRec.IsConverted){
                convertedLeadIdSet.add(leadRec.Id);
                // CSP-2552 added the converted lead to the map
                leadConvertedAccIdMap.put(leadRec.Id, leadRec.ConvertedAccountId);
            }
        }

        if (!leadConvertedAccIdMap.isEmpty()) {
            try {
                updateEndorsementList = [Select Id, Account__c, Lead__c From Endorsement__c where Lead__c IN: leadConvertedAccIdMap.keySet()];
            } catch (Exception e) {
                XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
                this.exceptionList.add(xoException);
            }
            if (!updateEndorsementList.isEmpty()) {
                for (Endorsement__c currentEndorsement: updateEndorsementList) {
                    currentEndorsement.Account__c = leadConvertedAccIdMap.get(currentEndorsement.Lead__c);
                }
            }
        }

        if (!updateEndorsementList.isEmpty()) {
            List<Database.SaveResult> saveResultList = Database.update(updateEndorsementList);
            List<XO_Exception__c> xoExceptionList = ExceptionUtility.consumeException(saveResultList);
            if (!xoExceptionList.isEmpty()) {
                insert xoExceptionList;
            }
        }       
    }

    public void createAccountContactRole(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap) {
        List<AccountContactRole> convertLeadAccountContactRoleList = new List<AccountContactRole>();

        for(Lead leadRec : leadList) {
            if(leadRec.IsConverted  && !idToLeadOldMap.get(leadRec.Id).IsConverted){
                AccountContactRole newContactRole = new AccountContactRole();
                newContactRole.Role = 'Primary';
                newContactRole.AccountId = leadRec.ConvertedAccountId;
                newContactRole.ContactId = leadRec.ConvertedContactId;
                convertLeadAccountContactRoleList.add(newContactRole);
            }   
        }
        if(!convertLeadAccountContactRoleList.isEmpty()){
            Database.insert(convertLeadAccountContactRoleList, false);
        }
    }

    // CSP-2061
    private void scoringLeads(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap) {
        Set<String> SCORING_FIELDS_SET = LeadAndAccountScoringUtilities.getLeadScoringFieldsNameSet();
        Set<Id> scoreLeadsIdSet = new Set<Id>();

        if(idToLeadOldMap == null) {
            for(Lead leadRec: leadList) {
                scoreLeadsIdSet.add(leadRec.Id);
            }
        }

        if(idToLeadOldMap != null) {
            for(Lead leadRec: leadList) {

                for (String scoringField : SCORING_FIELDS_SET) {
                    // Note: as of 4-11-17 we are only doing comparisons against text fields
                    String oldFieldValue = (String)idToLeadOldMap.get(leadRec.Id).get(scoringField);
                    String newFieldValue = (String)leadRec.get(scoringField);
                    if (oldFieldValue != newFieldValue) {
                        scoreLeadsIdSet.add(leadRec.Id);
                        break;
                    }
                }
            }
        }

        if (!scoreLeadsIdSet.isEmpty() && !System.isBatch() && !System.isFuture()) {
            LeadAndAccountScoringUtilities.scoreLeadsFutureJob(scoreLeadsIdSet);
        }       
    }

    public void phoneValidation(List<Lead> newLeadList){
        for(Lead leadRec: newLeadList) {
            if(String.isNotBlank(leadRec.Phone)) {
            
                DataUtility.ValidationResult phoneValidation = DataUtility.formatPhoneNumber(leadRec.Phone);
            
                // If the Phone is valid then put the formatted value into the Phone field
                if(phoneValidation.valid) {
                    leadRec.Phone = phoneValidation.formattedValue;
                } 
                else {
                    leadRec.Phone.addError(System.Label.Phone_Validation_Error);
                }
            }
        }
    }

    public void zipValidation(List<lead> newLeadList){
        
        for(Lead leadRec: newLeadList) {
            if (String.isNotBlank(leadRec.CountryCode) && String.isNotBlank(leadRec.PostalCode) && String.isNotBlank(leadRec.Status)) {

                //CSP-2954: Allow Leads with incomplete (3-digit) Canadian postal codes
                //6-digit format postal code is required when we qualify a canadian lead or convert a canadian lead.
                if( (leadRec.Status == 'Qualified' || leadRec.IsConverted)                   
                    && !XOCustomValidationUtility.hasCompleteCanadianZip(leadRec.CountryCode, leadRec.PostalCode) ){
                    leadRec.PostalCode.addError('6-digit postal code is required for the selected Country');
                }

                if(!XOCustomValidationUtility.validZip(leadRec.CountryCode, leadRec.PostalCode)){
                    leadRec.PostalCode.addError('Not a valid zip code for the selected Country');
                }
            }
        }
    }

    private void assignCountryAndState(List<Lead> newLeadList, Map<Id, Lead> idToLeadOldMap) {
        // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
        // Fill in StateCode if it's blank 
        for(Lead leadRec: newLeadList) {
            if(String.isNotBlank(leadRec.Country) && String.isBlank(leadRec.CountryCode) 
                && COUNTRY_AND_COUNTRYCODE_MAP.containsKey(leadRec.Country)) {

                if(idToLeadOldMap == null || (idToLeadOldMap != null && leadRec.Country != idToLeadOldMap.get(leadRec.Id).Country && leadRec.CountryCode == idToLeadOldMap.get(leadRec.Id).CountryCode)) {
                    leadRec.CountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);
                }
            }

            if(String.isNotBlank(leadRec.State) && String.isBlank(leadRec.StateCode) 
                && STATE_AND_STATECODE_MAP.containsKey(leadRec.State)) {

                if(idToLeadOldMap == null || (idToLeadOldMap != null && leadRec.State != idToLeadOldMap.get(leadRec.Id).State && leadRec.State == idToLeadOldMap.get(leadRec.Id).State)) {
                    leadRec.StateCode = STATE_AND_STATECODE_MAP.get(leadRec.State);
                }
            }
        }
    }

    // csp-2559
    public void preventEditOnCreation(List<Lead> newLeadList) {

        Set<String> PROFILE_NAME_SET;
        if(PROFILE_NAME_SET == null) {
            List<String> profileNameRestrictedList = new List<String>(System.Label.ProfileNamesRestrictedList.split('\n'));
            PROFILE_NAME_SET = new Set<String>();

            for(String profileNameRec: profileNameRestrictedList) {
                PROFILE_NAME_SET.add(profileNameRec.trim());
            }
        }

        for(Lead leadRec: newLeadList) {
            //csp-2559
            if(PROFILE_NAME_SET.contains(this.userObjList[0].Profile.Name) && leadRec.Status != 'New') {
                leadRec.addError('User with ' + this.userObjList[0].Profile.Name + ' profile cannot update the lead status on creation');
            }
        }
    }

    public void assignDynamicsleadid(List<lead> leadList){

        for(Lead leadRec: leadList) {
            if(String.isBlank(leadRec.DynamicsLeadID__c)){
                leadRec.DynamicsLeadID__c = RandomStringUtils.randomUUID();
                leadRec.Salesforce_Generated_GUID__c = true;
            }
        }
    }

    public void assignCountry(List<lead> leadList){

        for(Lead leadRec: leadList) {

            if(!countryRegExList.isEmpty() && String.isBlank(leadRec.CountryCode) && String.isBlank(leadRec.Country) && String.isNotBlank(leadRec.PostalCode)){
                leadRec = (Lead)XOCustomValidationUtility.assignCountryBasedOnZip(leadRec, 'CountryCode', leadRec.PostalCode);
            }
        }
    }

    public void assignCitystate(List<lead> leadList, Map<Id, Lead> idToLeadOldMap){

        Map<String, Zip__c> poastalCodeZipMap = new Map<String, Zip__c>();
        Set<String> zipSet = new Set<String>();

        for(Lead leadRec : (List<Lead>)Trigger.New) {      
            if(String.isNotBlank(leadRec.PostalCode)){
                // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
                // Different bewteen US and Canada country 
                // Get leadRec Country Code
                String tempCountryCode = String.isNotBlank(leadRec.CountryCode) ? leadRec.CountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);

                if(leadRec.PostalCode.length() >= 5 
                    && tempCountryCode == 'US') {

                    zipSet.add(leadRec.PostalCode.left(5));
                }
                // Add first three digits of Canadian Zipcod to set for query zipcode leadRec
                else if(leadRec.PostalCode.length() >= 3 
                      && (tempCountryCode == 'CA')) {

                    zipSet.add(leadRec.PostalCode.left(3).toUpperCase());
                }
                else {
                    zipSet.add(leadRec.PostalCode);
                }
            }
        }

        for (Zip__c zipObj : [SELECT Id, ZipCode__c, Local_Market__c, Local_Market__r.Market_ID__c, City__c, State__c, Portfolio__c  
                              FROM Zip__c
                              WHERE ZipCode__c IN :zipSet]) {
            poastalCodeZipMap.put(zipObj.ZipCode__c, zipObj);
        }

        for(Lead leadRec: leadList) {

            Zip__c currentZip = new Zip__c();
            if((idToLeadOldMap == null || (idToLeadOldMap != null && idToLeadOldMap.get(leadRec.Id) != Null &&  leadRec.PostalCode != idToLeadOldMap.get(leadRec.Id).PostalCode))
                && (leadRec.CountryCode == 'US' || leadRec.CountryCode == 'CA') 
                && String.isNotBlank(leadRec.PostalCode)) {

                // Get zip code leadRec for Canada 
                if (leadRec.CountryCode == 'CA' 
                    && leadRec.PostalCode.length() >= 3 
                    && poastalCodeZipMap.containsKey(leadRec.PostalCode.left(3).toUpperCase())){

                   currentZip = poastalCodeZipMap.get(leadRec.PostalCode.left(3).toUpperCase());      
                }
                // Get zip code leadRec for US
                if (leadRec.CountryCode == 'US' 
                    && leadRec.PostalCode.length() >= 5 
                    && poastalCodeZipMap.containsKey(leadRec.PostalCode.left(5))) {
                        
                   currentZip = poastalCodeZipMap.get(leadRec.PostalCode.left(5));      
                }
                // fill City/State info to lead from zip leadRec 
                if(currentZip != null) {
                    if (String.isNotBlank(currentZip.City__c)) {
                        leadRec.City = currentZip.City__c;
                    }
                    if (String.isNotBlank(currentZip.State__c)) {
                        leadRec.State = currentZip.State__c;
                    }
                }
            }
        }
    }

    // TODO: This can be a workflow
    public void assignFulfillstorefront(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap){
        for(Lead leadRec: leadList) {
            if ( (idToLeadOldMap == null && (leadRec.Storefront_Status__c == 'Claimed' || leadRec.Storefront_Status__c == 'Unclaimed') ) 
                || (idToLeadOldMap != null && !leadRec.Fulfill_Storefront__c && (leadRec.Storefront_Status__c == 'Claimed' || leadRec.Storefront_Status__c == 'Unclaimed'))){
                leadRec.Fulfill_Storefront__c = true;
            }
        }
    }

    public void assignStrategyspecialist(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap){

        Set<Id> salesRepIdSet = new Set<Id>(); 
        Map<Id, Id> salesRepStrategySpecialistMap = new Map<Id, Id>();

        if(idToLeadOldMap != null) {
            for(Lead leadRec: leadList) {
                salesRepIdSet.add(leadRec.OwnerId);
            }     
            if(!salesRepIdSet.isEmpty()){
                for(User userRec : [select Id, Strategy_Specialist__c from User where Id IN : salesRepIdSet and Strategy_Specialist__c != null]){
                    salesRepStrategySpecialistMap.put(userRec.Id, userRec.Strategy_Specialist__c);
                }
            } 
        }
        
        for(Lead leadRec: leadList) {

            if (salesRepStrategySpecialistMap.containsKey(leadRec.OwnerId)) {            
                if(idToLeadOldMap != null) {
                    if(idToLeadOldMap.containsKey(leadRec.Id) && !leadRec.IsConverted 
                            && salesRepStrategySpecialistMap.containsKey(leadRec.OwnerId) && leadRec.OwnerId != idToLeadOldMap.get(leadRec.Id).OwnerId) {
                        leadRec.Strategy_Specialist__c = salesRepStrategySpecialistMap.get(leadRec.OwnerId);
                    }
                } else if(idToLeadOldMap == null) {
                    leadRec.Strategy_Specialist__c = salesRepStrategySpecialistMap.get(leadRec.OwnerId);
                }
            }
        }
    }

    private void routeLeads(List<lead> leadList, Map<Id, Lead> idToLeadOldMap) {
        
        for(Lead leadRec: leadList) {
            // shall i map be created here ?
            if(leadRec.Status == 'New') {
                newLeads(leadRec, idToLeadOldMap);
            } else if (leadRec.Status == 'Valid') {
                validLeads(leadRec, idToLeadOldMap);
            } else if(leadRec.Status == 'Qualified'){
                qualifiedLeads(leadRec, idToLeadOldMap); 
            } else if (leadRec.Status != 'Invalid' && leadRec.Status != 'New') {
                updateReason(leadRec);
            }

            if(idToLeadOldMap == null) {
                this.assignZip(leadRec, this.zipNameToIdMap, null);
            } else if(idToLeadOldMap != null) {
                Lead oldleadRec = (Lead)trigger.oldMap.get(leadRec.Id);
                this.assignZip(leadRec, this.zipNameToIdMap, oldleadRec);
            }
        }
    }

    public void assignZip(Lead record, Map<String, Id> zipNameToIdMap, Lead oldRecord){
        // CSP-3075 Update Automation on Lead to fill in Market based on Zip Codes
        // Created lead or update postalCode to assign Zip logic 
        if((oldRecord == null || (oldRecord != null && record.PostalCode != oldRecord.PostalCode))) {
            // CSP-3067 9 digit zips not populating marketplace health and portfolio fields
            // if the postal code length is greater than 5, we should get the 5th digit to assign zip
            if( record.CountryCode == 'US'
                && String.isNotBlank(record.PostalCode)
                && zipNameToIdMap.containsKey(record.PostalCode.left(5))){

                record.Zip__c = zipNameToIdMap.get(record.PostalCode.left(5));    
            }
            //CSP-3075 Update Automation on Lead to fill in Market based on the Canadian Zip Codes
            // get first three digits of Canadian Zip Code assign zip
            else if(record.CountryCode == 'CA'
                 && String.isNotBlank(record.PostalCode)
                 && zipNameToIdMap.containsKey(record.PostalCode.left(3).toUpperCase())){

                record.Zip__c = zipNameToIdMap.get(record.PostalCode.left(3).toUpperCase());  
            }
            else if(String.isNotBlank(record.PostalCode) 
                && zipNameToIdMap.containsKey(record.PostalCode)) {
                
               record.Zip__c = zipNameToIdMap.get(record.PostalCode); 
            }
            else{
               record.Zip__c = null;  
            }
        }
    }

    private void newLeads(Lead leadRec, Map<Id, Lead> idToLeadOldMap) {

        // this will prevent the lead from routing the owner back to 'Data Enrichment' when a 
        // data team member edits a record and saves it
        if(this.userObjList[0].Profile.Name == 'Local Sales Data Team') {
            return;
        }

        if(hotLeadSourcesSet.contains(leadRec.LeadSource)) {
            leadRec.Status = 'Valid'; 
            leadRec.Valid_Status_Time_Stamp__c = System.now();
            leadRec.OwnerId = userObjList[0].Id; // fast path lead
        } else {

            Id dataEnrichmentId;
            if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                    dataEnrichmentId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
                }
            }

            leadRec.Status = 'New';

            if(idToLeadOldMap != null && 
                idToLeadOldMap.get(leadRec.Id).OwnerId != hubspotUserRecord.Id && idToLeadOldMap.get(leadRec.Id).OwnerId != dataEnrichmentId) {

                leadRec.OwnerId = dataEnrichmentId;
            }

            if(idToLeadOldMap == null) {
                leadRec.OwnerId = dataEnrichmentId;
            }
        }
            
        if(Trigger.isUpdate) {
            if(idToLeadOldMap.get(leadRec.Id).Status != 'New') {
                leadRec.Negative_Disposition_Reason__c = '';
                if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                    // if the owner id is different it means the request for assigning the owner id is from the 'Accept' button
                    // we check if the owner ids are different and the previous owner is indeed data enrichment queue
                    if(idToLeadOldMap.get(leadRec.Id).OwnerId == leadRec.OwnerId) {
                        leadRec.OwnerId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
                    }
                }
            }   
        }
    }

    private Boolean missingMapping(Lead leadRec) {

        if(leadRec.Local_Sales_Market__c == null && String.isNotBlank(leadRec.PostalCode) 
                && (!this.zipMarketMap.containsKey(leadRec.PostalCode) && !this.zipMarketMap.containsKey(leadRec.PostalCode.left(5)))){

            if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {

                if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                    leadRec.OwnerId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
                }
                leadRec.Status = 'Invalid';
                leadRec.Negative_Disposition_Reason__c = 'Missing Required Information';
            }
            return true;
        }
        return false;
    }

    private void validLeads(Lead leadRec, Map<Id, Lead> idToLeadOldMap) {
        if(idToLeadOldMap == null) {

            if(!missingMapping(leadRec)) {
                //If it is a fast lead, we skip distribution and directly assign lead to its creator
                if(hotLeadSourcesSet.contains(leadRec.LeadSource)) {
                    leadRec.Status = 'Valid'; 
                    leadRec.Valid_Status_Time_Stamp__c = System.now();
                    leadRec.OwnerId = userObjList[0].Id; // fast path lead
                }else{
                    ownerAssignment(leadRec);
                }
            }

        }else{

            //If Local Sales Data Team converts lead status from anything that is not Valid to Valid after cleansing
            //lead should follow standard routing logic. 
            if(idToLeadOldMap.containsKey(leadRec.Id) 
            && idToLeadOldMap.get(leadRec.Id).Status != 'Valid'
            && leadRec.Status == 'Valid'){
                if(this.userObjList[0].Profile.Name == 'Local Sales Data Team'){
                    ownerAssignment(leadRec);
                }
            }
        }
    }

    private void qualifiedLeads(Lead leadRec, Map<Id, Lead> idToLeadOldMap) {

        if(!leadRec.Local_Partners_Claiming__c) {
            return;
        }

        if(leadRec.OwnerId == QUEUE_NAME_MAP.get('Distributable').Id) {
            if(QUEUE_NAME_MAP.containsKey('Distributable')) {  
                leadRec.OwnerId = QUEUE_NAME_MAP.get('Distributable').Id;
            }
        }

        if(leadRec.OwnerId == QUEUE_NAME_MAP.get('Data Enrichment').Id) {
            if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {  
                ownerAssignment(leadRec);
            }
        }

        if(idToLeadOldMap != null) {
            Lead oldleadRec = idToLeadOldMap.get(leadRec.Id);
            if(oldleadRec.Status == 'Valid') {
                this.qualifyLead(leadRec);
            }
        }
    }

    // TODO: This can be converted to validation rules 
    public void qualifyLead(Lead record){

        List<Schema.FieldSetMember> qualifyFilters = Schema.SObjectType.Lead.fieldSets.Qualify_Lead_Fields.getFields();
        Set<String> LEAD_LASTNAME_FILTERS = new Set<String>();
        Set<String> LEAD_FIRSTNAME_FILTERS = new Set<String>();

        LEAD_FIRSTNAME_FILTERS.addAll(system.label.Lead_First_Name_Filters.split('\r\n'));
        LEAD_LASTNAME_FILTERS.addAll(system.label.Lead_Last_Name_Filters.split('\r\n'));
        
        // step1: check fields has values
        for(Schema.FieldSetMember fsm : qualifyFilters){
            String val = String.valueOf(record.get(fsm.getFieldPath()));

            if(String.isBlank(val)){
                record.addError(fsm.getLabel() + ' is required');
            }
        }

        // after that, check the last name / first name is contains junk value
        // CSP-2772 Leads Bulk Data Loading bypassing trigger
        // Check the lastName and firstName whether they are null before check the junk value
        if(String.isNotBlank(record.LastName) && LEAD_LASTNAME_FILTERS.contains(String.valueOf(record.LastName).toLowerCase())){
            record.addError('LastName cannot be a junk value');
        } else if(String.isNotBlank(record.FirstName) && LEAD_FIRSTNAME_FILTERS.contains(String.valueOf(record.FirstName).toLowerCase())){
            record.addError('FirstName cannot be a junk value');
        }
    }

    private void invalidLeads(List<lead> leadList) {
        for(Lead leadRec: leadList) {
            if(leadRec.Status == 'Invalid' && leadRec.Negative_Disposition_Reason__c == 'Out of Business' && QUEUE_NAME_MAP.containsKey('Dead Queue')) {
                Group deadQueue = QUEUE_NAME_MAP.get('Dead Queue');
                leadRec.OwnerId = deadQueue.Id;
            }
        }
    }

    private void disqualifiedLeads(List<lead> leadList) {

        for(Lead leadRec: leadList) {

            if(leadRec.Status != 'Disqualified') {
                continue;
            }

            if(leadRec.Negative_Disposition_Reason__c != 'Other' && String.isNotBlank(leadRec.Reason_Details__c)) {
                leadRec.Reason_Details__c = '';
            }

            Lead oldleadRec = (Lead)trigger.oldMap.get(leadRec.Id);

            // selection of Do Not Contact as the reason sets the Lead to an end of life state.
            if(leadRec.Negative_Disposition_Reason__c == 'Do Not Contact' || leadRec.Negative_Disposition_Reason__c == 'Out of Business') {
                if(QUEUE_NAME_MAP.containsKey('Dead Queue')) {
                    Group deadQueue = QUEUE_NAME_MAP.get('Dead Queue');
                    Group dataEnrichmentQueue = QUEUE_NAME_MAP.get('Data Enrichment');

                    if(oldleadRec.OwnerId == leadRec.OwnerId) { // csp-1940
                        leadRec.OwnerId = deadQueue.Id;
                    }
                }
            }
            // selection of Bad Contact or Duplicate buckets the lead for the Data Enrichment team
            if(leadRec.Negative_Disposition_Reason__c == 'Bad Contact' || leadRec.Negative_Disposition_Reason__c == 'Duplicate') { 
                if(QUEUE_NAME_MAP.containsKey('Data Enrichment')) {
                    Group dataEnrichmentQueue = QUEUE_NAME_MAP.get('Data Enrichment');
                    
                    if(oldleadRec.OwnerId == leadRec.OwnerId) { // csp-1940
                        leadRec.OwnerId = dataEnrichmentQueue.Id;
                    }
                }
            }
        }
    }

    private Map<String, String> createZipMarketMap() {

        Set<String> zipSet = new Set<String>();
        Set<Id> marketIdSet = new Set<Id>();  
        Map<String, String> zipMarketMap = new Map<String, String>();
      
        for(Lead leadRec : (List<Lead>)Trigger.New) {
            if(String.isNotBlank(leadRec.PostalCode)){
                // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
                // Different bewteen US and Canada country 
                // Get leadRec Country Code
                String tempCountryCode = String.isNotBlank(leadRec.CountryCode) ? leadRec.CountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);

                if(leadRec.PostalCode.length() >= 5 && tempCountryCode == 'US') {
                    zipSet.add(leadRec.PostalCode.left(5));
                }
                // Add first three digits of Canadian Zipcod to set for query zipcode leadRec
                else if(leadRec.PostalCode.length() >= 3 && (tempCountryCode == 'CA')) {
                    zipSet.add(leadRec.PostalCode.left(3).toUpperCase());
                }
                else {
                    zipSet.add(leadRec.PostalCode);
                }
            }
        }

        for(Zip__c zipObj : getZipCodeList(zipSet)) {
            marketIdSet.add(zipObj.Local_Market__c);
            zipMarketMap.put(zipObj.ZipCode__c, zipObj.Local_Market__c);
        }

        return zipMarketMap;
    }

    private static List<Zip__c> getZipCodeList(Set<String> zipSet) {
        
        return ([SELECT Id, ZipCode__c, Local_Market__c, Local_Market__r.Market_ID__c, City__c, State__c, Portfolio__c  
                FROM Zip__c
                WHERE ZipCode__c IN :zipSet]);            
    }

    private void updateReason(Lead leadRec) {
        if(String.isNotBlank(leadRec.Potential_Duplicates__c)) {
            leadRec.Potential_Duplicates__c = '';
        } 
        else if (leadRec.Status != 'Unknown' && leadRec.Status != 'Disqualified' && String.isNotBlank(leadRec.Negative_Disposition_Reason__c)) {
            leadRec.Negative_Disposition_Reason__c = '';
        }
    }

    private void populateAssignmentMap(List<Lead> leadList) {

        Set<String> zipSet = new Set<String>();
        Set<Id> categoryIdSet = new Set<Id>();
        Set<Id> marketIdSet = new Set<Id>();
     
        for(Lead leadRec : leadList) {

            if(String.isNotBlank(leadRec.Local_Sales_Market__c)){
                marketIdSet.add(leadRec.Local_Sales_Market__c);
            }

            if(String.isNotBlank(leadRec.Primary_Category__c)){
                categoryIdSet.add(leadRec.Primary_Category__c);
            }

            if(String.isNotBlank(leadRec.PostalCode)){
                // CSP-3075 Update Automation on Lead to fill in Market based on Canadian Zip Codes
                // Different bewteen US and Canada country 
                // Get leadRec Country Code
                String tempCountryCode = String.isNotBlank(leadRec.CountryCode) ? leadRec.CountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(leadRec.Country);

                if(leadRec.PostalCode.length() >= 5 && tempCountryCode == 'US') {
                    zipSet.add(leadRec.PostalCode.left(5));
                }
                // Add first three digits of Canadian Zipcod to set for query zipcode leadRec
                else if(leadRec.PostalCode.length() >= 3 && (tempCountryCode == 'CA')) {
                    zipSet.add(leadRec.PostalCode.left(3).toUpperCase());
                }
                else {
                    zipSet.add(leadRec.PostalCode);
                }
            }                
        }
       
        for (Zip__c zipObj : [SELECT Id, ZipCode__c, Local_Market__c, Local_Market__r.Market_ID__c, City__c, State__c, Portfolio__c  
                              FROM Zip__c
                              WHERE ZipCode__c IN :zipSet]) {
            
            marketIdSet.add(zipObj.Local_Market__c);
            this.zipNameToIdMap.put(zipObj.ZipCode__c, zipObj.id);  
        }
        if(!zipSet.isEmpty() || !categoryIdSet.isEmpty() || !marketIdSet.isEmpty()) {
            AssignmentRulesUtility.buildAssignmentMap(marketIdSet, categoryIdSet, zipSet);
        }
    }

    public void ownerAssignment(Lead leadRec) {
        
        if(!validateCatMarketZip(leadRec)) {
            return;
        }

        Local_Sales_Rep_Assignment__c localSalesRepAssignmentRec = AssignmentRulesUtility.getRecordAssignment(leadRec);

        if((localSalesRepAssignmentRec  == null) || 
            (localSalesRepAssignmentRec != null && 
                localSalesRepAssignmentRec.Sales_Rep__c == null && 
                localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c == null)) {
            
            if(QUEUE_NAME_MAP.containsKey('Distributable')) {
                leadRec.OwnerId = QUEUE_NAME_MAP.get('Distributable').Id;
            }
        }
        // if Sales Rep on LSRA does exist, update the owner to point to the Sales rep and also create Assignment History records
        else if(localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Sales_Rep__c != null) {
            leadRec.OwnerId = localSalesRepAssignmentRec.Sales_Rep__c;
            this.createAssignmentHistoryRecords(localSalesRepAssignmentRec.Id, leadRec);
        }
        else if(localSalesRepAssignmentRec != null && localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c != null) {
            leadRec.OwnerId = localSalesRepAssignmentRec.Lead_Distribution_Queue_Id__c;
            this.createAssignmentHistoryRecords(localSalesRepAssignmentRec.Id, leadRec);
        }

        if(leadRec.Local_Partners_Claiming__c) {
            // distributable accounts user
            leadRec.OwnerId = this.DISTRIBUTABLE_ACCOUNT_USER.Id;
        }
    }

    public void createAssignmentHistoryRecords(Id localSalesRepAssignmentRecId, Lead leadRec) {

        Map<Id, List<Lead>> localSalesRepAssignmentToLeadListMap = new Map<Id, List<Lead>>();

        List<Lead> assignmentHistoryLeadList = localSalesRepAssignmentToLeadListMap.containsKey(localSalesRepAssignmentRecId) 
                ? localSalesRepAssignmentToLeadListMap.get(localSalesRepAssignmentRecId) : new List<Lead>();
        
        assignmentHistoryLeadList.add(leadRec);
        localSalesRepAssignmentToLeadListMap.put(localSalesRepAssignmentRecId, assignmentHistoryLeadList);

        if (!localSalesRepAssignmentToLeadListMap.isEmpty()) {
            List<Assignment_History__c> assignmentHistoryInsertList = new List<Assignment_History__c>();
            
            for (Id localSalesRepAssignmentRecordId : localSalesRepAssignmentToLeadListMap.keySet()) {
                
                for (Lead newLeadRecord : localSalesRepAssignmentToLeadListMap.remove(localSalesRepAssignmentRecordId)) {
                   
                    Assignment_History__c assignmentHistoryRecord = new Assignment_History__c();
                    assignmentHistoryRecord.Local_Sales_Rep_Assignment__c = localSalesRepAssignmentRecordId;
                    // CSP-2448 - If the Owner starts with 005 then this is a User assignment, else this is a Queue
                    if(newLeadRecord != null && newLeadRecord.OwnerId != null) {
                        if(String.valueOf(newLeadRecord.OwnerId).startsWith('005')) {
                            assignmentHistoryRecord.User__c = newLeadRecord.OwnerId;
                        } else {
                            assignmentHistoryRecord.Lead_Distribution_Queue_Id__c = newLeadRecord.OwnerId;
                        }
                        
                        assignmentHistoryRecord.Lead__c = newLeadRecord.Id;
                        assignmentHistoryInsertList.add(assignmentHistoryRecord);
                    }
                }
            }

            if(!assignmentHistoryInsertList.isEmpty()){
                try {
                    insert assignmentHistoryInsertList;
                }
                catch (Exception ex) {
                    XO_Exception__c xoException = ExceptionUtility.consumeException(ex, false);
                    this.exceptionList.add(xoException);
                }
            }
        }
    }

    // check if at least one of zip, market, category exist. If not route the leadRec to 'Data Enrichment' queue 
    public Boolean validateCatMarketZip(Lead leadRec) {
        
        if((leadRec.Primary_Category__c == null) && (leadRec.Local_Sales_Market__c == null) && (leadRec.Zip__c == null)) {
            leadRec.OwnerId = QUEUE_NAME_MAP.get('Data Enrichment').Id;
            leadRec.Status = 'Invalid';
            leadRec.Negative_Disposition_Reason__c = 'Missing Required Information';
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

    private void commitXOExceptions() {
        if(!this.exceptionList.isEmpty()) {
            insert this.exceptionList;
        }
    }
}