global class BatchCalcLiveChargeTCVMonthly implements Schedulable, Database.Batchable<sObject> {
    private String query;

    private static final String ACCOUNT_QUERY = 'SELECT ' 
                                                    + ' Id, '
                                                    + ' Last_AM_Transfer__c, '
                                                    + ' Live_at_Last_Month_Start__c, '
                                                    + ' Live_at_Every_Month__c, '
                                                    + ' Live_at_Month_Start__c, '
                                                    + ' Last_Live_Stamp_Date__c, '
                                                    + ' Live_Stamp_Date__c, '
                                                    + ' (Select '
                                                        +'Id, '
                                                        +'Live_Price__c, '
                                                        +'Product_Type__c '
                                                      +' From '
                                                        +'Live_Subscription_Product_and_Charges__r '
                                                      +'WHERE '
                                                        +' Commission_Line_Item_Status__c = \'Live\' AND Product_Type__c = \'Internet\') '
                                                + ' FROM '
                                                    +' Account '
                                                + ' WHERE '
                                                    + ' RecordType.Name = \'Local\' '
                                                  + ' AND '
                                                    + ' (Owner.Title =  \'Account Manager\' OR VIP_Program__c = TRUE)';


    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    global BatchCalcLiveChargeTCVMonthly() {
        query = ACCOUNT_QUERY;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

     /**
     * @purpose Calculate the live amount for the account which under the Account Manager
     * @author  Tony
     * @date    2018-10-22
     * @param   List<Account>  the local accounts under the account manager
     */
    global void execute(Database.BatchableContext BC, list<Account> scope) {
        List<Account> listAccountUpdate = new List<Account>();

        for (Account currentAccount :  scope) {
            Decimal tempLiveValue = 0;
            if (!currentAccount.Live_Subscription_Product_and_Charges__r.isEmpty()) {
                for (Live_Subscription_Product_and_Charge__c liveSPC : currentAccount.Live_Subscription_Product_and_Charges__r) {

                    Decimal lp = liveSPC.Live_Price__c!=null ? liveSPC.Live_Price__c:0;
                    tempLiveValue += lp;
                }
            }

            currentAccount.Live_at_Last_Month_Start__c = currentAccount.Live_at_Month_Start__c;
            currentAccount.Live_at_Month_Start__c = tempLiveValue;
            //Stamp calculate the live amount date
            currentAccount.Last_Live_Stamp_Date__c = currentAccount.Live_Stamp_Date__c;
            currentAccount.Live_Stamp_Date__c = System.today();
            listAccountUpdate.add(currentAccount);
        }
        if (!listAccountUpdate.isEmpty()) {

            Database.SaveResult[] updateResults = Database.update(listAccountUpdate, false);
            List<XO_Exception__C> exceptionList = ExceptionUtility.consumeException(updateResults);
            if(!exceptionList.isEmpty()){
                insert exceptionList;
            }
        }
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}