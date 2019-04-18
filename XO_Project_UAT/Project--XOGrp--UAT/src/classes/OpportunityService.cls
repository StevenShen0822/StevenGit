public with sharing class OpportunityService {
    // CSP-1306 Nick Wu modified
    // add one more field in the Opportunity query No_of_Times_To_Extend__c
    private static final String OPP_QUERY = 'SELECT '
                                                + 'Id, '
                                                + 'StageName, '
                                                + 'Contract_Signer__c, '
                                                + 'Three_Business_Days_From_Today__c, '
                                                + 'Opportunity_Expiration_Date__c, '
                                                + 'EchoSign_Contract_Due_Date__c, '
                                                + 'No_of_Times_To_Extend__c, '
                                                + 'AccountId, '
                                                + 'Lock_Quotes__c, '
                                                + '(SELECT '
                                                        + 'zqu__TermStartDate__c, '
                                                        + 'zqu__SubscriptionType__c, '
                                                        + 'zqu__BillToContact__c, '
                                                        + 'zqu__SoldToContact__c '
                                                    + 'FROM '
                                                        + 'zqu__Quotes__r '
                                                    + 'ORDER BY '
                                                    + 'CreatedDate DESC ) '
                                            + 'FROM '
                                                + 'Opportunity '
                                            + 'WHERE '
                                                + '{WHERECLAUSE}';


    /**
     * @purpose Validate the Opportunity and Account when user click the cancel reenter button on Opportunity
     * @author  Tony
     * @date    2018-10-31
     * @param   Opportunity Id
     * @return  String errormessage, if no error, return ''
     */
    public static String validateOpportunityQuote(String oppId) {
        String responseErrorMessage = '';

        if(String.isBlank(oppId)) {
            responseErrorMessage = 'Invalid Opportunity ID Provided';
        }

        else{
          String oppQuery = OPP_QUERY.replace('{WHERECLAUSE}', ' Id = :oppId');

          Opportunity currentOpp;

          try{
              currentOpp = Database.query(oppQuery);
              
              List<AccountContactRole> acrList = [Select id from AccountContactRole where AccountId =: currentOpp.AccountId AND (Role = 'Primary' OR Role = 'Billing') LIMIT 1];

              List<Zuora__Subscription__c> subList = [Select Id from Zuora__Subscription__c where Zuora__Account__c =: currentOpp.AccountId AND Zuora__TermEndDate__c >: date.today()];

              if (currentOpp.StageName == 'Closed Won') {
                responseErrorMessage = Label.Opportunity_Closed_Won_Reopen_Error;
              }
              else if (currentOpp.StageName == 'Closed Lost') {
                responseErrorMessage = Label.Opportunity_Closed_Lost_Reopen_Error;
              }
              else if (currentOpp.Lock_Quotes__c) {
                responseErrorMessage = Label.Opportunity_Locked_Warning_Message;
              }
              else if (acrList.isEmpty()) {
                responseErrorMessage = Label.Primary_Account_Contact_Role_Required_Warning_message;
              }
              else if (subList.isEmpty()) {
                responseErrorMessage = Label.Cancel_Reenter_Need_a_Active_Subscription;
              }
              else {
                currentOpp.StageName = 'Quoting';
                update currentOpp;
              }
          } 
          catch(Exception e) {
              responseErrorMessage = e.getMessage();
          }
        }

        return responseErrorMessage;
    }
}