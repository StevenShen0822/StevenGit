global class BatchReminderForCancelCase implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
    public String query;
    public String emailTemplateId;
    private static final Integer endDays = Integer.valueOf(Label.Reminder_For_Cancel_Case_Days);
    public List<OrgWideEmailAddress> listOrgWideEmail;
    public List<User> listQueueMembers = new list<User>();
    private static final String CASE_QUERY = ' SELECT Id, CreatedDate, OwnerId, Num_Of_Days_Since_Created_Day__c FROM Case WHERE Save_For_Later__c = true '
                                                    + ' AND RecordType.Name = \'1 - Cancels\' '
                                                    + ' AND IsClosed = false '
                                                    + ' AND Num_Of_Days_Since_Created_Day__c <=: endDays '
                                                    + ' AND Num_Of_Days_Since_Created_Day__c != 0 ';

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    global BatchReminderForCancelCase() {
        String senderAddress = '';
        String sendToQueueName = '';
        String emailTemplateName = '';
        this.query = CASE_QUERY;

        // Prepare date for send  email start
        // Get send email info from Custeom Metadata Types, sush as sender address, email template name, queque name 
        List<Send_Email_Setting__mdt> listSendEmailSetting = [SELECT Sender_Address__c, Send_To_Queue_API_Name__c, Email_Template_API_Name__c
                                                              FROM Send_Email_Setting__mdt
                                                              WHERE DeveloperName = 'Reminder_For_Cancel_Case'
                                                              AND IsActive__c = TRUE limit 1]; 
        if(!listSendEmailSetting.isEmpty()){
            senderAddress = listSendEmailSetting[0].Sender_Address__c;
            sendToQueueName = listSendEmailSetting[0].Send_To_Queue_API_Name__c;
            emailTemplateName = listSendEmailSetting[0].Email_Template_API_Name__c;
        } 
        //Get Email Template id 
        for (EmailTemplate currentET : [SELECT Id, Name, DeveloperName FROM EmailTemplate 
                                        WHERE DeveloperName =: emailTemplateName]) {
            emailTemplateId = currentET.Id;
        }

        //Get Org Wide Email Address object from sender Address
        listOrgWideEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress 
                                  WHERE Address =: senderAddress limit 1];
        
        //Get queue memeber list from queque name                           
        for(user currentUser : [SELECT Id, name, username FROM user WHERE IsActive = TRUE 
                                     AND Id IN (SELECT userOrGroupId FROM groupmember WHERE group.DeveloperName =: sendToQueueName)]) {

           listQueueMembers.add(currentUser);
        }
        //Prepare data for send email end
        System.debug(LoggingLevel.INFO, '*** listOrgWideEmail: ' + listOrgWideEmail);
        System.debug(LoggingLevel.INFO, '*** listQueueMembers: ' + listQueueMembers);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, '*** query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Case> scope) {
        if(!listOrgWideEmail.isEmpty() && String.isNotBlank(emailTemplateId)) {
            CaseService.sendNotifications(scope, listOrgWideEmail, listQueueMembers, emailTemplateId, endDays);
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}