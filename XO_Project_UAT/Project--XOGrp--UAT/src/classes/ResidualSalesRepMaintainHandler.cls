public with sharing class ResidualSalesRepMaintainHandler {
    
    // the map stores residual subscription name with live subscription
    private static Map<String, Live_Subscription__c> mapResidualSubsForRenewalAndReenter = new Map<String, Live_Subscription__c>();

    /**
     * set value to mapResidualSubsForRenewalAndReenter
     * 
     * @return void
     */
    public static void setResidualSubsMap(String residualSubName, Live_Subscription__c ls){
        if(!mapResidualSubsForRenewalAndReenter.containskey(residualSubName)){
            mapResidualSubsForRenewalAndReenter.put(residualSubName, ls);
        }
    }

    /**
     * Create residual sales rep records from renewal or cancel re-enter
     * 
     * @return void
     */
    public static void createResidualSalesReps(){
        
        List<Residual_Sales_Rep__c> listRSRforInsert = new List<Residual_Sales_Rep__c>();
        List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
        
        if(!mapResidualSubsForRenewalAndReenter.isEmpty()){

            List<Residual_Sales_Rep__c> reslist = [SELECT Id, PayeeName__c, PayeeStartDate__c, PayeeType__c, Live_Subscription__r.Name, Live_Subscription__r.Residual_Subscription_Name__c FROM 
                                                Residual_Sales_Rep__c WHERE Live_Subscription__r.Name IN: mapResidualSubsForRenewalAndReenter.keyset()];
            
            if(!reslist.isEmpty()){
                for(Residual_Sales_Rep__c rsr: reslist){
                    
                    String rsName = rsr.Live_Subscription__r.Name;
                    if(mapResidualSubsForRenewalAndReenter.containskey(rsName)){

                        Id resId = mapResidualSubsForRenewalAndReenter.get(rsName).Id;
                        Residual_Sales_Rep__c resSalesRep = new Residual_Sales_Rep__c();
                        resSalesRep.Live_Subscription__c = resId;
                        resSalesRep.PayeeName__c = rsr.PayeeName__c;
                        resSalesRep.PayeeStartDate__c = rsr.PayeeStartDate__c; 
                        resSalesRep.PayeeType__c = rsr.PayeeType__c;

                        listRSRforInsert.add(resSalesRep);
                    }
                }
            }
        }
        
        if(!listRSRforInsert.isEmpty()){
            List<Database.SaveResult> resultList = Database.insert(listRSRforInsert, false);
            xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));
        }
        
    }
}