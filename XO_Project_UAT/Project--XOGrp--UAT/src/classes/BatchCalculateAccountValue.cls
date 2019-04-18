global class BatchCalculateAccountValue implements Schedulable, Database.Batchable<sObject> {
    public String query;
    private static final String ACCSNAP_QUERY = ' SELECT Id, Case__c, Case__r.AccountId, Snapshot_Date__c, Snapshot_Period__c ' +
                                                ' FROM Account_Snapshots__c WHERE Snapshot_Date__c = TODAY ';




    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    global BatchCalculateAccountValue() {
        this.query = ACCSNAP_QUERY;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    /**
     * @purpose Calculate Account value for Account Snapshots
     * @author  Mason
     * @date    2018-10-09
     * @param   List<Account_Snapshots__c>  the local Account_Snapshots__c under the case
     */
    global void execute(Database.BatchableContext BC, list<Account_Snapshots__c> scope) {
        Map<Id, Decimal> mapAccIdValue = new Map<Id, Decimal>();
        Set<Id> setAccId = new Set<Id>();
        
        for(Account_Snapshots__c currentAccSnap : scope) {
            Id accId = currentAccSnap.Case__r.AccountId;
            if(String.isNotBlank(accId)) {
                setAccId.add(accId);
            }
        }
        //Get Acccount And sum effective Revenue Mapping
        mapAccIdValue = CaseService.composeAccAndRevenueMapping(setAccId);
        
        //Fill account value under Account Snapshots
        for(Account_Snapshots__c currentAccSnap : scope) {
            Id accId = currentAccSnap.Case__r.AccountId;

            if(mapAccIdValue.containsKey(accId)) {
                currentAccSnap.Account_Value__c = mapAccIdValue.get(accId);
            }
            else{
                currentAccSnap.Account_Value__c = 0;
            }
        }

        //Update account Snapshots and insert xo exception if there is
        Database.SaveResult[] updateResults = Database.update(scope, false);
        List<XO_Exception__C> listException = ExceptionUtility.consumeException(updateResults);
        if(!listException.isEmpty()){
            insert listException;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}