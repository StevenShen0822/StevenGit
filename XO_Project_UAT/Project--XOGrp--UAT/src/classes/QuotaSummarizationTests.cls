@isTest
public with sharing class QuotaSummarizationTests {
    /*
                   1
                 /   \
                /     \
               2       3
             /  \     /  \
            4    5   6    7
           / \  / \  / \ / \
          8   9 10 11121314 15

          test traversing and summarizing a 4 level balanced hierarchy
          like the above
    */ 
    public static testMethod void test4LevelQuotaHierarchyInsert() {
        //this prevents the roll up until the end
        TestClassUtility.DISABLE_TRIGGERS = true;

        //level 1
        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.Direct_Amount__c = 100.00;
        insert quota1;

        //level 2
        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota2.Direct_Amount__c = 100.00;
        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota3.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota2, quota3};

        //level3
        Quota__c quota4 = TestDataFactory.getQuota(quota2.Id);
        quota4.Direct_Amount__c = 100.00;
        Quota__c quota5 = TestDataFactory.getQuota(quota2.Id);
        quota5.Direct_Amount__c = 100.00;
        Quota__c quota6 = TestDataFactory.getQuota(quota3.Id);
        quota6.Direct_Amount__c = 100.00;
        Quota__c quota7 = TestDataFactory.getQuota(quota3.Id);
        quota7.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota4, quota5, quota6, quota7};


        Test.startTest();
            
            TestClassUtility.DISABLE_TRIGGERS = false;

            //level 4
            Quota__c quota8 = TestDataFactory.getQuota(quota4.Id);
            quota8.Direct_Amount__c = 100.00;
            Quota__c quota9 = TestDataFactory.getQuota(quota4.Id);
            quota9.Direct_Amount__c = 100.00;
            Quota__c quota10 = TestDataFactory.getQuota(quota5.Id);
            quota10.Direct_Amount__c = 100.00;
            Quota__c quota11 = TestDataFactory.getQuota(quota5.Id);
            quota11.Direct_Amount__c = 100.00;
            Quota__c quota12 = TestDataFactory.getQuota(quota6.Id);
            quota12.Direct_Amount__c = 100.00;
            Quota__c quota13 = TestDataFactory.getQuota(quota6.Id);
            quota13.Direct_Amount__c = 100.00;
            Quota__c quota14 = TestDataFactory.getQuota(quota7.Id);
            quota14.Direct_Amount__c = 100.00;
            Quota__c quota15 = TestDataFactory.getQuota(quota7.Id);
            quota15.Direct_Amount__c = 100.00;
            insert new List<Quota__c>{quota8, quota9, quota10, quota11, quota12,
                quota13, quota14, quota15
            };

        Test.stopTest();

        //validate level 1
        List<Quota__c> quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota1.Id];

        TestUtility.itShouldBe('Indirect Amount', 1400, quotas[0].Indirect_Amount__c);

        //validate level 2
        List<Id> quotaIds = new List<Id>{quota2.Id, quota3.Id};
        quotas = [SELECT Indirect_Amount__c
                  FROM Quota__c
                  WHERE Id IN :quotaIds];

        for(Quota__c quota : quotas) {
            TestUtility.itShouldBe('Level 2 Quota', 600, quota.Indirect_Amount__c);
        }

        //validate level 3
        quotaIds = new List<Id>{quota4.Id, quota5.Id, quota6.Id, quota7.Id};
        quotas = [SELECT Indirect_Amount__c
                  FROM Quota__c
                  WHERE Id IN :quotaIds];

        for(Quota__c quota : quotas) {
            TestUtility.itShouldBe('Level 3 Quota', 200, quota.Indirect_Amount__c);
        }

        //validate level 4
        quotaIds = new List<Id>{quota8.Id, quota9.Id, quota10.Id, quota11.Id,
                                quota12.Id, quota13.Id, quota14.Id, quota15.Id
                               };
        quotas = [SELECT Indirect_Amount__c
                  FROM Quota__c
                  WHERE Id IN :quotaIds];

        for(Quota__c quota : quotas) {
            TestUtility.itShouldBe('Level 4 Quota', 0, quota.Indirect_Amount__c);
        }
    }

    /*
        Update a quota at the bottom of a four level hierarchy and verify the
        change in the amount cascades upwards
    */
    public static testMethod void test4LevelHierarchyUpdate() {
        //this prevents the roll up until the end
        TestClassUtility.DISABLE_TRIGGERS = true;

        //level 1
        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.Direct_Amount__c = 100.00;
        insert quota1;

        //level 2
        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota2.Direct_Amount__c = 100.00;
        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota3.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota2, quota3};

        //level3
        Quota__c quota4 = TestDataFactory.getQuota(quota2.Id);
        quota4.Direct_Amount__c = 100.00;
        Quota__c quota5 = TestDataFactory.getQuota(quota2.Id);
        quota5.Direct_Amount__c = 100.00;
        Quota__c quota6 = TestDataFactory.getQuota(quota3.Id);
        quota6.Direct_Amount__c = 100.00;
        Quota__c quota7 = TestDataFactory.getQuota(quota3.Id);
        quota7.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota4, quota5, quota6, quota7};

        //level 4
        Quota__c quota8 = TestDataFactory.getQuota(quota4.Id);
        quota8.Direct_Amount__c = 100.00;
        Quota__c quota9 = TestDataFactory.getQuota(quota4.Id);
        quota9.Direct_Amount__c = 100.00;
        Quota__c quota10 = TestDataFactory.getQuota(quota5.Id);
        quota10.Direct_Amount__c = 100.00;
        Quota__c quota11 = TestDataFactory.getQuota(quota5.Id);
        quota11.Direct_Amount__c = 100.00;
        Quota__c quota12 = TestDataFactory.getQuota(quota6.Id);
        quota12.Direct_Amount__c = 100.00;
        Quota__c quota13 = TestDataFactory.getQuota(quota6.Id);
        quota13.Direct_Amount__c = 100.00;
        Quota__c quota14 = TestDataFactory.getQuota(quota7.Id);
        quota14.Direct_Amount__c = 100.00;
        Quota__c quota15 = TestDataFactory.getQuota(quota7.Id);
        quota15.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota8, quota9, quota10, quota11, quota12,
            quota13, quota14, quota15
        };

        Test.startTest();
            
            TestClassUtility.DISABLE_TRIGGERS = false;

            quota8.Direct_Amount__c = 200;
            update quota8;

        Test.stopTest();

        //validate level 1
        List<Quota__c> quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota1.Id];

        TestUtility.itShouldBe('Level 1', quotas[0].Indirect_Amount__c, 1500);

        //validate level 2
        quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota2.Id];

        TestUtility.itShouldBe('Level 2', quotas[0].Indirect_Amount__c, 700);

        //validate level 3
        quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota4.Id];

        TestUtility.itShouldBe('Level 3', quotas[0].Indirect_Amount__c, 300);
    }

    /*
             1
            / \ 
           2   3
          / \
         4   5

        Test that an unabalanced hierarchy like above
        summarizes successfully on insert
    */
    public static testMethod void testUnbalancedHierarchy() {
        //this prevents the roll up until the end
        TestClassUtility.DISABLE_TRIGGERS = true;

        //level 1
        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.Direct_Amount__c = 100.00;
        insert quota1;

        //level 2
        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota2.Direct_Amount__c = 100.00;
        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota3.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota2, quota3};

        Test.startTest();

            TestClassUtility.DISABLE_TRIGGERS = false;

            //level3
            Quota__c quota4 = TestDataFactory.getQuota(quota2.Id);
            quota4.Direct_Amount__c = 100.00;
            Quota__c quota5 = TestDataFactory.getQuota(quota2.Id);
            quota5.Direct_Amount__c = 100.00;
            insert new List<Quota__c>{quota4, quota5};

        Test.stopTest();

        //validate level 1
        List<Quota__c> quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota1.Id];

        TestUtility.itShouldBe('Indirect Amount', quotas[0].Indirect_Amount__c, 400);

        //validate level 2
        quota2 = [SELECT Indirect_Amount__c FROM Quota__c WHERE Id = :quota2.Id];
        quota3 = [SELECT Indirect_Amount__c FROM Quota__c WHERE Id = :quota3.Id];

        TestUtility.itShouldBe('Indirect Amount', quota2.Indirect_Amount__c, 200);
        TestUtility.itShouldBe('Indirect Amount', quota3.Indirect_Amount__c, 0);   
    }

    /*
        Test that adding a new quota in the middle of a 4 level
        hierarchy properly pushes the values up
    */
    public static testMethod void testAddNewQuotaToMiddle() {
                //this prevents the roll up until the end
        TestClassUtility.DISABLE_TRIGGERS = true;

        //level 1
        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.Direct_Amount__c = 100.00;
        insert quota1;

        //level 2
        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota2.Direct_Amount__c = 100.00;
        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota3.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota2, quota3};

        //level3
        Quota__c quota4 = TestDataFactory.getQuota(quota2.Id);
        quota4.Direct_Amount__c = 100.00;
        Quota__c quota5 = TestDataFactory.getQuota(quota2.Id);
        quota5.Direct_Amount__c = 100.00;
        Quota__c quota6 = TestDataFactory.getQuota(quota3.Id);
        quota6.Direct_Amount__c = 100.00;
        Quota__c quota7 = TestDataFactory.getQuota(quota3.Id);
        quota7.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota4, quota5, quota6, quota7};

        TestClassUtility.DISABLE_TRIGGERS = false;

        //level 4
        Quota__c quota8 = TestDataFactory.getQuota(quota4.Id);
        quota8.Direct_Amount__c = 100.00;
        Quota__c quota9 = TestDataFactory.getQuota(quota4.Id);
        quota9.Direct_Amount__c = 100.00;
        Quota__c quota10 = TestDataFactory.getQuota(quota5.Id);
        quota10.Direct_Amount__c = 100.00;
        Quota__c quota11 = TestDataFactory.getQuota(quota5.Id);
        quota11.Direct_Amount__c = 100.00;
        Quota__c quota12 = TestDataFactory.getQuota(quota6.Id);
        quota12.Direct_Amount__c = 100.00;
        Quota__c quota13 = TestDataFactory.getQuota(quota6.Id);
        quota13.Direct_Amount__c = 100.00;
        Quota__c quota14 = TestDataFactory.getQuota(quota7.Id);
        quota14.Direct_Amount__c = 100.00;
        Quota__c quota15 = TestDataFactory.getQuota(quota7.Id);
        quota15.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota8, quota9, quota10, quota11, quota12,
            quota13, quota14, quota15
        };

        Test.startTest();
            TestClassUtility.DISABLE_TRIGGERS = false;

            Quota__c quota16 = TestDataFactory.getQuota(quota2.Id);
            quota16.Direct_Amount__c = 100.00;
            insert quota16;

        Test.stopTest();

        //validate level 1
        List<Quota__c> quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota1.Id];

        TestUtility.itShouldBe('Level 1', quotas[0].Indirect_Amount__c, 1500);

        //validate level 2
        quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota2.Id];

        TestUtility.itShouldBe('Level 2', quotas[0].Indirect_Amount__c, 700);

        //validate new quota
        quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota16.Id];

        TestUtility.itShouldBe('New Quota', quotas[0].Indirect_Amount__c, 0);
    }

    /*
        Test moving a quota from the bottom of the hierarchy
        to the third level in a four level tree
    */
    public static testMethod void testReparentQuota() {
        //this prevents the roll up until the end
        TestClassUtility.DISABLE_TRIGGERS = true;

        //level 1
        Quota__c quota1 = TestDataFactory.getQuota(null);
        quota1.Direct_Amount__c = 100.00;
        insert quota1;

        //level 2
        Quota__c quota2 = TestDataFactory.getQuota(quota1.Id);
        quota2.Direct_Amount__c = 100.00;
        Quota__c quota3 = TestDataFactory.getQuota(quota1.Id);
        quota3.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota2, quota3};

        //level3
        Quota__c quota4 = TestDataFactory.getQuota(quota2.Id);
        quota4.Direct_Amount__c = 100.00;
        Quota__c quota5 = TestDataFactory.getQuota(quota2.Id);
        quota5.Direct_Amount__c = 100.00;
        Quota__c quota6 = TestDataFactory.getQuota(quota3.Id);
        quota6.Direct_Amount__c = 100.00;
        Quota__c quota7 = TestDataFactory.getQuota(quota3.Id);
        quota7.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota4, quota5, quota6, quota7};

        //level 4
        Quota__c quota8 = TestDataFactory.getQuota(quota4.Id);
        quota8.Direct_Amount__c = 100.00;
        Quota__c quota9 = TestDataFactory.getQuota(quota4.Id);
        quota9.Direct_Amount__c = 100.00;
        Quota__c quota10 = TestDataFactory.getQuota(quota5.Id);
        quota10.Direct_Amount__c = 100.00;
        Quota__c quota11 = TestDataFactory.getQuota(quota5.Id);
        quota11.Direct_Amount__c = 100.00;
        Quota__c quota12 = TestDataFactory.getQuota(quota6.Id);
        quota12.Direct_Amount__c = 100.00;
        Quota__c quota13 = TestDataFactory.getQuota(quota6.Id);
        quota13.Direct_Amount__c = 100.00;
        Quota__c quota14 = TestDataFactory.getQuota(quota7.Id);
        quota14.Direct_Amount__c = 100.00;
        Quota__c quota15 = TestDataFactory.getQuota(quota7.Id);
        quota15.Direct_Amount__c = 100.00;
        insert new List<Quota__c>{quota8, quota9, quota10, quota11, quota12,
            quota13, quota14, quota15
        };

        Test.startTest();
            
            TestClassUtility.DISABLE_TRIGGERS = false;

            quota8.Quota__c = quota2.Id;
            update quota8;

        Test.stopTest();

        //validate level 1
        List<Quota__c> quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota1.Id];

        TestUtility.itShouldBe('Level 1', quotas[0].Indirect_Amount__c, 1400);

        //validate level 2
        List<Id> quotaIds = new List<Id>{quota2.Id, quota3.Id};
        quotas = [SELECT Indirect_Amount__c
                  FROM Quota__c
                  WHERE Id IN :quotaIds];

        for(Quota__c quota : quotas) {
            TestUtility.itShouldBe('Level 2 Quota', quota.Indirect_Amount__c, 600);
        }

        //validate level 3
        quotaIds = new List<Id>{quota5.Id, quota6.Id, quota7.Id};
        quotas = [SELECT Indirect_Amount__c
                  FROM Quota__c
                  WHERE Id IN :quotaIds];

        for(Quota__c quota : quotas) {
            TestUtility.itShouldBe('Level 3 Quota', quota.Indirect_Amount__c, 200);
        }

        //validate former parent quote indirect amount has reduced by 100
        quotas = [SELECT Indirect_Amount__c 
                                 FROM Quota__c 
                                 WHERE Id = :quota4.Id];

        TestUtility.itShouldBe('Former parent', quotas[0].Indirect_Amount__c, 100);
    }
}