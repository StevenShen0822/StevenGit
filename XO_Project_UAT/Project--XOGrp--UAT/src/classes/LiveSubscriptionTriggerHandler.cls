public without sharing class LiveSubscriptionTriggerHandler implements XOTrigger{
    ////////////////////////////
    // STATIC FINAL VARIABLES // 
    ////////////////////////////

    /**
     * Method used to bulkify all data needed in any "before" action of a trigger.
     */
    public void bulkBefore() {
        
    }
    
    /**
     *   Method used to bulkify all data needed in any "after" action of a trigger.
     */
    public void bulkAfter() {
        
    }
    
    /**
     *   All before insert logic should be done here. This method is called iteratively and as such
     *   should contain no actions which could potentially hit limits or is considered bad practice 
     *   in the Salesforce environment.
     *   
     *   @param  {SObject}   so Single SObject representation of the object being acted upon.
     */
    public void beforeInsert(SObject so) {
        
    }
    
    /**
    *   All before update logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentially hit limits or is considered bad practice
    *   in the Salesforce environment.
    *
    *   @param  {SObject}   oldSo Single SObject representation of the "old" copy of the current 
    *                             object being acted upon.
    *   @param  {SObject}   so    Single SObject representation of the object being acted upon.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {
        Live_Subscription__c newLiveSubObj = (Live_Subscription__c)so;
        Live_Subscription__c oldLiveSubObj = (Live_Subscription__c)oldSo;

        if (newLiveSubObj.Subscription_Version__c != oldLiveSubObj.Subscription_Version__c) {
            LiveSubscriptionHandler.updatePostToPreForLiveSubs(newLiveSubObj, oldLiveSubObj);
        }
    }
    
    /**
    *   All before delete logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentilly hit limits or is considered bad practice
    *   in the Salesforce environment.
    *
    *   @param  {SObject}   so Single SObject representation of the object being acted upon.
    */
    public void beforeDelete(SObject so) {
        
    }

    /**
    *   All after insert logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentilly hit limits or is considered bad practice
    *   in the Salesforce environment. 
    *
    *   @param  {SObject}   so Single SObject representation of the object being acted upon.
    */
    public void afterInsert(SObject so) {
        
        Live_Subscription__c ls = (Live_Subscription__c)so;
        if(ls.Subscription_Name__c != ls.Residual_Subscription_Name__c && String.isNotBlank(ls.Residual_Subscription_Name__c)){
            ResidualSalesRepMaintainHandler.setResidualSubsMap(ls.Residual_Subscription_Name__c, ls);
        }
    }
    
    /**
    *   All after update logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentilly hit limits or is considered bad practice
    *   in the Salesforce environment.
    *   
    *   @param  {SObject}   oldSo Single SObject representation of the "old" copy of the current 
    *                             object being acted upon.
    *   @param  {SObject}   so    Single SObject representation of the object being acted upon.
    */
    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    /**
    *   All after delete logic should be done here. This method is called iteratively and as such
    *   should contain no actions which could potentilly hit limits or is considered bad practice
    *   in the Salesforce environment. 
    *
    *   @param  {SObject}   so Single SObject representation of the object being acted upon.
    */
    public void afterDelete(SObject so) {
        
    }

    /**
    *   All final logic in the "before" context should be done at this point such as modification to objects outside of
    *   the current object. At this point all updates to the current trigger transaction should be
    *   complete and all validation done.
    */
    public void beforeAndFinally() {
        
    }
    
    /**
    *   All final logic in the "after" context should be done at this point such as modification to objects outside of
    *   the current object. At this point all updates to the current trigger transaction should be
    *   complete and all validation done.
    */
    public void afterAndFinally() {
        
        if(Trigger.isInsert){
            ResidualSalesRepMaintainHandler.createResidualSalesReps();
        }
    }
}