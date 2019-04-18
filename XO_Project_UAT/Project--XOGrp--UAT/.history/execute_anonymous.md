2018-05-30 16:17:22
```java
String sObjName = 003j000001PUlNu.getSObjectType().getDescribe().getName();
System.debug(LoggingLevel.INFO, '*** sObjName: ' + sObjName);

```

2018-05-30 16:18:04
```java
String sObjName = '003j000001PUlNu'.getSObjectType().getDescribe().getName();
System.debug(LoggingLevel.INFO, '*** sObjName: ' + sObjName);

```

2018-05-30 16:22:17
```java
Id tID = '003j000001PUlNu';
System.debug(tID.getSObjectType());
```

2018-05-30 16:27:25
```java

Schema.DescribeFieldResult dfr = Schema.SObjectType.Account.fields.Name;
System.debug(LoggingLevel.INFO, '*** dfr: ' + dfr);
```

2018-07-24 18:36:14
```java
list<String> l1 = new List<string>{'1','2','3'};


String q2 = 'SELECT Id FROM Account WHERE AccountNumber IN: ';
system.debug(':::' + q2.length());
String q = 'SELECT Id FROM Account WHERE AccountNumber IN: l1';
system.debug(':::' + q.length());

```

2018-07-24 18:38:08
```java
List<Id> l1 = new List<Id>();
for(Account acct : [SELECT Id FROM Account LIMIT 5]){
	L1.add(ACCT.Id);
}
System.debug(LoggingLevel.INFO, '*** l1: ' + l1);

String q2 = 'SELECT Id FROM Account WHERE AccountNumber IN: ';
system.debug(':::' + q2.length());
String q = 'SELECT Id FROM Account WHERE AccountNumber IN: l1';
system.debug(':::' + q.length());

```

2018-07-24 18:40:13
```java
List<Id> l1 = new List<Id>();
for(Account acct : [SELECT Id FROM Account LIMIT 5]){
	L1.add(ACCT.Id);
}
System.debug(LoggingLevel.INFO, '*** l1: ' + l1);

String b = ' (';
for(Id acctId : l1){
	b+= 'acctId, ';
}
b+=' )';


String q2 = 'SELECT Id FROM Account WHERE AccountNumber IN: ' + b;
system.debug(':::' + q2.length());
String q = 'SELECT Id FROM Account WHERE AccountNumber IN: l1';
system.debug(':::' + q.length());

```

2018-07-31 10:46:46
```java
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH5x');
lc.setDoNotCreateOpportunity(true);
lc.setConvertedStatus('Qualified');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc);
System.assert(lcr); 
```

2018-07-31 10:47:43
```java
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH5x');
lc.setDoNotCreateOpportunity(true);
lc.setConvertedStatus('Qualified');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc);
system.debug('---:::' + lcr);
```

2018-07-31 10:52:03
```java
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.allowSave = true;
dml.DuplicateRuleHeader.runAsCurrentUser = true;
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH5x');
lc.setDoNotCreateOpportunity(true);
lc.setConvertedStatus('Qualified');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc);
system.debug('---:::' + lcr);
```

2018-07-31 10:53:02
```java
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.allowSave = true;
dml.DuplicateRuleHeader.runAsCurrentUser = true;
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH5x');
lc.setDoNotCreateOpportunity(true);
lc.setConvertedStatus('Qualified');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc,dml);
system.debug('---:::' + lcr);
```

2018-07-31 11:00:26
```java
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.allowSave = true;
dml.DuplicateRuleHeader.runAsCurrentUser = true;
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH7j');
lc.setDoNotCreateOpportunity(false);
lc.setConvertedStatus('New');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc,dml);
```

2018-07-31 11:00:41
```java
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.allowSave = true;
dml.DuplicateRuleHeader.runAsCurrentUser = true;
Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId('00Q3F000001pH7j');
lc.setDoNotCreateOpportunity(false);
lc.setConvertedStatus('New');
lc.setOwnerId(UserInfo.getUserId());
Database.LeadConvertResult lcr = Database.convertLead(lc,dml);
System.debug(LoggingLevel.INFO, '*** lcr: ' + lcr);
```

2018-07-31 17:51:12
```java
        Lead lead1 = [SELECT DynamicsLeadID__c, Phone, Email, Company, LastName， FirstName,
                        Primary_Category__c, Street, PostalCode, State, Country, City 
                        FROM Lead WHERE Id = '00Q3F000001pJYf' limit 1];


        //e8bf544b-b0fc-44bf-a0e4-7218caeff433
        //3 digits Id  00Q3F000001pJYf
        //6 digits Id  00Q3F000001pJYk

        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = 'e8bf544b-b0fc-44bf-a0e4-7218caeff433';
        reqst.locationId = lead1.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = lead1.Phone;
        reqst.email = lead1.Email;
        reqst.contact.lastName = lead1.LastName;
        reqst.contact.firstName = lead1.FirstName;
        reqst.companyName = lead1.Company;
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = lead1.Primary_Category__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = lead1.Street;
        addressWrapper.street2 = lead1.Street;
        addressWrapper.postalCode = lead1.PostalCode;
        addressWrapper.stateOrProvince = lead1.State;
        addressWrapper.country = lead1.Country;
        addressWrapper.city = lead1.City;
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);

        String JsonMsg=JSON.serialize(reqst);
        System.debug(LoggingLevel.INFO, '*** JsonMsg: ' + JsonMsg);
```

2018-07-31 17:52:24
```java
        Lead lead1 = [SELECT DynamicsLeadID__c, Phone, Email, CompanyId, LastName， FirstName,
                        Primary_Category__c, Street, PostalCode, State, Country, City 
                        FROM Lead WHERE Id = '00Q3F000001pJYf' limit 1];


        //e8bf544b-b0fc-44bf-a0e4-7218caeff433
        //3 digits Id  00Q3F000001pJYf
        //6 digits Id  00Q3F000001pJYk

        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = 'e8bf544b-b0fc-44bf-a0e4-7218caeff433';
        reqst.locationId = lead1.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = lead1.Phone;
        reqst.email = lead1.Email;
        reqst.contact.lastName = lead1.LastName;
        reqst.contact.firstName = lead1.FirstName;
        reqst.companyName = lead1.Company;
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = lead1.Primary_Category__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = lead1.Street;
        addressWrapper.street2 = lead1.Street;
        addressWrapper.postalCode = lead1.PostalCode;
        addressWrapper.stateOrProvince = lead1.State;
        addressWrapper.country = lead1.Country;
        addressWrapper.city = lead1.City;
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);

        String JsonMsg=JSON.serialize(reqst);
        System.debug(LoggingLevel.INFO, '*** JsonMsg: ' + JsonMsg);
```

2018-07-31 17:52:48
```java
        Lead lead1 = [SELECT DynamicsLeadID__c, Phone, Company, LastName， FirstName,
                        Primary_Category__c, Street, PostalCode, State, Country, City 
                        FROM Lead WHERE Id = '00Q3F000001pJYf' limit 1];


        //e8bf544b-b0fc-44bf-a0e4-7218caeff433
        //3 digits Id  00Q3F000001pJYf
        //6 digits Id  00Q3F000001pJYk

        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = 'e8bf544b-b0fc-44bf-a0e4-7218caeff433';
        reqst.locationId = lead1.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = lead1.Phone;
        reqst.email = lead1.Email;
        reqst.contact.lastName = lead1.LastName;
        reqst.contact.firstName = lead1.FirstName;
        reqst.companyName = lead1.Company;
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = lead1.Primary_Category__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = lead1.Street;
        addressWrapper.street2 = lead1.Street;
        addressWrapper.postalCode = lead1.PostalCode;
        addressWrapper.stateOrProvince = lead1.State;
        addressWrapper.country = lead1.Country;
        addressWrapper.city = lead1.City;
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);

        String JsonMsg=JSON.serialize(reqst);
        System.debug(LoggingLevel.INFO, '*** JsonMsg: ' + JsonMsg);
```

2018-07-31 17:54:43
```java
        Lead lead1 = [SELECT DynamicsLeadID__c, Phone, Email, Company, LastName， FirstName,
                        Primary_Category__c, Street, PostalCode, State, Country, City 
                        FROM Lead WHERE Id = '00Q3F000001pJYf' limit 1];


        //e8bf544b-b0fc-44bf-a0e4-7218caeff433
        //3 digits Id  00Q3F000001pJYf
        //6 digits Id  00Q3F000001pJYk

        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = 'e8bf544b-b0fc-44bf-a0e4-7218caeff433';
        reqst.locationId = lead1.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = lead1.Phone;
        reqst.email = lead1.Email;
        reqst.contact.lastName = lead1.LastName;
        reqst.contact.firstName = lead1.FirstName;
        reqst.companyName = lead1.Company;
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = lead1.Primary_Category__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = lead1.Street;
        addressWrapper.street2 = lead1.Street;
        addressWrapper.postalCode = lead1.PostalCode;
        addressWrapper.stateOrProvince = lead1.State;
        addressWrapper.country = lead1.Country;
        addressWrapper.city = lead1.City;
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);

        String JsonMsg = JSON.serialize(reqst);
        System.debug(LoggingLevel.INFO, '*** JsonMsg: ' + JsonMsg);
```

2018-07-31 17:55:29
```java
        Lead lead1 = [SELECT DynamicsLeadID__c, Phone, Email, Company, LastName, FirstName,
                        Primary_Category__c, Street, PostalCode, State, Country, City 
                        FROM Lead WHERE Id = '00Q3F000001pJYf' limit 1];


        //e8bf544b-b0fc-44bf-a0e4-7218caeff433
        //3 digits Id  00Q3F000001pJYf
        //6 digits Id  00Q3F000001pJYk

        LeadPayloadWrapper reqst = new LeadPayloadWrapper();
        reqst.companyId = 'e8bf544b-b0fc-44bf-a0e4-7218caeff433';
        reqst.locationId = lead1.DynamicsLeadID__c;
        reqst.fulfillmentData.multipleCategoryInterest = false;
        reqst.fulfillmentData.tier = null;
        reqst.isClaiming = true;
        reqst.phone = lead1.Phone;
        reqst.email = lead1.Email;
        reqst.contact.lastName = lead1.LastName;
        reqst.contact.firstName = lead1.FirstName;
        reqst.companyName = lead1.Company;
        reqst.fulfillmentData.marketCode = '222';
        reqst.fulfillmentData.categoryId = lead1.Primary_Category__c;

        LeadPayloadWrapper.AddressWrapper addressWrapper = new LeadPayloadWrapper.AddressWrapper();
        addressWrapper.street1 = lead1.Street;
        addressWrapper.street2 = lead1.Street;
        addressWrapper.postalCode = lead1.PostalCode;
        addressWrapper.stateOrProvince = lead1.State;
        addressWrapper.country = lead1.Country;
        addressWrapper.city = lead1.City;
        addressWrapper.addressType = 'Shipping';

        reqst.address.add(AddressWrapper);

        String JsonMsg = JSON.serialize(reqst);
        System.debug(LoggingLevel.INFO, '*** JsonMsg: ' + JsonMsg);
```

2018-08-06 15:14:52
```java
Database.executeBatch(new BatchCCDeclinedReminder());
```

2018-08-06 15:51:42
```java
//Database.executeBatch(new BatchCCDeclinedReminder());
//
//
//
String a = String.valueOf(60).substringBefore('.');
System.debug(LoggingLevel.INFO, '*** a: ' + a);


```

2018-08-06 15:58:34
```java
Database.executeBatch(new BatchCCDeclinedReminder());
//
//
//



```

2018-08-06 16:09:00
```java
//Database.executeBatch(new BatchCCDeclinedReminder());
//
//
//
date expDate = Date.newInstance(2021, 3, 1);
System.debug(LoggingLevel.INFO, '*** Date.Today().daysBetween(expDate): ' + Date.Today().daysBetween(expDate));


```

2018-08-06 16:11:00
```java
Database.executeBatch(new BatchNotifyPaymentMethodExpiration());
//
//
//
date expDate = Date.newInstance(2021, 3, 1);
System.debug(LoggingLevel.INFO, '*** Date.Today().daysBetween(expDate): ' + Date.Today().daysBetween(expDate));


```

2018-08-08 12:54:28
```java
Database.executeBatch(new BatchCCDeclinedReminder());
```

2018-08-10 16:15:54
```java

//Paid Media Campaign Id: 70117000001U3iE
//Hot Campaign Id: 70117000001U3iJ

//Contact Id: 0031700000n0zdE
//Lead Id: 00Q1700000AgrIt

//Test Create
CampaignMember testPaidMediaCamMem = new CampaignMember();
testPaidMediaCamMem.CampaignId = '70117000001U3iE';
testPaidMediaCamMem.LeadId = '00Q1700000AgrIt';


CampaignMember testHotCamMem = new CampaignMember();
testHotCamMem.CampaignId = '70117000001U3iJ';
testHotCamMem.ContactId = '0031700000n0zdE';


//Test Create
CampaignMember testHotCamMem2 = new CampaignMember();
testHotCamMem2.CampaignId = '70117000001U3iJ';
testHotCamMem2.LeadId = '00Q1700000AgrIt';


CampaignMember testPaidMediaCamMem2 = new CampaignMember();
testPaidMediaCamMem2.CampaignId = '70117000001U3iE';
testPaidMediaCamMem2.ContactId = '0031700000n0zdE';

insert new List<CampaignMember>{testPaidMediaCamMem, testHotCamMem, testHotCamMem2, testPaidMediaCamMem2};
//insert new List<CampaignMember>{testHotCamMem, testHotCamMem2};
//insert new List<CampaignMember>{testHotCamMem, testPaidMediaCamMem};
//insert new List<CampaignMember>{testHotCamMem};
//delete 

   
```

2018-08-24 12:37:13
```java
List<zqu__QuoteRatePlanCharge__c> a = [select Name,zqu__EffectiveStartDate__c,zqu__EffectiveEndDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Customer_Acceptance_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__TermStartDate__c from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = 'a283F0000005OYu'];
System.debug(LoggingLevel.INFO, '*** a: ' + a);
```

2018-08-24 12:38:46
```java
List<zqu__QuoteRatePlanCharge__c> a = [select Name,zqu__EffectiveStartDate__c,zqu__EffectiveEndDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Customer_Acceptance_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__TermStartDate__c from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = 'a283F0000005OYu'];
System.debug(LoggingLevel.INFO, '*** a: ' + a);
for(zqu__QuoteRatePlanCharge__c qrpc : a){
	System.debug(LoggingLevel.INFO, '*** qrpc.zqu__Quote__r.zqu__StartDate__c: ' + qrpc.zqu__Quote__r.zqu__StartDate__c);
}

```

2018-08-24 12:39:04
```java
List<zqu__QuoteRatePlanCharge__c> a = [select Name,zqu__EffectiveStartDate__c,zqu__EffectiveEndDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Customer_Acceptance_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__TermStartDate__c from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = 'a283F0000005OYu'];
System.debug(LoggingLevel.INFO, '*** a: ' + a);
for(zqu__QuoteRatePlanCharge__c qrpc : a){
	System.debug(LoggingLevel.INFO, '*** qrpc.zqu__Quote__r.zqu__StartDate__c: ' + qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c);
}

```

2018-08-24 12:39:29
```java
List<zqu__QuoteRatePlanCharge__c> a = [select Name,zqu__EffectiveStartDate__c,zqu__EffectiveEndDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Customer_Acceptance_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Service_Activation_Date__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__TermStartDate__c from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = 'a283F0000005OYu'];
System.debug(LoggingLevel.INFO, '*** a: ' + a);
for(zqu__QuoteRatePlanCharge__c qrpc : a){
	System.debug(LoggingLevel.INFO, '*** qrpc.zqu__Quote__r.zqu__StartDate__c: ' + qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__StartDate__c);
	System.debug(LoggingLevel.INFO, '*** qrpc.zqu__Quote__r.zqu__TermStartDate__c: ' + qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__TermStartDate__c);
}

```

2018-08-30 15:11:58
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	stting.Name +=  '_' + setting.Market_Name__c + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + seeting.Name);
}
```

2018-08-30 15:12:53
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name +=  '_' + setting.Market_Name__c + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
```

2018-08-30 15:13:33
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name +=  '_' + setting.Market_Name__c + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
update list1;
```

2018-08-30 15:14:59
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name +=  '_' + setting.Market_Name__c.left(2) + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
//update list1;
```

2018-08-30 15:15:18
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name +=  '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
update list1;
```

2018-08-30 15:16:38
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name +=  '_' + setting.Market_Name__c.left(2) + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
update list1;
```

2018-08-30 15:17:18
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name =  setting.Canadian_Postal_Code__c + '_' + setting.Market_Name__c.left(2) + '_' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
update list1;
```

2018-08-30 15:17:46
```java
Map<String, Canadian_Postal_Code_Market_Mapping__c> canadaMarketMap = Canadian_Postal_Code_Market_Mapping__c.getAll();
List<Canadian_Postal_Code_Market_Mapping__c> list1 = canadaMarketMap.values();
for(Canadian_Postal_Code_Market_Mapping__c setting : list1){
	setting.Name =  setting.Canadian_Postal_Code__c + '-' + setting.Market_Name__c.left(2) + '-' + setting.Market_Id__c;
	System.debug(LoggingLevel.INFO, '*** seeting.Name: ' + setting.Name);
}
update list1;
```

2018-09-06 18:52:33
```java
Account acct = new Account();
acct.Name = 'test090601';
acct.ShippingCountry = 'Canada';
acct.ShippingPostalCode = 'A0Z0A0';

insert acct;
```

2018-09-06 19:19:21
```java
Boolean a = XOCustomValidationUtility.validZip(null, 'A0A0A0');
System.debug(LoggingLevel.INFO, '*** a: ' + a);
```

2018-09-06 19:19:57
```java
Account acct = new Account();
acct.Name = 'test090601';
acct.ShippingCountry = 'Canada';
acct.ShippingPostalCode = 'A0Z0A0';

insert acct;
```

2018-09-06 19:24:41
```java
Account acct = new Account();
acct.Name = 'test090601';
acct.ShippingCountry = 'Canada';
acct.ShippingPostalCode = 'A0Z0A0';

insert acct;
```

2018-09-06 19:26:46
```java
Account acct = new Account();
acct.Name = 'test090601';
acct.ShippingCountry = 'Canada';
acct.ShippingPostalCode = 'A0Z0A0';
acct.BillingCountry = 'Canada';
acct.BillingPostalCode = 'A0Z0A0';
insert acct;
```

2018-09-06 19:29:53
```java
Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}
```

2018-09-06 19:38:07
```java
/*Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}*/


Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}
```

2018-09-06 19:39:35
```java
Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}


/*Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}*/
```

2018-09-07 11:08:11
```java
Account record = new Account();
record.ShippingCountry = 'United States';
record.BillingCountry = 'United States';
record.Name = 'test record';
Account record2 = new Account();
record2.ShippingCountry = 'Canada';
record2.BillingCountry = 'Canada';
record2.Name = 'test record';
insert new List<Account>{record,record2};
```

2018-09-07 12:49:57
```java
Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}


/*Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}*/
```

2018-09-07 12:49:58
```java
Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}


/*Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}*/
```

2018-09-07 12:50:20
```java
Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}
```

2018-09-07 13:38:51
```java
Set<string> set1 = new Set<String>();
Integer count = 0;
Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
	count++;
System.debug(f.getLabel() +'::'+ f.getValue());
set1.add(f.getLabel());
}
System.debug(LoggingLevel.INFO, '*** count: ' + count);
System.debug(LoggingLevel.INFO, '*** set1.size(): ' + set1.size());
```

2018-09-07 13:40:13
```java
Set<string> set1 = new Set<String>();
Integer count = 0;
Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
	count++;
System.debug(f.getLabel() +'::'+ f.getValue());
set1.add(f.getLabel());
}
System.debug(LoggingLevel.INFO, '*** count: ' + count);
System.debug(LoggingLevel.INFO, '*** set1.size(): ' + set1.size());
```

2018-09-07 15:37:04
```java
public static Map<String,String> buildPicklistEntryMap(String objectAPIName, String picklistFieldAPIName) {
		Map<String,String> picklistLabelpicklistValueMap = new Map<String,String>();
		//get object 
		Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName); 
		System.debug(LoggingLevel.INFO, '*** objectType: ' + objectType);
		//get field
		Schema.SobjectField pisklistField = objectType.getDescribe().fields.getMap().get(picklistFieldAPIName);
		System.debug(LoggingLevel.INFO, '*** pisklistField: ' + pisklistField);
		Schema.DescribeFieldResult fieldResult = pisklistField.getDescribe();
		//get field picklist entries
		List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
		System.debug(LoggingLevel.INFO, '*** picklistEntryList: ' + picklistEntryList);
		//build field picklist label and picklist value map
		for(Schema.PicklistEntry picklistEntry : picklistEntryList){
			picklistLabelpicklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
		}
		System.debug(LoggingLevel.INFO, '*** picklistLabelpicklistValueMap: ' + picklistLabelpicklistValueMap);
		return picklistLabelpicklistValueMap;
}
System.debug( buildPicklistEntryMap('Account','ShippingCountry'));
```

2018-09-07 15:37:23
```java
public static Map<String,String> buildPicklistEntryMap(String objectAPIName, String picklistFieldAPIName) {
		Map<String,String> picklistLabelpicklistValueMap = new Map<String,String>();
		//get object 
		Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName); 
		System.debug(LoggingLevel.INFO, '*** objectType: ' + objectType);
		//get field
		Schema.SobjectField pisklistField = objectType.getDescribe().fields.getMap().get(picklistFieldAPIName);
		System.debug(LoggingLevel.INFO, '*** pisklistField: ' + pisklistField);
		Schema.DescribeFieldResult fieldResult = pisklistField.getDescribe();
		//get field picklist entries
		List<Schema.PicklistEntry> picklistEntryList = fieldResult.getPicklistValues();
		System.debug(LoggingLevel.INFO, '*** picklistEntryList: ' + picklistEntryList);
		//build field picklist label and picklist value map
		for(Schema.PicklistEntry picklistEntry : picklistEntryList){
			picklistLabelpicklistValueMap.put(picklistEntry.getLabel(), picklistEntry.getValue());
		}
		System.debug(LoggingLevel.INFO, '*** picklistLabelpicklistValueMap: ' + picklistLabelpicklistValueMap);
		return picklistLabelpicklistValueMap;
}
System.debug( buildPicklistEntryMap('Account','ShippingCountryCode'));
```

2018-09-07 15:38:14
```java
Schema.DescribeFieldResult fieldResult = Account.ShippingCountry.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}
```

2018-09-07 15:38:25
```java


Schema.DescribeFieldResult fieldResult = Account.ShippingCountrycODE.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
System.debug('Picklist::'+ple);
for( Schema.PicklistEntry f : ple){
System.debug(f.getLabel() +'::'+ f.getValue());
}
```

2018-09-07 18:37:46
```java
Account acct = new Account();
acct.Name = '1234567';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;

```

2018-09-07 18:38:42
```java
Account acct = new Account();
acct.Id = '0013F00000DgfnO';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:41:58
```java
delete acct;
```

2018-09-07 18:42:15
```java
Account acct = new Account();
acct.Name = '12345678';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 18:42:43
```java
Account acct = new Account();
acct.Id = '0013F00000Dgfpo';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:45:19
```java
Account acct = new Account();
acct.Name = '123456789';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 18:45:26
```java
Account acct = new Account();
acct.Id = '0013F00000Dgfpo';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:47:59
```java
Account acct = new Account();
acct.Name = '1234567890';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 18:48:06
```java
Account acct = new Account();
acct.Id = '0013F00000Dgfpo';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:53:04
```java
Account acct = new Account();
acct.Name = '12345678901';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 18:53:40
```java
Account acct = new Account();
acct.Name = '12345678901';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;

Account acct = new Account();
acct.Id = '0013F00000DgfuK';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;



```

2018-09-07 18:53:45
```java
Account acct = new Account();
acct.Id = '0013F00000DgfuK';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:57:20
```java
Account acct = new Account();
acct.Name = '123456789011';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 18:57:49
```java
Account acct = new Account();
acct.Id = '0013F00000DgfuZ';
acct.ShippingPostalCode='A0N1N1';
acct.BillingPostalCode='A0N1N1';
update acct;
```

2018-09-07 18:59:53
```java
Account acct = new Account();
acct.Name = '1234567890111';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
```

2018-09-07 19:00:20
```java
Account acct = new Account();
acct.Id = '0013F00000Dgfuy';
acct.ShippingPostalCode='10005';
acct.BillingPostalCode='10005';
acct.ShippingCountry='United States';
acct.BillingCountry='United States';
update acct;
```

2018-09-07 19:04:39
```java
Account acct = new Account();
acct.Name = '12345678901111';
acct.ShippingCountry='Canada';
acct.BillingCountry='Canada';
acct.ShippingPostalCode='B0N1N1';
acct.BillingPostalCode='B0N1N1';
insert acct;
System.debug(LoggingLevel.INFO, '*** acct.Id: ' + acct.Id);

```

2018-09-07 19:05:25
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode=null;
//acct.ShippingCountry='United States';
//acct.BillingCountry='United States';
update acct;

```

2018-09-07 19:06:50
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode=null;
acct.ShippingState = 'Ontario';
//acct.ShippingCountry='United States';
//acct.BillingCountry='United States';
update acct;
```

2018-09-07 19:07:47
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode= 'J2J 3J3';
acct.ShippingState = 'Ontario';
//acct.ShippingCountry='United States';
//acct.BillingCountry='United States';
update acct;
```

2018-09-07 19:09:13
```java

Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode= 'J2J 3J3';
acct.ShippingState = null;
acct.ShippingCountry = null;
//acct.ShippingCountry='United States';
//acct.BillingCountry='United States';
update acct;

```

2018-09-07 19:11:37
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode= 'J2J 3J3';
acct.ShippingState = null;
//acct.ShippingCountry = null;
acct.ShippingCountry='United States';
acct.BillingCountry=null;
update acct;

```

2018-09-07 19:13:49
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode=null;
acct.BillingPostalCode= 'A0N 3J3';
acct.ShippingState = null;
//acct.ShippingCountry = null;
acct.ShippingCountry='United States';
acct.BillingCountry='Canada';
update acct;

```

2018-09-07 19:15:46
```java
Account acct = new Account();
acct.Id = '0013F00000DgfwoQAB';
acct.ShippingPostalCode='10005';
acct.BillingPostalCode= 'A0N 3J3';
acct.ShippingState = null;
//acct.ShippingCountry = null;
acct.ShippingCountry='United States';
acct.BillingCountry='Canada';
update acct;
```

2018-09-10 17:00:37
```java
Account acct = new Account();
acct.name = 'Test123';
acct.ShippingCountry = 'Canada';
acct.ShippingState = 'New Bruswick';
acct.BillingCountry = 'Canada';
acct.BillingState = 'New Bruswick';
insert acct;
```

2018-09-10 17:01:26
```java
Account acct = new Account();
acct.name = 'Test123';
acct.ShippingCountry = 'Canada';
acct.ShippingState = 'New Bruswick';
acct.BillingCountry = 'Canada';
acct.BillingState = 'New Bruswick';
insert acct;
```

2018-09-10 17:02:07
```java
Account acct = new Account();
acct.name = 'Test123';
acct.ShippingCountry = 'Canada';
acct.ShippingState = 'New Brunswick';
acct.BillingCountry = 'Canada';
acct.BillingState = 'New Brunswick';
insert acct;
```

2018-09-10 17:03:51
```java
Account acct = new Account();
acct.Id = '0013F00000Dgvk2';
acct.ShippingState = 'Prince Edward Island';
update acct;
```

2018-09-11 12:25:58
```java

        String objectName = '';
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 

            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);

                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals('a28')){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }

```

2018-09-11 12:26:19
```java

        String objectName = '';
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 

            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();

                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals('a28')){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
```

2018-09-11 12:32:14
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c == null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());

```

2018-09-11 12:32:45
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c == null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());

```

2018-09-11 12:33:02
```java
List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c == null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + spcList.size());

```

2018-09-11 12:34:26
```java
List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c = null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + spcList.size());

```

2018-09-11 12:37:48
```java
List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Zuora__Subscription__c = 'a1Vj0000005Ajmj' ];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + spcList.size());

```

2018-09-11 12:38:31
```java
List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Zuora__Subscription__r.OriginalSalesforceQuoteID__c = 'a28j0000000Q7yxAAC' ];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + spcList.size());

```

2018-09-11 12:40:09
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT Print_Issue__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c = null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());
for(Zuora__SubscriptionProductCharge__c charge : list_charges){
    charge.Print_Issue__c = charge.Print_Issue_Id__c;
}
update list_charges;

```

2018-09-11 12:40:21
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT ,Print_Issue_Id__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c = null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());
for(Zuora__SubscriptionProductCharge__c charge : list_charges){
    charge.Print_Issue__c = charge.Print_Issue_Id__c;
}
update list_charges;

```

2018-09-11 12:40:35
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT ,Print_Issue_Id__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c = null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());
for(Zuora__SubscriptionProductCharge__c charge : list_charges){
    charge.Print_Issue__c = charge.Print_Issue_Id__c;
}
update list_charges;

```

2018-09-11 12:40:45
```java
List<Zuora__SubscriptionProductCharge__c> list_charges = [SELECT Print_Issue_Id__c FROM Zuora__SubscriptionProductCharge__c WHERE Product_Type__c = 'Print' AND Print_Issue_Id__c != null AND Print_Issue__c = null];
System.debug(LoggingLevel.INFO, '*** list_charges.size(): ' + list_charges.size());
for(Zuora__SubscriptionProductCharge__c charge : list_charges){
    charge.Print_Issue__c = charge.Print_Issue_Id__c;
}
update list_charges;

```

2018-09-19 12:49:55
```java
List<Opportunity> list_Opps = [SELECT Id,Name FROM Opportunity WHERE AccountId = '0013F00000DjAMs'];
System.debug(LoggingLevel.INFO, '*** list_Opps: ' + list_Opps);
```

2018-09-19 12:52:32
```java
List<Opportunity> list_Opps = [SELECT Id,Name FROM Opportunity WHERE AccountId = '0013F00000DjAMs'];
System.debug(LoggingLevel.INFO, '*** list_Opps: ' + list_Opps);
for(Opportunity opp : list_Opps){
	opp.Cancel_For_Convenience__c = true;
	opp.StageName = 'Closed Lost';
	opp.Lost_Reason__c = 'Out of Business';
}
update list_Opps;
```

2018-09-19 14:25:06
```java
List<Opportunity> list_Opps = [SELECT Id,Name FROM Opportunity WHERE Id = '0063F00000CCdKr' OR Id = '0063F00000CCdKh'];
System.debug(LoggingLevel.INFO, '*** list_Opps: ' + list_Opps);
for(Opportunity opp : list_Opps){
	opp.Cancel_For_Convenience__c = true;
	opp.StageName = 'Closed Lost';
	opp.Lost_Reason__c = 'Out of Business';
}

List<Database.SaveResult> resultList = Database.update(list_Opps, false);
List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
xoExceptionList.addAll(ExceptionUtility.consumeException(resultList));

if(!xoExceptionList.isEmpty()){
  Insert xoExceptionList;
}
        
```

2018-09-20 18:46:13
```java
Map<String,Account> map_Id_Account = new Map<String,Account>();
Account acct = new Account();
acct.Name = 'in map';
map_Id_Account.put('a',acct);

Account tempAcct = map_Id_Account.get('a');
System.debug(LoggingLevel.INFO, '*** tempAcct.Name: ' + tempAcct.Name);
tempAcct.Name = 'update ';
System.debug(LoggingLevel.INFO, '*** tempAcct.Name: ' + tempAcct.Name);
System.debug(LoggingLevel.INFO, '*** map_Id_Account.get(a): ' + map_Id_Account.get('a'));
```

2018-09-29 15:18:46
```java

System.debug(LoggingLevel.INFO, '*** : ' + Limits.getLimitEmailInvocations());
```

2018-10-15 17:25:42
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE zqu__Opportunity__c = '12313123123'];
```

2018-10-15 17:26:02
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = '12313123123'];
```

2018-10-15 17:26:18
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id != '12313123123'];
```

2018-10-15 17:26:46
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = '0063F00000COgbg'];
```

2018-10-15 17:27:08
```java
zqu__Quote__c quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = '0063F00000COgbg'];
```

2018-10-15 17:27:27
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = '0063F00000COgbg'];
System.debug(LoggingLevel.INFO, '*** quoteUpdateList.size(): ' + quoteUpdateList.size());
```

2018-10-15 17:27:40
```java
List<zqu__Quote__c> quoteUpdateList = [SELECT Id, zqu__Opportunity__c, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = '0063F00000COgbg'];
System.debug(LoggingLevel.INFO, '*** quoteUpdateList.size(): ' + quoteUpdateList.isEmpty());
```

2018-10-17 11:37:47
```java
System.debug(LoggingLevel.INFO, '*** Date.today(): ' + Date.today());
Date a = DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1);
System.debug(LoggingLevel.INFO, '*** a: ' + a);
```

2018-10-17 11:48:01
```java
Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

if(businessDays != 0 && businessHourId != NULL) {
  Integer milliseconds =  businessDays * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);
}
```

2018-10-17 11:48:12
```java
Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

if(businessDays != 0 && businessHourId != NULL) {
  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);
}
```

2018-10-17 11:48:24
```java
Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);

```

2018-10-17 11:48:49
```java
Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));


  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);
```

2018-10-17 11:49:32
```java
// System.debug(LoggingLevel.INFO, '*** Date.today(): ' + Date.today());
// Date a = DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1);
// System.debug(LoggingLevel.INFO, '*** a: ' + a);

Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

System.debug(LoggingLevel.INFO, '*** startDateTime: ' + startDateTime);
  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);

```

2018-10-17 11:54:18
```java
// System.debug(LoggingLevel.INFO, '*** Date.today(): ' + Date.today());
// Date a = DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1);
// System.debug(LoggingLevel.INFO, '*** a: ' + a);

Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

System.debug(LoggingLevel.INFO, '*** startDateTime: ' + startDateTime);
  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  Datetime reminderDate = Datetime.newInstance(DateUtility.AddBusinessDays(businessHourList[0].Id, Date.today(), 1), Time.newInstance(8, 0, 0, 0)) ;
  System.debug(LoggingLevel.INFO, '*** reminderDate: ' + reminderDate);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);

```

2018-10-17 11:54:26
```java
// System.debug(LoggingLevel.INFO, '*** Date.today(): ' + Date.today());
// Date a = DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1);
// System.debug(LoggingLevel.INFO, '*** a: ' + a);

Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

System.debug(LoggingLevel.INFO, '*** startDateTime: ' + startDateTime);
  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  Datetime reminderDate = Datetime.newInstance(DateUtility.AddBusinessDays(businessHourList[0].Id, Date.today(), 1), Time.newInstance(8, 0, 0, 0)) ;
  System.debug(LoggingLevel.INFO, '*** reminderDate: ' + reminderDate);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);

```

2018-10-17 11:54:46
```java
// System.debug(LoggingLevel.INFO, '*** Date.today(): ' + Date.today());
// Date a = DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1);
// System.debug(LoggingLevel.INFO, '*** a: ' + a);

Date finalDate = Date.today();
Datetime startDateTime = Datetime.newInstance(Date.today(), Time.newInstance(12, 00, 00, 0000));

System.debug(LoggingLevel.INFO, '*** startDateTime: ' + startDateTime);
  Integer milliseconds =  1 * 9* 60* 60* 1000;
  Datetime nextBusinessDateTime = BusinessHours.add('01mf1000000015y', startDateTime, milliseconds);
  Datetime reminderDate = Datetime.newInstance(DateUtility.AddBusinessDays('01mf1000000015y', Date.today(), 1), Time.newInstance(8, 0, 0, 0)) ;
  System.debug(LoggingLevel.INFO, '*** reminderDate: ' + reminderDate);
  System.debug(LoggingLevel.INFO, '*** nextBusinessDateTime: ' + nextBusinessDateTime);
  finalDate = nextBusinessDateTime.date();
  System.debug(LoggingLevel.INFO, '*** finalDate: ' + finalDate);

```

2018-10-18 15:46:09
```java
EmailMessage sentEmail = new EmailMessage();
		sentEmail.RelatedToId = testCaseWithSentEmail.Id;
		sentEmail.Subject = 'Test case with sent email, its status should be changed to reopened by trigger';
		System.debug(LoggingLevel.INFO, '*** JSON.serialize(sentEmail): ' + JSON.serialize(sentEmail));
```

2018-10-18 15:46:19
```java
EmailMessage sentEmail = new EmailMessage();
		sentEmail.RelatedToId = '123';
		sentEmail.Subject = 'Test case with sent email, its status should be changed to reopened by trigger';
		System.debug(LoggingLevel.INFO, '*** JSON.serialize(sentEmail): ' + JSON.serialize(sentEmail));
```

2018-10-18 15:46:29
```java
EmailMessage sentEmail = new EmailMessage();
		//sentEmail.RelatedToId = '123';
		sentEmail.Subject = 'Test case with sent email, its status should be changed to reopened by trigger';
		System.debug(LoggingLevel.INFO, '*** JSON.serialize(sentEmail): ' + JSON.serialize(sentEmail));
```

2018-10-19 14:57:03
```java
List<EmailMessage>  l1 = [select Status from EmailMessage limit 100];
System.debug(LoggingLevel.INFO, '*** : ' + l1);
```

2018-10-19 14:58:01
```java
List<EmailMessage>  l1 = [select Status from EmailMessage limit 100];
System.debug(LoggingLevel.INFO, '*** : ' + l1);
```

2018-11-20 11:05:29
```java
Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = caseRecTypeNameMap.get('Asset Collection').getRecordTypeId();
assetCollectionCase.OwnerId = '00Gf1000002rsH2';
assetCollectionCase.AccountId = '0012900000Ohsmt';
assetCollectionCase.Status = 'Materials in';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
assetCollectionCase.Product_Type__c = 'Internet';
assetCollectionCase.Term_Start_Date__c = Date.today(); 
assetCollectionCase.Term_End_Date__c = Date.today(); 
assetCollectionCase.LDE_Launch_Date__c = Date.today();
insert assetCollectionCase;
```

2018-11-20 11:06:34
```java
Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = '012f10000004YkB';
assetCollectionCase.OwnerId = '00Gf1000002rsH2';
assetCollectionCase.AccountId = '0012900000Ohsmt';
assetCollectionCase.Status = 'Materials in';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
assetCollectionCase.Product_Type__c = 'Internet';
assetCollectionCase.Term_Start_Date__c = Date.today(); 
assetCollectionCase.Term_End_Date__c = Date.today(); 
assetCollectionCase.LDE_Launch_Date__c = Date.today();
insert assetCollectionCase;
```

2018-11-20 11:15:05
```java
Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = '012f10000004YkB';
assetCollectionCase.OwnerId = '00Gf1000002rsH2';
assetCollectionCase.AccountId = '0012900000Ohsmt';
assetCollectionCase.Status = 'Working';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
assetCollectionCase.Product_Type__c = 'Internet';
assetCollectionCase.Term_Start_Date__c = Date.today(); 
assetCollectionCase.Term_End_Date__c = Date.today(); 
assetCollectionCase.LDE_Launch_Date__c = Date.today();
insert assetCollectionCase;
```

2018-11-20 11:20:56
```java
delete [SELECT Id FROM Case WHERE AccountId = '0012900000Ohsmt'];

Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = '012f10000004YkB';
assetCollectionCase.OwnerId = '00Gf1000002rsH2';
assetCollectionCase.AccountId = '0012900000Ohsmt';
assetCollectionCase.Status = 'Working';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
assetCollectionCase.Product_Type__c = 'Internet';
assetCollectionCase.Term_Start_Date__c = Date.today(); 
assetCollectionCase.Term_End_Date__c = Date.today(); 
assetCollectionCase.LDE_Launch_Date__c = Date.today();
insert assetCollectionCase;
```

2018-11-20 11:25:46
```java
//delete [SELECT Id FROM Case WHERE AccountId = '0012900000Ohsmt'];

Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = '012f10000004YkB';
assetCollectionCase.OwnerId = '00Gf1000002rsH2';
assetCollectionCase.AccountId = '0012900000Ohsmt';
assetCollectionCase.Status = 'New';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
assetCollectionCase.Product_Type__c = 'Internet';
assetCollectionCase.Term_Start_Date__c = Date.today(); 
assetCollectionCase.Term_End_Date__c = Date.today(); 
assetCollectionCase.LDE_Launch_Date__c = Date.today();
insert assetCollectionCase;
```

2018-12-04 11:35:57
```java
Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
assetCollectionCase.OwnerId = '00Gf1000002rsH3';
assetCollectionCase.AccountId = '0011b00000ZBoVN';
assetCollectionCase.ContactId = '0031b00000Szx6H';
assetCollectionCase.Status = 'New';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
insert assetCollectionCase;
```

2018-12-04 11:36:21
```java

Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
assetCollectionCase.OwnerId = '00Gf1000002rsH3';
assetCollectionCase.AccountId = '0011b00000ZBoVN';
//assetCollectionCase.ContactId = '0031b00000Szx6H';
assetCollectionCase.Status = 'New';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
insert assetCollectionCase;
```

2018-12-04 11:36:48
```java
Case assetCollectionCase = new Case();
assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
assetCollectionCase.OwnerId = '00Gf1000002rsH3';
assetCollectionCase.AccountId = '0011b00000ZBoVN';
//assetCollectionCase.ContactId = '0031b00000Szx6H';
assetCollectionCase.Status = 'New';
assetCollectionCase.Reason = 'Asset Collection';
assetCollectionCase.Origin = 'Auto-Generated';
insert assetCollectionCase;
```

2018-12-04 15:02:30
```java
delete [SELECT Id FROM Case WHERE AccountId = '0011b00000ZBoVN' OR AccountId = '0011b00000Z9USU'];
```

2018-12-06 16:27:41
```java

List<Case> listCases = new List<Case>();
for(Integer i =0; i < 5; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0011b00000ZBoVN';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Internet';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
for(Integer i =0; i < 5; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0011b00000Z9USU';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Internet';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2018-12-11 12:57:19
```java
string a = '2323';
System.debug(LoggingLevel.INFO, '*** a.substring(a.indexOf('4')): ' + a.substring(a.indexOf('4')));
```

2018-12-11 12:57:36
```java
string a = '2323';
System.debug(LoggingLevel.INFO, a.substring(a.indexOf('4')));
```

2018-12-13 16:48:18
```java
List<Task> uTaskList = new List<Task>();
for(ThoughtStarter_RFP__c currentTSRFP : [select Id, (select OwnerId, WhatId from Tasks where isClosed = false and Owner.UserRole.DeveloperName = 'Sales_Development') 
                                                    from ThoughtStarter_RFP__c where Id = 'a0gf1000004Z6AGAA0']){
		for(Task childRecord : currentTSRFP.Tasks){
			childRecord.Status = 'Completed';
			uTaskList.add(childRecord);
		}
}
                    
		       
	    		
			

			if (!uTaskList.isEmpty()) {
    			update uTaskList;
    		}
```

2018-12-13 17:47:15
```java
List<Task> uTaskList = new List<Task>();
for(ThoughtStarter_RFP__c currentTSRFP : [select Id, (select OwnerId, WhatId from Tasks where isClosed = false and Owner.UserRole.DeveloperName = 'Sales_Development') 
                                                    from ThoughtStarter_RFP__c where Id = 'a0gf1000004Z6AGAA0']){
		for(Task childRecord : currentTSRFP.Tasks){
			childRecord.Status = 'Completed';
			uTaskList.add(childRecord);
			// break;
		}
}

if (!uTaskList.isEmpty()) {
	update uTaskList;
}
```

2018-12-18 14:47:24
```java
System.schedule('BatchCalculateAccountValueJob14', '0 0 0 ? * 2/14', new BatchUpdateLocalAccountCBSSScheduledJob());
```

2018-12-20 12:15:55
```java
System.debug(LoggingLevel.INFO, '*** URL.getSalesforceBaseUrl(): ' + URL.getSalesforceBaseUrl());
System.debug(LoggingLevel.INFO, '*** URL.get: ' + URL.getCurrentRequestUrl());
```

2018-12-20 12:26:03
```java
System.debug(LoggingLevel.INFO, '*** URL.getSalesforceBaseUrl(): ' + URL.getSalesforceBaseUrl());
System.debug(LoggingLevel.INFO, '*** URL.get: ' + URL.getCurrentRequestUrl());
System.debug(LoggingLevel.INFO, '*** URL.get: ' + URL.Url.getOrgDomainUrl());
```

2018-12-20 12:26:17
```java
System.debug(LoggingLevel.INFO, '*** URL.getSalesforceBaseUrl(): ' + URL.getSalesforceBaseUrl());
System.debug(LoggingLevel.INFO, '*** URL.get: ' + URL.getCurrentRequestUrl());
System.debug(LoggingLevel.INFO, '*** URL.get: ' + URL.getOrgDomainUrl());
```

2018-12-20 14:34:48
```java
Datetime currentTime = system.now();
System.debug(LoggingLevel.INFO, '*** currentTime: ' + currentTime);
System.debug(LoggingLevel.INFO, '*** currentTime.formatGmt('YYYY-MM-DDThh:mm:ssZ'): ' + currentTime.formatGmt('YYYY-MM-DDThh:mm:ssZ'));
```

2018-12-20 14:35:08
```java
Datetime currentTime = system.now();
System.debug(LoggingLevel.INFO, '*** currentTime: ' + currentTime);
System.debug(currentTime.formatGmt('YYYY-MM-DDThh:mm:ssZ'));
```

2018-12-20 14:36:29
```java
Datetime currentTime = system.now();
System.debug(LoggingLevel.INFO, '*** currentTime: ' + currentTime);
System.debug(LoggingLevel.INFO, '*** Datetime.now(): ' + Datetime.now());
System.debug(currentTime.formatGmt('YYYY-MM-DDThh:mm:ssZ'));
```

2018-12-20 14:39:11
```java
Datetime currentTime = system.now();
System.debug(LoggingLevel.INFO, '*** currentTime: ' + currentTime);
System.debug(LoggingLevel.INFO, '*** Datetime.now(): ' + Datetime.now());
System.debug(currentTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
```

2018-12-20 14:43:43
```java
String currentDatetimeFormat = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

String queryStatement = 'SELECT Id FROM Account WHERE LastModifiedDate <=: currentDatetimeFormat limit 50';
List<Account> listAccts = Database.query(queryStatement);
System.debug(LoggingLevel.INFO, '*** listAccts: ' + listAccts);
```

2018-12-20 14:50:11
```java
String currentDatetimeFormat = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

String queryStatement = 'SELECT Id FROM Account WHERE LastModifiedDate <: currentDatetimeFormat limit 50';
List<Account> listAccts = Database.query(queryStatement);
System.debug(LoggingLevel.INFO, '*** listAccts: ' + listAccts);
```

2018-12-20 14:53:10
```java
Datetime dt = Datetime.now();
String queryStatement = 'SELECT Id FROM Account WHERE LastModifiedDate <: dt limit 50';
List<Account> listAccts = Database.query(queryStatement);
System.debug(LoggingLevel.INFO, '*** listAccts: ' + listAccts);
```

2018-12-20 14:53:33
```java
Datetime dt = Datetime.now();
String queryStatement = 'SELECT Id FROM Account WHERE LastModifiedDate <=: dt limit 50';
List<Account> listAccts = Database.query(queryStatement);
System.debug(LoggingLevel.INFO, '*** listAccts: ' + listAccts);
```

2018-12-25 12:45:32
```java
BatchCloseExpiredLocalOpps b = new BatchCloseExpiredLocalOpps();

        Database.executeBatch(b, 80);
```

2018-12-25 12:47:38
```java
 Account acc = null;
        update acc;
```

2018-12-25 14:37:17
```java
private Date dateToday;
private Set<String> oppStagesToIgnore;   
private String query;
private Date oldDate;
dateToday = Date.today();
OppUpdateLastModifiedNumberOfDays__c numberOfDays = OppUpdateLastModifiedNumberOfDays__c.getInstance('StandardDaysCount');
if(numberOfDays != null) {
    Integer days = Integer.valueOf(numberOfDays.Number_of_Days__c);
    oldDate = dateToday.addDays(-days);
} else {
    oldDate = dateToday.addDays(-90);
}

oppStagesToIgnore = new Set<String>{'Closed Won', 'Closed Lost', 'Client Approved'};

query = 'SELECT Id,StageName, Lost_Reason__c FROM Opportunity '
        +' WHERE (Opportunity_Expiration_Date__c < :dateToday OR LastModifiedDate < :oldDate) '
        +' AND StageName NOT IN :oppStagesToIgnore AND RecordType.Name = \'Local\'';


List<Opportunity> listOpps = new List<Opportunity>();
for(Opportunity opp : Datebase.query(query)){
	opp.StageName = 'Closed Lost';
    opp.CloseDate = Date.Today();
	opp.Lost_Reason__c = 'Opportunity Expired';
	listOpps.add(opp);
}

List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
Database.SaveResult[] dbSaveResult = Database.update(listOpps, false);
xoExceptionList.addAll(ExceptionUtility.consumeException(dbSaveResult));
```

2018-12-25 14:38:16
```java
private Date dateToday;
private Set<String> oppStagesToIgnore;   
private String query;
private Date oldDate;
dateToday = Date.today();
OppUpdateLastModifiedNumberOfDays__c numberOfDays = OppUpdateLastModifiedNumberOfDays__c.getInstance('StandardDaysCount');
if(numberOfDays != null) {
    Integer days = Integer.valueOf(numberOfDays.Number_of_Days__c);
    oldDate = dateToday.addDays(-days);
} else {
    oldDate = dateToday.addDays(-90);
}

oppStagesToIgnore = new Set<String>{'Closed Won', 'Closed Lost', 'Client Approved'};

query = 'SELECT Id,StageName, Lost_Reason__c FROM Opportunity '
        +' WHERE (Opportunity_Expiration_Date__c < :dateToday OR LastModifiedDate < :oldDate) '
        +' AND StageName NOT IN :oppStagesToIgnore AND RecordType.Name = \'Local\'';


List<Opportunity> listOpps = new List<Opportunity>();
for(Opportunity opp : Database.query(query)){
	opp.StageName = 'Closed Lost';
    opp.CloseDate = Date.Today();
	opp.Lost_Reason__c = 'Opportunity Expired';
	listOpps.add(opp);
}

List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
Database.SaveResult[] dbSaveResult = Database.update(listOpps, false);
xoExceptionList.addAll(ExceptionUtility.consumeException(dbSaveResult));





```

2018-12-25 14:51:56
```java
private Date dateToday;
private Set<String> oppStagesToIgnore;   
private String query;
private Date oldDate;
dateToday = Date.today();
OppUpdateLastModifiedNumberOfDays__c numberOfDays = OppUpdateLastModifiedNumberOfDays__c.getInstance('StandardDaysCount');
if(numberOfDays != null) {
    Integer days = Integer.valueOf(numberOfDays.Number_of_Days__c);
    oldDate = dateToday.addDays(-days);
} else {
    oldDate = dateToday.addDays(-90);
}

oppStagesToIgnore = new Set<String>{'Closed Won', 'Closed Lost', 'Client Approved'};

query = 'SELECT Id,StageName, Lost_Reason__c FROM Opportunity '
        +' WHERE (Opportunity_Expiration_Date__c < :dateToday OR LastModifiedDate < :oldDate) '
        +' AND StageName NOT IN :oppStagesToIgnore AND RecordType.Name = \'Local\'';


List<Opportunity> listOpps = new List<Opportunity>();
for(Opportunity opp : Database.query(query)){
	opp.StageName = 'Closed Lost';
    opp.CloseDate = Date.Today();
	opp.Lost_Reason__c = 'Opportunity Expired';
	listOpps.add(opp);
}

List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
Database.SaveResult[] dbSaveResult = Database.update(listOpps, false);
xoExceptionList.addAll(ExceptionUtility.consumeException(dbSaveResult));

```

2018-12-25 15:14:34
```java
Set<Integer> set1= new Set<Id>{1};
System.debug(LoggingLevel.INFO, '*** set1.contains(2): ' + set1.contains(2));
```

2018-12-25 15:14:46
```java
Set<Integer> set1= new Set<Integer>{1};
System.debug(LoggingLevel.INFO, '*** set1.contains(2): ' + set1.contains(2));
```

2018-12-25 15:14:58
```java
Set<Integer> set1= new Set<Integer>{1};
System.debug(LoggingLevel.INFO, '*** set1.contains(2): ' + set1.contains(null));
```

2018-12-25 15:16:25
```java
private Date dateToday;
private Set<String> oppStagesToIgnore;   
private String query;
private Date oldDate;
dateToday = Date.today();
OppUpdateLastModifiedNumberOfDays__c numberOfDays = OppUpdateLastModifiedNumberOfDays__c.getInstance('StandardDaysCount');
if(numberOfDays != null) {
    Integer days = Integer.valueOf(numberOfDays.Number_of_Days__c);
    oldDate = dateToday.addDays(-days);
} else {
    oldDate = dateToday.addDays(-90);
}

oppStagesToIgnore = new Set<String>{'Closed Won', 'Closed Lost', 'Client Approved'};

query = 'SELECT Id,StageName, Lost_Reason__c FROM Opportunity '
        +' WHERE (Opportunity_Expiration_Date__c < :dateToday OR LastModifiedDate < :oldDate) '
        +' AND StageName NOT IN :oppStagesToIgnore AND RecordType.Name = \'Local\'';


List<Opportunity> listOpps = new List<Opportunity>();
for(Opportunity opp : Database.query(query)){
	opp.StageName = 'Closed Lost';
    opp.CloseDate = Date.Today();
	opp.Lost_Reason__c = 'Opportunity Expired';
	listOpps.add(opp);
}

List<XO_Exception__c> xoExceptionList = new List<XO_Exception__c>();
Database.SaveResult[] dbSaveResult = Database.update(listOpps, false);
xoExceptionList.addAll(ExceptionUtility.consumeException(dbSaveResult));

```

2018-12-27 16:11:55
```java
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE 
                                                    //zqu__Quote__c IN ('a2829000000VMKV') AND 
													zqu__ChargeNumber__c IN ('C-01508755')
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:12:48
```java
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN ('C-01508755')
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:15:53
```java
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN ('C-01508755',null)
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}

```

2018-12-27 16:17:38
```java
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__Quote__c IN ('a2829000000VMKV',null) 
                                                    AND 
                                                    zqu__ChargeNumber__c IN ('C-01508755')
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:20:18
```java
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN (null)
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:20:36
```java
Set<String> set1 = new Set<String>();
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN: set1
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:22:41
```java
Set<String> set1 = new Set<String>{'C-01508755'};
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN: set1
                                                    AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    AND Sent_to_ZBilling__c = TRUE]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:26:05
```java
Set<String> set1 = new Set<String>{'C-01508755'};
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN: set1
                                                    //AND Inventory_Freed_By_Cancellation__c = TRUE 
                                                    //AND Sent_to_ZBilling__c = TRUE
                                                    ]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
```

2018-12-27 16:26:21
```java
Set<String> set1 = new Set<String>{'C-01508755'};
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN: set1
                                                    
                                                    ]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-27 16:30:07
```java
Set<String> set1 = new Set<String>{'C-01508755'};
for(zqu__QuoteChargeDetail__c qcdRec : [SELECT Id, zqu__ChargeNumber__c, zqu__ProductRatePlan__c, zqu__Quote__r.zqu__Opportunity__c 
                                                    FROM zqu__QuoteChargeDetail__c 
                                                    WHERE zqu__ChargeNumber__c IN: set1
                                                    AND zqu__OriginalRatePlanId__c IN (null)
                                                    
                                                    ]){
	System.debug(LoggingLevel.INFO, '*** qcdRec: ' + qcdRec);
}
```

2018-12-28 16:32:30
```java
delete [SELECT Id FROM zqu__QuoteChargeDetail__c WHERE ZQU__QUOTE__C = 'a2829000000VME3AAO' LIMIT 9999];
```

2018-12-28 16:37:13
```java
delete [SELECT Id FROM zqu__QuoteChargeDetail__c WHERE ZQU__QUOTE__C = 'a2829000000VME3AAO' LIMIT 9999];
```

2018-12-28 16:38:39
```java
delete [SELECT Id FROM zqu__QuoteChargeDetail__c WHERE ZQU__QUOTE__C = 'a2829000000VME3AAO' LIMIT 9999];
```

2018-12-29 16:52:46
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG' LIMIT 10000];
```

2018-12-29 16:54:32
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2018-12-29 16:57:57
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2018-12-29 16:59:11
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 10:47:22
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 10:48:40
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 10:51:21
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 10:53:54
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 10:57:50
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:00:03
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:02:57
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:03:48
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:08:39
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:24:25
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:34:04
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:35:08
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:40:20
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:44:16
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 11:47:33
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 12:22:49
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-02 12:23:05
```java
delete [SELECT Id from zqu__QuoteChargeDetail__c where zqu__ChargeNumber__c = null and (zqu__Quote__c = 'a2829000000VME3AAO' OR zqu__Quote__c = 'a2829000000VJnhAAG') LIMIT 10000];
```

2019-01-17 15:16:12
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0015600000BYUlb';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 11:45:22
```java
//create Inbound case
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 11:46:09
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '00Gf1000002nrpi';
	onboardingCase.AccountId = '0012900000SPtg1';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-01-24 11:48:06
```java
//create non-queue Onboarding case
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '005f100000HJIgA';
	onboardingCase.AccountId = '0012900000SPtg1';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-01-24 11:48:28
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 11:50:00
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 11:53:25
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 12:25:58
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0012900000SPtg1';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Direct Mail';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2019-01-24 12:33:22
```java
//create Inbound case
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 14:27:38
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 14:31:54
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 14:32:01
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 14:34:25
```java
//UAT
Id acctId = '0012900000SPtg1';
Id assetCollectionQueueId = '00Gf1000002rsH2';
Id inboundQueueId = '00Gf1000002rsH3';

delete [SELECT Id FROM Case WHERE AccountId =: acctId];
```

2019-01-24 14:34:41
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '005f100000HJIgA';
	onboardingCase.AccountId = '0012900000SPtg1';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-01-24 14:35:18
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 14:41:34
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 18:03:44
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 18:05:07
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0012900000SPtg1';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Internet';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2019-01-24 18:06:44
```java

Id acctId = '0012900000SPtg1';
Id assetCollectionQueueId = '00Gf1000002rsH2';
Id inboundQueueId = '00Gf1000002rsH3';

delete [SELECT Id FROM Case WHERE AccountId =: acctId];
```

2019-01-24 18:07:02
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0012900000SPtg1';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Internet';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2019-01-24 18:09:14
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0012900000SPtg1';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Direct Mail';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2019-01-24 18:09:58
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 18:10:43
```java

Id acctId = '0012900000SPtg1';
Id assetCollectionQueueId = '00Gf1000002rsH2';
Id inboundQueueId = '00Gf1000002rsH3';

delete [SELECT Id FROM Case WHERE AccountId =: acctId];
```

2019-01-24 18:11:00
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '005f100000HJIgA';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-24 18:13:06
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-25 11:16:53
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '00Gf1000002nrpi';
	onboardingCase.AccountId = '0012900000SPtg1';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-01-25 11:21:18
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-25 11:23:01
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case assetCollectionCase = new Case();
	assetCollectionCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Collection').getRecordTypeId();
	assetCollectionCase.OwnerId = '00Gf1000002rsH2';
	assetCollectionCase.AccountId = '0012900000SPtg1';
	assetCollectionCase.Status = 'New';
	assetCollectionCase.Reason = 'Asset Collection';
	assetCollectionCase.Origin = 'Auto-Generated';
	assetCollectionCase.Product_Type__c = 'Internet';
	assetCollectionCase.Term_Start_Date__c = Date.today();
	listCases.add(assetCollectionCase);
}
insert listCases;
```

2019-01-28 17:10:58
```java
delete [SELECT Id FROM Case WHERE AccountId = '0015600000BYWzv'];
```

2019-01-28 17:11:45
```java
delete [SELECT Id FROM Case WHERE AccountId = '0015600000BYWzv'];
```

2019-01-28 17:15:43
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '001j000000h5WN9';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-28 17:17:55
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	//inboundCase.AccountId = '001j000000h5WN9';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-28 17:19:34
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '001j000000h5WN9';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 17:05:10
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '001f100001Ttlh8';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 17:10:20
```java
for(Case recentOpenedCase : [SELECT Id, RecordType.Name, OwnerId, AccountId, Product_Type__c
                                    FROM Case 
                                    WHERE IsClosed = FALSE AND 
                                    
                                    AccountId = '001f100001Ttlh8' AND 
                                    Owner.Type = 'User' AND
                                    Owner.IsActive = TRUE
                                    ORDER BY LastModifiedDate DESC]){

          System.debug(LoggingLevel.INFO, '*** recentOpenedCase: ' + recentOpenedCase);
      }
```

2019-01-29 17:12:06
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '001f100001Ttlh8';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 19:00:47
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 19:03:18
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 19:25:53
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-01-29 19:29:50
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-02-03 11:19:58
```java
Id acctId = '0012900000SPtg1';
Id assetCollectionQueueId = '00Gf1000002rsH2';
Id inboundQueueId = '00Gf1000002rsH3';

delete [SELECT Id FROM Case WHERE AccountId =: acctId];
```

2019-02-03 11:26:32
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-02-03 11:31:46
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case inboundCase = new Case();
	inboundCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound').getRecordTypeId();
	inboundCase.OwnerId = '00Gf1000002rsH3';
	inboundCase.AccountId = '0012900000SPtg1';
	inboundCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	inboundCase.Origin = 'Auto-Generated';
	listCases.add(inboundCase);
}
insert listCases;
```

2019-02-15 15:29:28
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '00G56000001TalN';
	//onboardingCase.OwnerId = '00Gf1000002nrpi';
	onboardingCase.AccountId = '0015600000BYUlb';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-02-15 15:29:54
```java
List<Case> listCases = new List<Case>();
for(Integer i =0; i < 1; i++){
	Case onboardingCase = new Case();
	onboardingCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('2 - Onboarding').getRecordTypeId();
	onboardingCase.OwnerId = '00G56000001TalN';
	//onboardingCase.OwnerId = '00Gf1000002nrpi';
	onboardingCase.AccountId = '0015600000BYUlb';
	onboardingCase.Status = 'New';
	//inboundCase.Reason = 'Asset Collection';
	onboardingCase.Origin = 'Auto-Generated';
	listCases.add(onboardingCase);
}
insert listCases;
```

2019-03-05 02:49:46
```java

Account masterAcct = [SELECT Id, Name FROM Account WHERE Id = '0012900000TUa2d' LIMIT 1];
Account mergeAcct = [SELECT Id, Name FROM Account WHERE Id = '0012900000TUZxYAAX' LIMIT 1];


merge masterAcct mergeAcct;
```

2019-03-18 22:25:46
```java
Set<Id> setOppyIds = new Set<Id>{'00629000007eEU0'};
Set<Id> setAcctToOnboardingIDs = new Set<Id>{'0012900000SPYsAAAX'};
 Date lastYearDate = Date.today().addYears(-1);

String spcQueryString = 'SELECT Id,Zuora__Subscription__c, Zuora__Subscription__r.Zuora__TermStartDate__c, '
                                        + 'Zuora__Subscription__r.Zuora__TermEndDate__c, Zuora__Subscription__r.Zuora__Status__c, '
                                        + 'Zuora__Subscription__r.Zuora__Account__c FROM Zuora__SubscriptionProductCharge__c '
                                        + 'WHERE Zuora__Subscription__r.Zuora__Account__c IN: setAcctToOnboardingIDs '
                                        //Since we create Onboarding case after Opportunity stage is Closed Won,
                                        //we need to exclude the new subscription for current Opportunity  
                                        + 'AND Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__c NOT IN: setOppyIds '
                                        + 'AND Zuora__Subscription__r.Zuora__TermEndDate__c >: lastYearDate ';

                                        List<Zuora__SubscriptionProductCharge__c> subscriptionPCList = Database.query(spcQueryString);
                                        System.debug(LoggingLevel.INFO, '*** subscriptionPCList: ' + subscriptionPCList);
```

2019-03-18 22:26:11
```java
Set<Id> setOppyIds = new Set<Id>{'00629000007eEU0'};
Set<Id> setAcctToOnboardingIDs = new Set<Id>{'0012900000SPYsAAAX'};
 Date lastYearDate = Date.today().addYears(-1);

String spcQueryString = 'SELECT Id,Zuora__Subscription__c, Zuora__Subscription__r.Zuora__TermStartDate__c, '
                                        + 'Zuora__Subscription__r.Zuora__TermEndDate__c, Zuora__Subscription__r.Zuora__Status__c, '
                                        + 'Zuora__Subscription__r.Zuora__Account__c FROM Zuora__SubscriptionProductCharge__c '
                                        + 'WHERE Zuora__Subscription__r.Zuora__Account__c IN: setAcctToOnboardingIDs '
                                        //Since we create Onboarding case after Opportunity stage is Closed Won,
                                        //we need to exclude the new subscription for current Opportunity  
                                        //+ 'AND Zuora__Subscription__r.Latest_Quote__r.zqu__Opportunity__c NOT IN: setOppyIds '
                                        + 'AND Zuora__Subscription__r.Zuora__TermEndDate__c >: lastYearDate ';

                                        List<Zuora__SubscriptionProductCharge__c> subscriptionPCList = Database.query(spcQueryString);
                                        System.debug(LoggingLevel.INFO, '*** subscriptionPCList: ' + subscriptionPCList);
```

2019-04-11 04:27:56
```java
Case currentCase = [SELECT Id,ContactId,Case_Owner_Manager_Email__c,Case_Owner_Manager_Name__c FROM Case WHERE Id = '5002900000ABLmX' limit 1];
Messaging.SingleEmailMessage closeCompletedCaseSurveyEmail = EmailUtility.generateEmail('00Xf10000012nvk', currentCase.Id, currentCase.ContactId, true, null, currentCase.Case_Owner_Manager_Email__c, currentCase.Case_Owner_Manager_Name__c);
List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
emailList.add(closeCompletedCaseSurveyEmail);
List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList, false);
System.debug(LoggingLevel.INFO, '*** results: ' + results);
```

2019-04-11 04:31:23
```java
Case currentCase = [SELECT Id,ContactId,Case_Owner_Manager_Email__c,Case_Owner_Manager_Name__c FROM Case WHERE Id = '5002900000ABLmX' limit 1];
Messaging.SingleEmailMessage closeCompletedCaseSurveyEmail = EmailUtility.generateEmail('00Xf10000012nvk', currentCase.Id, currentCase.ContactId, true, null, currentCase.Case_Owner_Manager_Email__c, currentCase.Case_Owner_Manager_Name__c);
List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
emailList.add(closeCompletedCaseSurveyEmail);
List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList, false);
System.debug(LoggingLevel.INFO, '*** results: ' + results);
```

