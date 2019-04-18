/*
  Class(es) Tested:
    BatchNotifyPaymentMethodExpiration
 */
@isTest
private class BatchNotifyPaymentMethodExpirationTest {
    
  @isTest static void test_method_one() {
    // Implement test code
    Test.startTest();
    
      Map<String, Object> nationTestData = TestClassUtility.buildNationalData();
      
      BatchNotifyPaymentMthdExpScheduledJob job = new BatchNotifyPaymentMthdExpScheduledJob();
      String sch = '0 1 0 * * ?';
      System.schedule('Test BatchNotifyPaymentMethodExpirationTest Job', sch, job);
    
    Test.stopTest();
  }
    
}