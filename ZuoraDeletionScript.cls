///////////////////////////////
///													///
///		Zuora Deletion Script ///
///													///
///////////////////////////////

String zObjectName = 'ProductRatePlanCharge'; //set the Object name which you need to insert records
String staticResourceName = 'ZuoraDeleteCSV'; //name of csv file
List<String> reportRecipients = new String[]{'asu@xogrp.com','mzhao@xogrp.com','nwu@xogrp.com','rali@xogrp.com'}; //receipients
Zuora.zApi zapi = new Zuora.zapi();
zapi.zlogin();

// retrieve csv file
StaticResource delFile = [select id, name, body from StaticResource where name =: staticResourceName limit 1];
String contentCsv = delFile.body.toString();

Set<String> IDSets = new Set<String>();
List<String> fieldList = new List<String>();

Integer num =0;

for(String str : contentCsv.split('\n')){
	String[] templist = str.trim().split(',');
	if(num > 0){
		IDSets.add(templist[0].trim());
	}
	num++;
}

List<String> sList = new List<String>();
sList.addAll(IDSets);
System.debug(LoggingLevel.INFO, '*** sList: ' + sList);

Integer count = 0;
Integer countTotal=0;
Integer packSize = 40;
List<String> tempList = new List<String>();
List<String> resList = new List<String>();
resList.add('Deleted Id,Success,Errors');

for(String str : sList){
	countTotal++;
	count++;
	tempList.add(str.trim());
	if(count == packSize || countTotal == sList.size()){
		count = 0;
		System.debug(LoggingLevel.INFO, '*** tempList: ' + tempList.size());
		List<Zuora.zApi.DeleteResult> delList = zapi.zdelete(zObjectName, tempList);
		
		tempList = new List<String>();
	
		for(Zuora.zApi.DeleteResult dr : delList){

			if (dr.Success){
				resList.add(dr.id + ',' + dr.success);
			}
			else{
				String err = '';
				for (Zuora.zObject error : dr.errors) {
					String errorCode = (String)error.getValue('Code');
					String message = (String)error.getValue('Message');
					err = errorCode+',' + message;
				}
				resList.add(dr.id + ',' + dr.success + ',' + err);
			}
		}
	}
}

sendReports(reportRecipients, resList);

// send reports
public void sendReports(List<String> recipientList, List<string> reports){
	
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	mail.setToAddresses(recipientList);
	mail.setSubject('Zuora Data Deletion Report');
	mail.setPlainTextBody('Hi, Here is the Zuora Data Deletion Report');

	List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
	Messaging.EmailFileAttachment scr = new Messaging.EmailFileAttachment();
	scr.setFileName('ZuoraDataDeletionReport.csv');
	Blob reportsBlob = Blob.valueOf(String.Join(reports, '\n'));
	scr.setBody(reportsBlob);
	fileAttachments.add(scr);
	
	mail.setFileAttachments(fileAttachments);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

}