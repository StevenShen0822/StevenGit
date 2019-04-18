/**
 * The controller for the cancel case lightning components.
 */
public with sharing class CancelCaseController {
  public static final String CANCEL = 'Cancel';
  public static final String DOWNGRADE = 'Downgrade';
  public static final String PROSPECTING = 'PROSPECTING';
  public static final String SAVED = 'saved';

  /**
   * Get all picklist values.
   *
   * @return Map<String, List<PicklistValueWrapper>>.
   */
  @AuraEnabled
  public static Map<String, List<PicklistValueWrapper>> getAllPicklistOptions() {

    List<PicklistValueWrapper> originOptions = convertMapToWrapper(DataUtility.buildPicklistEntryMap('Case','Origin'));
    List<PicklistValueWrapper> typeOptions = convertMapToWrapper(DataUtility.buildPicklistEntryMap('Case','Type'));
    List<PicklistValueWrapper> reasonOptions = convertMapToWrapper(DataUtility.buildPicklistEntryMap('Case','Reason'));
    List<PicklistValueWrapper> outcomeOptions = convertMapToWrapper(DataUtility.buildPicklistEntryMap('Case','Outcome__c'));
    List<PicklistValueWrapper> savedByOptions = convertMapToWrapper(DataUtility.buildPicklistEntryMap('Case','Saved_By__c'));

    return new Map<String, List<PicklistValueWrapper>> {
        'originOptions' => originOptions,
        'typeOptions' => typeOptions,
        'reasonOptions' => reasonOptions,
        'outcomeOptions' => outcomeOptions,
        'savedByOptions' => savedByOptions
    };
  }

  /**
   * Get or create a case for the account id.
   *
   * @param accountId - The account id.
   * @return Case object.
   */
  @AuraEnabled
  public static CaseService.CaseInfoWrapper getCaseForAccount(String accountId) {
    try {
      return CaseService.getInstance().getOrCreateCaseForAccount(accountId);
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }
  }

  /**
   * Get or create a case for the account id.
   *
   * @param Map<String, Object> caseValues The case values to upsert.
   * @param Boolean insertOpportunity If true create a cancel case Opportunity.
   * @return Case object.
   */
  @AuraEnabled
  public static Map<String, String> saveCase(String caseValuesStr, Boolean insertOpportunity, 
                              Integer currentPage, Boolean isCloseCase, Boolean isAssignOwner, Boolean isSaveLater) {
    String OpportunityId = '';
    Map<String, Object> caseValues = ((Map<String, Object>)JSON.deserializeUntyped(caseValuesStr));

    try {
 
      Case caseInfo = CaseService.getInstance().getCaseInfo(caseValues, currentPage, isCloseCase, isAssignOwner, isSaveLater);
      Case upsertedCase = CaseService.getInstance().upsertCase(caseInfo);

      if (caseValues.get('associatedTaskOrEmail') != null) {
        String taskId = String.valueOf(caseValues.get('associatedTaskOrEmail'));

        CaseService.addCaseToTask(upsertedCase.Id, taskId);
      }

      if(insertOpportunity && caseValues.get('outcome') == 'Cancelled') {
        OpportunityId = generateCancelOpp(upsertedCase.Id);
      }
      return new Map<String, String> {
          'OpportunityId' => OpportunityId
      };
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }
  }

  /**
   * Upload file as attachment
   *
   * @param String parentId The parent the attachment belongs to.
   * @param String fileName The name of the file.
   * @param String base64Data The file contents.
   * @param String contentType The file type.
   * @param String fileId The attachment id.
   * @return String Id of the attachment.
   */
  @AuraEnabled
  public static String saveFileChunk(String parentId, String fileName, String base64Data, String contentType, String attachmentId) {
    try {
      if (String.isBlank(attachmentId)) {
          attachmentId = CaseService.getInstance().saveFile(parentId, fileName, base64Data, contentType);
      } 
      else {
        CaseService.getInstance().appendToFile(attachmentId, base64Data);
      }
      return attachmentId;
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }
  }

  /**
   * Delete an attachment
   *
   * @param String attachmentId The attachment id.
   * @return Map<String, Boolean>.
   */
  @AuraEnabled
  public static Map<String, Boolean> removeAttachment(String attachmentId) {
    try {
      Boolean result = CaseService.getInstance().deleteAttachment(attachmentId);
      return new Map<String, Boolean>{
          SAVED => result
      };
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }
  }

  /**
   * Create the cancel opportunity for the cancel case.
   *
   * @param cancelCaseId The case Id.
   */
  public static String generateCancelOpp(Id cancelCaseId) {

    //TODO: CaseService
    Case CancelCase = [SELECT Id, CaseNumber, OwnerId, AccountId, Cancel_Reason_Notes__c, Reason FROM Case WHERE Id = :cancelCaseId];

    list<Feature_Requested_Cancelled__c> listFRCs = [SELECT Id, Subscription_Name__c, Subscription_Product_Charge__r.Zuora__SubscriptionChargeNumber__c 
                        FROM Feature_Requested_Cancelled__c WHERE Case__c =:cancelCaseId AND Status__c = 'Cancelled'];

    RecordType localOpportunityRecordType = [SELECT Id, Name FROM RecordType 
                                            WHERE SobjectType = 'Opportunity' 
                                            AND RecordType.Name = 'Local' LIMIT 1];

    Opportunity newOpp = new Opportunity();

    if (localOpportunityRecordType != null) {
      newOpp.RecordTypeId = localOpportunityRecordType.Id;
    }
    newOpp.OwnerId = Label.Cancel_Opportunity_Owner_Id;  
    newOpp.Name = String.format('Cancel Case {0} Cancel Request', new String[] {cancelCase.CaseNumber});
    if(!Test.isRunningTest()) {
      newOpp.Contract_Signer__c = Label.Contact_Signer_for_Cancel_Opp;
    }
    newOpp.AccountId = cancelCase.AccountId;
    newOpp.CloseDate = Date.today().addDays(7);
    newOpp.Opportunity_Expiration_Date__c = Date.today().addDays(7);
    newOpp.StageName = PROSPECTING;
    newOpp.Type = CANCEL;
    newOpp.Approval_Process_Flag_Skip_EchoSign__c = true;
    newOpp.Skip_EchoSign_Reason_Code__c = DOWNGRADE;
    newOpp.Cancel_Case__c = cancelCase.Id;
    newOpp.Saved_By_Notes__c = cancelCase.Cancel_Reason_Notes__c;
    newOpp.Saved_By_Reason__c = cancelCase.Reason;
    if(!listFRCs.isEmpty()) {
      newOpp.Description = 'The following Subscription Product Charge is being cancelled: ';
      for(Feature_Requested_Cancelled__c FRC : listFRCs) {
        newOpp.Description += '\n Subscription Name: '+FRC.Subscription_Name__c +' with Charge Number: '+ FRC.Subscription_Product_Charge__r.Zuora__SubscriptionChargeNumber__c ;
      }
    }
    insert newOpp;
    return newOpp.Id;
  }
  /**
   * This method used to convert format to PicklistValueWrapper from Map 
   * 
   *   @author Mason
   *   @param mapPicklistValue .
   *   @date   2018-10-29
   */

  @AuraEnabled
  public static list<PicklistValueWrapper> convertMapToWrapper(Map<String,String> mapPicklistValue) {

    list<PicklistValueWrapper> listPicklistObj = new list<PicklistValueWrapper>{
      new PicklistValueWrapper('', '')
    };

    for(String label : mapPicklistValue.keySet()){
      listPicklistObj.add(new PicklistValueWrapper(label,mapPicklistValue.get(label)));
    }
    return listPicklistObj;
  }

  /**
   * This class used to return picklist value object 
   * 
   *   @author Mason
   *   @date   2018-10-29
   */
  public with sharing class PicklistValueWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }
    public PicklistValueWrapper(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

}