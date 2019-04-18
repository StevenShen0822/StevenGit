public with sharing class AccountDomain extends Domain {

    private List<XO_Exception__c> exceptionList; 
    private final Map<String, String> COUNTRY_AND_COUNTRYCODE_MAP;  
    private final Map<String, String> STATE_AND_STATECODE_MAP;  
    private final Map<String, String> parentGUIDToAccountIdMap;
    List<XO_Exception__C> xoExceptionList; 
    private final DefaulCBSSValues__c CBSS_DEFAULT_VALUES; 
    private Boolean updateZuoraAccountCBSS;
    private final Set<String> SCORING_FIELDS_SET;

    public AccountDomain(List<Account> accountList) {
        this.COUNTRY_AND_COUNTRYCODE_MAP = new Map<String, String>(DataUtility.buildPicklistEntryMap('Account','ShippingCountryCode'));
        this.STATE_AND_STATECODE_MAP = new Map<String, String>(DataUtility.buildPicklistEntryMap('Account','ShippingStateCode'));
        this.CBSS_DEFAULT_VALUES = DefaulCBSSValues__c.getInstance('InvoiceTemplate');
        this.updateZuoraAccountCBSS = false;
        this.SCORING_FIELDS_SET = LeadAndAccountScoringUtilities.getAccountScoringFieldsNameSet();
        this.exceptionList = new List<XO_Exception__c>();
    }

    public override void onBeforeInsert() {
        List<Account> newAccountsList = (List<Account>)Trigger.New; 
        LeadDomain leadDom = new LeadDomain();  

        this.populateAccountParentId(newAccountsList, null);
        this.populateAssignmentMap(newAccountsList);
        this.populateAccountsShippingAddress(newAccountsList, null);
        this.validateShippingPostalCode(newAccountsList);
        this.validateBillingPostalCode(newAccountsList);
        this.assignAccountZip(newAccountsList, null);
        this.updateFulfillStorefront(newAccountsList);
        this.phoneValidation(newAccountsList, null);
        this.phoneExtensionValidation(newAccountsList, null);
        this.websiteValidation(newAccountsList, null);
        this.assignSalesforceGeneratedGUID(newAccountsList, null);
        this.fulfillStorefrontValidation(newAccountsList);
        this.populatePrimaryCatHubspotFormula(newAccountsList, null);
        this.assignCountry(newAccountsList);
        this.populateCBSSData(newAccountsList, null);
        this.populateVIPProgramLastModifiedDate(newAccountsList, null);
        this.populatePreviousOwner(newAccountsList, null);
        this.commitXOExceptions();
    }

    public override void onBeforeUpdate() {
        Map<Id, Account> idToOldAccountMap = (Map<Id, Account>)Trigger.oldMap;
        List<Account> newAccountsList = (List<Account>)Trigger.New;

        this.populateAccountParentId(newAccountsList, idToOldAccountMap);
        this.populateAssignmentMap(newAccountsList);
        this.accOwnerAssignment(newAccountsList, idToOldAccountMap);
        this.populateAccountsShippingAddress(newAccountsList, idToOldAccountMap);
        this.validateShippingPostalCode(newAccountsList);
        this.validateBillingPostalCode(newAccountsList);
        this.assignAccountZip(newAccountsList, idToOldAccountMap);
        this.phoneValidation(newAccountsList, idToOldAccountMap);
        this.phoneExtensionValidation(newAccountsList, idToOldAccountMap);
        this.websiteValidation(newAccountsList, idToOldAccountMap);
        this.populatePrimaryCatHubspotFormula(newAccountsList, idToOldAccountMap);
        this.assignSalesforceGeneratedGUID(newAccountsList,idToOldAccountMap);
        this.assignCountry(newAccountsList);
        this.checkAccountForPrimaryContact(newAccountsList, idToOldAccountMap);
        this.populateCBSSData(newAccountsList, idToOldAccountMap);
        this.populateActiveStatusChangeDate(newAccountsList, idToOldAccountMap);
        this.populateVIPProgramLastModifiedDate(newAccountsList,idToOldAccountMap);
        this.populatePreviousOwner(newAccountsList, idToOldAccountMap);
        this.populateExpirationChangeDate(newAccountsList, idToOldAccountMap);
        this.validateStatus(newAccountsList, idToOldAccountMap);
        this.cloneReasnValues(newAccountsList, idToOldAccountMap);
        this.updateOwnerBasedOnReasonUpdate(newAccountsList, idToOldAccountMap);
        this.commitXOExceptions();
    }

    public override void onAfterInsert() {  
        this.populateCompanyIdAndLocationId((List<Account>)Trigger.New);
        this.createAccountVIPStatusTask((List<Account>)Trigger.New, null);
        this.scoringAccounts((List<Account>)Trigger.New, null);
        this.commitXOExceptions();      
    }

    public override void onAfterUpdate() {  
        Map<Id, Account> idToOldAccountMap = (Map<Id, Account>)Trigger.oldMap;
        List<Account> newAccountsList = (List<Account>)Trigger.New;    
        this.cloneClientBillingCase(newAccountsList, idToOldAccountMap);
        this.updateChildAccountOwners(newAccountsList, idToOldAccountMap);
        this.populateCompanyIdAndLocationIdAfterUpdate(newAccountsList, idToOldAccountMap);
        this.updateBillingAccounts(newAccountsList, idToOldAccountMap);
        this.updateBillingAccountData(newAccountsList, idToOldAccountMap);
        this.createAccountVIPStatusTask(newAccountsList, idToOldAccountMap);
        this.updateAccountContactOwner(newAccountsList, idToOldAccountMap);
        this.scoringAccounts(newAccountsList, idToOldAccountMap);
        this.updateAccountAddress(newAccountsList, idToOldAccountMap);
        this.updateAccountHierarchy(newAccountsList, idToOldAccountMap);
        this.updateSalesRepAndRSD(newAccountsList, idToOldAccountMap);
        this.commitXOExceptions();
    }

    public override void onBeforeDelete() {
        this.updateNeedToCalActiveHierarchy((List<Account>)Trigger.Old);
        this.commitXOExceptions();
    }

    public override void onAfterDelete() {
        Map<Id, Account> idToOldAccountMap = (Map<Id, Account>)Trigger.oldMap;
        this.updateAccountHierarchy(null, idToOldAccountMap);
    }

    private void populateAccountsShippingAddress(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account accObj : accountsList) {
            if(idToOldAccountMap == null) {
                // CSP-2657 Unable to Convert Canadian Leads
                // fixing the bug when lead address is CA, and unable to convert to acconut
                if(accObj.BillingCountryCode == 'CA'){

                    this.populateShippingAddressForCA(accObj);
                }
                // for those BillingCountryCode is US, keep the logic
                else{
                    this.populateShippingAddressForUS(accObj);
                }
               
                //CSP-3077 Update Automation on Account to fill in Market based on the first three digits of Canadian Zip Codes
                //populate country code if country code is blank but country is not blank(insert from API)
                if(String.isNotBlank(accObj.ShippingCountry) && String.isBlank(accObj.ShippingCountryCode)){
                    accObj.ShippingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accObj.ShippingCountry);
                }
                if(String.isNotBlank(accObj.BillingCountry) && String.isBlank(accObj.BillingCountryCode)){
                    accObj.BillingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accObj.BillingCountry);
                }
                //populate state code if state code is blank but state is not blank(insert from API)
                if(String.isNotBlank(accObj.ShippingState) && String.isBlank(accObj.ShippingStateCode)){
                    accObj.ShippingStateCode = STATE_AND_STATECODE_MAP.get(accObj.ShippingState);
                }
                if(String.isNotBlank(accObj.BillingState) && String.isBlank(accObj.BillingStateCode)){
                    accObj.BillingStateCode = STATE_AND_STATECODE_MAP.get(accObj.BillingState);
                }
            } else {
                Account oldAccObj;
                if(idToOldAccountMap.containsKey(accObj.Id)) {
                    oldAccObj = idToOldAccountMap.get(accObj.Id);
                }
                if(oldAccObj.ShippingCountryCode == accObj.ShippingCountryCode && oldAccObj.ShippingCountry != accObj.ShippingCountry){
                    accObj.ShippingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accObj.ShippingCountry);
                }

                if(oldAccObj.BillingCountryCode == accObj.BillingCountryCode && oldAccObj.BillingCountry != accObj.BillingCountry){
                    accObj.BillingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accObj.BillingCountry);
                }
                //populate state code if only state is changed(update from API)
                if(oldAccObj.ShippingStateCode == accObj.ShippingStateCode && oldAccObj.ShippingState != accObj.ShippingState){
                    accObj.ShippingStateCode = STATE_AND_STATECODE_MAP.get(accObj.ShippingState);
                }

                if(oldAccObj.BillingStateCode == accObj.BillingStateCode  && oldAccObj.BillingState != accObj.BillingState){
                    accObj.BillingStateCode = STATE_AND_STATECODE_MAP.get(accObj.BillingState);
                }
        
            }
        }
    }

    private void populateShippingAddressForCA(Account accObj) {
        // means shipping country code is non-CA
        if(accObj.BillingCountryCode != accObj.ShippingCountryCode){
            // If below address fields are all empty, it should be converted
            if(String.isBlank(accObj.ShippingStreet) && String.isBlank(accObj.ShippingCity) &&
               String.isBlank(accObj.ShippingStateCode) && String.isBlank(accObj.ShippingPostalCode)){

                accObj.ShippingCountryCode = accObj.BillingCountryCode;
                accObj.ShippingStreet = accObj.BillingStreet;
                accObj.ShippingCity = accObj.BillingCity;
                accObj.ShippingStateCode = accObj.BillingStateCode;
                accObj.ShippingPostalCode = accObj.BillingPostalCode;
            }
        }
        // for handling both country code are the same
        else{
            accObj.ShippingCountryCode = String.isBlank(accObj.Fulfillment_Data__c) && (String.isNotBlank(accObj.ShippingCountryCode)) ? accObj.ShippingCountryCode : accObj.BillingCountryCode;
            accObj.ShippingStreet = (String.isNotBlank(accObj.ShippingStreet)) ? accObj.ShippingStreet : accObj.BillingStreet;
            accObj.ShippingCity = (String.isNotBlank(accObj.ShippingCity)) ? accObj.ShippingCity : accObj.BillingCity;
            accObj.ShippingStateCode = (String.isNotBlank(accObj.ShippingStateCode)) ? accObj.ShippingStateCode : accObj.BillingStateCode;
            accObj.ShippingPostalCode = (String.isNotBlank(accObj.ShippingPostalCode)) ? accObj.ShippingPostalCode : accObj.BillingPostalCode;
        }
    }

    private void populateShippingAddressForUS(Account accObj) {
        accObj.ShippingCountryCode = String.isBlank(accObj.Fulfillment_Data__c) && (String.isNotBlank(accObj.ShippingCountryCode)) ? accObj.ShippingCountryCode : accObj.BillingCountryCode;
        accObj.ShippingStreet = (String.isNotBlank(accObj.ShippingStreet)) ? accObj.ShippingStreet : accObj.BillingStreet;
        accObj.ShippingCity = (String.isNotBlank(accObj.ShippingCity)) ? accObj.ShippingCity : accObj.BillingCity;
        accObj.ShippingStateCode = (String.isNotBlank(accObj.ShippingStateCode)) ? accObj.ShippingStateCode : accObj.BillingStateCode;
        accObj.ShippingPostalCode = (String.isNotBlank(accObj.ShippingPostalCode)) ? accObj.ShippingPostalCode : accObj.BillingPostalCode;
    }
    
    /**
     * @description populating assignment map which will used in the later part of the code for assignning account 
     * owner based on local sales assignent rules
    */
    private void populateAssignmentMap(List<Account> accountsList) {
        Set<String> zipSet = new Set<String>();
        Set<Id> categoryIdSet = new Set<Id>();
        Set<Id> marketIdSet = new Set<Id>();
     
        for(Account accountRec : accountsList) {

            if(String.isNotBlank(accountRec.Local_Sales_Market__c)){
                marketIdSet.add(accountRec.Local_Sales_Market__c);
            }

            if(String.isNotBlank(accountRec.Primary_Category__c)){
                categoryIdSet.add(accountRec.Primary_Category__c);
            }

            if(String.isNotBlank(accountRec.BillingPostalCode)){
                zipSet.add(retrieveBillingPostalCode(accountRec));
            }                
        }
       
        for (Zip__c zipObj : [SELECT Id, ZipCode__c, Local_Market__c, Local_Market__r.Market_ID__c, City__c, State__c, Portfolio__c  
                              FROM Zip__c
                              WHERE ZipCode__c IN :zipSet]) {  
            marketIdSet.add(zipObj.Local_Market__c);
        }

        if(!zipSet.isEmpty() || !categoryIdSet.isEmpty() || !marketIdSet.isEmpty()) {
            AssignmentRulesUtility.buildAssignmentMap(marketIdSet, categoryIdSet, zipSet);
        }
    }

    /**
     * @description: Returning Billing Postal Codes
    */
    private String retrieveBillingPostalCode(Account accountRec) {
        String tempCountryCode = String.isNotBlank(accountRec.BillingCountryCode) ? accountRec.BillingCountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(accountRec.BillingCountry);

        if(accountRec.BillingPostalCode.length() >= 5 && tempCountryCode == 'US') {
            return accountRec.BillingPostalCode.left(5);
        }
        else if(accountRec.BillingPostalCode.length() >= 3 && (tempCountryCode == 'CA')) {
            return accountRec.BillingPostalCode.left(3).toUpperCase();
        }
        else {
            return accountRec.BillingPostalCode;
        }
    }

    /**
     * @description: This method deals with updated ParentId and Active Hierarchy information
    */
    private void populateAccountParentId(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<String, String> parentGUIDToAccountIdMap = new Map<String, String>();
        Set<Id> accountParentIdSet = new Set<Id>();
        Map<Id, Id> accountParentOwnerMap = new Map<Id, Id>();
        Map<Id, Id> accountParentMap = new Map<Id, Id>(); // Used for Lead convert setting of parent
       
        for(Account accountRec: accountsList) {

            // before uinsert 
            if(idToOldAccountMap == null) {

                if(String.isNotBlank(accountRec.Fulfillment_Data__c)){
                    LeadPayloadWrapper.FulfillData fulfillment = (LeadPayloadWrapper.FulfillData) JSON.deserialize(accountRec.Fulfillment_Data__c, LeadPayloadWrapper.FulfillData.class);
                    
                    if(String.isNotBlank(fulfillment.parentGUID)){
                        parentGUIDToAccountIdMap.put(fulfillment.parentGUID, accountRec.Id);
                    }
                }

                if(String.isNotBlank(accountRec.ParentId)) {
                    accountParentIdSet.add(accountRec.ParentId);
                }
            }

           //before update
            if(idToOldAccountMap != null) {
                if(String.isNotBlank(accountRec.ParentId) && accountRec.ParentId != idToOldAccountMap.get(accountRec.Id).ParentId){
                    accountParentIdSet.add(accountRec.ParentId);
                }
            }
        }

        // before insert 
        if(idToOldAccountMap == null) {
            if(parentGUIDToAccountIdMap.size() > 0){
                for(Account record : [select Id, DynamicsAccID__c from Account where DynamicsAccID__c IN : parentGUIDToAccountIdMap.keySet()]){
                    accountParentMap.put(parentGUIDToAccountIdMap.get(record.DynamicsAccID__c), record.Id);
                    accountParentIdSet.add(record.Id);
                }
            }
        }

        if(!accountParentIdSet.isEmpty()){
            for(Account record : [select id, OwnerId from Account where Id IN : accountParentIdSet]){
                accountParentOwnerMap.put(record.Id, record.OwnerId);
            }
        }

        for(Account accountRec: accountsList) {
            if(idToOldAccountMap == null) {
                
                if(accountParentMap.containsKey(accountRec.Id)){
                    accountRec.ParentId = accountParentMap.get(accountRec.Id);
                }

                if(String.isNotBlank(accountRec.ParentId)){
                    accountRec.OwnerId = accountParentOwnerMap.get(accountRec.ParentId);
                    // CSP-2906 Paid Status Across the Parent-Child Hierarchy
                    // if the account has parent, set the flag to "Yes", and then the batch will recalculated the active hierarchy
                    this.updateHierarchyDate(accountRec, 'Yes');
                }else{
                    // CSP-2906 Paid Status Across the Parent-Child Hierarchy
                    //  if the account have no parent, set the Active_Hierarchy__c to 'Not Applicable' and the flag to "No"
                    accountRec.Active_Hierarchy__c = 'Not Applicable';
                    this.updateHierarchyDate(accountRec, 'No');
                } 
            } else {

                if(String.isNotBlank(accountRec.ParentId) && accountRec.ParentId != idToOldAccountMap.get(accountRec.Id).ParentId){
                    accountRec.Ignore_Parent_Account__c = false;
                    accountRec.OwnerId = accountParentOwnerMap.get(accountRec.ParentId);
                }

                if (accountRec.ParentId != idToOldAccountMap.get(accountRec.Id).ParentId) {
                    this.updateHierarchyDate(accountRec, 'Yes');
                }
                
                // if the account status has been changed to 'Active' or changed from 'Active', set the flag to "Yes"
                if (accountRec.Account_Status__c != idToOldAccountMap.get(accountRec.Id).Account_Status__c 
                    && (accountRec.Account_Status__c == 'Active' || idToOldAccountMap.get(accountRec.Id).Account_Status__c == 'Active')) {
                    this.updateHierarchyDate(accountRec, 'Yes');
                }
            }
        }
    }


    /**
     * @description: Updating hierarchy information
     * @param: accountRec - Current account
     * @param: needToCalculateHierarchy - Contains values of either 'Yes' or 'No' which is assigned to the field Need_to_Recalculate_Active_Hierarchy__c
    */
    private void updateHierarchyDate(Account accountRec, String needToCalulateHierachy) {
        accountRec.Active_Hierarchy_Date__c = Date.today();
        accountRec.Need_to_Recalculate_Active_Hierarchy__c = needToCalulateHierachy;
    }

    /**
     * @description: This method udpates child accounts owner Ids based on the Parents ownerId
    */
    @TestVisible
    private void updateChildAccountOwners(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<Id, Id> accountParentOwnerMap = new Map<Id, Id>();

        for(Account accountRec: accountsList) {
            if(String.isBlank(accountRec.ParentId) && accountRec.OwnerId != idToOldAccountMap.get(accountRec.Id).OwnerId){
                accountParentOwnerMap.put(accountRec.Id, accountRec.OwnerId);
            }
        }

        if(!accountParentOwnerMap.isEmpty()){
            this.updateChildAccount(accountParentOwnerMap);
        }
    }

    private void updateChildAccount(Map<Id, Id> accountParentOwnerMap) {
        List<Account> childAccountToUpdate = new List<Account>();
        for(Account record : [SELECT Id, OwnerId, ParentId, Parent.OwnerId FROM Account WHERE ParentId IN : accountParentOwnerMap.keySet()]){
            if(record.OwnerId != record.Parent.OwnerId){
                record.OwnerId = record.Parent.OwnerId;
                childAccountToUpdate.add(record);
            }
        }
        
        if(childAccountToUpdate != null && childAccountToUpdate.size() > 0){
            Database.SaveResult[] updateResults = Database.update(childAccountToUpdate, false);
            this.exceptionList = ExceptionUtility.consumeException(updateResults);
        }
    }

    /**
     * @description: This method is used to assign values to accounts zip 
    */
    private void assignAccountZip(List<Account> accountsList, Map<Id, Account> idToOldAccountMap){

        Map<String, Zip__c> zipCodeToZipObjMap = populateZipCodeMap(accountsList, idToOldAccountMap);
        Map<String, Market__c> canadianmarketIdToMarketNameMap = new Map<String, Market__c>();
        Map<String, Canadian_Postal_Code_Market_Mapping__c> canadianMarketSettingMap = new Map<String, Canadian_Postal_Code_Market_Mapping__c>();
        Map<String, String> stateCodeMarketIdMap = new Map<String, String>();

        for(Market__c marketObj : [SELECT Id, Name, Market_ID__c FROM Market__c WHERE Country__c = 'CA']){
            canadianmarketIdToMarketNameMap.put(marketObj.Market_ID__c, marketObj);
        }

        for(Canadian_Postal_Code_Market_Mapping__c canadaMarket : Canadian_Postal_Code_Market_Mapping__c.getAll().values()) {
           canadianMarketSettingMap.put(canadaMarket.Canadian_Postal_Code__c, canadaMarket);
           //Get default market id
           if(String.isNotBlank(canadaMarket.Default_State_Code__c)) {
               stateCodeMarketIdMap.put(canadaMarket.Default_State_Code__c, canadaMarket.Market_Id__c);
           }
        }

        for(Account acc: accountsList) { 
            /**
             * CPS-3077 Update Automation on Account to fill in Market based on the first three digits of Canadian Zip Codes
             * Account postal code allows lowercase and the zipcode of Zip__c record is uppercase
             * CA Local_Sales_Market__c value assignments
             * so we need to uppercase the first three digits to match Zip__c record because canadian postal code contains alphabet
             * US Local_Sales_Market__c value assignments
             * we do not need to uppercase the first five digits of US postal code because US postal code is numeric
             */
            String billingPostalCodeCA = (String.isNotBlank(acc.BillingPostalCode))? acc.BillingPostalCode.left(3).toUpperCase() : acc.BillingPostalCode;
            String shippingPostalCodeCA = (String.isNotBlank(acc.ShippingPostalCode))? acc.ShippingPostalCode.left(3).toUpperCase() : acc.ShippingPostalCode;
            
            this.assignValuesToLocalSalesMarket(billingPostalCodeCA, shippingPostalCodeCA, acc, zipCodeToZipObjMap, canadianmarketIdToMarketNameMap, canadianMarketSettingMap, stateCodeMarketIdMap);

            // Zip__c value assignment
            // CSP-2838 Base Portfolio & Marketplace Health on Billing Zip
            // Zip__c value assign by Billing Postal Code
            if(String.isNotBlank(acc.BillingPostalCode)){
                
                if(acc.BillingCountryCode == 'US' &&  zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(acc.BillingPostalCode.left(5))){

                    acc.Zip__c = zipCodeToZipObjMap.get(acc.BillingPostalCode.left(5)).Id;
                //CPS-3077 Update Automation on Account to fill in Market based on the first three digits of Canadian Zip Codes
                //Follow the same business logic as US Zip__c assignment， we set Zip__c value based on billing postal code
                }else if(acc.BillingCountryCode == 'CA' && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(billingPostalCodeCA)){

                    acc.Zip__c = zipCodeToZipObjMap.get(billingPostalCodeCA).Id;
                }
            }else{
                acc.Zip__c = null;
            } 
        }
    }

     /**
     * @description: This method is used to assign values to Accounts Local Sales Market 
     * @param billingPostalCodeCA Billing Postal Code for Canada
     * @param shippingPostalCodeCA Shipping Postal Code for Canada
     * @param acc Current Account being iterated 
     * @param zipCodeToZipObjMap Map of Zip Code to Zip object record
    */
    private void assignValuesToLocalSalesMarket(String billingPostalCodeCA, String shippingPostalCodeCA, Account acc, Map<String, Zip__c> zipCodeToZipObjMap, 
                                                Map<String, Market__c> canadianmarketIdToMarketNameMap, Map<String, Canadian_Postal_Code_Market_Mapping__c> canadianMarketSettingMap, 
                                                Map<String, String> stateCodeMarketIdMap) {      
        //Shipping is preferred
        //If shipping postal code has a corresponding Zip__c record directly regardless of the shipping country
        if(String.isNotBlank(acc.ShippingPostalCode) && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(acc.ShippingPostalCode)){
            
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(acc.ShippingPostalCode).Local_Market__c;
        //If shipping country is United States,  we use the first five digits of shipping postal code to match Zip__c record
        }else if(acc.ShippingCountryCode == 'US' && String.isNotBlank(acc.ShippingPostalCode) 
            && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(acc.ShippingPostalCode.left(5))){
              
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(acc.ShippingPostalCode.left(5)).Local_Market__c;
        //If shipping country is Canada, we use the first three uppercase digits of shipping postal code to match Zip__c record
        }else if(acc.ShippingCountryCode == 'CA' && String.isNotBlank(shippingPostalCodeCA) 
            && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(shippingPostalCodeCA)){
            
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(shippingPostalCodeCA).Local_Market__c;
        //If shipping country is Canada, shipping postal code does not have a corresponding Zip__c record or shipping postal code is blank
        }else if(acc.ShippingCountryCode == 'CA'){
            
            //If shipping postal code does not have a corresponding Zip__c record, we use the first letter to get a corresponding market__c record
            //If we do not have a shipping postal code, we use shipping state to get a corresponding market__c record
            Market__c canadianMarket = DataUtility.getDefaultCanadaMarket(shippingPostalCodeCA, acc.ShippingStateCode, canadianmarketIdToMarketNameMap, canadianMarketSettingMap, stateCodeMarketIdMap);
            if(canadianMarket != null){ 
                acc.Local_Sales_Market__c = canadianMarket.Id;
            }
        }
        //If shipping postal code is blank, we use billing postal code
        //If billing postal code has a corresponding Zip__c record directly regardless of the billing country
        else if(String.isBlank(acc.ShippingPostalCode) && String.isNotBlank(acc.BillingPostalCode) 
               && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(acc.BillingPostalCode)){
                   
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(acc.BillingPostalCode).Local_Market__c;
        //If billing country is United States,  we use the first five digits of billing postal code to match Zip__c record
        }else if(String.isBlank(acc.ShippingPostalCode) && acc.BillingCountryCode == 'US' && String.isNotBlank(acc.BillingPostalCode) 
                && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(acc.BillingPostalCode.left(5))){
                    
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(acc.BillingPostalCode.left(5)).Local_Market__c;
        //If billing country is Canada, we use the first three uppercase digits of billing postal code to match Zip__c record
        }else if(String.isBlank(acc.ShippingPostalCode) && acc.BillingCountryCode == 'CA' && String.isNotBlank(billingPostalCodeCA) 
                && zipCodeToZipObjMap != null && zipCodeToZipObjMap.containsKey(billingPostalCodeCA)){
                
            acc.Local_Sales_Market__c = zipCodeToZipObjMap.get(billingPostalCodeCA).Local_Market__c;
        //If billing country is Canada, billing postal code does not have a corresponding Zip__c record or billing postal code is blank
        }else if(String.isBlank(acc.ShippingPostalCode) && acc.BillingCountryCode == 'CA'){
            
            //If billing postal code does not have a corresponding Zip__c record, we use the first letter to get a corresponding market__c record
            //If we do not have a billing postal code, we use billing state to get a corresponding market__c record
            Market__c canadianMarket = DataUtility.getDefaultCanadaMarket(billingPostalCodeCA, acc.BillingStateCode, canadianmarketIdToMarketNameMap, canadianMarketSettingMap, stateCodeMarketIdMap);
            if(canadianMarket != null){
                acc.Local_Sales_Market__c = canadianMarket.Id;
            }
        }
    }

    private Map<String, Zip__c>  populateZipCodeMap(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<String, Zip__c> zipCodeToZipObjMap = new Map<String, Zip__c>();
        Set<String> zipCodeSet = new Set<String>();

        for(Account accountRec : accountsList) {
            if(idToOldAccountMap == null) {
                String tempBillingCountryCode = String.isNotBlank(accountRec.BillingCountryCode)? accountRec.BillingCountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(accountRec.BillingCountry);
                String tempShippingCountryCode = String.isNotBlank(accountRec.ShippingCountryCode)? accountRec.ShippingCountryCode : COUNTRY_AND_COUNTRYCODE_MAP.get(accountRec.ShippingCountry);

                zipCodeSet.addAll(this.populateZipCodeSet(accountRec, tempBillingCountryCode, tempShippingCountryCode));

            } else {
                Account oldnewAccObj = idToOldAccountMap.get(accountRec.Id);

                if(checkForChangeInAddress(accountRec, oldnewAccObj)){
                   
                    // CSP-3077 Update Automation on Account to fill in Market based on the first three digits of Canadian Zip Codes
                    // country code may be not the same as country name from API update(new country name, old country code)
                    // country code may be not the same as country name from UI update(new country code, old country name)
                    String tempBillingCountryCode = accountRec.BillingCountryCode;
                    String tempShippingCountryCode = accountRec.ShippingCountryCode;
                    
                    if(oldnewAccObj.BillingCountry != accountRec.BillingCountry){
                        tempBillingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accountRec.BillingCountry);
                    }

                    if(oldnewAccObj.ShippingCountry != accountRec.ShippingCountry){
                        tempShippingCountryCode = COUNTRY_AND_COUNTRYCODE_MAP.get(accountRec.ShippingCountry);
                    }

                    zipCodeSet.addAll(this.populateZipCodeSet(accountRec, tempBillingCountryCode, tempShippingCountryCode));
                }           
            }
        }

        // CSP-1820 | combined populating the zipCodeToZipObjMap and setting the canadaMarketRecordId into a single query
        for (Zip__c zipObj : [SELECT Id, ZipCode__c, MetroArea__c, Local_Market__c, Local_Market__r.Market_ID__c
                                FROM Zip__c 
                                WHERE ZipCode__c IN :zipCodeSet ]){
            zipCodeToZipObjMap.put(zipObj.ZipCode__c, zipObj);
        }
        return zipCodeToZipObjMap;
    }

    /**
     * @description: Return true only if there is a change in the address
    */
    private Boolean checkForChangeInAddress(Account accountRec, Account oldnewAccObj) {
        if(accountRec.ShippingPostalCode  != oldnewAccObj.ShippingPostalCode || accountRec.BillingPostalCode != oldnewAccObj.BillingPostalCode
                   || accountRec.ShippingCountryCode  != oldnewAccObj.ShippingCountryCode || accountRec.BillingCountryCode != oldnewAccObj.BillingCountryCode
                        || accountRec.ShippingStateCode  != oldnewAccObj.ShippingStateCode || accountRec.BillingStateCode != oldnewAccObj.BillingStateCode
                            || accountRec.ShippingCountry  != oldnewAccObj.ShippingCountry || accountRec.BillingCountry != oldnewAccObj.BillingCountry
                                || accountRec.ShippingState  != oldnewAccObj.ShippingState || accountRec.BillingState != oldnewAccObj.BillingState){

            return true;
        }
        return false;
    }

    /**
     * @description Populate a set of strings containss zip code which is used by other methods
    */
    //CSP-3077 Update Automation on Account to fill in Market based on the first three digits of Canadian Zip Codes
    //query corresponding zip records based on the first three digits of Canadian Zip Codes
    private Set<String> populateZipCodeSet(Account accountRec, String tempBillingCountryCode, String tempShippingCountryCode) {
        Set<String> zipCodeSet = new Set<String>();

        if(String.isNotBlank(accountRec.ShippingPostalCode)){
            zipCodeSet.addAll(populateShippingPostalCodeSet(accountRec, tempShippingCountryCode));
        } 
        if(String.isNotBlank(accountRec.BillingPostalCode)){
            zipCodeSet.addAll(populateBillingPostalCodeSet(accountRec, tempBillingCountryCode));
        }
        return zipCodeSet;
    }

    private Set<String> populateShippingPostalCodeSet(Account accountRec, String tempShippingCountryCode) {

        Set<String> zipCodeSet = new Set<String>();

        if(tempShippingCountryCode == 'US'){
            zipCodeSet.add(accountRec.ShippingPostalCode.left(5));
        }else if(tempShippingCountryCode == 'CA'){
            zipCodeSet.add(accountRec.ShippingPostalCode.left(3).toUpperCase());
        }else{
            zipCodeSet.add(accountRec.ShippingPostalCode);
        }

        return zipCodeSet;
    }

    private Set<String> populateBillingPostalCodeSet(Account accountRec, String tempBillingCountryCode) {

        Set<String> zipCodeSet = new Set<String>();

        if(tempBillingCountryCode == 'US'){
            zipCodeSet.add(accountRec.BillingPostalCode.left(5));
        }else if(tempBillingCountryCode == 'CA'){
            zipCodeSet.add(accountRec.BillingPostalCode.left(3).toUpperCase());
        }else{
            zipCodeSet.add(accountRec.BillingPostalCode);
        }
        return zipCodeSet;
    }

    /**
     * @description Populate Salesforce_Generated_GUID__c along with DynamicesAccountID
    */
    private void assignSalesforceGeneratedGUID(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account newAccObj: accountsList) {
            if(idToOldAccountMap != null) {
                if(newAccObj.DynamicsAccID__c != idToOldAccountMap.get(newAccObj.Id).DynamicsAccID__c && newAccObj.DynamicsAccID__c != null 
                    && idToOldAccountMap.get(newAccObj.Id).DynamicsAccID__c != null && idToOldAccountMap.get(newAccObj.Id).Salesforce_Generated_GUID__c){                       
                    newAccObj.Salesforce_Generated_GUID__c = false;
                }
            } else {
                if(String.isBlank(newAccObj.DynamicsAccID__c)){
                    newAccObj.DynamicsAccID__c = RandomStringUtils.randomUUID();
                    newAccObj.Salesforce_Generated_GUID__c = true;
                }
            }            
        }
    }

    /**
     * @description This method check if the Account has a primary contact. In case it does not, it throws an error
    */
    private void checkAccountForPrimaryContact(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> accountWithPrimaryContactRoleSet = new Set<Id>();
        Set<Id> checkAccountForPrimaryContactRoleIdSet = new Set<Id>();

        for(Account newnewAccObj : accountsList) {
            if(newnewAccObj.Fulfill_Storefront__c && !idToOldAccountMap.get(newnewAccObj.Id).Fulfill_Storefront__c){
                if(String.isBlank(newnewAccObj.ParentId)){
                    checkAccountForPrimaryContactRoleIdSet.add(newnewAccObj.Id);
                }else{
                    checkAccountForPrimaryContactRoleIdSet.add(newnewAccObj.ParentId);
                }
            }
        }

        if(checkAccountForPrimaryContactRoleIdSet.size() > 0){
            for(Account newAccObj : [SELECT Id, 
                                         (SELECT Id, Role FROM AccountContactRoles WHERE Role = 'Primary' AND Contact.Email != null) 
                                     FROM Account 
                                     WHERE Id 
                                     IN: checkAccountForPrimaryContactRoleIdSet]){
                
                if(!newAccObj.AccountContactRoles.isEmpty()){
                    accountWithPrimaryContactRoleSet.add(newAccObj.Id);
                }
            }
        }

        for(Account newnewAccObj : accountsList) {
            if(newnewAccObj.Fulfill_Storefront__c && !idToOldAccountMap.get(newnewAccObj.Id).Fulfill_Storefront__c && !accountWithPrimaryContactRoleSet.contains(newnewAccObj.Id) && String.isBlank(newnewAccObj.ParentId)){
                newnewAccObj.Fulfill_Storefront__c.addError('This Account needs a Primary Contact with an Email!');
            } else if(newnewAccObj.Fulfill_Storefront__c && !idToOldAccountMap.get(newnewAccObj.Id).Fulfill_Storefront__c && !accountWithPrimaryContactRoleSet.contains(newnewAccObj.ParentId) && String.isNotBlank(newnewAccObj.ParentId)){
                newnewAccObj.Fulfill_Storefront__c.addError('This Account\'s Parent Account needs a Primary Contact with an Email!');
            }
        }        
    }

    /**
     * @description This method is used to populate Primary_Category_Hubspot_Formula__c
    */
    private void populatePrimaryCatHubspotFormula(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> primaryCategoryIdSet = new Set<id>();
        Map<Id,String> categoryIdToCategoryNameMap = new Map<Id,String>();   
        
        for(Account newnewAccObj : accountsList) {
            if(idToOldAccountMap == null) {
                if(String.isNotBlank(newnewAccObj.Primary_Category__c)) {
                    primaryCategoryIdSet.add(newnewAccObj.Primary_Category__c);
                }
            } else {
                if(String.isNotBlank(newnewAccObj.Primary_Category__c) && newnewAccObj.Primary_Category__c != idToOldAccountMap.get(newnewAccObj.Id).Primary_Category__c){
                    primaryCategoryIdSet.add(newnewAccObj.Primary_Category__c);
                }
            }
        }
       
        if(!primaryCategoryIdSet.isEmpty()){
            categoryIdToCategoryNameMap = retrievePrimaryCategories(primaryCategoryIdSet);
        }

        for(Account newnewAccObj : accountsList) {
            if(idToOldAccountMap == null) {
                if(String.isNotBlank(newnewAccObj.Primary_Category__c)){
                    newnewAccObj.Primary_Category_Hubspot_Formula__c = categoryIdToCategoryNameMap.get(newnewAccObj.Primary_Category__c);
                }
            } else {
                 if(String.isNotBlank(newnewAccObj.Primary_Category__c) && categoryIdToCategoryNameMap.containsKey(newnewAccObj.Primary_Category__c)){
                    newnewAccObj.Primary_Category_Hubspot_Formula__c = categoryIdToCategoryNameMap.get(newnewAccObj.Primary_Category__c);
                }
            }
        }
    }


    private Map<Id,String> retrievePrimaryCategories(Set<Id> primaryCategoryIdSet) {
        Map<Id,String> categoryIdToCategoryNameMap = new Map<Id,String>();   

        for(Category__c categoryObj : [SELECT Id, 
                                              Name 
                                       FROM Category__c 
                                       WHERE Id 
                                       IN : primaryCategoryIdSet]){
            categoryIdToCategoryNameMap.put(categoryObj.Id,categoryObj.Name);
        }

        return categoryIdToCategoryNameMap;
    }

    /**
     * @description This method is used to populate Local_Sales_Market_Hubspot_Formula__c
    */
    private void populateLocalSalesMarketHubspotFormula(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<Id,String> marketIdToMarketNameMap = new Map<Id,String>();   
        Set<Id> localSalesMaketIdSet = new Set<Id>();
        
        for(Account newAccObj : accountsList) {
            if(idToOldAccountMap == null) {
                if(String.isNotBlank(newAccObj.Local_Sales_Market__c)) {
                    localSalesMaketIdSet.add(newAccObj.Local_Sales_Market__c);
                }
            } else {
                if(String.isNotBlank(newAccObj.Local_Sales_Market__c) && newAccObj.Local_Sales_Market__c != idToOldAccountMap.get(newAccObj.Id).Local_Sales_Market__c){
                    localSalesMaketIdSet.add(newAccObj.Local_Sales_Market__c);
                }
            }
        }
       
        if(!localSalesMaketIdSet.isEmpty()){
            for(Market__c marketObj : [SELECT Id, Name FROM Market__c WHERE Id IN : localSalesMaketIdSet]){
                marketIdToMarketNameMap.put(marketObj.Id,marketObj.name);
            }
        }

        for(Account newAccObj : accountsList) {
            if(String.isNotBlank(newAccObj.Local_Sales_Market__c) && marketIdToMarketNameMap.containsKey(newAccObj.Local_Sales_Market__c)){
                newAccObj.Local_Sales_Market_Hubspot_Formula__c = marketIdToMarketNameMap.get(newAccObj.Local_Sales_Market__c);
            }
        }
    }

    /**
     * @description This method is used to populate CBSS information on the Account 
    */
    private void populateCBSSData(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<Id, User> userMap;
        Set<Id> userIdSet = new Set<Id>();

        // bulk before insert 
        for(Account newAccObj : accountsList) {
            userIdSet = populateUserIdSet(newAccObj, idToOldAccountMap);
        }

        if(userIdSet.size() > 0){
            userMap = new Map<Id, User>([SELECT Id, Name, Title, Email, Phone, ARR__c, ARR__r.Phone, ARR__r.Email, SOR__C, Strategy_Specialist__c FROM User WHERE Id IN :userIdSet]);
        } else {
            userMap = new Map<Id, User>();
        }

        for(Account newAccObj : accountsList) {

            User currentOwner;
            if(userMap.containsKey(newAccObj.OwnerId)) {
                currentOwner = userMap.get(newAccObj.OwnerId);
            }

            if(currentOwner != null) {

                if(idToOldAccountMap != null) {
                    // CSP-596 | if override isn't checked, set CBBS__c to record.Owner.ARR__c
                    if(!newAccObj.Override_Account_CBSS__c && currentOwner != null) {
                        // If the field Override_Account_CBSS__c had been set to FALSE from TRUE, update the CBBS__c
                        if(newAccObj.Override_Account_CBSS__c != idToOldAccountMap.get(newAccObj.Id).Override_Account_CBSS__c) {
                            // Set the CBSS Zuora Update flag to true as the values have changed
                            this.updateZuoraAccountCBSS = true;
                            if(String.isNotBlank(currentOwner.ARR__c)) {
                                newAccObj.CBBS__c = currentOwner.ARR__c;
                            } else {
                                newAccObj.CBBS__c = null;
                            }
                        } 
                        // If account's Owner had been changed and the owner's ARR is not blank, update the CBBS__c to the Owner's ARR
                        else if(String.isNotBlank(currentOwner.ARR__c) && newAccObj.CBBS__c != currentOwner.ARR__c) {
                            // Set the CBSS Zuora Update flag to true as the values have changed
                            this.updateZuoraAccountCBSS = true;
                            newAccObj.CBBS__c = currentOwner.ARR__c;
                        }
                        // If account's Owner ARR is blank null the CBSS value
                        else if(String.isBlank(currentOwner.ARR__c)) {
                            // Set the CBSS Zuora Update flag to true as the values have changed
                            this.updateZuoraAccountCBSS = true;
                            newAccObj.CBBS__c = null;
                        }
                    }
                }

                if(idToOldAccountMap == null) {
                    if(!newAccObj.Override_Account_CBSS__c && String.isNotBlank(currentOwner.ARR__c)){
                        newAccObj.CBBS__c = currentOwner.ARR__c;
                    }
                }

                // CSP-1128
                if(userMap.containsKey(newAccObj.CBBS__c)) {

                    if(idToOldAccountMap == null) {
                        this.assignCBSSPhoneAndEmail(newAccObj, userMap.get(newAccObj.CBBS__c));
                    }

                    if(idToOldAccountMap != null) {
                        if(newAccObj.CBBS__c != idToOldAccountMap.get(newAccObj.Id).CBBS__c) {
                            this.updateZuoraAccountCBSS = true;
                            //this.assignCBSSPhoneAndEmail(newAccObj, userMap.get(newAccObj.CBBS__c));
                            User test = new User();
                            this.assignCBSSPhoneAndEmail(newAccObj, test);

                        }
                    }
                } else if(String.isNotBlank(currentOwner.ARR__c)) {
                    User currentCBSS = currentOwner.ARR__r;
                    this.assignCBSSPhoneAndEmail(newAccObj, currentCBSS);
                } else if (CBSS_DEFAULT_VALUES != null) {
                    newAccObj.CBSS_Email__c = CBSS_DEFAULT_VALUES.Email__c;
                    newAccObj.CBSS_Phone__c = CBSS_DEFAULT_VALUES.Phone__c;
                }
            }

            if(idToOldAccountMap != null) {
                if(currentOwner != null) {
                    populateLastAMTransferDate(newAccObj, idToOldAccountMap.get(newAccObj.Id), currentOwner, userMap);
                    populateSOR(newAccObj, idToOldAccountMap.get(newAccObj.Id), currentOwner);
                    populateStrategySpecialist(newAccObj, idToOldAccountMap.get(newAccObj.Id), currentOwner);
                }
            } else {
                if(currentOwner != null) {
                    populateLastAMTransferDate(newAccObj, null, currentOwner, userMap);
                    populateSOR(newAccObj, null, currentOwner);
                    populateStrategySpecialist(newAccObj, null, currentOwner);
                }
            }
        }
    }

    private Set<Id> populateUserIdSet(Account newAccObj, Map<Id, Account> idToOldAccountMap) {
        Set<Id> userIdSet = new Set<Id>();
        userIdSet.add(newAccObj.OwnerId);

        if(idToOldAccountMap == null) {                
            if (newAccObj.Override_Account_CBSS__c) {
                if (newAccObj.CBBS__c != null) {
                    userIdSet.add(newAccObj.CBBS__c);
                } else {
                    newAccObj.Override_Account_CBSS__c = false;
                }
            }
        } else {
            userIdSet.add(newAccObj.CBBS__c);
        }

        return userIdSet;
    }

    /**
     * @description: Populate Last AM Transfer Date to Today if the tile on the user is equal to Account Manager 
    */
    private void populateLastAMTransferDate(Account newAccObj, Account oldAccObj, User currentOwner, Map<Id, User> userMap) {
        if(oldAccObj == null) {
            // Stamp date to Last AM Transfer when Account owner title is Account Manage
            if(currentOwner.Title == Label.Account_Manager) {
                newAccObj.Last_AM_Transfer__c = system.today();
            }
        }

        if(oldAccObj != null) {
            if(newAccObj.OwnerId != oldAccObj.OwnerId && userMap.containsKey(newAccObj.OwnerId)) {
                currentOwner = userMap.get(newAccObj.OwnerId);
               
                if(currentOwner != null && currentOwner.Title == Label.Account_Manager) {
                    newAccObj.Last_AM_Transfer__c = system.today();
                }
            }                
        }
    }

    /**
     * @description: Populate SOR 
    */
    private void populateSOR(Account newAccObj, Account oldAccObj, User currentOwner) {
        if(currentOwner != null && String.isNotBlank(currentOwner.SOR__c)){
            if(oldAccObj == null && String.isBlank(newAccObj.SOR__c)) {
                newAccObj.SOR__c = currentOwner.SOR__c;
            } else {
                if(newAccObj.OwnerId != oldAccObj.OwnerId || String.isBlank(newAccObj.SOR__c) && currentOwner != null){
                    newAccObj.SOR__c = currentOwner.SOR__c;
                }
            }
        }
    }

    /**
     * @description: Populate Strategy Specialist  
    */ 
    private void populateStrategySpecialist(Account newAccObj, Account oldAccObj, User currentOwner) {
        if(currentOwner != null && String.isNotBlank(currentOwner.Strategy_Specialist__c)){
            if(oldAccObj == null) {
                if(String.isBlank(newAccObj.Strategy_Specialist__c)) {
                    newAccObj.Strategy_Specialist__c = currentOwner.Strategy_Specialist__c;
                }
            } else {
                if((newAccObj.OwnerId != oldAccObj.OwnerId || String.isBlank(newAccObj.Strategy_Specialist__c)) 
                        && currentOwner != null){
                    newAccObj.Strategy_Specialist__c = currentOwner.Strategy_Specialist__c;
                }
            }
        }
    }

    /**
     * @description: Populate CSBSS Phone and CBSS Email  
    */
    private void assignCBSSPhoneAndEmail(Account newAccObj, User currentCBSS) {

        if(String.isNotBlank(currentCBSS.Email) && currentCBSS.Email != newAccObj.CBSS_Email__c){
            newAccObj.CBSS_Email__c = currentCBSS.Email;
        } else if(CBSS_DEFAULT_VALUES != null) {
            newAccObj.CBSS_Email__c = CBSS_DEFAULT_VALUES.Email__c;
        }

        if(String.isNotBlank(currentCBSS.Phone) && currentCBSS.Phone != newAccObj.CBSS_Phone__c) {
            newAccObj.CBSS_Phone__c = currentCBSS.Phone;
        } else if(CBSS_DEFAULT_VALUES != null) {
            newAccObj.CBSS_Phone__c = CBSS_DEFAULT_VALUES.Phone__c;
        }
    }

    /**
     * @description: Populate Active Statue Change Date  
    */
    private void populateActiveStatusChangeDate(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account accountRec : accountsList) {
            if(accountRec.Local_Active__c && !idToOldAccountMap.get(accountRec.Id).Local_Active__c) {
                accountRec.Active_Status_Change_Date__c = Datetime.Now();
            }
        }
    }

    /**
     * @description: Populate VIP Program Last Modified Date  
    */
    private void populateVIPProgramLastModifiedDate(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account accountRec : accountsList) {

            if(idToOldAccountMap != null) {
                if(accountRec.VIP_Program__c != idToOldAccountMap.get(accountRec.Id).VIP_Program__c) {
                    accountRec.VIP_Program_Last_Modified_Date__c = Date.today();
                }
            } else {
                accountRec.VIP_Program_Last_Modified_Date__c = Date.today();
            }
        }
    }

    /**
     * @description: Populate Previous Owner and Ownership changed date 
    */
    private void populatePreviousOwner(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {

        Map<String,String> AccountOwnerNameMap = new Map<String,String>();

        List<Account> accountChangedList = retrieveAccountsWithOwnerName();
        
        for(Account acc : accountChangedList){
            accountOwnerNameMap.put(acc.OwnerID, acc.Owner.Name);
        }

        for(Account newAccObj : accountsList) {

            if(idToOldAccountMap == null) {
                newAccObj.Ownership_Changed_Date__c = System.today();
            } else if(newAccObj.OwnerId != idToOldAccountMap.get(newAccObj.Id).OwnerId){
                newAccObj.PreviousOwner__c = AccountOwnerNameMap.get(idToOldAccountMap.get(newAccObj.Id).OwnerID);
                newAccObj.Ownership_Changed_Date__c = System.today();
            }
        }
    }

    private List<Account> retrieveAccountsWithOwnerName() {
        return [SELECT Id, OwnerId, Owner.Name 
                FROM Account 
                WHERE ID IN: (List<Account>)Trigger.New];
    }

    /**
     * @description: Populate Expiration Changed Date  
    */
    private void populateExpirationChangeDate(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account newAccObj : accountsList) {
            if(newAccObj.Local_Paid_Status__c != idToOldAccountMap.get(newAccObj.Id).Local_Paid_Status__c && 
                newAccObj.Local_Paid_Status__c == 'Expired'){
                newAccObj.Expiration_Changed_Date__c = System.today();
            }    
        }
    }

    private void validateStatus(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> activeSubAccSet = new Set<Id>();
        Set<Id> openedOppSet = new Set<Id>();
        List<Opportunity> openedOppList = new List<Opportunity>();
        List<Account> statusChangeAccList = new List<Account>();
        List<Zuora__Subscription__c> activeSubsList = new List<Zuora__Subscription__c>();

        for(Account newAccObj : accountsList) {
            if(newAccObj.account_status__c != idToOldAccountMap.get(newAccObj.Id).account_status__c){
                statusChangeAccList.add(newAccObj);
            }
        }

        if(!statusChangeAccList.isEmpty()){

            activeSubsList = queryActiveSubs(statusChangeAccList);
             for(Zuora__Subscription__c sub : activeSubsList){
                activeSubAccSet.add(sub.Zuora__Account__c);
            }

            openedOppList = queryOpenOpps(statusChangeAccList);
            for(Opportunity opp : openedOppList){
                openedOppSet.add(opp.AccountId);
            }
        }

        for(Account newAccObj : accountsList) {

            String newStatus = newAccObj.account_status__c != NULL? newAccObj.account_status__c:'';
            String oldStatus = idToOldAccountMap.get(newAccObj.Id).account_status__c != NULL? idToOldAccountMap.get(newAccObj.Id).account_status__c:'';

            // CSP-2821 Selling to a Prospect
            // validate the status from non Active to Active
            if(!activeSubAccSet.contains(newAccObj.Id) && !oldStatus.equalsIgnoreCase('Active') && newStatus.equalsIgnoreCase('Active')){
                newAccObj.addError(Label.NonActiveErrMsg);
                return;
            }

            // CSP-2821 Selling to a Prospect
            // validate the status from non In opportunity to In Opportunity
            if(!openedOppSet.contains(newAccObj.Id) && !oldStatus.equalsIgnoreCase('In Opportunity') && newStatus.equalsIgnoreCase('In Opportunity')){
                newAccObj.addError(Label.NonInOpportunityErrMsg);
                return;
            }

            // CSP-2821 Selling to a Prospect
            // validate the status from Active to non Active
            if(activeSubAccSet.contains(newAccObj.Id) && !newStatus.equalsIgnoreCase('Active')){
                newAccObj.addError(Label.ActiveErrorMsg);
                return;
            }

            // CSP-2821 Selling to a Prospect
            // validate the status from In opportunity to non In Opportunity, 
            else if(openedOppSet.contains(newAccObj.Id) && !newStatus.equalsIgnoreCase('In Opportunity') && 
                    !newStatus.equalsIgnoreCase('Active')){
                newAccObj.addError(Label.InOpportunityErrorMsg);
                return;
            }
        }
    }

    /**
     * @description: Query all active subs 
    */
    private List<Zuora__Subscription__c> queryActiveSubs(List<Account> statusChangeAccList) {
        return [SELECT Id, Zuora__TermEndDate__c, Zuora__Account__c 
                FROM Zuora__Subscription__c 
                WHERE Zuora__Account__c 
                IN: statusChangeAccList
                AND Zuora__TermEndDate__c >=: System.today()];
    }

    /**
     * @description: Query all open opportunities
    */
    private List<Opportunity> queryOpenOpps(List<Account> statusChangeAccList) {
        return [SELECT Id, AccountId 
                FROM Opportunity 
                WHERE AccountId 
                IN: statusChangeAccList 
                AND IsClosed = FALSE];
    }

    /**
     * @description: Populate Negative Disposition Reasom and Reason Details based on Status information 
    */
    private void cloneReasnValues(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account newAccObj : accountsList) {
            String newReason = newAccObj.Negative_Disposition_Reason__c != NULL? newAccObj.Negative_Disposition_Reason__c:'';
            String oldReason = idToOldAccountMap.get(newAccObj.Id).Negative_Disposition_Reason__c != NULL? idToOldAccountMap.get(newAccObj.Id).Negative_Disposition_Reason__c:'';
            String newStatus = newAccObj.account_status__c != NULL? newAccObj.account_status__c:'';
            
            if(newStatus != 'Dormant' && newStatus != 'Disqualified'){
                newAccObj.Negative_Disposition_Reason__c = '';
                newAccObj.Reason_Details__c = '';
            }
            if(oldReason == 'Other' && newReason != 'Other'){
                newAccObj.Reason_Details__c = '';
            }
        }
    }

    private void updateOwnerBasedOnReasonUpdate(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        for(Account newAccObj : accountsList) {
            String newReason = newAccObj.Negative_Disposition_Reason__c != NULL? newAccObj.Negative_Disposition_Reason__c:'';
            String oldReason = idToOldAccountMap.get(newAccObj.Id).Negative_Disposition_Reason__c != NULL? idToOldAccountMap.get(newAccObj.Id).Negative_Disposition_Reason__c:'';

            if(checkForDateEnrichmentPass(newReason, oldReason)){
                newAccObj.OwnerId = Label.DataEnrichmentUserId;
            }

            // If reason changed, and changed to the following vlaues then assign to data enrichment team
            // Out of Business
            // Do Not Contact
            else if(newReason.equalsIgnoreCase('Out of Business') && !oldReason.equalsIgnoreCase('Out of Business') || 
                newReason.equalsIgnoreCase('Do Not Contact') && !oldReason.equalsIgnoreCase('Do Not Contact')){    
                newAccObj.OwnerId = Label.DeadUserId;
            }
        }
    }    

    private Boolean checkForDateEnrichmentPass(String newReason, String oldReason) {
        if(newReason.equalsIgnoreCase('Bad Contact') && !oldReason.equalsIgnoreCase('Bad Contact') || 
            newReason.equalsIgnoreCase('Duplicate') && !oldReason.equalsIgnoreCase('Duplicate') ||
                newReason.equalsIgnoreCase('Missing Required Information') && !oldReason.equalsIgnoreCase('Missing Required Information') ||
                    newReason.equalsIgnoreCase('Not My Territory') && !oldReason.equalsIgnoreCase('Not My Territory') ||
                        newReason.equalsIgnoreCase('Not Wedding Related') && !oldReason.equalsIgnoreCase('Not Wedding Related')){
            return true;
        }
        return false;
    }

    private void updateNeedToCalActiveHierarchy(List<Account> oldAccountList) {
        Set<Id> deleteAccountIdSet = new Set<Id>();
        
        for(Account newAccObj : oldAccountList) {
            deleteAccountIdSet.add(newAccObj.Id);
        }     

        if (!deleteAccountIdSet.isEmpty()) {
            List<Account> childAccList = [SELECT Id,Active_Hierarchy_Date__c,Need_to_Recalculate_Active_Hierarchy__c FROM Account WHERE ParentId IN: deleteAccountIdSet];
            for (Account childAcc : childAccList) {
                updateHierarchyDate(childAcc, 'Yes');
            }

            if (!childAccList.isEmpty()) {
                List<Database.SaveResult> updateResults = Database.update(childAccList,false);
                this.exceptionList = ExceptionUtility.consumeException(updateResults);
            }
        }   
    }

    // afterinsert
    private void populateCompanyIdAndLocationId(List<Account> newAccountsList) {
        
        Set<Id> profielIds = new Set<Id>();
        String profiles_can_Fulfill_to_Partners = Label.Profiles_can_Fulfill_to_Partners;
        for (String idString : profiles_can_Fulfill_to_Partners.split(',')) {
            profielIds.add((Id)idString);
        }

        Id profileId = UserInfo.getProfileId() ;

        List<RESTLocalStorefrontAPI.ObjectWrapper> orderFulfillmentList = new List<RESTLocalStorefrontAPI.ObjectWrapper>();
        Map<String, String> parentIdGUIDMap = new Map<String, String>(); 
        Set<Id> accountParentIdSet = new Set<Id>();

        for(Account accObj : newAccountsList) {
            if(String.isNotBlank(accObj.ParentId)){
                accountParentIdSet.add(accObj.ParentId);
            }
        } 

        if(accountParentIdSet.size() > 0){
            for(Account accObj : [SELECT Id, DynamicsAccID__c FROM Account WHERE Id IN : accountParentIdSet]){
                parentIdGUIDMap.put(accObj.Id, accObj.DynamicsAccID__c);
            }
        }

        for(Account accountObj : newAccountsList) {
            
            if(String.isNotBlank(accountObj.DynamicsAccID__c) 
                    && accountObj.Fulfill_Storefront__c 
                    && XOGroupSettingUtility.getPartnerCalloutSetting() 
                    && (accountObj.Account_Status__c == 'Active' || profielIds.contains(profileId) )){
                
                RESTLocalStorefrontAPI.ObjectWrapper objWrapper = new RESTLocalStorefrontAPI.ObjectWrapper();
                objWrapper.locationId = accountObj.DynamicsAccID__c;
            
                if(String.isBlank(accountObj.ParentId) || accountObj.Ignore_Parent_Account__c == true){
                    objWrapper.companyId = accountObj.DynamicsAccID__c;
                }else if(String.isNotBlank(accountObj.ParentId) && parentIdGUIDMap.containsKey(accountObj.ParentId)){
                    objWrapper.companyId = parentIdGUIDMap.get(accountObj.ParentId);
                }else if(String.isNotBlank(accountObj.ParentId) && !parentIdGUIDMap.containsKey(accountObj.ParentId)){
                    accountObj.ParentId.addError('Please generate a GUID for the parent Account');
                }
                orderFulfillmentList.add(objWrapper);
            }
        }

        if(!orderFulfillmentList.isEmpty() && !system.isBatch() && !system.isFuture() && XOGroupSettingUtility.getPartnerCalloutSetting()){
            PartnerCallouts.partnerOrderCallout(JSON.serializePretty(orderFulfillmentList));
        }
    }

    // afterupdate
    private void populateCompanyIdAndLocationIdAfterUpdate(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        
        List<RESTLocalStorefrontAPI.ObjectWrapper> orderFulfillmentList = new List<RESTLocalStorefrontAPI.ObjectWrapper>();
        List<RESTLocalStorefrontAPI.ObjectWrapper> accountUpdateList = new List<RESTLocalStorefrontAPI.ObjectWrapper>();
        Map<String, String> parentIdGUIDMap = new Map<String, String>(); 
        Set<Id> accountParentIdSet = new Set<Id>();

        for(Account accObj : accountsList) {
            if(String.isNotBlank(accObj.ParentId)){
                accountParentIdSet.add(accObj.ParentId);
            }
        } 

        if(accountParentIdSet.size() > 0){
            for(Account accObj : [SELECT Id, DynamicsAccID__c FROM Account WHERE Id IN : accountParentIdSet]){
                parentIdGUIDMap.put(accObj.Id, accObj.DynamicsAccID__c);
            }
        }

        for(Account newAccObj : accountsList) {
            Account oldAccObj = idToOldAccountMap.get(newAccObj.Id);
            if(newAccObj != oldAccObj && !RequestStorefrontRepublishController.requestFulfillRunning && XOGroupSettingUtility.getPartnerCalloutSetting()){
                if(newAccObj.Ignore_Parent_Account__c && !oldAccObj.Ignore_Parent_Account__c && newAccObj.Fulfill_Storefront__c){
                    RESTLocalStorefrontAPI.ObjectWrapper objWrapper = new RESTLocalStorefrontAPI.ObjectWrapper();
                    objWrapper.locationId = newAccObj.DynamicsAccID__c;
                    objWrapper.companyId = newAccObj.DynamicsAccID__c;
                    orderFulfillmentList.add(objWrapper);
                //}else if(newAccObj.Fulfill_Storefront__c && !oldAccObj.Fulfill_Storefront__c && !newAccObj.Fulfilled__c){
                }else if(newAccObj.Fulfill_Storefront__c && !oldAccObj.Fulfill_Storefront__c && newAccObj.Storefront_Status__c != 'Claimed'){
                    RESTLocalStorefrontAPI.ObjectWrapper objWrapper = new RESTLocalStorefrontAPI.ObjectWrapper();
                    objWrapper.locationId = newAccObj.DynamicsAccID__c;
                    if(String.isBlank(newAccObj.ParentId) || newAccObj.Ignore_Parent_Account__c == true){
                        objWrapper.companyId = newAccObj.DynamicsAccID__c;
                    }else if(String.isNotBlank(newAccObj.ParentId) && parentIdGUIDMap.containsKey(newAccObj.ParentId)){
                        objWrapper.companyId = parentIdGUIDMap.get(newAccObj.ParentId);
                    }else if(String.isNotBlank(newAccObj.ParentId) && !parentIdGUIDMap.containsKey(newAccObj.ParentId)){
                        newAccObj.ParentId.addError('Please generate a GUID for the parent Account');
                    }
                    orderFulfillmentList.add(objWrapper);
                } else if(newAccObj.Fulfilled__c && newAccObj.Storefront_Status__c == 'Claimed' && String.isBlank(newAccObj.ParentId)){
                    // CSP-1997 Modify Account Partner Update Fields to be Fieldset
                    List<String> fulfillmentFieldAcctChangeValidateList = new List<String>();
                    Map<String, Schema.FieldSet> accountFieldSets = Schema.SObjectType.Account.fieldSets.getMap();
                    if (accountFieldSets.containsKey('Fulfillment_Field_Validation')) {
                        List<Schema.FieldSetMember> fsmList = accountFieldSets.get('Fulfillment_Field_Validation').getfields();
                        for(Schema.FieldSetMember fs : fsmList ){
                            fulfillmentFieldAcctChangeValidateList.add(fs.getFieldPath());
                        }
                        for(String field : fulfillmentFieldAcctChangeValidateList){
                            if(newAccObj.get(field) != oldAccObj.get(field)){
                                if(String.isNotBlank(newAccObj.DynamicsAccID__c)){
                                    RESTLocalStorefrontAPI.ObjectWrapper objWrapper = new RESTLocalStorefrontAPI.ObjectWrapper();
                                    objWrapper.locationId = newAccObj.DynamicsAccID__c;
                                    
                                    if(String.isBlank(newAccObj.ParentId) || newAccObj.Ignore_Parent_Account__c == true){
                                        objWrapper.companyId = newAccObj.DynamicsAccID__c;
                                    }else if(String.isNotBlank(newAccObj.ParentId) && parentIdGUIDMap.containsKey(newAccObj.ParentId)){
                                        objWrapper.companyId = parentIdGUIDMap.get(newAccObj.ParentId);
                                    }else if(String.isNotBlank(newAccObj.ParentId) && !parentIdGUIDMap.containsKey(newAccObj.ParentId)){
                                        newAccObj.ParentId.addError('Please generate a GUID for the parent Account');
                                    }
                                    accountUpdateList.add(objWrapper);
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }

        if(!accountUpdateList.isEmpty() && !system.isBatch() && !system.isFuture() && XOGroupSettingUtility.getPartnerCalloutSetting()){
            PartnerAccountUpdateCallout.accountUpdateCallout(JSON.serializePretty(accountUpdateList));
        }
    }

    /**
     * @description:  
    */
    private void updateBillingAccounts(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<String> accIdSet = new Set<String>();

        for(Account newAccObj : accountsList) {
            if(!newAccObj.Name.equals(idToOldAccountMap.get(newAccObj.id).Name)){
                accIdSet.add(newAccObj.id);
            }
        }

        if(accIdSet.size() > 0 && !System.isQueueable()){
            List<Zuora__CustomerAccount__c> billingAccountsTobeUpdateList = updateBillingAccountNames(accIdSet);
            
            if(billingAccountsTobeUpdateList != null && billingAccountsTobeUpdateList.size() > 0){
                Database.SaveResult[] updateResults = Database.update(billingAccountsTobeUpdateList, false);
                this.exceptionList = ExceptionUtility.consumeException(updateResults);
            }
        }
    }

    /**
     *@description: Update All Billing Account Name(s) when there is change in Account name
     *
     */
    private List<Zuora__CustomerAccount__c> updateBillingAccountNames(Set<String> accountIdSet){
        List<Zuora__CustomerAccount__c> billingAccountsTobeUpdateList = new List<Zuora__CustomerAccount__c>();
        for(Zuora__CustomerAccount__c customerAccount : [SELECT id, Name, Zuora__Account__c, Zuora__Account__r.Name 
                                                         FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN: accountIdSet]){
                                                            
            // CSP -1400 use equals() instead of "!=" in Account Name Comparison                                             
            if(!customerAccount.Name.equals(customerAccount.Zuora__Account__r.Name) && customerAccount.Zuora__Account__r.Name.length() <= 80){
                customerAccount.Name = customerAccount.Zuora__Account__r.Name;
                billingAccountsTobeUpdateList.add(customerAccount);
            }
        }  
        return billingAccountsTobeUpdateList;
    }

    /**
     *@description: Update billing account Name, SalesRepName and NeedToUpdateAccountDetails
     *
     */
    private void updateBillingAccountData(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> billingAccountsToUpdateSet = new Set<Id>();
        Set<Id> ownerIdsSet = new Set<Id>();

        for(Account newAccObj : accountsList) {
            if(newAccObj.OwnerId != idToOldAccountMap.get(newAccObj.Id).ownerId || !newAccObj.Name.equals(idToOldAccountMap.get(newAccObj.Id).Name)) {
                billingAccountsToUpdateSet.add(newAccObj.Id);
                ownerIdsSet.add(newAccObj.OwnerId);
            }
        }

        Map<Id, String> idToOwnerMap = new Map<Id, String>();
        for(User userRecord: [Select Id,Name from User where Id IN: ownerIdsSet]) {
            idToOwnerMap.put(userRecord.id, userRecord.Name);
        }

        List<Zuora__CustomerAccount__c> customerAccountsToBeUpdated = new List<Zuora__CustomerAccount__c>();
        // looping through the billing accounts and update the sales rep name based on the changes made to owners account
        for(Zuora__CustomerAccount__c customerAccountRecord : [SELECT id,name, Zuora__Account__r.ownerId, Zuora__Account__c,Zuora__Account__r.Name from Zuora__CustomerAccount__c where Zuora__Account__c in : billingAccountsToUpdateSet]) {
            customerAccountRecord.Name = customerAccountRecord.Zuora__Account__r.Name;
            customerAccountRecord.Zuora__SalesRepName__c = idToOwnerMap.get(customerAccountRecord.Zuora__Account__r.ownerId);
            customerAccountRecord.NeedToUpdateAccountDetails__c = true;
            customerAccountsToBeUpdated.add(customerAccountRecord);
        }

        if(customerAccountsToBeUpdated.size() > 0) {
            Database.SaveResult[] updateResults = Database.update(customerAccountsToBeUpdated, false);
            this.exceptionList = ExceptionUtility.consumeException(updateResults);
        }
    }

    private void createAccountVIPStatusTask(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        List<Task> taskInsertList = new List<Task>();
        for(Account newAccObj: accountsList) {
            if(idToOldAccountMap == null) {
                if (newAccObj.VIP_Program__c && newAccObj.Strategy_Specialist__c != null) {
                    taskInsertList.add(generateAccountVIPStatusTask(newAccObj, true));
                }
            } else if (newAccObj.VIP_Program__c != idToOldAccountMap.get(newAccObj.Id).VIP_Program__c && newAccObj.Strategy_Specialist__c != null) {
                taskInsertList.add(generateAccountVIPStatusTask(newAccObj, newAccObj.VIP_Program__c));
            }
        }

        if (taskInsertList.size() > 0) {
            Database.insert(taskInsertList, false);
        }
    }

    /**
     *   CSP-1885 | "generateAccountVIPStatusTask" generates a Task whenever a local Account's "VIP Program"
     *   formula checkbox changes and assigns it to the Account's "Strategy Specialist" lookup user
     *
     *   @author Jonathan Satterfield
     *   @date   2017-02-16
     *   @param  {Account}   accountObj
     *   @param  {Boolean}   isVIP
     *   @return {Task}
     */
    private static Task generateAccountVIPStatusTask(Account accountObj, Boolean isVIP) {
        Task vipStatusTask = new Task();
        vipStatusTask.ActivityDate = Date.Today();
        vipStatusTask.OwnerId = accountObj.Strategy_Specialist__c; // before calling this method check to make sure this lookup != null
        vipStatusTask.WhatId = accountObj.Id;
        vipStatusTask.Type = 'Other';
        vipStatusTask.Purpose__c = 'VIP Status Change';
        vipStatusTask.Status = 'Not Started';
        vipStatusTask.Subject = isVIP ? accountObj.Name + ' has been upgraded to a VIP status' : accountObj.Name + ' has been downgraded to a non-VIP status';
        vipStatusTask.Description = isVIP ? 'The following account has been upgraded to a VIP status:' : 'The following account has been downgraded to a non-VIP status:';
        vipStatusTask.Description += '\nAccount Name: ' + accountObj.Name + '\nTotal Spend: ' + accountObj.ActiveSubscriptionTCVSummary__c;
        return vipStatusTask;
    }

    private void scoringAccounts(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> scoreAccountsIdSet = new Set<Id>();
        
        for(Account accountObj : accountsList) {
            if(idToOldAccountMap == null) {
                scoreAccountsIdSet.add(accountObj.Id);
            } else {
                // CSP-2061 | compare field values to see if any have been updated; if so, the Account's score needs to be re-evaluated
                for (String scoringField : SCORING_FIELDS_SET) {
                    String oldFieldValue = (String)idToOldAccountMap.get(accountObj.Id).get(scoringField);
                    String newFieldValue = (String)accountObj.get(scoringField);
                    if (oldFieldValue != newFieldValue) {
                        scoreAccountsIdSet.add(accountObj.Id);
                        break;
                    }
                }
            }
        }

        // CSP-2061 | score Accounts asynchronously since it's a long-running operation
        if (!scoreAccountsIdSet.isEmpty() && !System.isBatch() && !System.isFuture()) {
            LeadAndAccountScoringUtilities.scoreAccountsFutureJob(scoreAccountsIdSet);
        }
    }

    private void updateAccountAddress(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<String> updatedAccountAddressIdSet = new Set<String>();
        for(Account newAccObj : accountsList) {
            Account oldAccObj = idToOldAccountMap.get(newAccObj.Id);
        
            if (newAccObj.BillingStreet != oldAccObj.BillingStreet || newAccObj.BillingCity != oldAccObj.BillingCity
                || newAccObj.BillingState != oldAccObj.BillingState || newAccObj.BillingPostalCode != oldAccObj.BillingPostalCode
                    || newAccObj.BillingCountry != oldAccObj.BillingCountry) {

                updatedAccountAddressIdSet.add(newAccObj.Id);
            }
        }
        if(updatedAccountAddressIdSet.size() > 0){
            List<Contact> contactUpdateList = updateContactAddress(updatedAccountAddressIdSet);
            if(contactUpdateList != null && contactUpdateList.size() > 0){
                Database.SaveResult[] updateResults = Database.update(contactUpdateList, false);
                this.exceptionList = ExceptionUtility.consumeException(updateResults);
            }
        }
    }

    /**
     *@description: update contact Mailing Address with related Account Billling address.
     */
    private List<Contact> updateContactAddress(Set<String> accountIdSet){
        List<Contact> contactUpdateList = new List<Contact>();
        if (accountIdSet.size() > 0){
            contactUpdateList = [SELECT Id, MailingStreet, MailingCity,  MailingState, MailingPostalCode, MailingCountry, AccountId,
                                        Account.BillingCity, Account.BillingStreet, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry 
                                 FROM Contact 
                                 WHERE AccountId IN:accountIdSet 
                                 AND Same_Address_as_Account__c = true];
        
            if(contactUpdateList != null && contactUpdateList.size() > 0){
                for (Contact conObj : contactUpdateList){
                    conObj.MailingStreet = conObj.Account.BillingStreet;
                    conObj.MailingCity = conObj.Account.BillingCity;
                    conObj.MailingState = conObj.Account.BillingState;
                    conObj.MailingPostalCode = conObj.Account.BillingPostalCode;
                    conObj.MailingCountry = conObj.Account.BillingCountry;
                }
            }           
        }
        return contactUpdateList;
    }

    private void cloneClientBillingCase(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        
        List<Case> newCaseList = new List<Case>();
        Set<Id> needUpdateCaseAccIdSet = new Set<Id>();
        List<Case> updateCaseList = new List<Case>();
        Set<Id> pdbAccountIdSet = new Set<Id>();
        List<Group> queueList = new List<Group>();
        Set<Id> regionNationalOwnerIdSet = new Set<Id>();
        Set<Id> nonePDBAccountIdSet = new Set<Id>(); // stored the Id of the accounts which should close the related client billing case
        Map<Id, Decimal> pdbUpdateMap = new Map<Id,Decimal>(); // stored the Id and pdb increase of the accounts which should updated the related client billing case
        // CSP-2736 ACH Returns did not create cases
        // new a total Id Set for the all accounts which need to new/update/close case, so we can query the all data with one SOQL
        Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap = Schema.SObjectType.Case.getRecordTypeInfosByName();        

        // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
        // Stored the Id and pdb increase of the accounts which should updated the related Cancels case
        Map<Id, Decimal> pdbIncreaseMap = new Map<Id,Decimal>();


        for(Account newAccObj : accountsList) {
            Account oldAccObj = idToOldAccountMap.get(newAccObj.Id);

            // creating two decimal value to convert all brand new past due balance to 0
            Decimal oldAccPDB = oldAccObj.Past_Due_Balance__c== null ? 0 : oldAccObj.Past_Due_Balance__c;
            Decimal newAccPDB = newAccObj.Past_Due_Balance__c== null ? 0 : newAccObj.Past_Due_Balance__c;
            
            // get the account id set which need to create a new client billing case
            // CSP-2782 Client Billing Case Open Logic
            // if the field Need_to_Create_CB_Case__c checked, created a client billing case for the account
            if (!oldAccObj.Need_to_Create_CB_Case__c && newAccObj.Need_to_Create_CB_Case__c ) {
                // CSP-2736 ACH Returns did not create cases
                // added the account id to the total Id set
                needUpdateCaseAccIdSet.add(newAccObj.Id);
                pdbAccountIdSet.add(newAccObj.Id);
            }
            // get the account id set which the exist client billing case need to close
            else if (newAccPDB == 0 && oldAccPDB > 0) {
                // CSP-CSP-2736 ACH Returns did not create cases
                // added the account id to the total Id set
                needUpdateCaseAccIdSet.add(newAccObj.Id);                 
                nonePDBAccountIdSet.add(newAccObj.Id);
            }
            // get the account id,Increased balance map, so the exist client billing case need to increased the past due potential.
            // CSP-2725 Past Due Potential Error?
            // added the filter, the past due potential increased only once the old account's past due balance is not 0, and past due balance increased.
            else if (newAccPDB > oldAccPDB && oldAccPDB != 0 ) {
                // CSP-2736 ACH Returns did not create cases
                // added the account id to the total Id set
                needUpdateCaseAccIdSet.add(newAccObj.Id);
                Decimal pdbIncreased = newAccObj.Past_Due_Balance__c - oldAccObj.Past_Due_Balance__c;
                pdbUpdateMap.put(newAccObj.Id,pdbIncreased);
            }

            // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
            // Stored the Id and pdb increase of the accounts which should updated the related Cancels case
            if (newAccPDB > oldAccPDB) {
                Decimal pdbIncreased = newAccPDB - oldAccPDB;
                pdbIncreaseMap.put(newAccObj.Id,pdbIncreased);
            }
        }

        if (!needUpdateCaseAccIdSet.isEmpty()) {

            // CSP-3011 Client Billing Cases exclusion for particular CBSS
            // query the public group and the queue, and added to the different list/set base on the developer name
            // this query only used for the client billing case created
            for (Group currentGroup : [SELECT Id,Type,DeveloperName,(select UserOrGroupId from GroupMembers) 
                                       FROM Group 
                                       WHERE DeveloperName = 'Client_Billing_Queue' 
                                       OR DeveloperName = 'Regional_National_Account_Owner'] ) {

                if (currentGroup.DeveloperName == 'Client_Billing_Queue') {
                    queueList.add(currentGroup);
                }
                else if (currentGroup.DeveloperName == 'Regional_National_Account_Owner' && !currentGroup.GroupMembers.isEmpty()) {
                    for (GroupMember currentGM : currentGroup.GroupMembers) {
                        regionNationalOwnerIdSet.add(currentGM.UserOrGroupId);
                    } 
                }
            }

            // CSP-2736 ACH Returns did not create cases
            // query all account which need to new/update/close case
            // CSP-2781 | Close In House Collections Cases when Past Due Balance Reaches $0
            // In House Collections cases automatically close when Account Past Due Balance goes from >$0 to =$0

            List<Account> accountList  = queryAccountsToUpdate(needUpdateCaseAccIdSet, caseRecTypeNameMap);

            for (Account currentAccount : accountList) {
                // created new case for the account whose id is in the set pdbAccountIdSet
                if (pdbAccountIdSet.contains(currentAccount.Id)) {
                    // if the account onwerId is in the group Regional National Account Owner, we should not create client billing case for the account
                    if (!regionNationalOwnerIdSet.contains(currentAccount.OwnerId) && shouldWeCreateClientBillingCase(currentAccount, caseRecTypeNameMap)) {
                        newCaseList.add(createClientBillingCase(currentAccount, queueList, caseRecTypeNameMap));
                    }
                }
                // closed the case for the account whose id is in the set nonePDBAccountIdSet        
                else if(nonePDBAccountIdSet.contains(currentAccount.Id)){
                    Case updateCase = closeCase(currentAccount, caseRecTypeNameMap);
                    if (updateCase != NULL) {
                        updateCaseList.add(updateCase);
                    }
                }
                // updated the Past_Due_Potential__c of the case for the account whose id is in the set nonePDBAccountIdSet
                else if(pdbUpdateMap.containsKey(currentAccount.Id)){
                    Case updateCase = updatePastDuePotential(currentAccount, pdbUpdateMap);
                    if (updateCase != NULL) {
                        updateCaseList.add(updateCase);
                    }
                }
            }
        }

        // CSP-2704 Calculating Potential for In House Collections and Past Due Retention Cases
        // if the PDB of the account is increased, we should update the all opened cancel case
        if (!pdbIncreaseMap.isEmpty()) {
            Case updateCase = populatePastDuePotentialCollection(pdbIncreaseMap, caseRecTypeNameMap);
            if (updateCase != NULL) {
                updateCaseList.add(updateCase);
            }
        }
        if (!newCaseList.isEmpty()) {
            Database.SaveResult[] insertResults = Database.insert(newCaseList, false);
            this.exceptionList = ExceptionUtility.consumeException(insertResults);
        }
        if (!updateCaseList.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(updateCaseList, false);
            this.exceptionList = ExceptionUtility.consumeException(saveResults);
        }
    }

    /**
     *@description: if there is one opened client billling case under the account, we should not create a new client billing case for the account
     */                                         
    private Boolean shouldWeCreateClientBillingCase(Account currentAccount, Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap) {
        //Boolean createCBCase = TRUE;
        if (!currentAccount.Cases.isEmpty()) {
            for (Case caseRecord : currentAccount.Cases) {
                if (caseRecord.RecordTypeId == caseRecTypeNameMap.get('Client Billing').getRecordTypeId()) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     *@description: updating past due potential
     */  
    private Case updatePastDuePotential(Account currentAccount, Map<Id, Decimal> pdbUpdateMap) {
        if (!currentAccount.Cases.isEmpty()) {
            for (Case currentCase : currentAccount.Cases) {
                Decimal pastDueVal = currentCase.Past_Due_Potential__c == NULL ? 0: currentCase.Past_Due_Potential__c;
                currentCase.Past_Due_Potential__c = pastDueVal + pdbUpdateMap.get(currentAccount.Id);
                return currentCase;
            }
        }
        return null;
    }

    /**
     *@description: closing the case 
     */  
    private Case closeCase(Account currentAccount, Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap) {
        if (!currentAccount.Cases.isEmpty()) {
            for (Case currentCase : currentAccount.Cases) {
                // CSP-2781 | Close In House Collections Cases when Past Due Balance Reaches $0
                // In House Collections cases automatically close when Account Past Due Balance goes from >$0 to =$0
                currentCase.Status = 'Closed';                                
                if(currentCase.RecordTypeId == caseRecTypeNameMap.get('Client Billing').getRecordTypeId()){
                    currentCase.Outcome__c = 'Paid';
                }                                
                return currentCase;
            }
        }
        return null;
    }

    private Case populatePastDuePotentialCollection(Map<Id, Decimal> pdbIncreaseMap, Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap) {
        String timeStamp = System.Label.Time_Stamp_For_Cancel_Case;

        List<Case> caseList = queryCasesWithPDBIncrease(pdbIncreaseMap, caseRecTypeNameMap.get('1 - Cancels').getRecordTypeId());

        for (Case currentCase : caseList) {
            // prevent the work flow refire the logic.
            if (currentCase.PDPC_Date_Time_Stamp__c != null && currentCase.PDPC_Date_Time_Stamp__c > system.now().addMinutes(Integer.valueOf(timeStamp))) {
                continue;
            }
            Decimal pastDueVal = currentCase.Past_Due_Potential_Collections__c == NULL ? 0: currentCase.Past_Due_Potential_Collections__c;
            currentCase.Past_Due_Potential_Collections__c = pastDueVal + pdbIncreaseMap.get(currentCase.AccountId);
            currentCase.PDPC_Date_Time_Stamp__c = system.now();
            return currentCase;
        }
        return null;
    }

    /**
     *@description: Query cases with cancel record type and past due balance 
     */  
    private List<Case> queryCasesWithPDBIncrease(Map<Id, Decimal> pdbIncreaseMap, Id cancelsRecordTypeId) {
        return [SELECT id,Past_Due_Potential_Collections__c,AccountId,PDPC_Date_Time_Stamp__c 
                FROM Case 
                WHERE AccountId 
                IN : pdbIncreaseMap.keySet() 
                AND IsClosed = FALSE 
                AND RecordTypeID =:cancelsRecordTypeId];
    }

    /**
     *@description: Creates a client billing case  
     */  
    private Case createClientBillingCase(Account currentAccount, List<Group> queueList, Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap) {
        Case caseRecord = new Case();
        caseRecord.AccountId = currentAccount.Id;
        
        // if the account have primary contact, assigned the newest contact role's contact to case contact
        if (currentAccount.AccountContactRoles.size()>0) {
            caseRecord.ContactId = currentAccount.AccountContactRoles[0].ContactId;
        }
        // CSP-2736
        // need to check if the CBSS is null, yes assign to client billing queue
        if(currentAccount.CBBS__c != null){
          caseRecord.OwnerId = currentAccount.CBBS__c;
        }
        else{
          caseRecord.OwnerId = queueList[0].id;
        }

        caseRecord.RecordTypeId = caseRecTypeNameMap.get('Client Billing').getRecordTypeId();
        caseRecord.Origin = 'Auto Generated';
        caseRecord.Reason = 'Client Billing';
        caseRecord.Subject = 'Client Billing';
        caseRecord.Past_Due_Potential__c = currentAccount.Past_Due_Balance__c;
        caseRecord.Past_Due_on_Case_Open__c = currentAccount.Past_Due_Balance__c;
        return caseRecord;
    }

    private List<Account> queryAccountsToUpdate(Set<Id> needUpdateCaseAccIdSet, Map<String, Schema.RecordTypeInfo> caseRecTypeNameMap) {
        return [SELECT Id,CBBS__c, CBBS__r.Email, OwnerId, CBBS__r.Name, Past_Due_Balance__c, 
                    (SELECT ContactId, AccountId 
                     FROM AccountContactRoles 
                     WHERE Role in ('Primary','Billing') 
                     AND Contact.Status__c = 'Active' 
                     ORDER BY Role ASC, CreatedDate DESC limit 1), 
                    (SELECT Id, Status, Outcome__c, Past_Due_Potential__c, AccountId, RecordTypeId  
                     FROM Cases 
                     WHERE IsClosed = FALSE 
                     AND (RecordTypeID = :caseRecTypeNameMap.get('Client Billing').getRecordTypeId()
                     OR RecordTypeID = :caseRecTypeNameMap.get('In House Collections').getRecordTypeId()))
                FROM Account 
                WHERE Id 
                IN: needUpdateCaseAccIdSet AND RecordType.Name = 'Local'];
    }
    
    /**
     *@description: Updating Active Hirarchy Date and Need to recalculate active hierarchy fields   
     */  
    private void updateAccountHierarchy(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> oldParentIdSet = new Set<Id>();

        // after update
        for(Account newAccObj : accountsList) {
            if(accountsList != null) { // after update
               if (newAccObj.ParentId != idToOldAccountMap.get(newAccObj.Id).ParentId && String.isNotBlank(idToOldAccountMap.get(newAccObj.Id).ParentId)) {
                    oldParentIdSet.add(idToOldAccountMap.get(newAccObj.Id).ParentId);
                } 
            } else { // after delete 
                if (String.isNotBlank(idToOldAccountMap.get(newAccObj.Id).ParentId)) {
                    oldParentIdSet.add(idToOldAccountMap.get(newAccObj.Id).ParentId);
                }
            }
        }
    
        // CSP-2906 Paid Status Across the Parent-Child Hierarchy
        // if oldParentIdSet is not empty, we should set the all parent account's flag to 'Yes' 
        if (!oldParentIdSet.isEmpty()) {
            List<Account> parentAccList = new List<Account>();
            
            for (Id accId : oldParentIdSet) {
                parentAccList.add(updateParentAccountInfo(accId));
            }

            if (!parentAccList.isEmpty()) {
                Database.SaveResult[] saveResults = Database.update(parentAccList, false);
                this.exceptionList = ExceptionUtility.consumeException(saveResults);
            }
        }
    }

    private Account updateParentAccountInfo(Id accId) {
        Account parentAcc = new Account();
        parentAcc.Id = accId;
        parentAcc.Active_Hierarchy_Date__c = Date.today();
        parentAcc.Need_to_Recalculate_Active_Hierarchy__c = 'Yes';
        return parentAcc;
    }

    /**
     *@description: Validating shipping postasl code  
     */  
    private void validateShippingPostalCode(List<Account> accountsList) {
        for(Account record : accountsList) {
            if(String.isNotBlank(record.ShippingCountryCode) && String.isNotBlank(record.ShippingPostalCode)){
                //CSP-2954: Allow Leads with incomplete (3-digit) Canadian postal codes
                //Account must have complete zip for Canada  
                if(!XOCustomValidationUtility.hasCompleteCanadianZip(record.ShippingCountryCode, record.ShippingPostalCode) ){
                    record.ShippingPostalCode.addError('6-digit postal code is required for the selected Country');
                }
                
                if(!XOCustomValidationUtility.validZip(record.ShippingCountryCode, record.ShippingPostalCode)){
                    record.ShippingPostalCode.addError('Not a valid zip code for the selected Country');
                }
            }
        }
    }

    /**
     *@description: Validating billing postal code  
     */  
    private void validateBillingPostalCode(List<Account> accountsList) {
        for(Account record : accountsList) {
            if(String.isNotBlank(record.BillingCountryCode) && String.isNotBlank(record.BillingPostalCode)){
                //CSP-2954: Allow Leads with incomplete (3-digit) Canadian postal codes
                //Account must have complete zip for Canada 
                if(!XOCustomValidationUtility.hasCompleteCanadianZip(record.BillingCountryCode, record.BillingPostalCode) ){
                    record.BillingPostalCode.addError('6-digit postal code is required for the selected Country');
                }
                
                if(!XOCustomValidationUtility.validZip(record.BillingCountryCode, record.BillingPostalCode)){
                    record.BillingPostalCode.addError('Not a valid zip code for the selected Country');
                }
            }
        }  
    }

    /**
     *@description: Update Fultil storefront value 
     */  
    private void updateFulfillStorefront(List<Account> accountsList) {
        Set<String> dynamicsIdSet = new Set<String>();
        Map<String, Lead> leadMap = new Map<String, Lead>();

        for(Account accObj : accountsList) {
            if(String.isNotBlank(accObj.DynamicsAccID__c)) {
                dynamicsIdSet.add(accObj.DynamicsAccID__c);
            }
        }

        if(dynamicsIdSet.size() > 0){
            for(Lead leadObj : [SELECT Id, Fulfill_Storefront__c, Storefront_Status__c, DynamicsLeadID__c 
                                FROM Lead 
                                WHERE DynamicsLeadID__c IN: dynamicsIdSet AND Storefront_Status__c =: 'Claimed']){
                leadMap.put(leadObj.DynamicsLeadID__c,leadObj);
            }
        }

        for(Account accObj : accountsList) {
            if(String.isNotBlank(accObj.DynamicsAccID__c) && leadMap.containsKey(accObj.DynamicsAccID__c)){
                accObj.Fulfill_Storefront__c = true;
            }
        }        
    }

    /**
     *@description: Validate Fulfill Storefront   
     */ 
    private void fulfillStorefrontValidation(List<Account> accountsList) {
        for(Account accObj : accountsList) {
            if(LeadConvertDomain.leadConvert != null) {
                if(!accObj.Fulfilled__c && accObj.Fulfill_Storefront__c && !LeadConvertDomain.leadConvert && String.isBlank(accObj.DynamicsAccID__c)){
                    accObj.Fulfill_Storefront__c.addError('Please add a Contact and a Primary Contact Role before you can Fulfill Storefront!');
                }
            }
        }
    }

    /**
     *@description: Validate Phone 
     */ 
    public void phoneValidation(List<Account> accountsList, Map<Id, Account> idToOldAccountMap){
        for(Account accountRec: accountsList) {
            if(String.isNotBlank(accountRec.Phone)) {
                if(idToOldAccountMap != null) {
                    if(!accountRec.Phone.equalsIgnoreCase(idToOldAccountMap.get(accountRec.Id).Phone)) {
                        verifyPhone(accountRec);
                    }
                }

                if(idToOldAccountMap == null) {
                    verifyPhone(accountRec);
                }
            }
        }
    }

    public void verifyPhone(Account accountRec) {
        DataUtility.ValidationResult phoneValidation = DataUtility.formatPhoneNumber(accountRec.Phone);
            
        // If the Phone is valid then put the formatted value into the Phone field
        if(phoneValidation.valid) {
            accountRec.Phone = phoneValidation.formattedValue;
        } 
        else {
            accountRec.Phone.addError(System.Label.Phone_Validation_Error);
        }
    }

    /**
     *@description: Validate Phone Extension
     */ 
    public void phoneExtensionValidation(List<Account> accountsList, Map<Id, Account> idToOldAccountMap){
      
        for(Account accObj: accountsList) {
            
            if(String.isNotBlank(accObj.Phone_Extension__c)) {
                if(idToOldAccountMap != null) {
                    if(!accObj.Phone_Extension__c.equalsIgnoreCase(idToOldAccountMap.get(accObj.Id).Phone_Extension__c)) {
                        verifyPhoneExtension(accObj);
                    }
                }

                if(idToOldAccountMap == null) {
                    verifyPhoneExtension(accObj);
                }
            }
        }
    }

    public void verifyPhoneExtension(Account accObj) {
        DataUtility.ValidationResult extValidation = DataUtility.formatExt(accObj.Phone_Extension__c);
        // If the extension is valid then put the formatted value into the Phone field
        if(extValidation.valid) {
            accObj.Phone_Extension__c = extValidation.formattedValue;
        } 
        else {
            accObj.Phone_Extension__c.addError(System.Label.Ext_Validation_Error);
        }
    }

    /**
     *@description: Validate Website 
     */ 
    public void websiteValidation(List<Account> accountsList, Map<Id, Account> idToOldAccountMap){
        for(Account accObj: accountsList) {
            
            if(String.isNotBlank(accObj.Website)) {
                if(idToOldAccountMap != null) {
                    if(!accObj.Website.equalsIgnoreCase(idToOldAccountMap.get(accObj.Id).Website)) {
                        verifyWebsite(accObj);
                    }
                }

                if(idToOldAccountMap == null) {
                    verifyWebsite(accObj);
                }
            }

        }
    }

    public void verifyWebsite(Account accObj) {
        DataUtility.ValidationResult websiteValidation = DataUtility.validateWebsite(accObj.Website);
        // If the Website is valid put the formatted value into the Website field
        if(websiteValidation.valid) {
            accObj.Website = websiteValidation.formattedValue;
        } else {
            accObj.Website.addError(System.Label.Website_Validation_Error);
        }
    }

    /**
     *@description: Assing country based on zip code
     */ 
    public void assignCountry(List<Account> accountsList) {
        List<CountryZipREGEX__c> countryRegExList = [SELECT Id, Name, Active__c, CountryCode__c, RegExPattern__c FROM CountryZipREGEX__c WHERE Active__c = true];
        for(Account accObj : accountsList) {
            if(!countryRegExList.isEmpty() && ((String.isBlank(accObj.ShippingCountryCode) && String.isNotBlank(accObj.ShippingPostalCode)) 
                    || (String.isBlank(accObj.BillingCountryCode) && String.isNotBlank(accObj.BillingPostalCode)))){
                        
                if(String.isBlank(accObj.ShippingCountryCode) && String.isNotBlank(accObj.ShippingPostalCode)){
                    accObj = (Account)XOCustomValidationUtility.assignCountryBasedOnZip(accObj, 'ShippingCountryCode', accObj.ShippingPostalCode);            
                }

                if(String.isBlank(accObj.BillingCountryCode) && String.isNotBlank(accObj.BillingPostalCode)){
                    accObj = (Account)XOCustomValidationUtility.assignCountryBasedOnZip(accObj, 'BillingCountryCode', accObj.BillingPostalCode);            
                }
            }
        }
    }

    /**
     *@description: Update contacts owner id  
     */ 
    // CSP-2040 | used to update child Contact Owners when an Account Owner is updated
    private void updateAccountContactOwner(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Map<Id, Id> accountIdToOwnerIdMap = new Map<Id, Id>();

        for(Account newAccObj : accountsList) {
            if (newAccObj.OwnerId != idToOldAccountMap.get(newAccObj.Id).OwnerId) {
                accountIdToOwnerIdMap.put(newAccObj.Id, newAccObj.OwnerId);
            }
        }

        // CSP-2040 | update child Contact Owners when an Account Owner is updated
        // NOTE: queueable execution context causes both System.isBatch() and System.isQueueable() to return true,
        // but future jobs can be called from a queueable, hence the complicated IF statement below
        if (accountIdToOwnerIdMap.size() > 0 && !System.isFuture() && (!System.isBatch() || System.isQueueable())) {
            updateChildContactsOwner(accountIdToOwnerIdMap);
        }

    }

    /**
     *@description: Future method to update contacts owner Id  
     */ 
    @future
    private static void updateChildContactsOwner(Map<Id, Id> accountIdToOwnerIdMap) {
        List<Contact> childContactList = [SELECT Id, AccountId, Email, OwnerId FROM Contact WHERE AccountId IN :accountIdToOwnerIdMap.keySet()];
        // if no child Contacts found return immediately
        if (childContactList.isEmpty()) {
            return;
        }
        // if records found, set this static boolean flag to skip ContactTriggerHandler record owner assignment logic
        ContactTriggerHandler.accountTriggerUpdatingContactOwners = true;
        for (Integer i = 0; i < childContactList.size(); i++) {
            Contact childContact = childContactList[i];
            // due to the query's WHERE clause there's no need to check to see if the map contains the key
            childContact.OwnerId = accountIdToOwnerIdMap.get(childContact.AccountId);
        }
        List<Database.SaveResult> updateResultsList = Database.update(childContactList, false);
        List<XO_Exception__c> xoExceptionList = ExceptionUtility.consumeException(updateResultsList);
        if (!xoExceptionList.isEmpty()) {
            insert xoExceptionList;
        }
    }

    /**
     *@description: Updateing all active sales rep and RSD values 
     */ 
    private void updateSalesRepAndRSD(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        Set<Id> setAMAccId = new Set<Id>();
        User userObj = [SELECT id, profile.Name, Name FROM User WHERE id = : UserInfo.getUserId()];

        for(Account acc : accountsList) {
            if (acc.OwnerId != idToOldAccountMap.get(acc.Id).OwnerId) {
                if (acc.Owner_Title__c == Label.Account_Manager) {
                    setAMAccId.add(acc.Id);
                }
            }
        }

        // if the account assign to AM, we should update the all active subs Sales Rep and RSD
        if (!setAMAccId.isEmpty()) {

            List<Zuora__Subscription__c> listZuoraSubs = getZuoraSubs(setAMAccId);

            // send email to System Admin if there are too many subs.
            Integer zuoraSubsNum = Integer.valueOf(Label.Zuora_Subscription_Numbers);
            if (listZuoraSubs.size() > zuoraSubsNum) {
                this.exceptionList.addAll(EmailUtility.sendSalesRepRSDEmail(setAMAccId, userObj.Name));
            }
            else{
                Database.SaveResult[] updateResults = Database.update(listZuoraSubs, false);
                this.exceptionList.addAll(ExceptionUtility.consumeException(updateResults));
            }
        }
    }

    /**
     *@description: getting zuora subscriptions with term end date greater than today and accounts 
     *              with Account Manager as the title 
     */ 
    private List<Zuora__Subscription__c> getZuoraSubs(Set<Id> setAMAccId) {
        List<Zuora__Subscription__c> listZuoraSubs = new List<Zuora__Subscription__c>();

        for(Account currentAcc : [SELECT id, OwnerId, Owner.SalesRepID__c, Owner.ManagerId, 
                                        (SELECT Id, Sales_Rep__c, RSD__c 
                                        FROM Zuora__Subscriptions__r 
                                        WHERE Zuora__TermEndDate__c>: Date.today()) 
                                  FROM Account 
                                  WHERE id 
                                  IN: setAMAccId]){

            if (!currentAcc.Zuora__Subscriptions__r.isEmpty()) {
                for (Zuora__Subscription__c zuoraSub: currentAcc.Zuora__Subscriptions__r) {
                    if (zuoraSub.Sales_Rep__c != currentAcc.OwnerId || zuoraSub.RSD__c != currentAcc.Owner.ManagerId) {
                        zuoraSub.Sales_Rep__c = currentAcc.OwnerId;
                        zuoraSub.RSD__c = currentAcc.Owner.ManagerId;

                        listZuoraSubs.add(zuoraSub);
                    }
                }
            }
        }
        return listZuoraSubs;
    }

    /**
     *@description: csp-2912 - Assigning owner to Sales Rep. If Sales Rep is not present, assign the owner to Data Enrichment
     */ 
    private void accOwnerAssignment(List<Account> accountsList, Map<Id, Account> idToOldAccountMap) {
        User userObj = [SELECT id, profile.Name FROM User WHERE id = : UserInfo.getUserId()];
        User distributableUser = [SELECT Id,Name,Alias FROM User WHERE Alias = 'distacts' AND IsActive = true Limit 1];

        for(Account acc : accountsList) {
            if(acc.Account_Status__c == 'Qualified' && idToOldAccountMap.get(acc.Id).Account_Status__c != 'Qualified' && userObj.profile.Name == Label.Local_Sales_Data_Team){

                Local_Sales_Rep_Assignment__c localSalesRepAssignmentRecord = AssignmentRulesUtility.getRecordAssignment(acc);

                if(localSalesRepAssignmentRecord != null) {
                    if (localSalesRepAssignmentRecord.Sales_Rep__c != null ){
                        acc.OwnerId = localSalesRepAssignmentRecord.Sales_Rep__c;
                    }
                    else{
                        acc.OwnerId = distributableUser.Id;
                    }
                }
                else {
                    // If not find local user to do 
                    acc.OwnerId = Label.DataEnrichmentUserId; 
                    acc.Account_Status__c = 'Dormant';
                    acc.Negative_Disposition_Reason__c = 'Missing Required Information';
                }
            }
        }
    }

    private void commitXOExceptions() {
        if(!this.exceptionList.isEmpty()) {
            insert this.exceptionList;
        }
    }
}