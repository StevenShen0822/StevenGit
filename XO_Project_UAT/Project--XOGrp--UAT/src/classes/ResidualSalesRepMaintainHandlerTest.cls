@isTest
private class ResidualSalesRepMaintainHandlerTest {

    static testMethod void DoNotCreateRSR() {
        
        Map<String, SObject> mapData = TestClassUtility.buildLocalData(true);
        
        List<Live_Subscription__c> liveSubList = [SELECT Id FROM Live_Subscription__c];


        Test.startTest();

        ResidualSalesRepMaintainHandler.setResidualSubsMap('Test Residual Sub', liveSubList[0]);
        ResidualSalesRepMaintainHandler.createResidualSalesReps();

        Test.stopTest();

        List<Residual_Sales_Rep__c> resList = [SELECT Id FROM Residual_Sales_Rep__c];
        
        System.assert(resList.isEmpty());

    }

    static testMethod void createRSR() {
        
        Map<String, SObject> mapData = TestClassUtility.buildLocalData(true);
        
        List<Live_Subscription__c> liveSubList = [SELECT Id, OwnerId, Name FROM Live_Subscription__c];
        
        Residual_Sales_Rep__c rsr = new Residual_Sales_Rep__c();
        rsr.Live_Subscription__c = liveSubList[0].id;
        rsr.PayeeName__c = liveSubList[0].OwnerId;
        rsr.PayeeStartDate__c = Date.today();
        rsr.PayeeType__c = 'test';

        insert rsr;

        Test.startTest();

        ResidualSalesRepMaintainHandler.setResidualSubsMap(liveSubList[0].Name, liveSubList[0]);
        ResidualSalesRepMaintainHandler.createResidualSalesReps();

        Test.stopTest();

        List<Residual_Sales_Rep__c> resList = [SELECT Id FROM Residual_Sales_Rep__c];
        System.assert(!resList.isEmpty());
    }

}