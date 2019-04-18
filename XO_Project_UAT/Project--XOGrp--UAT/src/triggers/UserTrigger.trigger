trigger UserTrigger on User (after insert, before update, after update) {
    new UserQuotaManagementDomain().execute();

    if (Trigger.isAfter && Trigger.isUpdate) {
        // CSP-596 | for all user's who had their ARR updated,
        // update the CBSS lookup on Local Account's they own (when applicable
        Set<Id> updatedARRUserIdSet = new Set<Id>();
        Set<Id> updatedTitleUserIdSet = new Set<Id>();
        // Set<Id> arrIdSet = new Set<Id>();
        for (User newUserRec : Trigger.new) {
            // CSP-2315 Update CBSS Information on Account and Billing Account
            User oldUserRecord = Trigger.oldMap.get(newUserRec.Id);
            if (newUserRec.ARR__c != oldUserRecord.ARR__c || newUserRec.Phone != oldUserRecord.Phone || 
                !(newUserRec.FirstName + newUserRec.LastName).equals(oldUserRecord.FirstName + oldUserRecord.LastName) ) {
                updatedARRUserIdSet.add(newUserRec.Id);
            }
            // Store user id when updated user's title for update Last AM Transfe on Account
            if(newUserRec.Title != oldUserRecord.Title && newUserRec.Title == label.Account_Manager) {
                updatedTitleUserIdSet.add(newUserRec.Id);
            }
        }
        if (!updatedARRUserIdSet.isEmpty() || !updatedTitleUserIdSet.isEmpty()) {
            System.debug(LoggingLevel.INFO, '*** updatedARRUserIdSet: ' + updatedARRUserIdSet);
            System.debug(LoggingLevel.INFO, '*** updatedTitleUserIdSet: ' + updatedTitleUserIdSet);
            BatchUpdateLocalAccountCBSS accountCBSSBatchJob = new BatchUpdateLocalAccountCBSS(updatedARRUserIdSet, updatedTitleUserIdSet);
            Database.ExecuteBatch(accountCBSSBatchJob, 200);
        }
    }
}