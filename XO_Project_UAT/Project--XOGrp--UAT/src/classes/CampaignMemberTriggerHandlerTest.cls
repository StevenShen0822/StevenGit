@isTest
private class CampaignMemberTriggerHandlerTest {
    static testMethod void testMethod1() {
      test.startTest();
        lead testLead = TestClassUtility.createLead(false);
        testLead.DE_Backlog__c = true;
        insert testLead;

        Campaign testCam = new Campaign();
        testCam.Notify_Sales_Team__c = true;
        // testCam.Active = true;
        testCam.Name = 'Test Campaign';
        insert testCam;

        CampaignMember testCamMem = new CampaignMember();
        testCamMem.CampaignId = testCam.Id;
        testCamMem.LeadId = testLead.Id;
        // testCamMem.Name = 'test';
        insert testCamMem;

        update testCamMem;

        delete testCamMem;
      test.stopTest();
    }
    static testMethod void testMethod2() {
      test.startTest();
        lead testLead = TestClassUtility.createLead(false);
        testLead.DE_Backlog__c = true;
        insert testLead;

        Campaign testCam = new Campaign();
        testCam.Notify_Sales_Team__c = true;
        // testCam.Active = true;
        testCam.Name = 'Paid Media';
        testCam.Type = 'Paid Media';
        insert testCam;

        CampaignMember testCamMem = new CampaignMember();
        testCamMem.CampaignId = testCam.Id;
        testCamMem.LeadId = testLead.Id;
        // testCamMem.Name = 'test';
        insert testCamMem;

        update testCamMem;

        delete testCamMem;
      test.stopTest();
    }

     static testMethod void testMethod3() {
      test.startTest();

        lead testLead = TestClassUtility.createLead(false);
        testLead.DE_Backlog__c = true;
        insert testLead;

        Campaign testCam = new Campaign();
        testCam.Notify_Sales_Team__c = false;
        // testCam.Active = true;
        testCam.Name = 'Paid Media';
        testCam.Type = 'Paid Media';
        insert testCam;

        CampaignMember testCamMem = new CampaignMember();
        testCamMem.CampaignId = testCam.Id;
        testCamMem.LeadId = testLead.Id;
        // testCamMem.Name = 'test';
        insert testCamMem;

        update testCamMem;

        delete testCamMem;
      test.stopTest();
    }
}