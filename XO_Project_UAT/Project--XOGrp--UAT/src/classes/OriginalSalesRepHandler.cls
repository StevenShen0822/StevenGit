public with sharing class OriginalSalesRepHandler {
    
  // prepare the account w/ sub map for running the original Sales rep logic
  private static Map<Id, Zuora__Subscription__c> mapAccIdtoSub = new Map<Id, Zuora__Subscription__c>();

  /**
   * It used to pass accIdtoSub map from trigger
   * 
   * @param accMap map with account id with subs
   *
   * @return void
   */
  public static void setMapAccIdtoSub(Map<Id, Zuora__Subscription__c> accMap){
    mapAccIdtoSub = accMap;
  }

  /**
   * firstly check those account if exist in OSR object,
   * if yes, need to check if those subscriptions under those accounts will expired within 12 months
   * if no, then need to insert to OSR
   *
   * @return void
   */
  public static void runOriginalSalesRepLogic(){

    // using to store those account id which needs to check if the subs are greater than 12 months
    Set<Id> setAccInOsr = new Set<Id>();
    // this set store those account ids are NO NEED to create OSR records as filter
    Set<Id> setAccFilter = new Set<Id>();

    // Used to check if there are any existing Original Sales Rep records for these accounts
    List<Original_Sales_Rep__c> osrlist = [SELECT Id, Account__c, Original_Sales_Rep__c FROM Original_Sales_Rep__c 
                                          WHERE Account__c IN: mapAccIdtoSub.keySet()];

    if(!osrlist.isEmpty()){
      for(Original_Sales_Rep__c osr : osrlist){
        // store all osr account ids to the set
        setAccInOsr.add(osr.Account__c);
      }
    }
    
    if(!setAccInOsr.isEmpty()){
        // query all the subs that expired within 12 months, this will NOT creating OSR records
        List<Zuora__Subscription__c> subList = [SELECT Id, Name, Zuora__Account__c, Account_OwnerId__c, Zuora__ServiceActivationDate__c FROM Zuora__Subscription__c 
                                                WHERE Zuora__Account__c IN: setAccInOsr AND 
                                                expired_within_12months__c = TRUE];

        if(!subList.isEmpty()){

            for(Zuora__Subscription__c sub : subList){
                // exclude all those subs being inserted from the current batch
                // only store the account ids from those queried subs
                if(!Trigger.newMap.containsKey(sub.id)){
                    setAccFilter.add(sub.Zuora__Account__c);
                }
            }
        }
    }

    // insert the mapAccIdtoSubInsert to Original Sales Rep object
    if(!mapAccIdtoSub.isEmpty()){
      createOriginalSalesRep(mapAccIdtoSub, setAccFilter);
    }
  }

  /**
   * It used to insert list of OSR records
   * 
   * @param subMap map with account id with subs
   *
   * @return void
   */
  public static void createOriginalSalesRep(Map<Id, Zuora__Subscription__c> subMap, Set<Id> accFilter){
    
    // createOSRMap is used to dedup if one account map to multiple subs
    Map<Id, Original_Sales_Rep__c> createOSRMap = new Map<Id, Original_Sales_Rep__c>();

    if(!subMap.isEmpty()){
      for(Zuora__Subscription__c sub : subMap.values()){

        // create the OSR records when the account id not in the filter
        if(accFilter.isEmpty() || !accFilter.contains(sub.Zuora__Account__c)){
            Original_Sales_Rep__c osr = new Original_Sales_Rep__c();
            osr.Account__c = sub.Zuora__Account__c;
            osr.Original_Sales_Rep__c = sub.Account_OwnerId__c;
            osr.Subscription_Name__c = sub.Name;
            osr.Service_Activation_Date__c = sub.Zuora__ServiceActivationDate__c;
            createOSRMap.put(sub.Zuora__Account__c, osr);
        }
      }

      List<Database.SaveResult> saveResultList = Database.insert(createOSRMap.values(), false);
      List<XO_Exception__c> xoExceptionList = ExceptionUtility.consumeException(saveResultList);
      if (!xoExceptionList.isEmpty()) {
          insert xoExceptionList;
      }
    }
  }
}