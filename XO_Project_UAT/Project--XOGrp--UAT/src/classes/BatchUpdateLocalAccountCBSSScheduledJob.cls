global class BatchUpdateLocalAccountCBSSScheduledJob implements Schedulable {
    global void execute(SchedulableContext sc) {
		  Set<Id> updatedCBSSUserIdSet = new Set<Id>();
		  Set<Id> updatedTitleUserIdSet = new Set<Id>();
			BatchUpdateLocalAccountCBSS accountCBSSBatchJob = new BatchUpdateLocalAccountCBSS(updatedCBSSUserIdSet, updatedTitleUserIdSet);
			Database.ExecuteBatch(accountCBSSBatchJob, 200);
    }
}