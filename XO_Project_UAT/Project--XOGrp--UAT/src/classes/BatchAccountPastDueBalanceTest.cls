@isTest
private class BatchAccountPastDueBalanceTest {

    static testMethod void testNormalCreateEmails(){
        
        Invoice_Past_Due_Config__c ipdc = TestClassUtility.createInvoicePastDueConfig(true);
        ipdc.Create_ARR_Task__c = FALSE;
        update ipdc;

        Map<String,SObject> testMap = TestClassUtility.buildLocalData(true);

        Map<Integer, Date> daysLateDateMap = new Map<Integer, Date>();
        
        Integer daysPastDue = (Integer)ipdc.Number_Of_Days_Past_Due__c;
        Date pastDueDate = Date.today().addDays(daysPastDue * -1);
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        List<Folder> folderlist = [SELECT Id FROM Folder WHERE isreadonly = false limit 1];
        Document authDoc = new Document();
        authDoc.Name = 'TheKnot CC ACH Authorization Form';
        authDoc.folderId = folderlist[0].id;
        insert authDoc;

        Account acc = (Account)testMap.get('Account');
        Contact con = (Contact)testMap.get('Contact');
        con.Email = 'testtest@xogrp.com';

        update con;
        Zuora__CustomerAccount__c ca = TestClassUtility.createCustomerAccount(true, acc);
        ca.Bill_To_Contact__c = con.Id;
        update ca;
        
        acc.Past_Due_Balance__c = 100.0;
        acc.Customer_on_Payment_Arrangement__c = false;
        acc.Longest_Past_Due_Date__c = pastDueDate;
        acc.CBBS__c = UserInfo.getUserId();
        acc.Override_Account_CBSS__c = true;
        acc.Local_Paid_Status__c= 'Paid';

        update acc;
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        
        Test.startTest();
        Database.executeBatch(new BatchAccountPastDueBalanceEmailsAndTasks());
        Test.stopTest();
        System.assert([SELECT Id FROM Task WHERE  subject LIKE 'Account : %'].size()==0);
    
    }

    static testMethod void testAmnestyCreateEmailAndTasks(){

        Invoice_Past_Due_Config__c ipdc = TestClassUtility.createInvoicePastDueConfig(true);
        ipdc.Number_Of_Days_Past_Due__c = 30;
        update ipdc;

        Map<String,SObject> testMap = TestClassUtility.buildLocalData(true);

        Map<Integer, Date> daysLateDateMap = new Map<Integer, Date>();
        
        Integer daysPastDue = (Integer)ipdc.Number_Of_Days_Past_Due__c;
        Date pastDueDate = Date.today().addDays(daysPastDue * -1);
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        List<Folder> folderlist = [SELECT Id FROM Folder WHERE isreadonly = false limit 1];
        Document authDoc = new Document();
        authDoc.Name = 'TheKnot CC ACH Authorization Form';
        authDoc.folderId = folderlist[0].id;
        insert authDoc;

        Account acc = (Account)testMap.get('Account');
        Contact con = (Contact)testMap.get('Contact');
        con.Email = 'testtest@xogrp.com';

        update con;
        Zuora__CustomerAccount__c ca = TestClassUtility.createCustomerAccount(true, acc);
        ca.Bill_To_Contact__c = con.Id;
        update ca;

        acc.Past_Due_Balance__c = 100.0;
        acc.Customer_on_Payment_Arrangement__c = false;
        acc.Longest_Past_Due_Date__c = pastDueDate;
        acc.CBBS__c = UserInfo.getUserId();
        acc.Override_Account_CBSS__c = true;
        acc.Local_Paid_Status__c= 'Paid';
        acc.amnesty_promotion__c = '50% Amnesty Eligible';
        update acc;
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        
        Test.startTest();
        Database.executeBatch(new BatchAccountPastDueBalanceEmailsAndTasks());
        Test.stopTest();
        System.assert([SELECT Id FROM Task].size()>0);
        
    }


    static testMethod void testCreateAccOwnerEmailAndTasks(){

        Invoice_Past_Due_Config__c ipdc = TestClassUtility.createInvoicePastDueConfig(true);
        ipdc.Send_Email_To_Customer__c = FALSE;
        ipdc.Send_Email_To_Account_Owner__c = true;
        ipdc.Number_Of_Days_Past_Due__c = 70;
        ipdc.For_Non_Amnesty__c = true;
        update ipdc;

        Map<String,SObject> testMap = TestClassUtility.buildLocalData(true);

        Map<Integer, Date> daysLateDateMap = new Map<Integer, Date>();
        
        Integer daysPastDue = (Integer)ipdc.Number_Of_Days_Past_Due__c;
        Date pastDueDate = Date.today().addDays(daysPastDue * -1);
        
        TestClassUtility.DISABLE_TRIGGERS = TRUE;

        List<Folder> folderlist = [SELECT Id FROM Folder WHERE isreadonly = false limit 1];
        Document authDoc = new Document();
        authDoc.Name = 'TheKnot CC ACH Authorization Form';
        authDoc.folderId = folderlist[0].id;
        insert authDoc;

        Account acc = (Account)testMap.get('Account');
        Contact con = (Contact)testMap.get('Contact');
        con.Email = 'testtest@xogrp.com';

        update con;
        Zuora__CustomerAccount__c ca = TestClassUtility.createCustomerAccount(true, acc);
        ca.Bill_To_Contact__c = con.Id;
        update ca;

        acc.Past_Due_Balance__c = 100.0;
        acc.Customer_on_Payment_Arrangement__c = false;
        acc.Longest_Past_Due_Date__c = pastDueDate;
        acc.CBBS__c = UserInfo.getUserId();
        acc.Override_Account_CBSS__c = true;
        acc.Local_Paid_Status__c= 'Paid';
        update acc;
        TestClassUtility.DISABLE_TRIGGERS = FALSE;
        
        Test.startTest();
        Database.executeBatch(new BatchAccountPastDueBalanceEmailsAndTasks());
        Test.stopTest();

        System.assert([SELECT Id FROM Task].size()>0);

    }
}