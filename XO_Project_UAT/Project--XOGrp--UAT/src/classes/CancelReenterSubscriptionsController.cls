public with sharing class CancelReenterSubscriptionsController {

    private static final String ACCOUNT_QUERY = 'SELECT '
                                                    + 'Id, '
                                                    + 'Name, '
                                                    + '(SELECT '
                                                            + 'Id, '
                                                            + 'Name, '
                                                            + 'Zuora__TermStartDate__c, '
                                                            + 'Zuora__TermEndDate__c, '
                                                            + 'Product_Line__c, '
                                                            + 'Billing_Account_ID_Formula_c__c, '
                                                            + 'Zuora__Version__c, '
                                                            + 'Zuora__Account__c, '
                                                            + 'AutoRenewal__c, '
                                                            + 'Renewal_Rep__c, '
                                                            + 'Sales_Rep__c, '
                                                            + 'Preferred_Payment_Schedule__c, '
                                                            + 'Payment_Method__c, '
                                                            + 'Zuora__MRR__c, '
                                                            + 'Zuora__TCV__c, '
                                                            + 'Zuora__External_Id__c, '
                                                            + 'Residual_Subscription_Name__c, '
                                                            + 'Zuora__InvoiceOwner__r.Name, '
                                                            + 'Zuora__InvoiceOwner__r.Zuora__Zuora_Id__c, '
                                                            + 'Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, '
                                                            + 'Zuora__CustomerAccount__r.Zuora__BillCycleDay__c '
                                                        + 'FROM '
                                                            + 'Zuora__Subscriptions__r '
                                                        + 'WHERE '
                                                            + '{0} '
                                                          + 'AND '
                                                            + 'Zuora__Status__c != \'\'Cancelled\'\' '
                                                        + ' ), '
                                                    + '(SELECT '
                                                            + 'Id, '
                                                            + 'Zuora__AccountNumber__c, '
                                                            + 'Name, '
                                                            + 'Zuora__SoldToName__c, '
                                                            + 'Zuora__BillCycleDay__c, '
                                                            + 'Zuora__BillToName__c, '
                                                            + 'Zuora__DefaultPaymentMethod__c, '
                                                            + 'Zuora__External_Id__c, '
                                                            + 'Zuora__Default_Payment_Method__c, '
                                                            + 'CreditCard_ACH_Number__c, '
                                                            + 'Zuora__PaymentTerm__c, '
                                                            + 'Zuora__Currency__c '
                                                        + 'FROM '
                                                            + 'Zuora__R00N40000001kyLcEAI__r '
                                                        + ' ) '
                                                + 'FROM '
                                                    + 'Account '
                                                + 'WHERE '
                                                    + '{1}';

    private static final String CANCEL_OPP_QUERY = 'SELECT '
                                                + 'Id, '
                                                + 'Name, '
                                                + 'AccountId, '
                                                + 'StageName, '
                                                + 'Description, '
                                                + 'Contract_Signer__c, '
                                                + 'Opportunity_Expiration_Date__c, '
                                                + 'CloseDate '
                                            + 'FROM '
                                                + 'Opportunity '
                                            + 'WHERE '
                                                + 'id =: oppId ';


    private static final String CANCEL_REENTER_OWNER_QUERY ='SELECT '
                                                + 'Id, '
                                                + 'Name '
                                            + 'FROM '
                                                + 'User '
                                            + 'WHERE '
                                                + 'Name =\'{WHERECLAUSE}\'';


    private static final String EXCEPTION_ERROR = '; Please contact your admin team';
    

    /**
    *   Main function/method used to grab summary data for display on the front end. This retrieves data on a specific
    *   Account based upon an Id specificed as a parameter. Billing Accounts and Subscriptions are also pulled as related
    *   information about this Account. Subscriptions have a status filter which is used to filter the type of subscriptions
    *   which are being displayed on the front end.
    *
    *   @author Justin
    *   @date   2016-05-04
    *   @param  {String}         accountId    The Account Id which is used to query all Account Information
    *   @param  {String}         statusFilter The status filter which is used to filter subscription data being retrieved.
    *   @return {Map<String, Object>}         A map object which is returned with a key to compelx object. The keys for
    *                                         this map are: Account, Billing, Subscriptions, Markets, and Categories.
    */
    @AuraEnabled
    public static List<SubscriptionWrapper> getSubscriptionsData(String oppId, String accId) {
        if(String.isBlank(oppId) || String.isBlank(accId)) {
            return null;
        }

        List<SubscriptionWrapper> listSubscriptionWrapper = new List<SubscriptionWrapper>();

        String dateStr = String.valueOf(Date.today());
        List<String> listWhereCLause = new String[]{'Zuora__TermEndDate__c > '+ dateStr,'Id = \''+accId + '\''};

        String accQueryString = String.format(ACCOUNT_QUERY, listWhereCLause); 
        List<Account> listAccount = Database.query(accQueryString);

        for (Account acc: listAccount) {
            List<BillingAccountWrapper> listBillingAccountWrapper = new List<BillingAccountWrapper>();

            BillingAccountWrapper newBillAccWrap = new BillingAccountWrapper();
            newBillAccWrap.ZuoraBillingAcc =  new Zuora__CustomerAccount__c();
            newBillAccWrap.ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c = 'Credit Card';
            newBillAccWrap.isSelectedBillingAcc = false;
            newBillAccWrap.selectNewBillingAcc = 'Create New Billing Account';
            listBillingAccountWrapper.add(newBillAccWrap);

            if (!acc.Zuora__R00N40000001kyLcEAI__r.isEmpty()) {
                for (Zuora__CustomerAccount__c billAcc :acc.Zuora__R00N40000001kyLcEAI__r ) {
                    BillingAccountWrapper billAccWrap = new BillingAccountWrapper();
                    billAccWrap.ZuoraBillingAcc =  billAcc;
                    billAccWrap.isSelectedBillingAcc = false;
                    billAccWrap.selectNewBillingAcc = 'Existing Billing Account';
                    listBillingAccountWrapper.add(billAccWrap);
                }
            }

            if (!acc.Zuora__Subscriptions__r.isEmpty()) {
                for (Zuora__Subscription__c zuoraSub :  acc.Zuora__Subscriptions__r) {
                    zuoraSub.Zuora__SubscriptionStartDate__c = Date.today().adddays(14);
                    zuoraSub.Zuora__SubscriptionEndDate__c = Date.today().adddays(14);

                    SubscriptionWrapper subWrap= new SubscriptionWrapper();
                    subWrap.isSelected = false;
                    subWrap.zuoraSub = zuoraSub;
                    subWrap.listBillingAccWrap.addAll(listBillingAccountWrapper);
                    listSubscriptionWrapper.add(subWrap);
                }
            }
            
        }

        return listSubscriptionWrapper;
    }

    @AuraEnabled
    public static String createOpportunitAndQuote(String subWrappersString, String oppId, String accId) {
        string checkedresult = '';

        String cancelReenterOwnerQueryStr = CANCEL_REENTER_OWNER_QUERY.replace('{WHERECLAUSE}', Label.Cancel_Reenter_Opp_Owner);
        List<User> userList = Database.query(cancelReenterOwnerQueryStr);

        Id ownerUserId;
        if (!userList.isEmpty()) {
            ownerUserId = userList[0].Id;
        }else{
            ownerUserId = UserInfo.getUserId();
        }

        Savepoint sp = Database.setSavepoint();

        try{
            // retrieve the primary contact role
            AccountContactRole primaryContactRole = ZuoraSubscriptionUtility.retrievePrimaryContactRole(oppId);

            List<Opportunity> upsertOppList = new List<Opportunity>();

            Opportunity cancelOpp = Database.query(CANCEL_OPP_QUERY);
            //update Cancel Reenter (Cancel) Opp
            cancelOpp.OwnerId = ownerUserId;
            upsertOppList.add(cancelOpp);

            // create the Cancel Reenter (new)  OPP
            Opportunity newOpp = new Opportunity();
            newOpp.Name = 'Cancel Reenter(New) Subscription ' + String.valueOf(Date.today());
            newOpp.AccountId = (ID)accId;
            newOpp.OwnerId = ownerUserId;
            newOpp.Contract_Signer__c = cancelOpp.Contract_Signer__c;
            newOpp.Description = cancelOpp.Description;
            newOpp.CloseDate = cancelOpp.CloseDate;
            newOpp.Opportunity_Expiration_Date__c = cancelOpp.Opportunity_Expiration_Date__c;
            newOpp.StageName = 'Quoting';
            newOpp.Type = 'New';
            upsertOppList.add(newOpp);

            upsert upsertOppList;

            List<CancelReenterSubscriptionsController.SubscriptionWrapper> listSubWrappers = (List<CancelReenterSubscriptionsController.SubscriptionWrapper>) System.JSON.deserialize(subWrappersString, List<CancelReenterSubscriptionsController.SubscriptionWrapper>.class);
            Set<Id> setSubsId = new Set<Id>();
            Map<Id,Id> mapSubIdToBillAccountId = new Map<Id,Id>();
            
            Map<String,zqu__Quote__c> mapOppIdTolistQuote = new Map<String,zqu__Quote__c>();
            

            if (!listSubWrappers.isEmpty()) {
                for (SubscriptionWrapper subWrap : listSubWrappers) {
                    if (subWrap.isSelected) {

                        zqu__Quote__c cancelQuote = new zqu__Quote__c();
                        cancelQuote.OwnerId = ownerUserId;
                        cancelQuote.Name = 'Quote for ' + cancelOpp.Name;
                        cancelQuote.zqu__Opportunity__c = cancelOpp.Id;
                        cancelQuote.zqu__Account__c = (ID)accId;
                        cancelQuote.zqu__ValidUntil__c = Date.today()+10;
                        cancelQuote.zqu__StartDate__c = subWrap.zuoraSub.Zuora__SubscriptionEndDate__c;
                        cancelQuote.zqu__CancellationDate__c = subWrap.zuoraSub.Zuora__SubscriptionEndDate__c;
                        cancelQuote.zqu__CancellationEffectiveDate__c = 'Enter a Date';
                        cancelQuote.zqu__ExistSubscriptionID__c = subWrap.zuoraSub.Zuora__External_Id__c;
                        cancelQuote.zqu__SubscriptionType__c = 'Cancel Subscription';
                        cancelQuote.RecordTypeId = Schema.SObjectType.zqu__Quote__c.RecordTypeInfosByName.get('Cancellation').RecordTypeId;
                        cancelQuote.zqu__ZuoraAccountID__c = subWrap.zuoraSub.Billing_Account_ID_Formula_c__c;
                        cancelQuote.zqu__Currency__c = 'USD';
                        cancelQuote.zqu__Amendment_Name__c = cancelQuote.Name;
                        cancelQuote.zqu__SubscriptionVersion__c = subWrap.zuoraSub.Zuora__Version__c;
                        cancelQuote.zqu__Is_Charge_Expired__c = True;
                        cancelQuote.zqu__Calculate_Quote_Metrics_Through__c = 'EOT';
                        cancelQuote.zqu__InvoiceProcessingOption__c = 'Subscription';
                        cancelQuote.Subscription_Being_Renewed__c = subWrap.zuoraSub.Id;
                        cancelQuote.Order_Type1__c = 'Cancel Reenter(Original)';


                        // create the Cancel Reenter (new) quote
                        zqu__Quote__c newQuote = new zqu__Quote__c();
                        newQuote.zqu__Currency__c = 'USD';
                        newQuote.OwnerId = ownerUserId;
                        newQuote.Name = 'Cancel Reenter(New) Quote for Subscription '+ subWrap.zuoraSub.Name;
                        newQuote.zqu__Opportunity__c = newOpp.Id;
                        newQuote.zqu__Account__c = (ID)accId;
                        newQuote.zqu__Amendment_Name__c = newQuote.Name;
                        cancelQuote.zqu__ValidUntil__c = Date.today()+10;
                        newQuote.zqu__StartDate__c = subWrap.zuoraSub.Zuora__SubscriptionStartDate__c;
                        newQuote.zqu__SubscriptionType__c = 'New Subscription';
                        newQuote.RecordTypeId = Schema.SObjectType.zqu__Quote__c.RecordTypeInfosByName.get('Default').RecordTypeId;
                        newQuote.Cancel_Reenter_Original_Subscription__c = subWrap.zuoraSub.Id;
                        newQuote.zqu__Calculate_Quote_Metrics_Through__c = 'EOT';
                        newQuote.AutoRenewal__c = subWrap.zuoraSub.AutoRenewal__c;
                        newQuote.Reporting_Rep__c = UserInfo.getUserId();
                        newQuote.SalesRepLookup__c = subWrap.zuoraSub.Sales_Rep__c;
                        newQuote.RenewalRepLookup__c = subWrap.zuoraSub.Renewal_Rep__c;
                        newQuote.zqu__CancellationEffectiveDate__c = 'Enter a Date';
                        newQuote.zqu__BillToContact__c = primaryContactRole.ContactId;
                        newQuote.zqu__SoldToContact__c = primaryContactRole.ContactId;
                        newQuote.zqu__BillingMethod__c = 'Email';
                        newQuote.zqu__Calculate_Quote_Metrics_Through__c = 'EOT';
                        newQuote.zqu__GenerateInvoice__c = true;
                        newQuote.zqu__ProcessPayment__c = true;
                        newQuote.zqu__InitialTerm__c = 12;
                        newQuote.zqu__InvoiceProcessingOption__c = 'Subscription';
                        newQuote.zqu__Is_Charge_Expired__c = false;
                        newQuote.zqu__PaymentTerm__c = 'Due Upon Receipt';
                        newQuote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';
                        newQuote.zqu__RenewalTerm__c = 12;
                        newQuote.zqu__TermStartDate__c = subWrap.zuoraSub.Zuora__SubscriptionStartDate__c;
                        newQuote.zqu__Subscription_Term_Type__c = 'Termed';
                        
                        newQuote.zqu__InvoiceProcessingOption__c = 'Subscription';
                        newQuote.Order_Type1__c = 'Cancel Reenter(New)';
                        newQuote.Original_Subscription_CMRR__c = subWrap.zuoraSub.Zuora__MRR__c;
                        newQuote.Original_Subscription_TCV__c = subWrap.zuoraSub.Zuora__TCV__c;
                        newQuote.Residual_Subscription_Name__c = subWrap.zuoraSub.Name;
                        
                        newQuote.Product_Line__c = subWrap.zuoraSub.Product_Line__c;
                        
                        newQuote.zqu__BillCycleDay__c = String.valueOf(subWrap.zuoraSub.Zuora__SubscriptionStartDate__c.Day());

                        for (BillingAccountWrapper billAccWrapp :  subWrap.listBillingAccWrap) {
                            if(billAccWrapp.isSelectedBillingAcc && billAccWrapp.selectNewBillingAcc == 'Existing Billing Account'){
                                newquote.zqu__InvoiceOwnerName__c = billAccWrapp.ZuoraBillingAcc.Name;
                                newquote.zqu__InvoiceOwnerId__c = billAccWrapp.ZuoraBillingAcc.Zuora__External_Id__c;
                                // using billing account default payment method instead of sub payment method
                                newQuote.zqu__PaymentMethod__c = billAccWrapp.ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c;
                                newQuote.Payment_Method__c = billAccWrapp.ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c;
                                
                                newQuote.zqu__ZuoraAccountID__c = billAccWrapp.ZuoraBillingAcc.Zuora__External_Id__c;
                                newQuote.zqu__BillCycleDay__c = generateBillingCycleDay(billAccWrapp.ZuoraBillingAcc.Zuora__BillCycleDay__c,
                                                                                    subWrap.zuoraSub.Zuora__SubscriptionStartDate__c);
                            }
                            else if(billAccWrapp.isSelectedBillingAcc && billAccWrapp.selectNewBillingAcc == 'Create New Billing Account'){
                                newQuote.zqu__PaymentMethod__c = billAccWrapp.ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c;
                                newQuote.Payment_Method__c = billAccWrapp.ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c;
                            }
                        }

                        if ( newQuote.zqu__PaymentMethod__c == 'Check') {
                            newQuote.Preferred_Payment_Schedule__c = 'Annual';
                        }else{
                            newQuote.Preferred_Payment_Schedule__c = subWrap.zuoraSub.Preferred_Payment_Schedule__c;
                        }

                        mapOppIdTolistQuote.put(subWrap.zuoraSub.Name,cancelQuote);
                        mapOppIdTolistQuote.put(subWrap.zuoraSub.Name+'New',newQuote);
                    }
                }
            }


            if (!mapOppIdTolistQuote.isEmpty()) {
                insert mapOppIdTolistQuote.values();
            }
            List<zqu__Quote__c> listUpdateQuote = new List<zqu__Quote__c>();
            for (String subName: mapOppIdTolistQuote.keySet()) {
                if (!subName.contains('New') && mapOppIdTolistQuote.containsKey(subName+'New')) {
                    zqu__Quote__c cancelQuote = mapOppIdTolistQuote.get(subName);
                    zqu__Quote__c newQuote = mapOppIdTolistQuote.get(subName+ 'New');

                    cancelQuote.Cancel_Reenter_New_Quote__c = newQuote.Id;
                    newQuote.Cancel_Reenter_Cancel_Quote__c = cancelQuote.Id;


                    // Create the cancel quote charge detail and quote amendment
                    zqu.zQuoteUtil.createCancellationAmendment(cancelQuote.Id);
                    zqu.zQuoteUtil.ZBillingResult result = zqu.QuoteRecalculateController.JR_recalculate(cancelQuote.Id);

                    listUpdateQuote.add(cancelQuote);
                    listUpdateQuote.add(newQuote);
                }
            }
            if (!listUpdateQuote.isEmpty()) {
                update listUpdateQuote;
            }

            checkedresult = 'Successed'+newOpp.Id;
        }catch(Exception ex){
            Database.rollback( sp );

            checkedresult = ex.getMessage()+EXCEPTION_ERROR;
        }
        

        return string.valueOf(checkedresult);
    }


    public class SubscriptionWrapper {
        @AuraEnabled
        public Zuora__Subscription__c zuoraSub;
        @AuraEnabled
        public List<BillingAccountWrapper> listBillingAccWrap;
        @AuraEnabled
        public Boolean isSelected;

        public SubscriptionWrapper() {
            zuoraSub = new Zuora__Subscription__c();
            listBillingAccWrap = new List<BillingAccountWrapper>();
            isSelected = false;

        }
    }

    public class BillingAccountWrapper {
        @AuraEnabled
        public Zuora__CustomerAccount__c ZuoraBillingAcc;

        @AuraEnabled
        public Boolean isSelectedBillingAcc;

        @AuraEnabled
        public String selectNewBillingAcc;


        public billingAccountWrapper() {
            ZuoraBillingAcc = new Zuora__CustomerAccount__c();
            isSelectedBillingAcc = false;
            selectNewBillingAcc = '';
        }
    }


    /**
     * @purpose generate BillingCycleDay for the new quote
     * @author  Tony liu   
     * @date    2018-10-11
     * @param   String     the value of the custom account bill cycle day
     * @param   Date       the value the quote term start date
     * @return  String.    the quote bill cycle day
     */
    public static String generateBillingCycleDay(String customAccountBillCycleDay, Date quoteTermStartDate){
        String billingCycleDay = '';

        if(String.isNotBlank(customAccountBillCycleDay)) {
            // regEx to find digits
            Pattern digitRegexPattern = Pattern.compile('(\\d+)');
            // Use the Pattern to create a matcher against the Bill Cycle Day on Billing Account
            Matcher billCycleMatcher = digitRegexPattern.matcher(customAccountBillCycleDay);
            
            // Determine if a digit was found
            if(billCycleMatcher.find()) {
                // Slap that digit in the Bill Cycle Day on the Quote
                billingCycleDay = billCycleMatcher.Group();
            } else {
                // Fail safe - set the bill cycle day to the quote start dates day
                billingCycleDay = String.valueOf(quoteTermStartDate.Day());
            }
        } else {
            // Fail safe - set the bill cycle day to the quote start dates day
            billingCycleDay = String.valueOf(quoteTermStartDate.Day());
        }

        return billingCycleDay;
    }

}