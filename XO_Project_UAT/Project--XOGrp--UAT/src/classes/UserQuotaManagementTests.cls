@isTest
public with sharing class UserQuotaManagementTests {
    public static testMethod void testCreateQuotaHierarchy() {

        //disable triggers that would create quotas for new users
        TestClassUtility.DISABLE_TRIGGERS = true;

        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Local Core Account Executive'];
        User u1 = TestDataFactory.getUser('test1', null, salesProfile.Id);
        insert u1;

        User u2 = TestDataFactory.getUser('test2', u1.Id, salesProfile.Id);
        u2.SalesRepID__c = '12346';
        User u3 = TestDataFactory.getUser('test3', u1.Id, salesProfile.Id);
        u3.SalesRepID__c = '12347';

        insert new List<User>{u2, u3};
        TestClassUtility.DISABLE_TRIGGERS = false;

        Test.startTest();

            new UserQuotaManagementDomain().generateQuotasFromUserHierarchy(new Set<String>{'January'}, new Set<String>{'2019'});

        Test.stopTest();

        List<Quota__c> quotas = [SELECT Id, (SELECT Id FROM Child_Quotas__r) FROM Quota__c WHERE User__c = :u1.Id];

        Integer correctAmount = new UserQuotaManagementDomain().getProductFamilies().size();

        TestUtility.itShouldBe('Top level quotas count', correctAmount, quotas.size());
    
        Integer childQuotasCount = 0;

        for(Quota__c quota : quotas) {
            childQuotasCount+=quota.Child_Quotas__r.size();
        }

        correctAmount = 2 * new UserQuotaManagementDomain().getProductFamilies().size();

        TestUtility.itShouldBe('Child level quotas count', correctAmount, childQuotasCount);
    }

    public static testMethod void testNewUserQuotaSync() {
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Local Core Account Executive'];
        User u1 = TestDataFactory.getUser('test1', null, salesProfile.Id);
        
        Test.startTest();
            
            insert u1; 

        Test.stopTest();

        List<Quota__c> quotas = [SELECT Id, (SELECT Id FROM Child_Quotas__r) FROM Quota__c WHERE User__c = :u1.Id];

        Integer correctAmount = new UserQuotaManagementDomain().getProductFamilies().size() * new UserQuotaManagementDomain().getMonthsLeftInYear(Date.today()).size();

        TestUtility.itShouldBe('Top level quotas count', correctAmount, quotas.size());
    }

    public static testMethod void testUserManagerChangeFromNone() {
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Local Core Account Executive'];

        User u1 = TestDataFactory.getUser('test1', null, salesProfile.Id);
        u1.SalesRepID__c = '12346';
        User u2 = TestDataFactory.getUser('test2', null, salesProfile.Id);
        u2.SalesRepID__c = '12347';

        insert new List<User>{u1, u2};

        for(Quota__c quota : [SELECT Quota__c FROM Quota__c WHERE User__c = :u1.Id]) {
            TestUtility.itShouldBe('Parent Quota', null, quota.Quota__c);
        }

        Test.startTest();

            u1.ManagerId = u2.Id;
            update u1;

        Test.stopTest();

        Map<String, Quota__c> managerQuotas = new UserQuotaManagementDomain().getManagerQuotas(new Set<Id>{u2.Id});

        for(Quota__c quota : [SELECT User__c, Product_Family__c, Month__c, Quota__r.Year__c, Quota__r.Month__c, Quota__r.Product_Family__c, Quota__r.User__c, Year__c, Id, Quota__c FROM Quota__c WHERE User__c = :u1.Id]) {
            TestUtility.itShouldBe('Manager Quota User', u2.Id, quota.Quota__r.User__c);
            TestUtility.itShouldBe('Manager Quota Year', quota.Year__c, quota.Quota__r.Year__c);
            TestUtility.itShouldBe('Manager Quota Month', quota.Month__c, quota.Quota__r.Month__c);
            TestUtility.itShouldBe('Manager Quota Product Family', quota.Product_Family__c, quota.Quota__r.Product_Family__c);

        }

    }

    public static testMethod void testUserManagerChangeFromOtherUser() {
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Local Core Account Executive'];

        //disable triggers to avoid two queuable jobs being created
        TestClassUtility.DISABLE_TRIGGERS = true;

        User u1 = TestDataFactory.getUser('test1', null, salesProfile.Id);
        u1.SalesRepID__c = '12348';
        insert u1;

        User u2 = TestDataFactory.getUser('test10', u1.Id, salesProfile.Id);
        u1.SalesRepID__c = '12346';
        User u3 = TestDataFactory.getUser('test11', null, salesProfile.Id);
        u2.SalesRepID__c = '12347';

        insert new List<User>{u2, u3};

        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.User__c = u1.Id;
        quota1.Month__c = DateTime.now().format('MMMMM');
        quota1.Product_Family__c = 'New Internet Target';
        quota1.Year__c = '2019';

        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota1.User__c = u2.Id;
        quota1.Month__c = DateTime.now().format('MMMMM');
        quota1.Product_Family__c = 'New Internet Target';
        quota1.Year__c = '2019';

        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota1.User__c = u3.Id;
        quota1.Month__c = DateTime.now().format('MMMMM');
        quota1.Product_Family__c = 'New Internet Target';
        quota1.Year__c = '2019';

        Test.startTest();

            TestClassUtility.DISABLE_TRIGGERS = false;

            u2.ManagerId = u3.Id;
            update u2;

        Test.stopTest();

        Map<String, Quota__c> managerQuotas = new UserQuotaManagementDomain().getManagerQuotas(new Set<Id>{u3.Id});

        for(Quota__c quota : [SELECT User__c, Product_Family__c, Month__c, Quota__r.Year__c, Quota__r.Month__c, Quota__r.Product_Family__c, Quota__r.User__c, Year__c, Id, Quota__c FROM Quota__c WHERE User__c = :u2.Id]) {
            TestUtility.itShouldBe('Manager Quota User', u2.Id, quota.Quota__r.User__c);
            TestUtility.itShouldBe('Manager Quota Year', quota.Year__c, quota.Quota__r.Year__c);
            TestUtility.itShouldBe('Manager Quota Month', quota.Month__c, quota.Quota__r.Month__c);
            TestUtility.itShouldBe('Manager Quota Product Family', quota.Product_Family__c, quota.Quota__r.Product_Family__c);
        }

    }

    public static testMethod void testUserDeactivation() {
        Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Local Core Account Executive'];
        User u1 = TestDataFactory.getUser('test1', null, salesProfile.Id);
        insert u1; 
            
        List<Quota__c>  updateQuotas = new List<Quota__c>();
        for(Quota__c quota : [SELECT Direct_Amount__c FROM Quota__c WHERE User__c = :u1.Id]) {
            quota.Direct_Amount__c = 100;
            updateQuotas.add(quota);
        }

        update updateQuotas;

        Test.startTest();
            
            u1.IsActive = false;
            update u1;

        Test.stopTest();

        for(Quota__c quota : [SELECT Direct_Amount__c FROM Quota__c WHERE User__c = :u1.Id]) {
            TestUtility.itShouldBe('Quota Direct Amount', 0, quota.Direct_Amount__c);
        }
    }

    /*
        this is a crucial function in the user to quota sync, so these tests
        should remain to ensure it is always working properly
    */

    public static testMethod void testGetMonthsLeftInYearJanuary() {
        List<String> monthsRemaining = new UserQuotaManagementDomain().getMonthsLeftInYear(Date.newInstance(2019, 1, 1));
        TestUtility.itShouldBe('Months left in year', 12, monthsRemaining.size());
    }

    public static testMethod void testGetMonthsLeftInYearJuly() {
        List<String> monthsRemaining = new UserQuotaManagementDomain().getMonthsLeftInYear(Date.newInstance(2019, 7, 1));
        TestUtility.itShouldBe('Months left in year', 6, monthsRemaining.size());
    }

    public static testMethod void testGetMonthsLeftInYearDecember() {
        List<String> monthsRemaining = new UserQuotaManagementDomain().getMonthsLeftInYear(Date.newInstance(2019, 12, 1));
        TestUtility.itShouldBe('Months left in year', 1, monthsRemaining.size());
    }
}