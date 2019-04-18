@IsTest
private class FeatureRequestedCanceledAuraCtrlTest {

  public static final String TEST_JSON_STRING = '[{"SubProductChargeNumber":"2","spcId":"a1Tq0000002NmOBEA0","Status":"Requested Cancelled","frcId":"a1Aq0000001JkyyEAC"},' +
      '{"SubProductChargeNumber":"4","spcId":"a1Tq0000002NmOLEA0","Status":"Cancelled","frcId":"a1Aq0000001Jkz0EAC"},' +
      '{"SubProductChargeNumber":"3","spcId":"a1Tq0000002NmOGEA0","Status":"Saved","frcId":"a1Aq0000001Jkz1EAC"}]';

  public static final String TEST_JSON_STRING_NOFRC = '[{"SubProductChargeNumber":"2","spcId":"{0}","Status":"Requested Cancelled"},' +
      '{"SubProductChargeNumber":"4","spcId":"{1}","Status":"Cancelled"},' +
      '{"SubProductChargeNumber":"3","spcId":"{2}","Status":"Saved"}]';

  public static Zuora__SubscriptionProductCharge__c generateSPC(Account account, String chargeNumber) {
    Zuora__Product__c zp = new Zuora__Product__c();
    zp.Name = 'Storefront';
    insert zp;

    Zuora__SubscriptionRatePlan__c zsp = new Zuora__SubscriptionRatePlan__c();
    zsp.Name = 'Storefront | MI-Grand Rpds/Northern | Florists';
    insert zsp;

    Zuora__Subscription__c subscription = new Zuora__Subscription__c();
    subscription.Name = 'Recurring Charge';
    subscription.Zuora__SubscriptionEndDate__c  = Date.valueOf('2019-06-15');
    insert subscription;

    Zuora__SubscriptionProductCharge__c zspc = new Zuora__SubscriptionProductCharge__c();
    zspc.Name = chargeNumber;
    zspc.Zuora__ChargeNumber__c = chargeNumber;
    zspc.Zuora__SubscriptionRatePlan__c = zsp.Id;
    zspc.LDE_Email_Launch_Date__c = Date.valueOf('2017-05-15');
    zspc.LocationVendorDynamicsAccountID__c = 'abc123';
    zspc.List_Price__c = '45';
    zspc.Zuora__Price__c = 45.01;
    zspc.Zuora__BillingPeriod__c = 'Month';
    zspc.Zuora__Product__c = zp.Id;
    zspc.Zuora__Account__c = account.Id;
    zspc.Zuora__Subscription__c = subscription.Id;

    insert zspc;

    return zspc;
  }


  @IsTest
  static void testGetFeatureRequestCanceledForCaseNoFRCs() {
    Case testCase = new Case();
    insert testCase;

    Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);

    Map<String, SObject> testsub =TestClassUtility.buildSubscriptionData((Account)testObjects.get('Account'), 
                                                    (Contact)testObjects.get('Contact'), 
                                                    (Opportunity)testObjects.get('Opportunity') , 
                                                    (Zuora__CustomerAccount__c)testObjects.get('Zuora__CustomerAccount__c'));

    Zuora__SubscriptionProductCharge__c testzuoraSPC = (Zuora__SubscriptionProductCharge__c)testsub.get('Zuora__SubscriptionProductCharge__c');

    Feature_Requested_Cancelled__c testFRC = new Feature_Requested_Cancelled__c();
    testFRC.Case__c = testCase.Id;
    testFRC.Subscription_Product_Charge__c = testzuoraSPC.Id;
    testFRC.UniqueId__c = '1234b000004veRgAAIa1T1b000002GmgfABC';
    testFRC.Sub_Product_Charge_Number__c = '1';
    insert testFRC;

    Test.startTest();
      Map<String, Object> result = FeatureRequestedCanceledAuraController.getFeatureRequestCanceledForCase(testCase.Id);
    Test.stopTest();
    System.assert(result.size() == 2);

  }


  @IsTest
  static void testUpdateFRCsUpdateExisting() {
    Map<String, SObject> testObjects = TestClassUtility.buildLocalData(false);
    Account account = (Account)testObjects.get('Account');

    Case fakeCase = new Case();
    fakeCase.accountId = account.Id;
    insert fakeCase;

    // values in fake json are 2, 3, 4
    List<Zuora__SubscriptionProductCharge__c> spcs = new List<Zuora__SubscriptionProductCharge__c>{
        generateSPC(account, '2'),
        generateSPC(account, '3'),
        generateSPC(account, '4')
    };

    // Create a FRC object that is related to the case with Status 'Cancelled'
    Feature_Requested_Cancelled__c frc = new Feature_Requested_Cancelled__c();
    frc.Case__c = fakeCase.Id;
    frc.Status__c = 'Cancelled';
    frc.UniqueId__c = 'abc123';
    frc.Subscription_Product_Charge__c = spcs[0].Id;
    frc.Sub_Product_Charge_Number__c = '2';
    insert frc;

    List<Map<String, String>> frcs = FeatureRequestedCanceledAuraController.deserializeSPCList(TEST_JSON_STRING_NOFRC);
    frcs[0].put('spcId', spcs[0].Id);
    frcs[1].put('spcId', spcs[1].Id);
    frcs[2].put('spcId', spcs[2].Id);

    frcs[0].put('frcId', frc.Id);
    frcs[0].put('Status', 'Saved');

    String updatedJson = JSON.serialize(frcs);

    // Update the json string to include the correct SPC Ids
    Test.startTest();
    FeatureRequestedCanceledAuraController.updateFRCs(fakeCase.Id, updatedJSON);
    Test.stopTest();

    Feature_Requested_Cancelled__c frcsAfterUpdate = [SELECT Id,Status__c FROM Feature_Requested_Cancelled__c WHERE Subscription_Product_Charge__c =: spcs[0].Id];
    system.assert(frcsAfterUpdate.Status__c == 'Saved' );


  }


}