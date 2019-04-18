public without sharing class TransactionTaggingHandler {

    public static Map<Id, Date> mapAccountIdToSubEndDate = new Map<Id,Date>();
    public static Map<Id, Date> mapInternetSub = new Map<Id,Date>();
    public static Map<String,Date> mapKeyStrToEndDate = new Map<String,Date>();

    /**
     * @purpose generate the static data to calculate the order type 1 and order type 2 of the quote
     * @author  Tony Liu
     * @date    2018-10-11
     * @param   Set account id set
     * @return  null
     */
    public static void buildDataMap(Set<Id> accountIdSet) {

        List<Live_Subscription_Product_and_Charge__c> listLSPC = [SELECT Id,Market_ID__c,Zuora_EffectiveEndDate__c, Zuora_Account__c,
                                                                        Live_Subscription__r.Zuora_TermEndDate__c, Live_Subscription__r.Product_Line__c
                                                                FROM Live_Subscription_Product_and_Charge__c 
                                                                WHERE Zuora_Account__c IN : accountIdSet 
                                                                    AND Live_Subscription__r.Is_Valid_Subscription__c = TRUE 
                                                                ORDER BY Live_Subscription__r.Zuora_TermEndDate__c DESC]; 

        if (!listLSPC.isEmpty()) {
            for (Live_Subscription_Product_and_Charge__c lspc:  listLSPC) {
                
                if (!mapAccountIdToSubEndDate.containsKey(lspc.Zuora_Account__c)){
                    mapAccountIdToSubEndDate.put(lspc.Zuora_Account__c, lspc.Live_Subscription__r.Zuora_TermEndDate__c);
                }

                if(!mapInternetSub.containsKey(lspc.Zuora_Account__c) && lspc.Live_Subscription__r.Product_Line__c == 'Internet'){
                    mapInternetSub.put(lspc.Zuora_Account__c, lspc.Live_Subscription__r.Zuora_TermEndDate__c);
                }

                Id accountId = lspc.Zuora_Account__c;
                
                String productLine = lspc.Live_Subscription__r.Product_Line__c;
                String keyString = accountId + productLine;

                if (lspc.Live_Subscription__r.Product_Line__c != 'Print') {
                                        
                    if (!mapKeyStrToEndDate.containsKey(keyString)) {
                        mapKeyStrToEndDate.put(keyString, lspc.Live_Subscription__r.Zuora_TermEndDate__c);
                    }
                    
                }else{

                    keyString += lspc.Market_ID__c;

                    if(!mapKeyStrToEndDate.containsKey(keyString)){
                        mapKeyStrToEndDate.put(keyString,lspc.Zuora_EffectiveEndDate__c);
                    }else if (mapKeyStrToEndDate.get(keyString) < lspc.Zuora_EffectiveEndDate__c) {
                        mapKeyStrToEndDate.put(keyString,lspc.Zuora_EffectiveEndDate__c);
                    }
                }
            }
        }
    }

    /**
     * @purpose assign order type 1 and order type 2 for the quote which is cancel reenter/renewal
     * @author  Tony Liu
     * @date    2018-10-11
     * @param   Wrapperclass ZuoraTCVAndPaymentSchedule.QuotesWrapper
     * @return  Wrapperclass ZuoraTCVAndPaymentSchedule.QuotesWrapper
     */
    public static ZuoraTCVAndPaymentSchedule.QuotesWrapper assignTransactionTag(ZuoraTCVAndPaymentSchedule.QuotesWrapper qw) {

        if (qw.quoteSubscriptionType == 'Amend Subscription' 
            && qw.quote.Count_of_Quote_Charge_Detail__c == qw.quote.Count_of_Remove_Amendment__c) {

            qw.quote.Order_Type1__c = 'Removal';
        }
        else if (qw.quoteSubscriptionType == 'Amend Subscription' && qw.quote.Count_Of_Not_Remove_Amendment__c == 0) {
            qw.quote.Order_Type1__c = 'Amendment(Removal)';
        }
        else if (qw.quoteSubscriptionType == 'Amend Subscription') {
            qw.quote.Order_Type1__c = 'Amendment';
        }

        // if the quote is renewal(new) or Cancel Reenter(New), we should compare the mrr with the mrr of the original subs
        if ( qw.quote.Order_Type1__c == 'Renewal(New)' 
                && (String.isNotBlank(qw.quote.Subscription_Being_Renewed__c) )
            || ( qw.quote.Order_Type1__c == 'Cancel Reenter(New)' 
                && String.isNotBlank(qw.quote.Cancel_Reenter_Original_Subscription__c) ) ) {
            
            if ( (qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_MRR__c > qw.quote.Original_Subscription_CMRR__c) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_TCV__c > qw.quote.Original_Subscription_TCV__c)) {

                qw.quote.Order_Type2__c = 'Upsell';
            } 
            else if ( (qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_MRR__c == qw.quote.Original_Subscription_CMRR__c) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_TCV__c == qw.quote.Original_Subscription_TCV__c)) {
                
                qw.quote.Order_Type2__c = 'Delta Zero';
            } 
            else if ( (qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_MRR__c < qw.quote.Original_Subscription_CMRR__c) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_TCV__c < qw.quote.Original_Subscription_TCV__c)) {
                
                qw.quote.Order_Type2__c = 'Downsell';
            }

        }
        // if the quote is amend, we should check the delta MRR(For Internet) or delta TCV(For Print and LDE)
        else if (qw.quoteSubscriptionType == 'Amend Subscription') {
            if ((qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_Delta_MRR__c > 0 ) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_Delta_TCV__c > 0 )) {

                qw.quote.Order_Type2__c = 'Upsell';
            }
            else if ((qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_Delta_MRR__c == 0 ) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_Delta_TCV__c == 0 )) {

                qw.quote.Order_Type2__c = 'Delta Zero';
            }
            else if ((qw.quoteProductLine == 'Internet' && qw.quote.zqu__Previewed_Delta_MRR__c < 0 ) || 
                    (qw.quoteProductLine != 'Internet' && qw.quote.zqu__Previewed_Delta_TCV__c < 0 )) {

                qw.quote.Order_Type2__c = 'Downsell';
            }
        }

        if (qw.quoteSubscriptionType == 'New Subscription' 
            && qw.quote.Order_Type1__c != 'Renewal(New)' 
            && qw.quote.Order_Type1__c != 'Cancel Reenter(New)'){
            
            Id accountId = qw.quote.zqu__Account__c;
            // set the Order_Type2__c to amend when the quote is new subscription but not cancel reenter(new) and renewal
            if (mapAccountIdToSubEndDate.containsKey(qw.quote.zqu__Account__c)) {

                Date originalSubLatestEnd = mapAccountIdToSubEndDate.get(qw.quote.zqu__Account__c);
                
                if(qw.quoteProductLine == 'Internet'){
                    assignOrderType2(qw, originalSubLatestEnd);
                }
                else{
                    // if there is an active subscription under the account, set the Order_Type2__c to upsell
                    if (originalSubLatestEnd >= Date.today()) {
                        qw.quote.Order_Type2__c = 'Upsell';
                    }
                    // if there is no active subscription under the account and the latest subs has been expired/cancelled in one year, 
                    // set the Order_Type2__c to Winback
                    else if (originalSubLatestEnd < Date.today() 
                        && originalSubLatestEnd > qw.quote.zqu__TermStartDate__c.addmonths(-12)) {
                        
                        qw.quote.Order_Type2__c = 'Winback';
                    }
                    else{
                        qw.quote.Order_Type2__c = '';
                    }
                }
            }

            if(qw.quoteProductLine == 'Internet'){
                
                assignOrderType1(qw);
                System.debug(LoggingLevel.INFO, '*** qw: ' + qw.quote);
            }
            else if (qw.quoteProductLine == 'Print') {
                String tempOrderType1 = 'First Print Sale';
                for (List<zqu__QuoteRatePlanCharge__c> listQRPC : qw.quoteRatePlanChargeListMap.values()) {
                    for (zqu__QuoteRatePlanCharge__c qrpc:  listQRPC) {
                        String printKeyString = accountId + qw.quote.Product_Line__c + qrpc.Market_ID__c;
                        if (!isFirstSale(qw.quote,printKeyString)){
                            tempOrderType1 = '';
                            break;
                        }
                    }
                }
            
                qw.quote.Order_Type1__c = tempOrderType1;
            }
            else{
                String keyString = accountId + qw.quote.Product_Line__c;
                if (isFirstSale(qw.quote, keyString)) {
                    qw.quote.Order_Type1__c = 'First ' +qw.quote.Product_Line__c+' Sale';
                }
                else{
                    qw.quote.Order_Type1__c = '';
                }
            } 
        }

        return qw;
    }

    /**
     * @purpose Check the quote is the first sale for the product line on the account
     * @author  Tony Liu
     * @date    2018-10-11
     * @param   object   zqu_quote
     * @param   String   keyString, generate by accountId + product line
     * @return  Boolean
     */
    public static Boolean isFirstSale(Zqu__Quote__c zquQuoteObj, String keyString){

        Boolean checkFirstSale = true;

        // check the first sale for the quote only initial term greater than 12 months
        if (zquQuoteObj.zqu__InitialTerm__c < 12 || 
            ( mapKeyStrToEndDate.containsKey(keyString) && 
                mapKeyStrToEndDate.get(keyString) >= Date.today().addmonths(-12) ) ) {
            
            checkFirstSale = false;
        }


        return checkFirstSale;
    }

   
    /**
     * @purpose Determine if the Quote is used for new subscription
     * @author  Tony Liu
     * @date    2018-10-12
     * @param   Object Quote currentQuote 
     * @return  Boolean is the Quote new Sub or not
     */
    public static Boolean isNewSubscription(Zqu__Quote__c currentQuote) {
        return (currentQuote.Opportunity_Stage__c == 'Calculating TCV' 
            && currentQuote.zqu__SubscriptionType__c == 'New Subscription' 
            && currentQuote.Order_Type1__c != 'Renewal(New)' 
            && currentQuote.Order_Type1__c != 'Cancel Reenter(New)');
    }

    /**
    * @description it's used to determine if the quote initial term greater equal than 12 or not
    * @param Zqu__Quote__c the current Quote
    *
    * @return Boolean true if the quote initial term greater equal than 12 months otherwise false
    */
    public static Boolean InitialTermGreaterEqualThan12(Zqu__Quote__c currentQuote){
        return currentQuote.zqu__InitialTerm__c >= 12;
    }
    
    /**
    * @description it's used to determine if there are any active live subs or not
    * @param Zqu__Quote__c the current Quote
    * @param Date the latest live subscription term start date
    * 
    * @return Boolean true if there are any active live subs otherwise false
    */
    public static Boolean hasActiveLiveSub(Zqu__Quote__c currentQuote, Date originalSubLatestEnd){

        if(originalSubLatestEnd!=NULL){
            return originalSubLatestEnd >= currentQuote.zqu__TermStartDate__c;
        }
        else{
            return false;
        }
    }
    
    /**
    * @description it's used to determine if there are any expired or cancelled live subs within 12 months
    * @param Zqu__Quote__c the current Quote
    * @param Date the latest live subscription term start date
    * 
    * @return Boolean true if there are any expired or cancelled live subs within 12 months otherwise false
    */
    public static Boolean hasExpiredCancelledLiveSubWithin12(Zqu__Quote__c currentQuote, Date originalSubLatestEnd){

        if(originalSubLatestEnd!=NULL){
            return !hasActiveLiveSub(currentQuote, originalSubLatestEnd) && 
                    (originalSubLatestEnd >= currentQuote.zqu__TermStartDate__c.addmonths(-12));
        }
        else{
            return false;
        }
    }
    
    /**
    * @description it's used to determine if the Quote true TCV greater than 0 or not
    * @param Zqu__Quote__c the current Quote
    * 
    * @return Boolean true if the Quote true TCV greater than 0 otherwise false
    */
    public static Boolean trueTCVGreaterThan0(Zqu__Quote__c currentQuote){
        return currentQuote.True_TCV__c > 0;
    }
    
    /**
    * @description it's used to assign the Order type 2 with appropriate value
    * @param ZuoraTCVAndPaymentSchedule.QuotesWrapper Quote Wrapper
    * @param Date the latest live subscription term start date
    * 
    */
    public static void assignOrderType2(ZuoraTCVAndPaymentSchedule.QuotesWrapper qw, Date originalSubLatestEnd){
        
        if(hasActiveLiveSub(qw.quote,originalSubLatestEnd)){
            qw.quote.Order_Type2__c = 'Upsell';
        }
        else{
            if(hasExpiredCancelledLiveSubWithin12(qw.quote,originalSubLatestEnd)){
                qw.quote.Order_Type2__c = 'Winback';
            }
        }
    }
    
    /**
    * @description it's used to assign the Order type 1 with appropriate value
    * @param ZuoraTCVAndPaymentSchedule.QuotesWrapper Quote Wrapper
    * 
    */
    public static void assignOrderType1(ZuoraTCVAndPaymentSchedule.QuotesWrapper qw){
        
        Date internetSubLatestEnd = null;

        System.debug(LoggingLevel.INFO, '*** mapInternetSub: ' + mapInternetSub);
        System.debug(LoggingLevel.INFO, '*** qw.quote.zqu__Account__c: ' + qw.quote.zqu__Account__c);
        if(mapInternetSub.containsKey(qw.quote.zqu__Account__c)){
            internetSubLatestEnd = mapInternetSub.get(qw.quote.zqu__Account__c);
        }

        if(qw.quoteProductLine == 'Internet'){
            System.debug(LoggingLevel.INFO, '*** qw.quote: qw.quote');
            System.debug(LoggingLevel.INFO, '*** internetSubLatestEnd: '+ internetSubLatestEnd);

            if(!hasActiveLiveSub(qw.quote,internetSubLatestEnd) && !hasExpiredCancelledLiveSubWithin12(qw.quote,internetSubLatestEnd)){
            
                if(InitialTermGreaterEqualThan12(qw.quote)){
                    
                    if(trueTCVGreaterThan0(qw.quote)){
                        qw.quote.Order_Type1__c = 'First Internet Sale';
                    }
                    else{
                        if(qw.hasTradeDiscountReason){
                            qw.quote.Order_Type1__c = 'First Internet Sale';
                        }
                        else{
                            qw.quote.Order_Type1__c = 'Non-Qualified New';
                        }
                    }
                }
                else{
                    qw.quote.Order_Type1__c = 'Non-Qualified New';
                }
            }
        }
        else{
            qw.quote.Order_Type1__c = 'First Internet Sale';
        }
    }
}