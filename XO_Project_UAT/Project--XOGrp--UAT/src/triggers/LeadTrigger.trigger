trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {   
	
	private Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Lead.getRecordTypeInfosById();
	List<Lead> localLeadsList = new List<Lead>();

	for(Lead leadRec: Trigger.New) {
		if(rtMapById.get(leadRec.RecordTypeId).getName().containsIgnoreCase('Local')){
			localLeadsList.add(leadRec);
		}
	}

	if(!localLeadsList.isEmpty()) {
		LeadDomain domain = new LeadDomain(localLeadsList);
		domain.execute();

		LeadConvertDomain leadCvtDomain = new LeadConvertDomain();
		leadCvtDomain .execute();
	}
}