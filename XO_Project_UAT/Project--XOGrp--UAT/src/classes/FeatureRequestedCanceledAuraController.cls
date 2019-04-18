/**
 * Lightning controller for FeatureRequestCanceled UI.
 */
public with sharing class FeatureRequestedCanceledAuraController {

  public static final String FRC_ID = 'frcId';
  public static final String FRCS = 'frcs';
  public static final String LABEL = 'label';
  public static final String OPTIONS = 'options';
  public static final String SPC_ID = 'spcId';
  public static final String STATUS = 'Status';
  public static final String SUBPRODUCT_CHARGE_NUMBER = 'SubProductChargeNumber';
  public static final String VALUE = 'value';

  /**
   * Get the existing and potential Feature_Requested_Cancelled__c object assocated with a case.
   *
   * @param caseId The case Id.
   *
   * @return A Map containing two keys.  FRCS which have a map as the value that lists details of potential FCRs for the case,
   * and a OPTIONS property that has available options for the FRC status.
   */
  @AuraEnabled
  public static Map<String, Object> getFeatureRequestCanceledForCase(Id caseId) {
    try {
      Case frcCase = CaseService.getInstance().getCaseWithFeatureRequestCancelled(caseId);
      Map<String, Feature_Requested_Cancelled__c> existingFeatureRCMap = getFRCMapForCase(frcCase);
      List<FeatureRequestCanceledDTO> listSubsPCWrappers = new List<FeatureRequestCanceledDTO>();

      // Retrieve all Active Zuora__SubscriptionProductCharge__c for Account
      for (Zuora__SubscriptionProductCharge__c sPC : getFRCListForAccount(frcCase.AccountId)) {
        FeatureRequestCanceledDTO wrapper = new FeatureRequestCanceledDTO(sPC);

        if (existingFeatureRCMap.containsKey(sPC.Zuora__ChargeNumber__c)) {
          Feature_Requested_Cancelled__c frc = existingFeatureRCMap.get(sPC.Zuora__ChargeNumber__c);
          wrapper.Status = frc.Status__c;
          wrapper.frcId = frc.Id;
          wrapper.isAdded = true;
        }

        listSubsPCWrappers.add(wrapper);
      }

      Map<String, Object> mapResult = new Map<String, Object>();
      mapResult.put(FRCS, listSubsPCWrappers);
      mapResult.put(OPTIONS, getFCRStatuses());

      return mapResult;
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }

  }

  /**
   * Update or Create FeatureRequestCanceled objects for a case.  If there is an existing FRC it will update the status if it has changed.
   * If there is currently no FRC it will create one and assoicate it with the Case.
   *
   * @param caseId The Case Id.
   * @param addedFRCsString A JSON string contatin a List of Maps that have information for each FRC to be updated/created.
   */
  @AuraEnabled
  public static void updateFRCs(Id caseId, String addedFRCsString) {

    try {
      // Lightning gets all bend out of shape about serializing objects.  The JSON string was the end result of a lot trying to
      // get it marshaled automatically.
      List<Map<String, String>> listAddedFRCs = deserializeSPCList(addedFRCsString);

      Case frcCase = CaseService.getInstance().getCaseWithFeatureRequestCancelled(caseId);
      Map<String, Feature_Requested_Cancelled__c> mapPCNumberFrcExisting = getFRCMapForCase(frcCase);
      List<Feature_Requested_Cancelled__c> listFrcsToDelete = new List<Feature_Requested_Cancelled__c>();
      List<Feature_Requested_Cancelled__c> listFrcsToUpsert = new List<Feature_Requested_Cancelled__c>();

      Map<Id, Zuora__SubscriptionProductCharge__c> mapSpcIdAndCharge = new Map<Id, Zuora__SubscriptionProductCharge__c>();

      // There were some permission issues encountered trying to lookup SubscriptionProductCharge directly by Id.  So in order to ensure we
      // have all necessary fields looking them up via the account of the case was simplest.
      for (Zuora__SubscriptionProductCharge__c spcAccount : getFRCListForAccount(frcCase.AccountId)) {
        mapSpcIdAndCharge.put(spcAccount.Id, spcAccount);
      }

      // Iterate over the added FRCs and either create a new FRC object if not previously selected or update if existing.
      for (Map<String, String> frcMap : listAddedFRCs) {

        // If the added FRC was existing find it and update the status if necessary.
        if (frcMap.containsKey(FRC_ID)) {

          String subProductChargeNumber = frcMap.get(SUBPRODUCT_CHARGE_NUMBER);
          Feature_Requested_Cancelled__c frc = mapPCNumberFrcExisting.get(subProductChargeNumber);
          // Remove it from the list
          mapPCNumberFrcExisting.remove(subProductChargeNumber);

          String status = frcMap.get(STATUS);
          // If the status has changed update the FRC and queue for upsert
          if (status != frc.Status__c) {
            frc.Status__c = status;
            listFrcsToUpsert.add(frc);
          }

        } else { // This is a brand new FRC
          Zuora__SubscriptionProductCharge__c spc = mapSpcIdAndCharge.get(frcMap.get(SPC_ID));
          if (spc != null) {
            Feature_Requested_Cancelled__c currentFRC = new Feature_Requested_Cancelled__c();
            currentFRC.Case__c = caseId;
            currentFRC.Subscription_Product_Charge__c = spc.Id;
            currentFRC.UniqueId__c = String.format('{0}{1}', new String[]{
                caseId,
                spc.Id });
            currentFRC.Status__c = frcMap.get(STATUS);
            currentFRC.Period_Text__c = spc.Zuora__BillingPeriod__c;
            currentFRC.Charge_Price__c = spc.Zuora__Price__c;
            currentFRC.Rate_Plan_Name_Text__c = spc.Zuora__RatePlanName__c;
            currentFRC.Sub_Sales_Rep__c = String.format('{0} {1}', new String[]{
                spc.Zuora__Subscription__r.Sales_Rep__r.FirstName,
                spc.Zuora__Subscription__r.Sales_Rep__r.LastName
            });
            currentFRC.Subscription_Sales_Rep__c = spc.Zuora__Subscription__r.Sales_Rep__c;
            currentFRC.Sub_Product_Charge_Number__c = spc.Zuora__ChargeNumber__c;
            currentFRC.Sub_Term_End_Date__c = spc.Zuora__Subscription__r.Zuora__TermEndDate__c;
            currentFRC.Sub_Term_Start_Date__c = spc.Zuora__Subscription__r.Zuora__TermStartDate__c;
            currentFRC.Subscription_Name__c = spc.Zuora__Subscription__r.Name;
            currentFRC.Zuora_Version__c = spc.Zuora__Subscription__r.Zuora__Version__c;
            currentFRC.Subscription_Zuora_Id__c = spc.Zuora__Subscription__r.Zuora__Zuora_Id__c;
            currentFRC.Charge_Zuora_Id__c = spc.Zuora__Zuora_Id__c;
            listFrcsToUpsert.add(currentFRC);
          } 
          else {
            throw LightningUtility.createException('Error finding Zuora__SubscriptionProductCharge__c for FeatureRequestCanceled creation.');
          }
        }

      }

      // Any remaining FRCs in the list of existing were unchecked and should be deleted.
      if (!mapPCNumberFrcExisting.isEmpty()) {
        listFrcsToDelete.addAll(mapPCNumberFrcExisting.values());
      }

      if (!listFrcsToUpsert.isEmpty()) {
        upsert listFrcsToUpsert UniqueId__c;
      }

      if (!listFrcsToDelete.isEmpty()) {
        delete listFrcsToDelete;
      }
    } 
    catch (Exception e) {
      throw LightningUtility.createException(e.getMessage());
    }
  }

  /**
   * Utility for getting a Map of FRC objects for a Case.
   *
   * @param c The Case.
   *
   * @return The Map of Sub_Product_Charge_Number__c to FRC objects.
   */
  public static Map<String, Feature_Requested_Cancelled__c> getFRCMapForCase(Case c) {

    Map<String, Feature_Requested_Cancelled__c> existingMap = new Map<String, Feature_Requested_Cancelled__c>();
    for (Feature_Requested_Cancelled__c frc : c.Feature_Requested_Cancelled__r) {
      // get the all FRCs which has Subscription_Product_Charge__c
      if (String.isNotBlank(frc.Sub_Product_Charge_Number__c)) {
        existingMap.put(frc.Sub_Product_Charge_Number__c, frc);
      }
    }

    return existingMap;
  }

    /**
   * Utility for getting a List of FRC objects for a account.
   *
   * @param accountId .
   *
   * @return The list of Zuora__SubscriptionProductCharge__c objects.
   */
  public static List<Zuora__SubscriptionProductCharge__c> getFRCListForAccount(Id accountId) {

    List<Zuora__SubscriptionProductCharge__c> listReturnSubPC = [SELECT Id, Name, Zuora__Account__c, Zuora__Account__r.Name, Zuora__ChargeNumber__c, 
                                                              Zuora__Subscription__r.Zuora__Version__c, Zuora__Subscription__c, 
                                                              Zuora__Subscription__r.Name, Zuora__Zuora_Id__c, 
                                                              Zuora__Subscription__r.Zuora__Zuora_Id__c,
                                                              LDE_Email_Launch_Date__c, Zuora__SubscriptionChargeNumber__c, Zuora__Product__c,
                                                              Zuora__Product__r.Name, Zuora__RatePlanName__c, LocationVendorDynamicsAccountID__c,
                                                              List_Price__c,Zuora__Price__c, Zuora__BillingPeriod__c, 
                                                              Zuora__Subscription__r.Zuora__SubscriptionEndDate__c,
                                                              Zuora__Subscription__r.Sales_Rep__r.FirstName, Zuora__Subscription__r.Sales_Rep__r.LastName,
                                                              Zuora__Subscription__r.Sales_Rep__c, Zuora__Subscription__r.Zuora__TermEndDate__c, 
                                                              Zuora__Subscription__r.Zuora__TermStartDate__c
                                                              FROM Zuora__SubscriptionProductCharge__c
                                                              WHERE Zuora__Account__c = :accountId 
                                                              AND Zuora__Subscription__r.True_Subscription_Status__c = 'Active'];

    return listReturnSubPC;
  }


  /**
   * Get the FRC status options as a map.
   *
   * @return A map that can be sent to a lightning component.
   */
  public static List<Map<String, Object>> getFCRStatuses() {

    List<SelectOption> statusOptions = new List<SelectOption>();
    List<Map<String, Object>> ListStatuses = new List<Map<String, Object>>();

    Schema.DescribeFieldResult fieldResult = Feature_Requested_Cancelled__c.Status__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f : ple){
      statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
    }

    for (SelectOption so : statusOptions) {
      Map<String, Object> statusOption = new Map<String, Object>();
      statusOption.put(LABEL, so.getLabel());
      statusOption.put(VALUE, so.getValue());
      ListStatuses.add(statusOption);
    }

    return ListStatuses;
  }

  /**
   * Deserialzie a JSON string into in a List<Map<String, String>>.
   *
   * @param jsonString The serialized JSON.
   *
   * @return A list of Maps.
   */
  public static List<Map<String, String>> deserializeSPCList(String jsonString) {
    List<Map<String, String>> listOfSPCs = new List<Map<String, String>>();
    List<Object> listObjs = (List<Object>) JSON.deserializeUntyped(jsonString);

    for (Object instance : listObjs) {
      Map<String, Object> temp = (Map<String, Object>) instance;
      Map<String, String> strTemp = new Map<String, String>();
      for (String key : temp.keySet()) {
        strTemp.put(key, (String) temp.get(key));
      }
      listOfSPCs.add(strTemp);
    }

    return listOfSPCs;
  }

  /**
   * Lightning DTO for a Feature Request Cancled object.
  */
  public with sharing class FeatureRequestCanceledDTO {
    @AuraEnabled public Id frcId;
    @AuraEnabled public Boolean isAdded { get; set; }
    @AuraEnabled public String Status { get; set; }
    @AuraEnabled public String SubscriptionChargeName;
    @AuraEnabled public Id SubscriptionChargeId;
    @AuraEnabled public String ProductName;
    @AuraEnabled public String RatePlanName;
    @AuraEnabled public Date LaunchDate;
    @AuraEnabled public String ZuoraAccountName;
    @AuraEnabled public String SubscriptionName;
    @AuraEnabled public Date SubscriptionEndDate;
    @AuraEnabled public String LocationId;
    @AuraEnabled public String ListPrice;
    @AuraEnabled public Decimal Price;
    @AuraEnabled public String BillingPeriod;
    @AuraEnabled public String SubProductChargeNumber;
    @AuraEnabled public Id spcId;

    public FeatureRequestCanceledDTO(Zuora__SubscriptionProductCharge__c spc) {
      this.isAdded = false;
      this.Status = '';
      this.SubscriptionChargeId = spc.Id;
      this.SubscriptionChargeName = spc.Name;
      this.ProductName = spc.Zuora__Product__r.Name;
      this.RatePlanName = spc.Zuora__RatePlanName__c;
      this.LaunchDate = spc.LDE_Email_Launch_Date__c;
      this.ZuoraAccountName = spc.Zuora__Account__r.Name;
      this.SubscriptionName = spc.Zuora__Subscription__r.Name;
      this.SubscriptionEndDate = spc.Zuora__Subscription__r.Zuora__SubscriptionEndDate__c;
      this.LocationId = spc.LocationVendorDynamicsAccountID__c;
      this.ListPrice = spc.List_Price__c;
      this.Price = spc.Zuora__Price__c;
      this.BillingPeriod = spc.Zuora__BillingPeriod__c;
      this.SubProductChargeNumber = spc.Zuora__ChargeNumber__c;
      this.spcId = spc.Id;
    }
  }
}