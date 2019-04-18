public with sharing class LeadParentAccountController {
	// the parent account
	public Account parentAccount {get; set;}
	// the converted lead
	public Lead leadRecord {get; set;}

	// the param determine to show the Continue Conversion Button.
	public Boolean displayContinueConversionButton {get; set;}

	// the Id of converted lead 
	private String leadId;

	// the Wrapper class param to deserialize the fulfilldata of the lead, used for got the parent account dynamic Id
	private LeadPayloadWrapper.FulfillData fillData = new LeadPayloadWrapper.FulfillData();

	public LeadParentAccountController() {
		parentAccount = new Account();
		leadRecord = new Lead();

		leadId = ApexPages.currentPage().getParameters().get('id');

		if(String.isNotBlank(leadId)){

			leadRecord = [SELECT Id, DynamicsLeadId__c, Fulfillment_Data__c, Storefront_Status__c, Name, FirstName, Country, PostalCode, Status, Email
										FROM Lead 
										WHERE Id = :leadId];

			if(String.isNotBlank(leadRecord.Fulfillment_Data__c)){
				// Retrive the parent account with parentGUID in the lead's fulfillmentData 
				try{
					fillData = (LeadPayloadWrapper.FulfillData)JSON.deserialize(leadRecord.Fulfillment_Data__c, LeadPayloadWrapper.FulfillData.class);

					if(String.isNotBlank(fillData.parentGUID) && fillData.parentGUID != 'null'){
						List<Account> accList = [SELECT Id, DynamicsAccId__c FROM Account WHERE DynamicsAccId__c =: fillData.parentGUID];
						if (!accList.isEmpty()) {
							parentAccount.ParentId = accList[0].id;
						}
						// parentAccount.ParentId = [SELECT Id, DynamicsAccId__c FROM Account WHERE DynamicsAccId__c =: fillData.parentGUID].Id;
					}
				}catch(Exception E){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, E.getMessage()));
				}
			}

			// CSP-1966 | don't display the "Continue Conversion" button if certain fields are blank or status is not 'Qualified'
			if (leadRecord.Status != 'Qualified') {
				displayContinueConversionButton = false;
				String validationMsgString = 'You cannot convert a lead to an account before the lead\'s status has been set to \'Qualified\'';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, validationMsgString));
			}
			else if (String.isBlank(leadRecord.FirstName) || String.isBlank(leadRecord.Country) || String.isBlank(leadRecord.PostalCode) || String.isBlank(leadRecord.Email)) {
				displayContinueConversionButton = false;
				String validationMsgString = 'A Lead is required to have a First Name, Email, Country, and Zip Code in order to convert to an Account.';
				validationMsgString += 'Please cancel and fill out this data on the Lead before you convert.';
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, validationMsgString));
			}
			else {
				displayContinueConversionButton = true;
			}
		}

	}


	public PageReference saveParent(){

		// if the Parent account is not null, we should generated the fulfilldata for the Lead
		if(String.isBlank(parentAccount.ParentId)){
			fillData.parentGUID = '';
		}else{
			fillData.parentGUID = [SELECT Id, DynamicsAccId__c FROM Account WHERE Id =: parentAccount.ParentId].DynamicsAccId__c;
		}
		system.debug(parentAccount);
		try{
			Lead saveLead = new Lead();
			saveLead.Id = leadId;
			saveLead.Fulfillment_Data__c = JSON.serializePretty(fillData);
			
			update saveLead;
		}catch(Exception E){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, E.getMessage()));
			return null;
		}

		PageReference pageRef = new PageReference('/lead/leadconvert.jsp?retURL=%2F'+leadId+'&id='+leadId);
		pageRef.setRedirect(true);

		return pageRef;
	}

	public PageReference cancelConvert(){
		PageReference pageRef = new PageReference('/'+leadId);
		pageRef.setRedirect(true);

		return pageRef;
	}

}