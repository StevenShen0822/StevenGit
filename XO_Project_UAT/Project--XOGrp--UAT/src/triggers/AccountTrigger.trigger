trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
    private Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
    List<Account> localAccountsList = new List<Account>();

    for(Account accountRec: Trigger.New) {
        if(rtMapById.get(accountRec.RecordTypeId).getName().containsIgnoreCase('Local')){
            localAccountsList.add(accountRec);
        }
    }

    if(!localAccountsList.isEmpty()) {
        AccountDomain domain = new AccountDomain(localAccountsList);
        domain.execute();
    }
}