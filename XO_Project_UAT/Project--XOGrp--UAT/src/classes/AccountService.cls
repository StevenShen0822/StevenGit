public without sharing class AccountService {

    /**
    * @purpose For BatchUpdateLocalAccountCBSS class assign cbbs info or Last AM Transfer info on Account
    * @author  Mason
    * @date    2019-1-10
    * @param   Account accRec    need update account record
    * @param   Set<Id> updatedCBSSUserIdSet   User's ids when updated user's ARR info
    * @param   Set<Id> updatedTitleUserIdSet  User's ids when updated user's title info
    * @return  Account accRec                 have updaed account recrod
    */
    public static Account assignAccountInfo(Account accRec, Set<Id> updatedCBSSUserIdSet, Set<Id> updatedTitleUserIdSet) {
        // CSP-2315 Update CBSS Information on Account and Billing Account
        if(updatedCBSSUserIdSet.contains(accRec.OwnerId) || !accRec.CBSS_Email_Is_Matched__c || updatedCBSSUserIdSet.contains(accRec.CBBS__c)){
           if(!accRec.Override_Account_CBSS__c){
                accRec.CBBS__c = accRec.Owner.ARR__c;
                accRec.CBSS_Email__c = accRec.Owner.ARR__r.Email;
                accRec.CBSS_Phone__c = accRec.Owner.ARR__r.Phone;
            }else{
                accRec.CBSS_Email__c = accRec.CBBS__r.Email;
                accRec.CBSS_Phone__c = accRec.CBBS__r.Phone;
            } 
        }
        // Update Last AM Transfer on Account where user title change to Account Manager
        if(updatedTitleUserIdSet.contains(accRec.OwnerId)) {
            accRec.Last_AM_Transfer__c = System.today();
        }
        return accRec;
    }
}