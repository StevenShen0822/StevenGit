global class BatchUpdateLocalAccountCBSS implements Database.Batchable<sObject>, Database.Stateful{
    public Set<Id> updatedCBSSUserIdSet = new Set<Id>();
    public Set<Id> updatedTitleUserIdSet = new Set<Id>();
    public Set<Id> allUserIdSet = new Set<Id>();
    public String query;
    public Id localAccountRecordTypeId;

    global BatchUpdateLocalAccountCBSS(Set<Id> updatedCBSSUserIdSet, Set<Id> updatedTitleUserIdSet) {
        this.updatedCBSSUserIdSet = updatedCBSSUserIdSet;
        this.updatedTitleUserIdSet = updatedTitleUserIdSet;
        this.localAccountRecordTypeId = getLocalAccountRecordTypeId();
        // CSP-2315 Update CBSS Information on Account and Billing Account
        // if updatedCBSSUserIdSet is not isEmpty, means this batch class is called by UserTrigger or Admin run batch one user on demand.
        // if updatedTitleUserIdSet is not isEmpty, means this batch class is called by UserTrigger update user's title.
        this.query = 'SELECT Id, CBBS__c, Owner.ARR__c, CBBS__r.Email, CBBS__r.Phone, Owner.ARR__r.Email, Owner.ARR__r.Phone, Override_Account_CBSS__c, Account.CBSS_Email_Is_Matched__c FROM Account WHERE RecordTypeId = :localAccountRecordTypeId ';
        // Only updated user ARR info, there are not update user's title 
        if(!updatedCBSSUserIdSet.isEmpty() && updatedTitleUserIdSet.isEmpty()) {
            this.query += ' AND (CBBS__c IN :updatedCBSSUserIdSet OR OwnerId IN :updatedCBSSUserIdSet)';
        }
        // Only updated user's title, there are not update user ARR info 
        else if(updatedCBSSUserIdSet.isEmpty() && !updatedTitleUserIdSet.isEmpty()) {
            this.query += ' AND (OwnerId IN :updatedTitleUserIdSet)';
        }
        // Updated user's title and user ARR info
        else if(!updatedCBSSUserIdSet.isEmpty() && !updatedTitleUserIdSet.isEmpty()) {
            allUserIdSet.addAll(updatedCBSSUserIdSet);
            allUserIdSet.addAll(updatedTitleUserIdSet);
            this.query += ' AND (CBBS__c IN :updatedCBSSUserIdSet OR OwnerId IN :allUserIdSet)';
        }
        // when batch is call by Scheduled Jobs
        else {
            this.query += ' AND CBSS_Email_Is_Matched__c = False';
        }
        System.debug('querystring');
        System.debug(this.query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, '*** start query: ' + query);
        Database.QueryLocator retVal = Database.getQueryLocator(query);
        return retVal;
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug(LoggingLevel.INFO, '***execute scope: ' + scope);
        
        List<Account> listNeedUpdateAccounts = new List<Account>();
        for (Account accRec : scope) {
            // Update CBSS or Last AM Transfer fields on Account.
            accRec = AccountService.assignAccountInfo(accRec, updatedCBSSUserIdSet, updatedTitleUserIdSet); 
            listNeedUpdateAccounts.add(accRec);
        }
        // CSP-2315 Update CBSS Information or Last AM Transfe on Account and Billing Account
        Database.SaveResult[] updateResults = Database.update(listNeedUpdateAccounts, false);
        List<XO_Exception__C> exceptionList = ExceptionUtility.consumeException(updateResults);
        if(!exceptionList.isEmpty()) {
            insert exceptionList;
        } 
    }

    global void finish(Database.BatchableContext BC) {
        // CSP-1659 | run BatchZuoraDataUpdater job if needed
        Set<String> asyncJobInProgressStatusSet = new Set<String>{'Holding', 'Queued', 'Preparing', 'Processing'};
        Integer runningBatchZuoraDataUpdaterJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'BatchZuoraDataUpdater' AND Status IN :asyncJobInProgressStatusSet LIMIT 1];
        if (runningBatchZuoraDataUpdaterJobCount == 0 && !Test.isRunningTest()) {
            Database.executebatch(new BatchZuoraDataUpdater());
        }
    }

    private Id getLocalAccountRecordTypeId() {
        Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
        Id localAccountRecordTypeId;
        for (Schema.RecordTypeInfo rti : rtMapById.values()) {
            if (rti.getName().containsIgnoreCase('Local')) {
                localAccountRecordTypeId = rti.getRecordTypeId();
                break;
            }
        }
        return localAccountRecordTypeId;
    }
}