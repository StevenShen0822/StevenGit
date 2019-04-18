public without sharing class ZuoraSubscriptionPCTriggerHandler implements iTrigger{


    private Map<String, Zuora__SubscriptionProductCharge__c> cancelledSubInventoryReleaseMap = new Map<String, Zuora__SubscriptionProductCharge__c>();

    //Store the cancel quote ID to query quote charge detail record for inventory release
    private static Set<String> setCancelQuoteIDsToReleaseInventory = new Set<String>();

    // CSP-2443 the original quote Id set for the cancelled subscription 
    private Map<String,Map<String,Id>> cancelledRenewSubInventoryBackMap = new Map<String,Map<String,Id>>();

    private Map<Id,Boolean> hasLess12ItemSubMap = new Map<Id,Boolean>();
    
    // we should created a new map for creating Asset Collection Case
    private Map<String, Zuora__SubscriptionProductCharge__c> amendedSubACCaseMap = new Map<String, Zuora__SubscriptionProductCharge__c>(); 
    private Map<String, List<Zuora__SubscriptionProductCharge__c>> newSubACCaseMap = new Map<String, List<Zuora__SubscriptionProductCharge__c>>();

    private static Map<Id, Zuora__SubscriptionProductCharge__c> mapIdToSpc = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    
    Map<String, Map<String,Zuora__SubscriptionProductCharge__c>> mapSubNameToMapChargeNumberToSubCharge = new Map<String, Map<String,Zuora__SubscriptionProductCharge__c>>();
    Map<String,Date> mapSubscriptionNameToEffectDate = new Map<String,Date>();

    private static final String SUBSCRIPTION_PRODUCT_CHARGE_QUERY = 'SELECT '
                                                            + 'Id, '
                                                            + 'Name, '
                                                            + 'Zuora__SubscriptionChargeNumber__c, '
                                                            + 'Do_not_create_inventory__c, '
                                                            + 'Zuora__ProductSKU__c, '
                                                            + 'Zuora__ChargeNumber__c, '
                                                            + 'Zuora__Account__c, '
                                                            + 'Zuora__RatePlanName__c, '
                                                            + 'Is_Possible_Renewal__c, '
                                                            + 'LocationVendorDynamicsAccountID__c, '
                                                            + 'Zuora__EffectiveStartDate__c, '
                                                            + 'Zuora__EffectiveEndDate__c, '
                                                            + 'LDE_Email_Launch_Date__c, '
                                                            + 'Category_Taxonomy_ID__c, '
                                                            + 'Market_ID__c, '
                                                            + 'Product_Type__c, '
                                                            + 'Discount_Percentage__c, '
                                                            + 'Discount_Reason__c, '
                                                            + 'List_Price__c, '
                                                            + 'RSD_Id__c, '
                                                            + 'SalesRepID__c, '
                                                            + 'Zuora__Price__c, '
                                                            + 'Zuora__TotalContractValue__c, '
                                                            + 'X1st_cover_ship_date__c, '
                                                            + 'Zuora__ProductName_Product__c, '
                                                            + 'Product_Name_Text__c, '
                                                            + 'Print_Issue__c, '
                                                            + 'Zuora__MonthlyRecurringRevenue__c, '
                                                            + 'Zuora__Subscription__r.OriginalSalesforceQuoteID__c, '
                                                            + 'Zuora__Subscription__r.CreatingSalesforceQuoteID__c, '
                                                            + 'Zuora__Subscription__r.Zuora__Version__c, '
                                                            + 'Zuora__Subscription__r.True_Subscription_Status__c, '
                                                            + 'Zuora__Subscription__r.Name, '
                                                            + 'Zuora__Subscription__r.AutoRenewal__c, '
                                                            + 'Zuora__Subscription__r.Is_Valid_Subscription__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__c, '
                                                            + 'Zuora__Subscription__r.Opportunity_Id__c, '
                                                            + 'Zuora__Subscription__r.Original_Quote__c, '
                                                            + 'Zuora__Subscription__r.Payment_Method__c, '
                                                            + 'Zuora__Subscription__r.Preferred_Payment_Schedule__c, '
                                                            + 'Zuora__Subscription__r.Product_Line__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote_Number__c, '
                                                            + 'Zuora__Subscription__r.RSD_Id__c, '
                                                            + 'Zuora__Subscription__r.Sales_Rep__c, '
                                                            + 'Zuora__Subscription__r.SalesRepId__c, '
                                                            + 'Zuora__Subscription__r.Zuora__CancelledDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__TermStartDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__TermEndDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__Account__c, '
                                                            + 'Zuora__Subscription__r.Zuora__ContractEffectiveDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__CustomerAccount__c, '
                                                            + 'Zuora__Subscription__r.Zuora__InitialTerm__c, '
                                                            + 'Zuora__Subscription__r.Zuora__InitialTermPeriodType__c, '
                                                            + 'Zuora__Subscription__r.Zuora__Status__c, '
                                                            + 'Zuora__Subscription__r.Zuora__SubscriptionEndDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__SubscriptionStartDate__c, '
                                                            + 'Zuora__Subscription__r.Zuora__TermSettingType__c, '
                                                            + 'Zuora__Subscription__r.Zuora__External_Id__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__r.zqu__ZuoraSubscriptionID__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__r.zqu__TermStartDate__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__c, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__r.AccountId, '
                                                            + 'Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__r.Onboarding_Required__c, '
                                                            + 'Zuora__ProductSKU_Product__c, '
                                                            + 'Zuora__Account__r.OwnerId, '
                                                            + 'Zuora__Account__r.Strategy_Specialist__c, '
                                                            + 'Zuora__Account__r.Name, '
                                                            + 'Zuora__Account__r.Owner.Strategy_Specialist__c, '
                                                            + 'Zuora__Account__r.Strategy_Specialist__r.Name, '
                                                            + '(SELECT '
                                                                    + 'Id, '
                                                                    + 'Subscription_Product_Charge__r.Zuora__ChargeNumber__c, '
                                                                    + 'Product_Rate_Plan__c, '
                                                                    + 'Subscription_Product_Charge__c, '
                                                                    + 'Subscription_RatePlan_Id__c, '
                                                                    + 'Inventory_Hold_Expiry_Date__c '
                                                                +'FROM ' 
                                                                    +'Inventory__r) '
                                                        + 'FROM '
                                                            + 'Zuora__SubscriptionProductCharge__c '
                                                        + 'WHERE '
                                                            + '{WHERECLAUSE}';

    public ZuoraSubscriptionPCTriggerHandler() {

    }

    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    
    public void bulkBefore(){

    }

    public void bulkAfter(){
        if (Trigger.isInsert) {
            Set<Id> setSubscriptionProductChargeId = new Set<Id>();
            setSubscriptionProductChargeId.addAll(Trigger.newMap.keySet());
            String queryString = SUBSCRIPTION_PRODUCT_CHARGE_QUERY.replace('{WHERECLAUSE}', 'Id IN: setSubscriptionProductChargeId');

            for (Zuora__SubscriptionProductCharge__c newRec : database.query(queryString)) {

                if (mapSubNameToMapChargeNumberToSubCharge.containsKey(newRec.Zuora__Subscription__r.Name)) {
                    mapSubNameToMapChargeNumberToSubCharge.get(newRec.Zuora__Subscription__r.Name).put(newRec.Zuora__ChargeNumber__c,newRec);
                }else{
                    mapSubNameToMapChargeNumberToSubCharge.put(newRec.Zuora__Subscription__r.Name, new Map<String,Zuora__SubscriptionProductCharge__c>());
                    mapSubNameToMapChargeNumberToSubCharge.get(newRec.Zuora__Subscription__r.Name).put(newRec.Zuora__ChargeNumber__c,newRec);
                }

                if (newRec.Zuora__Subscription__r.Zuora__External_Id__c == newRec.Zuora__Subscription__r.Latest_Quote__r.zqu__ZuoraSubscriptionID__c) {
                    mapSubscriptionNameToEffectDate.put(newRec.Zuora__Subscription__r.Name, newRec.Zuora__Subscription__r.Latest_Quote__r.zqu__TermStartDate__c);
                }

                // CSP-1543 | add cancelled SubscriptionProductCharge records to later determine if Inventory should be released due to cancel/replace "renewal"
                if (newRec.Zuora__Subscription__r.True_Subscription_Status__c == 'Cancelled' && newRec.Inventory__r.size() > 0) {
                    cancelledSubInventoryReleaseMap.put(newRec.Zuora__ChargeNumber__c, newRec);

                    //Collect CreatingSalesforceQuoteID__c as the cancel quote Id on to cancelled SubscriptionProductCharge record
                    if(String.isNotBlank(newRec.Zuora__Subscription__r.CreatingSalesforceQuoteID__c)){
                        setCancelQuoteIDsToReleaseInventory.add(newRec.Zuora__Subscription__r.CreatingSalesforceQuoteID__c);
                    }

                    // CSP-2443 rollback for the original subscription when cancelled a renewal subscription.
                    if (cancelledRenewSubInventoryBackMap.containsKey(newRec.Zuora__Subscription__r.OriginalSalesforceQuoteID__c)) {
                        Map<String,Id> prlLocationInvetoryMap = cancelledRenewSubInventoryBackMap.get(newRec.Zuora__Subscription__r.OriginalSalesforceQuoteID__c);
                        String keyString = newRec.LocationVendorDynamicsAccountID__c + newRec.Zuora__RatePlanName__c;
                        prlLocationInvetoryMap.put(keyString, newRec.Inventory__r[0].Product_Rate_Plan__c);
                        cancelledRenewSubInventoryBackMap.put(newRec.Zuora__Subscription__r.OriginalSalesforceQuoteID__c,prlLocationInvetoryMap);
                    }
                    else{
                        Map<String,Id> prlLocationInvetoryMap = new Map<String,Id>();
                        String keyString = newRec.LocationVendorDynamicsAccountID__c + newRec.Zuora__RatePlanName__c;
                        prlLocationInvetoryMap.put(keyString, newRec.Inventory__r[0].Product_Rate_Plan__c);
                        cancelledRenewSubInventoryBackMap.put(newRec.Zuora__Subscription__r.OriginalSalesforceQuoteID__c,prlLocationInvetoryMap);
                    }
                }
                if (newRec.Zuora__Subscription__r.True_Subscription_Status__c == 'Active') {
                    // CSP-2749 | (Asset Collections Cases) exclude SubscriptionProductCharge records for LDE 20% charges (adding logic here instead of in the query to prevent a loss of query selectivity)
                    if (newRec.Name.containsIgnoreCase('20% Down')) {
                        continue;
                    }
                    // CSP-2749 Asset Collections Cases we should created a new map for creating Asset Collection Case
                    if (newRec.Zuora__Subscription__r.Zuora__Version__c > 1) {
                        amendedSubACCaseMap.put(newRec.Zuora__SubscriptionChargeNumber__c, newRec);
                    }
                    // CSP-2749 Asset Collections Cases we should created a new map for creating Asset Collection Case
                    else {
                        List<Zuora__SubscriptionProductCharge__c> spcList = newSubACCaseMap.containsKey(newRec.Zuora__ProductSKU__c) ? newSubACCaseMap.get(newRec.Zuora__ProductSKU__c) : new List<Zuora__SubscriptionProductCharge__c>();
                        spcList.add(newRec);
                        newSubACCaseMap.put(newRec.Zuora__ProductSKU__c, spcList);
                    }
                }
                
                // CSP-2749 Asset Collections Cases 
                // if the sub has been cancelled, we also should added to the new map amendedSubACCaseMap
                else if (newRec.Zuora__Subscription__r.True_Subscription_Status__c == 'Cancelled' 
                    && !newRec.Name.containsIgnoreCase('20% Down') 
                    && newRec.Zuora__Subscription__r.Zuora__Version__c > 1) {

                        amendedSubACCaseMap.put(newRec.Zuora__SubscriptionChargeNumber__c, newRec);
                }
            }
        }
    }   
    
    public void beforeInsert(SObject so){
        // CSP-1838; calculate the term of subscription product charge, if the term less than 12, check the flag TermLessThan12__c
        Zuora__SubscriptionProductCharge__c record = (Zuora__SubscriptionProductCharge__c)so;
        if(record.Zuora__EffectiveStartDate__c != NULL && record.Zuora__EffectiveEndDate__c != NULL && record.Zuora__EffectiveStartDate__c.monthsBetween(record.Zuora__EffectiveEndDate__c) < integer.valueOf(system.Label.SubscriptionPCTerms)){
            record.TermLessThan12__c = TRUE;
        }
        //CSP-2898 Enable Discounts for a Promotional Period (Switch Pitch)
        //Prevent inventory from double counting for Promotional 
        if(record.Discount_Reason__c == 'Wedding Wire Switch Pitch' && record.Zuora__TotalContractValue__c == 0) {
            record.Do_not_create_inventory__c = 'Yes';
        }

        // CSP-3143 A field on subscription to stamp the the print issue and 1st cover ship date
        // Assign Print_Issue__c lookup field based on Print_Issue_Id__c text value
        if(String.isNotBlank(record.Print_Issue_Id__c)){
            record.Print_Issue__c = record.Print_Issue_Id__c;
        }

    }
 
    public void beforeUpdate(SObject oldSo, SObject so){
    }
    
    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */  
    
    
    public void beforeDelete(SObject so){
    }
 
    public void afterInsert(SObject so){
        Zuora__SubscriptionProductCharge__c record = (Zuora__SubscriptionProductCharge__c)so;

        // CSP-1838 check the terms of subscription product charge, if the terms less than 12, check the subscription's flag includeLess12Item__c which is used for indicating the subscripiton has one or more Items whose Terms is less than 12
        if(record.TermLessThan12__c){
            hasLess12ItemSubMap.put(record.Zuora__Subscription__c,TRUE);
        }

        if(String.isNotBlank(record.Quote_Rate_Plan_Charge_Id__c) && !mapIdToSpc.containsKey(record.Quote_Rate_Plan_Charge_Id__c)){
            mapIdToSpc.put(record.Quote_Rate_Plan_Charge_Id__c, record);
        }
    }
    
    
    public void afterUpdate(SObject oldSo, SObject so){
    }
 
    public void afterDelete(SObject so){
    }   
    
    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    */  
    public void andFinally(){

        List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();

        if(Trigger.isAfter && Trigger.isInsert){
            List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id, Subscription_Charge_Number__c, Charge_Effective_End_Date__c, Charge_Effective_Start_Date__c
                                                         FROM zqu__QuoteRatePlanCharge__c WHERE Id IN: mapIdToSpc.keySet()];

            List<zqu__QuoteRatePlanCharge__c> listQrpcForUpdate = new List<zqu__QuoteRatePlanCharge__c>();

            for(zqu__QuoteRatePlanCharge__c qrpc : qrpcList){
                
                if(mapIdToSpc.containsKey(qrpc.Id) && String.isBlank(qrpc.Subscription_Charge_Number__c)){
                    
                    Zuora__SubscriptionProductCharge__c spc = mapIdToSpc.get(qrpc.Id);
                    qrpc.Subscription_Charge_Number__c = spc.Zuora__SubscriptionChargeNumber__c;
                    qrpc.Charge_Effective_Start_Date__c = spc.Zuora__EffectiveStartDate__c;
                    qrpc.Charge_Effective_End_Date__c = spc.Zuora__EffectiveEndDate__c;

                    listQrpcForUpdate.add(qrpc);
                }
            }

            List<Database.SaveResult> resultList = Database.update(listQrpcForUpdate, FALSE);
            xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
        }

        // CSP-2749 Asset Collections Cases
        // create/update the asset collections case for the beta account
        if (!amendedSubACCaseMap.isEmpty() || !newSubACCaseMap.isEmpty()) {
            createAndUpdateACCase(amendedSubACCaseMap, newSubACCaseMap);
        }

        // CSP-2443 rollback for the original subscription when cancelled a renewal subscription.
        if (!cancelledRenewSubInventoryBackMap.isEmpty()) {
            rollBackInventoryForCacelRenewalSub(cancelledRenewSubInventoryBackMap);
        }

        // CSP-1543
        if (cancelledSubInventoryReleaseMap.size() > 0) {
            releaseCancelledReplaceInventory(cancelledSubInventoryReleaseMap);
        }

        
        // CSP-1838 check the terms of subscription product charge, if the terms less than 12, check the subscription's flag includeLess12Item__c which is used for indicating the subscripiton has one or more Items whose Terms is less than 12
        if (!hasLess12ItemSubMap.isEmpty()) {
            List<Zuora__Subscription__c> updateSubList = [select id,includeLess12Item__c from Zuora__Subscription__c where id in : hasLess12ItemSubMap.keySet()];
            for (Zuora__Subscription__c record : updateSubList) {
                record.includeLess12Item__c = TRUE;
            }
            List<Database.SaveResult> resultList = Database.update(updateSubList, FALSE);
            xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
            
        }

        if (!mapSubNameToMapChargeNumberToSubCharge.isEmpty()) {

            List<Live_Subscription_Product_and_Charge__c> listLiveSPC = new list<Live_Subscription_Product_and_Charge__c>();

            listLiveSPC.addAll(LiveSubscriptionHandler.generateLiveSubscriptionPC(mapSubNameToMapChargeNumberToSubCharge, mapSubscriptionNameToEffectDate));
        
            if (!listLiveSPC.isEmpty()) {
                Schema.SObjectField subscriptionChargeNumber = Live_Subscription_Product_and_Charge__c.Fields.Zuora_ChargeNumber__c;
                List<Database.UpsertResult> resultList = Database.upsert(listLiveSPC, subscriptionChargeNumber, FALSE);
                xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
                
            }
        }
        
        if (!xoExceptionList.isEmpty()) {
            insert xoExceptionList;
        }
    }

    /**
     *   CSP-2443 | 
     *   due to a cancel a renewal subscription, we should rollback the flag "Do_not_create_inventory__c" to "NO" for the Original Subscription
     *
     *   @author Tony Liu
     *   @date   2017-10-16
     *   @param  {Set<String>}   cancelledRenewSubInventoryBackSet (the OriginalSalesforceQuoteID__c of subscription)
     */
    private static void rollBackInventoryForCacelRenewalSub(Map<String,Map<String,Id>> cancelledRenewSubInventoryBackMap) {

        System.debug(LoggingLevel.INFO, '*** cancelledRenewSubInventoryBackMap: ' + cancelledRenewSubInventoryBackMap);

        Map<Id,Map<String,Id>> originalSubInventoryBackMap = new Map<Id,Map<String,Id>>();
        List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
        Inventory_Hold_Expiry_Date_Offsets__c invHoldExpDate = Inventory_Hold_Expiry_Date_Offsets__c.getOrgDefaults();
        List<Inventory__c> rollBackInventoryList = new List<Inventory__c>();
        // query the original quote for the cancelled renewal subscription
        List<zqu__Quote__c> quoteList = [SELECT Id, Subscription_Being_Renewed__c 
                                         FROM zqu__Quote__c 
                                         WHERE Id in: cancelledRenewSubInventoryBackMap.keySet() AND Subscription_Being_Renewed__c != null];

        System.debug(LoggingLevel.INFO, '***quoteList : ' + quoteList);
        Set<Id> originalSubscriptionIdSet = new Set<Id>();
        if (!quoteList.isEmpty()) {

        for (zqu__Quote__c currentQuote : quoteList) {
            originalSubscriptionIdSet.add(currentQuote.Subscription_Being_Renewed__c);
            originalSubInventoryBackMap.put(currentQuote.Subscription_Being_Renewed__c, cancelledRenewSubInventoryBackMap.get(String.valueOf(currentQuote.Id)));
        }
        System.debug(LoggingLevel.INFO, '***originalSubInventoryBackMap : ' + originalSubInventoryBackMap);
        // query the original subscripiton product charge for the cancelled renewal subscription
        List<Zuora__SubscriptionProductCharge__c> zspcList = [SELECT Id, Do_not_create_inventory__c, Zuora__RatePlanId__c, Zuora__Subscription__c, LocationVendorDynamicsAccountID__c, 
                                                                     Zuora__Subscription__r.Zuora__TermEndDate__c, Zuora__RatePlanName__c, Zuora__Zuora_Id__c  
                                                              FROM Zuora__SubscriptionProductCharge__c 
                                                              WHERE Zuora__Subscription__c IN: originalSubscriptionIdSet];

        Map<String,String> zspcZuoraIdMap = new Map<String,String>();
        for ( Zuora__SubscriptionProductCharge__c currentZSPC: zspcList) {
            //  set Do_not_create_inventory__c back to NO for the original subscripiton product charge
            currentZSPC.Do_not_create_inventory__c = 'No';

            zspcZuoraIdMap.put(currentZSPC.Zuora__Zuora_Id__c,currentZSPC.Do_not_create_inventory__c);

            Map<String,Id> prlLocationInvetoryMap = originalSubInventoryBackMap.get(currentZSPC.Zuora__Subscription__c);
            System.debug(LoggingLevel.INFO, '***prlLocationInvetoryMap : ' + prlLocationInvetoryMap);
            // created back inventory for the original subscripiton product charge 
            // newRec.LocationVendorDynamicsAccountID__c + newRec.Zuora__RatePlanName__c;
            String keyString = currentZSPC.LocationVendorDynamicsAccountID__c + currentZSPC.Zuora__RatePlanName__c;

            System.debug(LoggingLevel.INFO, '*** keyString: ' + keyString);

            if (prlLocationInvetoryMap.containsKey(keyString)) {
                // generate a new inventory for original subscription product charge
                Inventory__c newInventoryRecord = new Inventory__c();
                newInventoryRecord.Product_Rate_Plan__c = prlLocationInvetoryMap.get(keyString);
                newInventoryRecord.Quote_Rate_Plan__c = null;
                    newInventoryRecord.Waitlist_Account__c = null;
                    newInventoryRecord.Subscription_Product_Charge__c = currentZSPC.id;
                    newInventoryRecord.Subscription_RatePlan_Id__c = currentZSPC.Zuora__RatePlanId__c;
                    newInventoryRecord.Inventory_Hold_Expiry_Date__c = DateUtility.AddBusinessDays(currentZSPC.Zuora__Subscription__r.Zuora__TermEndDate__c, (Integer)invHoldExpDate.Subscription_Product_Charge_Day_Offset__c);
                    rollBackInventoryList.add(newInventoryRecord);
                    System.debug(LoggingLevel.INFO, '***newInventoryRecord : ' + newInventoryRecord);
            }
        }

        Database.SaveResult[] dbUpdateResult = Database.update(zspcList, false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(dbUpdateResult));

            Database.SaveResult[] dbUpdateInventoryResult = Database.insert(rollBackInventoryList, false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(dbUpdateInventoryResult));

            if(xoExceptionList.size() > 0) {
                insert xoExceptionList;
            }
            // Sync the flag Do_not_create_inventory__c to zuora
            System.debug(LoggingLevel.INFO, '***zspcZuoraIdMap : ' + zspcZuoraIdMap);
            updateDataToZuora(zspcZuoraIdMap);
        }
    }

    /**
     *   CSP-1543 | "releaseCancelledReplaceInventory" determines if Inventory should be released
     *   due to a cancel/replace "renewal"
     *
     *   @author Jonathan Satterfield
     *   @date   2016-12-19
     *   @param  {Map<String, Zuora__SubscriptionProductCharge__c>}   cancelledSubInventoryReleaseMap     (key: Zuora__SubscriptionProductCharge__c.Zuora__ChargeNumber__c | value: Zuora__SubscriptionProductCharge__c)
     */
    private static void releaseCancelledReplaceInventory(Map<String, Zuora__SubscriptionProductCharge__c> cancelledSubInventoryReleaseMap) {
        Map<String, Inventory__c> spcChargeNumberToInventoryRecord = new Map<String, Inventory__c>();

        Map<String, List<Inventory__c>> oppPlusPRPIdsKeyToCancelInventoryListMap = new Map<String, List<Inventory__c>>();
        
        List<Inventory__c> inventoryDeleteList = new List<Inventory__c>();
        
        List<Zuora__SubscriptionProductCharge__c> updatedSPCList = new List<Zuora__SubscriptionProductCharge__c>();

        //Store ID of opportunity which contains the cancel quote and renewal quote
        Set<Id> setOppyIDs = new Set<Id>();

        //Store product rate plan ID to release cancellation inventory
        Set<Id> setProductRatePlanIDs = new Set<Id>();

        //Store all exception
        List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();

        for (String spcChargeNumber : cancelledSubInventoryReleaseMap.keySet()) {
            Zuora__SubscriptionProductCharge__c spcRec = cancelledSubInventoryReleaseMap.get(spcChargeNumber);
            // spcRec.Inventory__r will always have a value because we checked prior to calling this method
            spcChargeNumberToInventoryRecord.put(spcChargeNumber, spcRec.Inventory__r[0]);
        }

        if(!setCancelQuoteIDsToReleaseInventory.isEmpty()){
            // this first query populates data used in the next query below, which is where all the logic happens
            for (zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__Quote__c IN: setCancelQuoteIDsToReleaseInventory
                                                    AND zqu__ChargeNumber__c IN :cancelledSubInventoryReleaseMap.keySet() 
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]) {
                String oppPlusPRPIdsKey = '';

                if(String.isNotBlank(qcdRec.zqu__Quote__r.zqu__Opportunity__c)){
                    setOppyIDs.add(qcdRec.zqu__Quote__r.zqu__Opportunity__c);
                    oppPlusPRPIdsKey += (String)qcdRec.zqu__Quote__r.zqu__Opportunity__c;
                }
                
                if(String.isNotBlank(qcdRec.zqu__ProductRatePlan__c)){
                    setProductRatePlanIDs.add(qcdRec.zqu__ProductRatePlan__c);
                    oppPlusPRPIdsKey += (String)qcdRec.zqu__ProductRatePlan__c;
                }

                if(String.isNotBlank(oppPlusPRPIdsKey)){
                    List<Inventory__c> invList = oppPlusPRPIdsKeyToCancelInventoryListMap.containsKey(oppPlusPRPIdsKey) ? oppPlusPRPIdsKeyToCancelInventoryListMap.get(oppPlusPRPIdsKey) : new List<Inventory__c>();
                    
                    invList.add(spcChargeNumberToInventoryRecord.get(qcdRec.zqu__ChargeNumber__c));
                    
                    oppPlusPRPIdsKeyToCancelInventoryListMap.put(oppPlusPRPIdsKey, invList);
                }
            }
        }
        
        if(!setOppyIDs.isEmpty() && !setProductRatePlanIDs.isEmpty()){
            // determine if Inventory should be released due to a cancel/replace "renewal"
            for (zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                     FROM zqu__QuoteChargeDetail__c 
                                                     WHERE zqu__Quote__r.zqu__Opportunity__c IN :setOppyIDs 
                                                     AND zqu__ProductRatePlan__c IN :setProductRatePlanIDs 
                                                     AND Sent_to_ZBilling__c = TRUE
                                                     AND Subscription_Type__c = 'New Subscription']) {
                String oppPlusPRPIdsKey = '';
                if(String.isNotBlank(qcdRec.zqu__Quote__r.zqu__Opportunity__c)){
                    oppPlusPRPIdsKey += (String)qcdRec.zqu__Quote__r.zqu__Opportunity__c;
                }
                
                if(String.isNotBlank(qcdRec.zqu__ProductRatePlan__c)){
                    oppPlusPRPIdsKey += (String)qcdRec.zqu__ProductRatePlan__c;
                }

                if(String.isNotBlank(oppPlusPRPIdsKey)){
                    //If there is no any renewal zqu__QuoteChargeDetail__c under the same opportunity and product rate plan,
                    //we do not need to release cancellation inventory
                    if (!oppPlusPRPIdsKeyToCancelInventoryListMap.containsKey(oppPlusPRPIdsKey)) {
                        continue;
                    }

                    //If there is a renewal zqu__QuoteChargeDetail__c under the same opportunity and product rate plan,
                    //we pick up the cancellation inventory and delete it
                    List<Inventory__c> invList = oppPlusPRPIdsKeyToCancelInventoryListMap.get(oppPlusPRPIdsKey);
                    Inventory__c invRec = invList.remove(0);
                    if(invList.size() == 0) {
                        oppPlusPRPIdsKeyToCancelInventoryListMap.remove(oppPlusPRPIdsKey);
                    }
                    else{
                        oppPlusPRPIdsKeyToCancelInventoryListMap.put(oppPlusPRPIdsKey, invList);
                    }

                    //add Inventory record to delete list, and update the SubscriptionProductCharge so that Inventory isn't recreated by the nightly rebuild job
                    Zuora__SubscriptionProductCharge__c spcRec = cancelledSubInventoryReleaseMap.get(invRec.Subscription_Product_Charge__r.Zuora__ChargeNumber__c);
                    spcRec.Do_not_create_inventory__c = 'Yes';

                    updatedSPCList.add(spcRec);
                    inventoryDeleteList.add(invRec);
                }
            }
        }

        if(!inventoryDeleteList.isEmpty()) {
            Database.DeleteResult[] dbDeleteResult = Database.delete(inventoryDeleteList, false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(dbDeleteResult));
        }

        if(!updatedSPCList.isEmpty()) {
            Database.SaveResult[] dbUpdateResult = Database.update(updatedSPCList, false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(dbUpdateResult));
        }

        if(xoExceptionList.size() > 0) {
            insert xoExceptionList;
        }
    }

    /**
     *   CSP-1464 | "getSubscriptionAccountContactRolesForCallbacks" populates and returns a map that associates a Subscription Charge Number
     *   with an AccountContactRole record (when applicable). This map is then used to populate certain fields on a Callback__c record.
     *
     *   @author Jonathan Satterfield
     *   @date   2016-09-22
     *   @param  {List<Zuora__SubscriptionProductCharge__c>}     spcCallbackList
     *   @return {Map<Id, AccountContactRole>} (key: Zuora__SubscriptionProductCharge__c.Zuora__SubscriptionChargeNumber__c | value: AccountContactRole)
     */
    public static Map<Id, AccountContactRole> getSubscriptionAccountContactRolesForCallbacks(List<Zuora__SubscriptionProductCharge__c> spcCallbackList) {
        Map<Id, AccountContactRole> accountIdToAccountContactRoleMap = new Map<Id, AccountContactRole>();
        Set<Id> accountIdSet = new Set<Id>();
        for (Zuora__SubscriptionProductCharge__c spcRec : spcCallbackList) {
            accountIdSet.add(spcRec.Zuora__Account__c);
        }
        for (AccountContactRole acrRec : [SELECT Id, Role, IsPrimary, AccountId, ContactId, Contact.Email, Contact.Phone FROM AccountContactRole WHERE AccountId IN :accountIdSet AND (IsPrimary = true OR Role = 'Primary' OR Role = 'Online Materials')]) {
            // if the map doesn't contain a value yet or acrRec.IsPrimary == true, add it and continue to the next record
            if (!accountIdToAccountContactRoleMap.containsKey(acrRec.AccountId) || acrRec.IsPrimary) {
                accountIdToAccountContactRoleMap.put(acrRec.AccountId, acrRec);
                continue;
            }
            // otherwise, it's comparison time to determine which ACR record is assigned to the map
            // order of assignment: (1) IsPrimary == true, (2) Role == 'Primary', (3) Role == 'Online Materials'
            // note: there can be more than one ACR record with the same 'Role' value, in which case it doesn't matter who specifically gets assigned
            AccountContactRole acrMapRec = accountIdToAccountContactRoleMap.get(acrRec.AccountId);
            if (!acrMapRec.IsPrimary && acrMapRec.Role != 'Primary') {
                accountIdToAccountContactRoleMap.put(acrRec.AccountId, acrRec);
            }
        }
        return accountIdToAccountContactRoleMap;
    }

    /**
     *   CSP-2443 | 
     *   we should sync the data to zuora when the flag Do_not_create_inventory__c of subscription product charge has been changed to 'No'
     *
     *   @author Tony Liu
     *   @date   2017-10-16
     *   @param  {List<String>}   zspcZuoraIdList (the zuora Id of original subscription product charge)
     */
    @future(callout=true)   
    public static void updateDataToZuora(Map<String,String> zspcZuoraIdMap) {
        try{
            Zuora.ZApi zApiInstance = new Zuora.ZApi();
        // skip the login call if this is a test
        if (!Test.isRunningTest()) {
          Zuora.zApi.LoginResult loginResult = zApiInstance.zlogin();
        }
        System.debug(LoggingLevel.INFO, '***zspcZuoraIdMap : ' + zspcZuoraIdMap);
        List<Zuora.zObject> zuoraZObjectList = new List<Zuora.zObject>();

        List<Zuora.zApi.SaveResult> zuoraSaveResults = new List<Zuora.zApi.SaveResult>();

        for (String zuoraIdString : zspcZuoraIdMap.keySet()) {
          Zuora.zObject sub = new Zuora.zObject('RatePlanCharge');
          sub.setValue('Id',zuoraIdString);
          sub.setValue('Do_not_create_inventory__c',zspcZuoraIdMap.get(zuoraIdString));
          
          zuoraZObjectList.add(sub);

          if(zuoraZObjectList.size() == 50){
            if (!Test.isRunningTest()) {
              // callout method documention is here: https://knowledgecenter.zuora.com/CA_Commerce/E_Development_Resources/B_Order_Builder/D_Programming_with_Order_Builder
              zuoraSaveResults.addAll(zApiInstance.zupdate(zuoraZObjectList));
            }
            zuoraZObjectList.clear();
          }
        }

        if(!zuoraZObjectList.isEmpty()) {
            if (!Test.isRunningTest()) {
              // callout method documention is here: https://knowledgecenter.zuora.com/CA_Commerce/E_Development_Resources/B_Order_Builder/D_Programming_with_Order_Builder
              zuoraSaveResults.addAll(zApiInstance.zupdate(zuoraZObjectList));
            }
            }
            
            List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
            for (Zuora.zApi.SaveResult zuoraResult: zuoraSaveResults) {
                if (!zuoraResult.Success) {
                    String errorMessages = zuoraResult.Id + ': \r\n';
                for(Integer i = 0, length = zuoraResult.Errors.size(); i < length; i++) {
                  errorMessages += zuoraResult.Errors[i].getValue('Code') + ' | ' + zuoraResult.Errors[i].getValue('Message') + '\r\n';
                }
                    xoExceptionList.add(ExceptionUtility.consumeException('zuotaDataUpdateError',errorMessages,false,null));
                }
            }
            if (!xoExceptionList.isEmpty()) {
                insert xoExceptionList;
            }
        }catch(Exception ex){
            ExceptionUtility.consumeException(ex, true);
        }       
    }   


    /**
     *   CSP-2749 | Asset Collections Cases
     *   Purpose: for all beta account (The beta account means the account strategist is the dummy user),
     *   (1) if a Subscription Product Charge was removed as part of a Subscription Amendment, open Asset Collections Case records for that Product are marked as "Cancelled"
     *   (2) for the rest of the Subscription Product Charge records on the amended Subscription, open Asset Collections Case records that were associated with the previous
     *       (and now deleted) version of the Subscription Product Charge record are queried and then associated with the new version of the record
     *   (3) if no existing Asset Collections Case record is found for the amendmend Subscription Product Charge record, or the Subscription Product Charge record is for a 
     *       brand new Subscription, a new Asset Collections Case record is created
     *
     *   @author Tony
     *   @date   2018-04-16
     *   @param  {Map<String, Zuora__SubscriptionProductCharge__c>}   amendedSubACCaseMap     (key: Zuora__SubscriptionProductCharge__c.Zuora__SubscriptionChargeNumber__c | value: Zuora__SubscriptionProductCharge__c)
     *   @param  {Map<String, List<Zuora__SubscriptionProductCharge__c>>}   newSubACCaseMap     (key: Zuora__SubscriptionProductCharge__c.Zuora__ProductSKU__c | value: List<Zuora__SubscriptionProductCharge__c>)
     */
    public static void createAndUpdateACCase(Map<String, Zuora__SubscriptionProductCharge__c> amendedSubACCaseMap, Map<String, List<Zuora__SubscriptionProductCharge__c>> newSubACCaseMap) {
        // The Asset Collection Case List which we need assign to new charge or update status or insert
        List<Case> acCaseUpsertList = new List<Case>();

        if (!amendedSubACCaseMap.isEmpty()) {
            // set up data for the Asset Collections Case query
            Set<String> subscriptionNameSet = new Set<String>();
            for (Zuora__SubscriptionProductCharge__c spcRec : amendedSubACCaseMap.values()) {
                if (String.isNotBlank(spcRec.Zuora__Subscription__r.Name)) {
                    subscriptionNameSet.add(spcRec.Zuora__Subscription__r.Name);
                }
            }
            if (!subscriptionNameSet.isEmpty()) {
                for (Case existingACCaseRecord : [SELECT Id, Subscription_Name__c, Subscription_Charge_Number__c, SubscriptionProductCharge__c, Status 
                                                    FROM Case WHERE RecordType.Name ='Asset Collection' AND Subscription_Name__c IN :subscriptionNameSet]) {
                    // this handles Product Removal Amendments (no related Subscription Product Charge record synced down)
                    if (!amendedSubACCaseMap.containsKey(existingACCaseRecord.Subscription_Charge_Number__c)) {
                        existingACCaseRecord.Status = 'Cancelled';
                        acCaseUpsertList.add(existingACCaseRecord);
                        continue;
                    }
                    //if the Subscription Product Charge is updated or cancelled, we should remove this charge from the amendedSubACCaseMap
                    Zuora__SubscriptionProductCharge__c zspcRec = amendedSubACCaseMap.remove(existingACCaseRecord.Subscription_Charge_Number__c);
                    // if the Subscription Product Charge is cancelled, we should set the Case Status to Cancelled, otherwise remain the status. 
                    // And all the case should assign to new Subscription Product Charge.
                    existingACCaseRecord.Status = zspcRec.Zuora__Subscription__r.True_Subscription_Status__c == 'Cancelled' ? 'Cancelled' : existingACCaseRecord.Status;
                    existingACCaseRecord.SubscriptionProductCharge__c = zspcRec.Id;
                    acCaseUpsertList.add(existingACCaseRecord);

                }
            }
            
            // after the initial run, if there are leftover records in the amendedSubACCaseMap (aka no existing Callback was found), move them over to the newSubACCaseMap so a Callback__c record will be created
            for (Zuora__SubscriptionProductCharge__c zspcRec : amendedSubACCaseMap.values()) {
                List<Zuora__SubscriptionProductCharge__c> spcList = newSubACCaseMap.containsKey(zspcRec.Zuora__ProductSKU__c) ? newSubACCaseMap.get(zspcRec.Zuora__ProductSKU__c) : new List<Zuora__SubscriptionProductCharge__c>();
                spcList.add(zspcRec);
                newSubACCaseMap.put(zspcRec.Zuora__ProductSKU__c, spcList);
            }       
        }

        if (!newSubACCaseMap.isEmpty()) {
            List<Zuora__SubscriptionProductCharge__c> spcACCaseList = new List<Zuora__SubscriptionProductCharge__c>();

            // query for products that do NOT require a callback task, and remove them from the newSubACCaseMap
            for (Product2 productRec : [SELECT Id, zqu__SKU__c, RequiresCallbackTask__c FROM Product2 WHERE zqu__SKU__c IN :newSubACCaseMap.keySet() AND RequiresCallbackTask__c != 'YES' AND zqu__Deleted__c = false]) {
                newSubACCaseMap.remove(productRec.zqu__SKU__c);
            }
            
            // get all Subscription Product Charges which should generate an asset collection case
            for (List<Zuora__SubscriptionProductCharge__c> spcList : newSubACCaseMap.values()) {
                spcACCaseList.addAll(spcList);
            }

            if(!spcACCaseList.isEmpty()){
                // get the primary account contact role
                Map<Id, AccountContactRole> accountIdToAccountContactRoleMap = getSubscriptionAccountContactRolesForCallbacks(spcACCaseList);

                //create Asset Collection case
                List<Case> listAssetCollectionCaseToInsert = CaseService.createAssetCollectionCase(spcACCaseList, accountIdToAccountContactRoleMap);

                if(!listAssetCollectionCaseToInsert.isEmpty()){

                    acCaseUpsertList.addAll(listAssetCollectionCaseToInsert);
                }
            }

        }

        if (!acCaseUpsertList.isEmpty()) {
            Database.UpsertResult[] upsertResults = Database.upsert(acCaseUpsertList, false);
            List<XO_Exception__C> acCaseUpsertExceptionList = ExceptionUtility.consumeException(upsertResults);
            if (!acCaseUpsertExceptionList.isEmpty()) {
                insert acCaseUpsertExceptionList;
            }
        }
    }

}