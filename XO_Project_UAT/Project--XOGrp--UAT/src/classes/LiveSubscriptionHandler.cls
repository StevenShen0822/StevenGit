public without sharing class LiveSubscriptionHandler {

    private static final String EXIST_LIVE_SUBSCRIPTION_QUERY = 'SELECT '
                                                            + 'Id, '
                                                            + 'Switch_Date__c, '
                                                            + 'Subscription_Name__c, '
                                                            + 'Original_Subscription__r.Zuora__External_Id__c, '
                                                            + '(SELECT '
                                                                    + 'Id, '
                                                                    + 'Zuora_ChargeNumber__c, '
                                                                    + 'Zuora_EffectiveEndDate__c, '
                                                                    + 'Zuora_EffectiveStartDate__c, '
                                                                    + 'LDE_Email_Launch_Date__c, '
                                                                    + 'List_Price__c, '
                                                                    + 'Live_Subscription__c, '
                                                                    + 'Market_ID__c, '
                                                                    + 'Print_Issue__c, '
                                                                    + 'Zuora_Product_Name__c, '
                                                                    + 'Product_Type__c, '
                                                                    + 'Amement_Type__c, '
                                                                    + 'Error_Email_Notification_Flag__c, '
                                                                    + 'Subscription_Product_And_Charge__c, '
                                                                    + 'Live_Subscription__r.Subscription_Name__c '
                                                                +'FROM ' 
                                                                    +'Live_Subscription_Product_and_Charges__r) '
                                                        + 'FROM '
                                                            + 'Live_Subscription__c '
                                                        + 'WHERE '
                                                            + '{0}';

    private static final String MESSAGE_SUBJECT = 'Live Charge missing Service Activation Date';
    private static final String MESSAGE_BODY = 'Live Charge missing Service Activation Date';
    private static final String DELIMITER = '\r\n';
    private static final String LIVE_CHARGE_ERROR_MESSAGE_USER_ID = System.Label.Live_Charge_Error_Message_User_ID;

    /**
     * @purpose copy the subscription info to the live subscription
     * @author  Tony
     * @date    2018-10-18
     * @param   object Zuora__Subscription__c  the subscription inserted
     * @return  object Live_Subscription__c
     */
    public static Live_Subscription__c copySubscription(Zuora__Subscription__c zuoraSub){

        Live_Subscription__c liveSub = New Live_Subscription__c();
        liveSub.Name = zuoraSub.Name;
        liveSub.Original_Quote__c = zuoraSub.Original_Quote__c;
        liveSub.Original_Subscription__c = zuoraSub.Id;
        liveSub.Product_Line__c = zuoraSub.Product_Line__c;
        liveSub.Post_Zuora_TermEndDate__c = zuoraSub.Zuora__TermEndDate__c;
        liveSub.Post_Zuora_TermStartDate__c = zuoraSub.Zuora__TermStartDate__c;
        liveSub.Zuora_CancelledDate__c = zuoraSub.Zuora__CancelledDate__c;
        liveSub.Post_AutoRenewal__c = zuoraSub.AutoRenewal__c;
        liveSub.Post_Is_Valid_Subscription__c = zuoraSub.Is_Valid_Subscription__c;
        liveSub.Post_Latest_Quote__c = zuoraSub.Latest_Quote__c;
        liveSub.Post_Opportunity__c = zuoraSub.Opportunity_Id__c;
        liveSub.Post_Payment_Method__c = zuoraSub.Payment_Method__c;
        liveSub.Post_Preferred_Payment_Schedule__c = zuoraSub.Preferred_Payment_Schedule__c;
        liveSub.Post_Quote_Number__c = zuoraSub.Latest_Quote_Number__c;

        liveSub.Post_RSD__c = zuoraSub.RSD__c;
        liveSub.Post_RSD_Id__c = zuoraSub.RSD_Id__c;
        liveSub.Post_Sales_Rep__c = zuoraSub.Sales_Rep__c;
        liveSub.Post_SalesRepId__c = zuoraSub.SalesRepId__c;
        liveSub.Post_Renewal_Rep__c = zuoraSub.Renewal_Rep__c;
        liveSub.Post_RenewalRepId__c = zuoraSub.RenewalRepId__c;

        liveSub.Post_Zuora_Account__c = zuoraSub.Zuora__Account__c;
        liveSub.Post_Zuora_ContractEffectiveDate__c = zuoraSub.Zuora__ContractEffectiveDate__c;
        liveSub.Post_Zuora_CustomerAccount__c = zuoraSub.Zuora__CustomerAccount__c;
        liveSub.Post_Zuora_InitialTerm__c = zuoraSub.Zuora__InitialTerm__c;
        liveSub.Post_Zuora_InitialTermPeriodType__c = zuoraSub.Zuora__InitialTermPeriodType__c;
        liveSub.Post_Zuora_Status__c = zuoraSub.Zuora__Status__c;
        liveSub.Post_Zuora_SubscriptionEndDate__c = zuoraSub.Zuora__SubscriptionEndDate__c;
        liveSub.Post_Zuora_SubscriptionStartDate__c = zuoraSub.Zuora__SubscriptionStartDate__c;
        liveSub.Post_Zuora_TermSettingType__c = zuoraSub.Zuora__TermSettingType__c;
        liveSub.Subscription_Name__c = zuoraSub.Name;
        liveSub.Subscription_Version__c = zuoraSub.Zuora__Version__c;
        

        liveSub.Residual_Subscription_Name__c = zuoraSub.Residual_Subscription_Name__c;

        if (zuoraSub.Zuora__Version__c == 1) {
            liveSub.Switch_Date__c = date.today();
        }else{
            liveSub.Switch_Date__c = zuoraSub.Quote_Term_Start_Date__c;
        }

        return liveSub;
    }

    /**
     * @purpose generate the live subscription product charge from the Zuora subscription product charge
     * @author  Tony
     * @date    2018-10-18
     * @param   map  mapSubNameToMapChargeNumberToSubCharge  stored the subs name to map stored all charges under the subs
     * @param   map subscriptionNameEffectDateMap   Store the salesforce amendment subscription's name to the activation date of the new version
     * @return  object Live_Subscription__c
     */
    public static List<Live_Subscription_Product_and_Charge__c> generateLiveSubscriptionPC(Map<String, Map<String,Zuora__SubscriptionProductCharge__c>> mapSubNameToMapChargeNumberToSubCharge, 
                                                                                    Map<String,Date> subscriptionNameEffectDateMap){
        
        List<Live_Subscription_Product_and_Charge__c> listLiveSPC = new List<Live_Subscription_Product_and_Charge__c>();
        Map<String,List<Live_Subscription_Product_and_Charge__c>> mapSubZuoraIdToListLiveCharge = new Map<String,List<Live_Subscription_Product_and_Charge__c>>();
        
        Set<String> subscriptionNameSet = new Set<String>();
        subscriptionNameSet.addAll(mapSubNameToMapChargeNumberToSubCharge.keySet());
        List<String> listWhereClause = new String[]{'Subscription_Name__c IN: subscriptionNameSet'};
        String liveSubscriptionQuery = String.format(EXIST_LIVE_SUBSCRIPTION_QUERY, listWhereClause);
        List<Live_Subscription__c> liveSubscriptionList = database.query(liveSubscriptionQuery);

        if (!liveSubscriptionList.isEmpty()) {

            for (Live_Subscription__c currentLS: liveSubscriptionList) {

                Map<String, Zuora__SubscriptionProductCharge__c> chargeNumberMap = mapSubNameToMapChargeNumberToSubCharge.remove(currentLS.Subscription_Name__c);
                // New Subscription 
                if (currentLS.Live_Subscription_Product_and_Charges__r.isEmpty()) {
                    for (String chargeNumber : chargeNumberMap.keySet()) {
                        Zuora__SubscriptionProductCharge__c currentCharge = chargeNumberMap.get(chargeNumber);

                        Live_Subscription_Product_and_Charge__c newLSPC = new Live_Subscription_Product_and_Charge__c();

                        newLSPC = LiveSubscriptionHandler.copyLiveSPCFromSPC(currentCharge,currentLS);
                        newLSPC.Amement_Type__c = 'New Subscription';
                        newLSPC.Switch_Date__c = Date.newInstance(1900, 1, 1);

                        listLiveSPC.add(newLSPC);
                    }
                }
                // Amend/cancel subscription, the LSPC already existed in system
                else{
                    for (Live_Subscription_Product_and_Charge__c currentLSPC : currentLS.Live_Subscription_Product_and_Charges__r) {
                        // if the live charge has been found, Update product/ cancel subscription
                        if (chargeNumberMap.containsKey(currentLSPC.Zuora_ChargeNumber__c)) {

                            Zuora__SubscriptionProductCharge__c currentCharge = chargeNumberMap.remove(currentLSPC.Zuora_ChargeNumber__c);
                            // for the amendment subscription, the charge has been update

                            if (currentCharge.Zuora__EffectiveStartDate__c != currentLSPC.Zuora_EffectiveStartDate__c){
                                date effectiveStartDate = currentLSPC.Zuora_EffectiveStartDate__c;
                                currentLSPC = LiveSubscriptionHandler.copyLiveSPCFromSPC(currentCharge,currentLS);
                                
                                currentLSPC.Amement_Type__c = 'Update Product';
                                currentLSPC.Switch_Date__c = currentCharge.Zuora__EffectiveStartDate__c;
                            }
                            // for the cancelled subscription, all live subscription product charges should be updated the end date
                            else if (currentCharge.Zuora__EffectiveEndDate__c != currentLSPC.Zuora_EffectiveEndDate__c) {
                                currentLSPC = LiveSubscriptionHandler.copyLiveSPCFromSPC(currentCharge,currentLS);
                                currentLSPC.Amement_Type__c = 'Cancel Subscription';
                                currentLSPC.Zuora_EffectiveEndDate__c = currentCharge.Zuora__EffectiveEndDate__c;
                                
                            }else{
                                currentLSPC = LiveSubscriptionHandler.copyLiveSPCFromSPC(currentCharge,currentLS);
                            }

                            listLiveSPC.add(currentLSPC);
                        }
                        else if (currentLSPC.Amement_Type__c != 'Remove Product' && !currentLSPC.Error_Email_Notification_Flag__c) {
                            // amend removed from salesforce, we can find the effective date from latest subscription and assign to the Switchdate
                            if (subscriptionNameEffectDateMap.containsKey(currentLSPC.Live_Subscription__r.Subscription_Name__c)) {

                                currentLSPC.Zuora_EffectiveEndDate__c = subscriptionNameEffectDateMap.get(currentLSPC.Live_Subscription__r.Subscription_Name__c);
                                currentLSPC.Amement_Type__c = 'Remove Product';

                                listLiveSPC.add(currentLSPC);

                            }
                            // the subs was amend/canceled from zuora
                            else{
                                currentLSPC.Error_Email_Notification_Flag__c = TRUE;

                                if (mapSubZuoraIdToListLiveCharge.containsKey(currentLS.Original_Subscription__r.Zuora__External_Id__c)) {
                                    mapSubZuoraIdToListLiveCharge.get(currentLS.Original_Subscription__r.Zuora__External_Id__c).add(currentLSPC);
                                }else {
                                    List<Live_Subscription_Product_and_Charge__c> listTempLiveSPC = new List<Live_Subscription_Product_and_Charge__c>();
                                    listTempLiveSPC.add(currentLSPC);
                                    mapSubZuoraIdToListLiveCharge.put(currentLS.Original_Subscription__r.Zuora__External_Id__c,listTempLiveSPC);
                                }

                                listLiveSPC.add(currentLSPC);
                            }
                        }
                    }

                    // add product
                    if (!chargeNumberMap.isEmpty()) {

                        for (String chargeNumber: chargeNumberMap.keySet() ) {
                            Zuora__SubscriptionProductCharge__c currentCharge = chargeNumberMap.get(chargeNumber);

                            Live_Subscription_Product_and_Charge__c newLSPC = new Live_Subscription_Product_and_Charge__c();

                            newLSPC = LiveSubscriptionHandler.copyLiveSPCFromSPC(currentCharge,currentLS);
                            newLSPC.Amement_Type__c = 'Add Product';
                            newLSPC.Switch_Date__c = currentCharge.Zuora__EffectiveStartDate__c;

                            listLiveSPC.add(newLSPC);
                        }
                        
                    }

                }
            }
            
            // we should send email to the special users when the charge has been removed from Zuora
            if (!mapSubZuoraIdToListLiveCharge.isEmpty()) {

                List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
                try{
                    List<Messaging.SingleEmailMessage> listLiveSPCErrorMessage = new List<Messaging.SingleEmailMessage>();
                    listLiveSPCErrorMessage = EmailUtility.createLiveChargeEmail(LIVE_CHARGE_ERROR_MESSAGE_USER_ID,mapSubZuoraIdToListLiveCharge);

                    List<Messaging.SendEmailResult> listResultsOfSendEmail = Messaging.sendEmail(listLiveSPCErrorMessage, false);
                    xoExceptionList.addAll(ExceptionUtility.consumeException(listResultsOfSendEmail));

                }catch(Exception ex){

                    xoExceptionList.add(ExceptionUtility.consumeException(ex,false));
                }

                if (!xoExceptionList.isEmpty()) {
                    insert xoExceptionList;
                }
            }
        }
        return listLiveSPC;
    }

    /** 
     * @purpose copy the subscription product charge info to the live subscription product charge
     * @author  Tony
     * @date    2018-10-18
     * @param   object Zuora__SubscriptionProductCharge__c  the subscription product charge be inserted
     * @param   object Live_Subscription__c  the live subscription that the parent zuora subscription of the charge generate
     * @return  object Live_Subscription_Product_and_Charge__c
     */
    public static Live_Subscription_Product_and_Charge__c copyLiveSPCFromSPC(Zuora__SubscriptionProductCharge__c zuoraSPC, Live_Subscription__c liveSubscription){

        Live_Subscription_Product_and_Charge__c newLSPC = new Live_Subscription_Product_and_Charge__c();

        newLSPC.Name = zuoraSPC.Zuora__ChargeNumber__c;
        newLSPC.Zuora_Account__c = zuoraSPC.Zuora__Account__c;
        newLSPC.Live_Subscription__c = liveSubscription.Id;
        newLSPC.Subscription_Product_And_Charge__c = zuoraSPC.Id;
        newLSPC.Zuora_ChargeNumber__c = zuoraSPC.Zuora__ChargeNumber__c;
        newLSPC.Category_Taxonomy_ID__c = zuoraSPC.Category_Taxonomy_ID__c;
        newLSPC.Market_ID__c = zuoraSPC.Market_ID__c;
        newLSPC.Product_Type__c = zuoraSPC.Product_Type__c;
        newLSPC.Rate_Plan_Name__c = zuoraSPC.Zuora__RatePlanName__c;
        newLSPC.Zuora_EffectiveEndDate__c = zuoraSPC.Zuora__EffectiveEndDate__c;
        newLSPC.Zuora_EffectiveStartDate__c = zuoraSPC.Zuora__EffectiveStartDate__c;
        newLSPC.Zuora_Product_Name__c = zuoraSPC.Product_Name_Text__c;
        newLSPC.Subscription_Version__c = zuoraSPC.Zuora__Subscription__r.Zuora__Version__c;

        newLSPC.Post_Discount_Percentage__c = zuoraSPC.Discount_Percentage__c;
        newLSPC.Post_Discount_Reason__c = zuoraSPC.Discount_Reason__c;
        newLSPC.Post_List_Price__c = zuoraSPC.List_Price__c;
        newLSPC.Post_RSD_Id__c = zuoraSPC.RSD_Id__c;
        newLSPC.Post_SalesRepID__c = zuoraSPC.SalesRepID__c;
        newLSPC.Post_Zuora_MonthlyRecurringRevenue__c = zuoraSPC.Zuora__MonthlyRecurringRevenue__c;
        newLSPC.Post_Zuora_Price__c = zuoraSPC.Zuora__Price__c;
        newLSPC.Post_Zuora_TotalContractValue__c = zuoraSPC.Zuora__TotalContractValue__c;

        // LDE
        newLSPC.LDE_Email_Launch_Date__c = zuoraSPC.LDE_Email_Launch_Date__c;
        // print
        newLSPC.X1st_Cover_Date__c = zuoraSPC.X1st_cover_ship_date__c;
        newLSPC.Print_Issue__c = zuoraSPC.Print_Issue__c;

        return newLSPC;
    }

    /** 
     * @purpose copy the post value to the pre value for the live subscription that the zuora version has been changed
     * @author  Tony 
     * @date    2018-10-18
     * @param   object Live_Subscription__c  the live subscription after update
     * @param   object Live_Subscription__c  the live subscription before update
     * @return  object Live_Subscription__c  
     */
    public static Live_Subscription__c updatePostToPreForLiveSubs( Live_Subscription__c newLiveSubObj, Live_Subscription__c oldLiveSubObj){

        newLiveSubObj.Pre_Zuora_TermEndDate__c = oldLiveSubObj.Post_Zuora_TermEndDate__c;
        newLiveSubObj.Pre_Zuora_TermStartDate__c = oldLiveSubObj.Post_Zuora_TermStartDate__c;
        newLiveSubObj.Pre_AutoRenewal__c = oldLiveSubObj.Post_AutoRenewal__c;
        newLiveSubObj.Pre_Is_Valid_Subscription__c = oldLiveSubObj.Post_Is_Valid_Subscription__c;
        newLiveSubObj.Pre_Latest_Quote__c = oldLiveSubObj.Post_Latest_Quote__c;
        newLiveSubObj.Pre_Opportunity__c = oldLiveSubObj.Post_Opportunity__c;
        newLiveSubObj.Pre_Payment_Method__c = oldLiveSubObj.Post_Payment_Method__c;
        newLiveSubObj.Pre_Preferred_Payment_Schedule__c = oldLiveSubObj.Post_Preferred_Payment_Schedule__c;
        newLiveSubObj.Pre_Quote_Number__c = oldLiveSubObj.Post_Quote_Number__c;
        newLiveSubObj.Pre_RSD_Id__c = oldLiveSubObj.Post_RSD_Id__c;
        newLiveSubObj.Pre_Sales_Rep__c = oldLiveSubObj.Post_Sales_Rep__c;
        newLiveSubObj.Pre_SalesRepId__c = oldLiveSubObj.Post_SalesRepId__c;
        newLiveSubObj.Pre_Zuora_Account__c = oldLiveSubObj.Post_Zuora_Account__c;
        newLiveSubObj.Pre_Zuora_ContractEffectiveDate__c = oldLiveSubObj.Post_Zuora_ContractEffectiveDate__c;
        newLiveSubObj.Pre_Zuora_CustomerAccount__c = oldLiveSubObj.Post_Zuora_CustomerAccount__c;
        newLiveSubObj.Pre_Zuora_InitialTerm__c = oldLiveSubObj.Post_Zuora_InitialTerm__c;
        newLiveSubObj.Pre_Zuora_InitialTermPeriodType__c = oldLiveSubObj.Post_Zuora_InitialTermPeriodType__c;
        newLiveSubObj.Pre_Zuora_Status__c = oldLiveSubObj.Post_Zuora_Status__c;
        newLiveSubObj.Pre_Zuora_SubscriptionEndDate__c = oldLiveSubObj.Post_Zuora_SubscriptionEndDate__c;
        newLiveSubObj.Pre_Zuora_SubscriptionStartDate__c = oldLiveSubObj.Post_Zuora_SubscriptionStartDate__c;
        newLiveSubObj.Pre_Zuora_TermSettingType__c = oldLiveSubObj.Post_Zuora_TermSettingType__c;

        newLiveSubObj.Pre_RSD__c = oldLiveSubObj.Post_RSD__c;
        newLiveSubObj.Pre_RSD_Id__c = oldLiveSubObj.Post_RSD_Id__c;
        newLiveSubObj.Pre_Sales_Rep__c = oldLiveSubObj.Post_Sales_Rep__c;
        newLiveSubObj.Pre_SalesRepId__c = oldLiveSubObj.Post_SalesRepId__c;
        newLiveSubObj.Pre_Renewal_Rep__c = oldLiveSubObj.Post_Renewal_Rep__c;
        newLiveSubObj.Pre_RenewalRepId__c = oldLiveSubObj.Post_RenewalRepId__c;

        return newLiveSubObj;
    }

    /** 
     * @purpose copy the post value to the pre value for the live subscription product charge that the zuora version has been changed
     * @author  Tony 
     * @date    2018-10-18
     * @param   object Live_Subscription_Product_and_Charge__c  the live subscription after update
     * @param   object Live_Subscription_Product_and_Charge__c  the live subscription before update
     * @return  object Live_Subscription_Product_and_Charge__c  
     */
    public static Live_Subscription_Product_and_Charge__c updatePostToPreForLiveSPC( Live_Subscription_Product_and_Charge__c newLiveSubPCObj, 
                                                                            Live_Subscription_Product_and_Charge__c oldLiveSubPCObj){

        newLiveSubPCObj.Pre_Discount_Percentage__c = oldLiveSubPCObj.Post_Discount_Percentage__c;
        newLiveSubPCObj.Pre_Discount_Reason__c = oldLiveSubPCObj.Post_Discount_Reason__c;
        newLiveSubPCObj.Pre_List_Price__c = oldLiveSubPCObj.Post_List_Price__c;
        newLiveSubPCObj.Pre_RSD_Id__c = oldLiveSubPCObj.Post_RSD_Id__c;
        newLiveSubPCObj.Pre_SalesRepID__c = oldLiveSubPCObj.Post_SalesRepID__c;
        newLiveSubPCObj.Pre_Zuora_MonthlyRecurringRevenue__c = oldLiveSubPCObj.Post_Zuora_MonthlyRecurringRevenue__c;
        newLiveSubPCObj.Pre_Zuora_Price__c = oldLiveSubPCObj.Post_Zuora_Price__c;
        newLiveSubPCObj.Pre_Zuora_TotalContractValue__c = oldLiveSubPCObj.Post_Zuora_TotalContractValue__c;

        return newLiveSubPCObj;
    }

    /** 
     * @purpose Update the Sales/Renewal/RSD Rep info for the live subscription when the Rep info on Subscription has been changed
     * @author  Tony
     * @date    2018-12-16
     * @param   mapNameToSubscription the map about zuora Subscripiton name to the record of zuora Subscription
     */
    public static void updateRenewalSalesRSDForLiveSub(Map<String, Zuora__Subscription__c> mapNameToSubscription){

        List<Live_Subscription__c> listLiveSubs = [SELECT Id, Subscription_Name__c, Pre_RSD__c, Post_RSD__c, Pre_RSD_Id__c, Post_RSD_Id__c, Pre_Sales_Rep__c, Post_Sales_Rep__c,
                                                        Pre_SalesRepId__c, Post_SalesRepId__c, Pre_Renewal_Rep__c, Post_Renewal_Rep__c, Pre_RenewalRepId__c,
                                                        Post_RenewalRepId__c ,Renewal_Rep_Id__c, RSD_Id__c, SalesRepId__c 
                                                    FROM Live_Subscription__c 
                                                    WHERE Subscription_Name__c in: mapNameToSubscription.keySet()];
        for (Live_Subscription__c liveSub: listLiveSubs) {
            
            if (mapNameToSubscription.containsKey(liveSub.Subscription_Name__c)) {
                Zuora__Subscription__c zuoraSub = mapNameToSubscription.get(liveSub.Subscription_Name__c);

                if (liveSub.Renewal_Rep_Id__c != zuoraSub.RenewalRepId__c) {

                    liveSub.Pre_RenewalRepId__c = zuoraSub.RenewalRepId__c;
                    liveSub.Post_RenewalRepId__c = zuoraSub.RenewalRepId__c;
                    liveSub.Pre_Renewal_Rep__c = zuoraSub.Renewal_Rep__c;
                    liveSub.Post_Renewal_Rep__c = zuoraSub.Renewal_Rep__c;
                }

                if (liveSub.SalesRepId__c != zuoraSub.SalesRepID__c) {
                    
                    liveSub.Pre_SalesRepId__c = zuoraSub.SalesRepID__c;
                    liveSub.Post_SalesRepId__c = zuoraSub.SalesRepID__c;
                    liveSub.Pre_Sales_Rep__c = zuoraSub.Sales_Rep__c;
                    liveSub.Post_Sales_Rep__c = zuoraSub.Sales_Rep__c;
                }

                if (liveSub.RSD_Id__c != zuoraSub.RSD_Id__c) {

                    liveSub.Pre_RSD__c = zuoraSub.RSD__c;
                    liveSub.Post_RSD__c = zuoraSub.RSD__c;
                    liveSub.Pre_RSD_Id__c = zuoraSub.RSD_Id__c;
                    liveSub.Post_RSD_Id__c = zuoraSub.RSD_Id__c;
                }

            }
        }

        List<Database.SaveResult> listUpdateResults = Database.update(listLiveSubs, false);
        List<XO_Exception__c> xoExceptionList = ExceptionUtility.consumeException(listUpdateResults);
        if (!xoExceptionList.isEmpty()) {
            insert xoExceptionList;
        }
    }

}