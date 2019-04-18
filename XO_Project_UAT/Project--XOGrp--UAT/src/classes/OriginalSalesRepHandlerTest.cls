@isTest
private class OriginalSalesRepHandlerTest {

    static testMethod void testCreateOSR() {

        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        Account testAccount = (Account)testData.get('Account');

        Test.startTest();
        Zuora__Subscription__c sub = TestClassUtility.createSubscription(false, testAccount);
        sub.Zuora__Version__c = 1;
        insert sub;
        Test.stopTest();

        List<Original_Sales_Rep__c> osrlist = [SELECT Id, Account__c, Original_Sales_Rep__c FROM Original_Sales_Rep__c 
                                              WHERE Account__c =: testAccount.id];
                                              
        system.assert(!osrlist.isEmpty());
    }

    static testMethod void testNotCreateOSR() {

        Map<String, SObject> testData =TestClassUtility.buildLocalData(false);
        Account testAccount = (Account)testData.get('Account');
        
        // exist subs with 12 months, and this will create one OSR records
        Zuora__Subscription__c sub1 = TestClassUtility.createSubscription(false, testAccount);
        sub1.Zuora__termstartdate__c = Date.today().addmonths(-4);
        sub1.Zuora__termenddate__c = Date.today().addmonths(-3);
        sub1.Zuora__Version__c = 1;
        insert sub1;

        Test.startTest();
        
        // exist subs with 12 months, and this will NOT create one OSR records
        Zuora__Subscription__c sub2 = TestClassUtility.createSubscription(false, testAccount);
        sub2.Zuora__termstartdate__c = Date.today();
        sub2.Zuora__termenddate__c = Date.today();
        insert sub2;
        Test.stopTest();

        List<Original_Sales_Rep__c> osrlist = [SELECT Id, Account__c, Original_Sales_Rep__c FROM Original_Sales_Rep__c 
                                              WHERE Account__c =: testAccount.id];

        System.assertEquals(osrlist.size(), 1);

    }
}