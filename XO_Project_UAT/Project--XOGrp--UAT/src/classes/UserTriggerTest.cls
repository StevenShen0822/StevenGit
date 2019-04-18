@isTest
private class UserTriggerTest {
    static testMethod void TestUpdateUser() {
        List<User> userList = [select Id, Name, ARR__r.Email from User where Id != :UserInfo.getUserId() and isActive = true and Title != 'Account Manager' limit 2];
        Test.startTest();
        userList[0].ARR__c = userList[1].Id;
        userList[1].Title = 'Account Manager';
        Database.SaveResult[] result = Database.update(userList,true);
        Test.stopTest();
        System.assert(result[0].isSuccess());
    }
}