@isTest
public class LeadDomainTest {

    // TODO: this method will be moved to a test data factory after making some more refinements 
    public static List<Lead> testDataSetup(Integer numberOfLeads) {
        
        Market__c testMarket = TestClassUtility.createMarket(false);
        testMarket.Active__c = true;
        insert testMarket;

        Category__c testCategory = TestClassUtility.createCategory(false);
        testCategory.Category_Group__c = 'Primary';
        testCategory.Active__c = true;
        testCategory.Name = 'Reception Venues - REC';
        insert testCategory;

        List<Lead> newLeadsList = new List<Lead>();

        for(Integer index=0; index < numberOfLeads; index++) {
            newLeadsList.add(TestClassUtility.createLead(false, testMarket, testCategory));
        }
        return newLeadsList;
    }

    @isTest 
    public static void leadRoutingAfterCleansingTest() {
        Profile testDataTeamProfile = [SELECT Id FROM Profile WHERE Name = 'Local Sales Data Team' LIMIT 1];
        User testDataTeamUser = TestClassUtility.createUser(true, testDataTeamProfile);

        Market__c testMarket = TestClassUtility.createMarket(false);
        testMarket.Name = 'OH - Toledo - 208';
        testMarket.Market_ID__c = '208';
        testMarket.Market_Tier__c = 'C';
        testMarket.Short_Description__c = 'OH-Toledo';
        testMarket.Active__c = true;
        insert testMarket;

        Category__c testCategory = TestClassUtility.createCategory(false);
        testCategory.Category_Group__c = 'Primary';
        testCategory.Active__c = true;
        testCategory.Name = 'Bridal Salons - BWP';
        testCategory.Category_ID__c = '585';
        testCategory.Category_Code__c = 'BWP';
        testCategory.Zuora_Description__c = 'Bridal Salons';   
        testCategory.Short_Description__c = 'Bridal Salons';   
        insert testCategory;

        List<Local_Sales_Rep_Assignment__c> localSalesRepAssignmentList = new List<Local_Sales_Rep_Assignment__c>();       
        Local_Sales_Rep_Assignment__c localSalesRepAssignment = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, testMarket, null);
        localSalesRepAssignment.Sales_Rep__c = UserInfo.getUserId();
        localSalesRepAssignmentList.add(localSalesRepAssignment);
        insert localSalesRepAssignmentList;

        System.runAs(testDataTeamUser){
            Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
            testLead.Status = 'Invalid';
            testLead.Negative_Disposition_Reason__c = 'Other';
            testLead.Reason_Details__c = 'test';
            insert testLead;
        
            Test.startTest();

                testLead.Status = 'Valid';
                testLead.Negative_Disposition_Reason__c = null;
                testLead.Reason_Details__c = null;
                update testLead;
            
            Test.stopTest();
        
            List<Lead> listLeadsAssert = [SELECT OwnerId FROM Lead WHERE Id =: testLead.Id];
            System.assert(!listLeadsAssert.isEmpty());
            System.assertEquals(localSalesRepAssignment.Sales_Rep__c, listLeadsAssert[0].OwnerId);
        }
    }
    
    @isTest 
    public static void phoneValidationInvalidTest() {
       
        List<Lead> testLeadsList = testDataSetup(2);

        if(testLeadsList.size() > 0) {
            testLeadsList[0].Phone =  '1231231231';
            testLeadsList[1].Phone = '77777qweqwe';
        }

        try {
            insert testLeadsList;
        } catch(Exception e) {
            System.Assert(e.getMessage().contains('Phone should be in the format of (###) ###-####. Please correct before saving.'));
        }
    }

    @isTest
    public static void leadConvertTest() {
        
        List<Lead> testLeadsList = testDataSetup(2);
        Lead leadRec = testLeadsList[0];
        leadRec.Website = 'www.spacexone.com';
        leadRec.Phone = '3453453456';
        leadRec.Email = 'goforit@gmail.com';
        insert testLeadsList;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadRec.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());

        Event evnt = new Event(WhoId = leadRec.Id, Subject = 'Test Lead Conversion');

        Test.startTest();
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            FeedItem testFeed = New FeedItem();
            testFeed.ParentId = testLeadsList[0].id;
            testFeed.Title = 'test title';
            testFeed.Body = 'Hello';
            testFeed.LinkUrl = 'www.abc123.com';
            insert testFeed;

            LeadDomain domain = new LeadDomain();
            FeedItem feedItemRec = domain.createNewFeed(leadRec.ConvertedAccountId, testFeed);
        Test.stopTest();

        System.assert(lcr.isSuccess());
        System.assertEquals(feedItemRec.Title, testFeed.Title, 'Both titles should be same as we are cloning the feed');
    }

    @isTest
    public static void qualifyLeadNegativeTest() {
        List<Lead> testLeadsList = testDataSetup(2);
        testLeadsList[0].LastName = 'Last Name';
        insert testLeadsList;

        Test.startTest();
            try {
                LeadDomain domain = new LeadDomain();
                domain.qualifyLead(testLeadsList[0]);
            } catch (Exception e) {
                // failure expected here as we are passing junk last name to the method 
                System.assert(e.getMessage().contains('LastName cannot be a junk value')); 
            }
        Test.stopTest();
    }

    @isTest
    public static void createAssignmentHistoryRecords() {

        List<Lead> leadList = new List<Lead>();

        Market__c testMarket = TestClassUtility.createMarket(false);
        testMarket.Active__c = true;
        insert testMarket;

        Category__c testCategory = TestClassUtility.createCategory(false);
        testCategory.Category_Group__c = 'Primary';
        testCategory.Active__c = true;
        testCategory.Name = 'Reception Venues - REC';
        insert testCategory;

        MetroArea__c ma = TestClassUtility.createMetroArea(true);
        
        Zip__c testzip = TestClassUtility.createZip(false);
        testzip.MetroArea__c = ma.id;
        testzip.ZipCode__c = '94230';
        testzip.name = '94230';
        testzip.Local_Market__c = testMarket.id;
        testzip.Portfolio__c = 'Senior Sales Executive';
        insert testzip;

        Lead testLead = TestClassUtility.createLead(false, testMarket, testCategory);
        testLead.Phone = '1231231231';
        testLead.CountryCode = 'US';
        testLead.PostalCode = testZip.ZipCode__c;
        testLead.OwnerId = UserInfo.getUserId();
        leadList.add(testLead);

        Lead testLead2 = TestClassUtility.createLead(false, testMarket, testCategory);
        testLead2.Phone = '8888888888';
        testLead.CountryCode = 'US';
        testLead.PostalCode = 'pppppppp';
        leadList.add(testLead2);

        List<Local_Sales_Rep_Assignment__c> localSalesRepAssignmentList = new List<Local_Sales_Rep_Assignment__c>();       
        Local_Sales_Rep_Assignment__c lsra = TestClassUtility.createLocalSalesRepAssignment(false, testCategory, testMarket, null);
        localSalesRepAssignmentList.add(lsra);
        insert localSalesRepAssignmentList;

        Test.startTest();
            LeadDomain domain = new LeadDomain();
            domain.createAssignmentHistoryRecords(localSalesRepAssignmentList[0].Id, leadList[0]);
        Test.stopTest();

        Assignment_History__c assignmentHistoryRec = [Select Id from Assignment_History__c where Local_Sales_Rep_Assignment__c =: lsra.Id];
        System.assert(assignmentHistoryRec != null); // this means assignment history records were created which is the job of this function
    }
}