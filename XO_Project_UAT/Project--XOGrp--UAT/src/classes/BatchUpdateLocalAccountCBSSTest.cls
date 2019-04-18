/*******************************************************************************
 *  Summary      : Test class for BatchCloseExpiredLocalOppsSchedJob
 *  Refer Object : 
 *  Author       : Tony
 *  RefactorDate : 19 Dec 2016
 *  Change Log   : Refactoring by CSP-1686
 ******************************************************************************/
@isTest
private class BatchUpdateLocalAccountCBSSTest {
    static testMethod void testUpdateARR() {
        
        //Map<String, SObject> testObjects = TestClassUtility.buildZQUTestObjects(false);
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(FALSE);
        Set<Id> updatedCBSSUserIdSet = new Set<Id>();
        Set<Id> updatedTitleUserIdSet = new Set<Id>();
        List<User> userList = [select Id, Name, ARR__c from User where Id != :UserInfo.getUserId() and isActive = true and ARR__c != null limit 2];
        for (User userRecord : userList) {
            updatedCBSSUserIdSet.add(userRecord.Id);
        }
        Account testAccount = (Account)testObjects.get('Account');
        testAccount.Override_Account_CBSS__c = True;
        testAccount.CBBS__c =userList[0].id;
        update testAccount;
        
        Test.startTest();
        BatchUpdateLocalAccountCBSS bb = new BatchUpdateLocalAccountCBSS(updatedCBSSUserIdSet,updatedTitleUserIdSet);
        Database.executeBatch(bb);
        Test.stopTest();

        Account assertAccount = [select Id, CBSS_Email__c, CBBS__r.Email From Account where id =: testAccount.Id];
        System.assert(assertAccount.CBSS_Email__c == assertAccount.CBBS__r.Email);
    }
    static testMethod void testUpdateUserTitle() {
        
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(FALSE);
        Set<Id> updatedCBSSUserIdSet = new Set<Id>();
        Set<Id> updatedTitleUserIdSet = new Set<Id>();
        List<User> userList = [select Id, Name from User where Id != :UserInfo.getUserId() and isActive = true and Title = 'Account Manager' limit 2];
        for (User userRecord : userList) {
            updatedTitleUserIdSet.add(userRecord.Id);
        }
        Account testAccount = (Account)testObjects.get('Account');
        testAccount.OwnerId = userList[0].id;
        update testAccount;
        
        Test.startTest();
        BatchUpdateLocalAccountCBSS bb = new BatchUpdateLocalAccountCBSS(updatedCBSSUserIdSet,updatedTitleUserIdSet);
        Database.executeBatch(bb);
        Test.stopTest();

        Account assertAccount = [select Id, CBSS_Email__c, Last_AM_Transfer__c From Account where id =: testAccount.Id];
        System.assert(assertAccount.Last_AM_Transfer__c == System.today());
    }
    static testMethod void testUpdateUserTitleAndARR() {
        
        Map<String, SObject> testObjects = TestClassUtility.buildLocalData(FALSE);
        Set<Id> updatedCBSSUserIdSet = new Set<Id>();
        Set<Id> updatedTitleUserIdSet = new Set<Id>();
        List<User> userList = [select Id, Name, ARR__r.Email from User where Id != :UserInfo.getUserId() and isActive = true and Title = 'Account Manager' limit 2];
        for (User userRecord : userList) {
            updatedTitleUserIdSet.add(userRecord.Id);
            updatedCBSSUserIdSet.add(userRecord.Id);
        }
        Account testAccount = (Account)testObjects.get('Account');
        testAccount.OwnerId = userList[0].id;
        testAccount.Override_Account_CBSS__c = FALSE;
        update testAccount;
        
        Test.startTest();
        BatchUpdateLocalAccountCBSS bb = new BatchUpdateLocalAccountCBSS(updatedCBSSUserIdSet,updatedTitleUserIdSet);
        Database.executeBatch(bb);
        Test.stopTest();

        Account assertAccount = [select Id, CBSS_Email__c, CBBS__r.Email, Last_AM_Transfer__c From Account where id =: testAccount.Id];
        System.assert(assertAccount.Last_AM_Transfer__c == System.today());

    }
}