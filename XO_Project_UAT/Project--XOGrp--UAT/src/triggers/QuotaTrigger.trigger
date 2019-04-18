trigger QuotaTrigger on Quota__c (after insert, after update) {
	new QuotaDomain().execute();
}