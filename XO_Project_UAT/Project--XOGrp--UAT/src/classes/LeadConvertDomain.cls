public with sharing class LeadConvertDomain extends Domain{

    private List<XO_Exception__c> exceptionList; 
    public static Boolean leadConvert;
    
    public LeadConvertDomain() {
		this.exceptionList = new List<XO_Exception__c>();    	
    }

	public override void onAfterUpdate() {  
        this.convertLeads((List<Lead>)Trigger.New, (Map<Id, Lead>)Trigger.oldMap);  
        leadConvert = false;    
        this.commitXOExceptions();
    }

    private void convertLeads(List<Lead> leadList, Map<Id, Lead> idToLeadOldMap) {

        List<Id> leadsToConvertIdList = new List<Id>();

        for(Lead leadRec : leadList) { 
			if(!(leadRec.Local_Partners_Claiming__c == false && String.isNotBlank(leadRec.DynamicsLeadID__c) 
				&& leadRec.IsConverted == false && leadRec.Status == 'Qualified' && leadRec.Storefront_Status__c == 'Claimed')) {
				continue;
			} 
			if(leadRec.Status != idToLeadOldMap.get(leadRec.Id).Status || leadRec.Storefront_Status__c != idToLeadOldMap.get(leadRec.Id).Storefront_Status__c) {
				leadsToConvertIdList.add(leadRec.Id);
			}
        }

        if(!leadsToConvertIdList.isEmpty()){
            leadConvert = true;
            List<Database.LeadConvert> leadConverts = this.populateLeadConvert(leadsToConvertIdList);
            this.massConvertLeads(leadConverts);
            leadConvert = false;
        }        
    }

    private List<Database.LeadConvert> populateLeadConvert(List<Id> leadsToConvertIdList) {

        LeadStatus convertStatus = new LeadStatus();
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        
        try {
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel = 'Qualified' LIMIT 1];
        } catch (Exception e) {
            XO_Exception__c xoException = ExceptionUtility.consumeException(e, false);
            this.exceptionList.add(xoException);
        }  

        for(Id record : leadsToConvertIdList){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(record);
            lc.convertedStatus = convertStatus.MasterLabel;
            lc.setDoNotCreateOpportunity(true); // CSP-1937
            leadConverts.add(lc);
        }
        return leadConverts;
    }

    private void massConvertLeads(List<Database.LeadConvert> leadConverts) {

        if(leadConverts.isEmpty()) {
            return;
        }

        for(Integer i = 0; i <= leadConverts.size()/100; i++){
            List<Database.LeadConvert> tempList = new List<Database.LeadConvert>();
            Integer startIndex = i*100;
            Integer endIndex = ((startIndex + 100) < leadConverts.size()) ? startIndex+100 : leadConverts.size();
            for(Integer j = startIndex; j < endIndex; j++){
                tempList.add(leadConverts[j]);
            }
            Database.LeadConvertResult[] lcrList = Database.convertLead(tempList, false);
            for(Database.LeadConvertResult lcr : lcrList){
                if(!lcr.isSuccess()) {
                    List<SObject> duplicateRecords = new List<SObject>();
                    Map<String, String> objectToErrorMap = new Map<String, String>();
                    Lead errorLead = (Lead)trigger.newMap.get(lcr.leadId);
                    for(Database.Error error : lcr.getErrors()) {
                        if(error instanceof Database.DuplicateError) {
                            Database.DuplicateError duplicateError = 
                            (Database.DuplicateError)error;
                            Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                            
                            // Return only match results of matching rules that 
                            //  find duplicate records
                            Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();

                            // Just grab first match result (which contains the 
                            // duplicate record found and other match info)
                            Datacloud.MatchResult matchResult = matchResults[0];

                            Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();

                            // Add matched record to the duplicate records variable
                            for (Datacloud.MatchRecord matchRecord : matchRecords) {
                                //this.duplicateRecords.add(matchRecord.getRecord());
                                duplicateRecords.add(matchRecord.getRecord());
                            }

                            objectToErrorMap.put('Duplicate errors during conversion for Lead: ' + errorLead.Id, String.valueOf(duplicateRecords));
                        } else {
                            objectToErrorMap.put('Error during conversion for Lead: ' + errorLead.Id, String.valueOf(lcr.getErrors()));
                        }
                    }
                    errorLead.addError(String.valueOf(objectToErrorMap));
                }
            }
        }
    }

    private void commitXOExceptions() {
        if(!this.exceptionList.isEmpty()) {
            insert this.exceptionList;
        }
    }
}