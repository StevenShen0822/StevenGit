public with sharing class EmailUtility {
  
  private static final String SF_BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();

  public static Messaging.SingleEmailMessage createTwoDayContractEmail(Opportunity currentOpp) {
    Messaging.SingleEmailMessage twoDayEmail = new Messaging.SingleEmailMessage();

    String subtitle = Label.Echo_Sign_Notification_Subtitle;
    String title = Label.Echo_Sign_Two_Day_Title;
    String bodyText = Label.Echo_Sign_Two_Day_Body.replace('{OPPLINK}', '<a href="' + SF_BASE_URL + '/' + currentOpp.Id + '">here</a>');

    twoDayEmail.setSubject(Label.Echo_Sign_Two_Day_Subject);
    twoDayEmail.setHTMLBody(createEmailBody(subtitle, title, bodyText));
    twoDayEmail.setTargetObjectId(currentOpp.OwnerId);
    twoDayEmail.saveAsActivity = false;

    return twoDayEmail;
  }

  public static Messaging.SingleEmailMessage createExpiredContractEmail(Opportunity currentOpp) {
    Messaging.SingleEmailMessage expiredEmail = new Messaging.SingleEmailMessage();

    String subtitle = Label.Echo_Sign_Notification_Subtitle;
    String title = Label.Echo_Sign_Expired_Title;
    String bodyText = Label.Echo_Sign_Expired_Body.replace('{OPPLINK}', '<a href="' + SF_BASE_URL + '/' + currentOpp.Id + '" target="_blank">here</a>');

    expiredEmail.setSubject(Label.Echo_Sign_Expired_Subject);
    expiredEmail.setHTMLBody(createEmailBody(subtitle, title, bodyText));
    expiredEmail.setTargetObjectId(currentOpp.OwnerId);
    expiredEmail.saveAsActivity = false;

    return expiredEmail;
  }

  public static Messaging.SingleEmailMessage createWaitListOnDeckEmail(Inventory__c currentInventory) {

    String formattedDate = currentInventory.Inventory_Hold_Expiry_Date__c.Month() + '/' + currentInventory.Inventory_Hold_Expiry_Date__c.Day() + '/' + currentInventory.Inventory_Hold_Expiry_Date__c.Year();

    Messaging.SingleEmailMessage onDeckEmail = new Messaging.SingleEmailMessage();

    String subtitle = Label.Waitlist_Notifications_Subtitle;
    String title = Label.Waitlist_Move_On_Deck_Notifications_Title;
    // csp-1992
    String bodyText = '<a href="' + SF_BASE_URL + '/' + currentInventory.Waitlist_Account__c + '">' + currentInventory.Waitlist_Account__r.Name + '</a>' + ' has moved to the top of the list for ' + 
                      currentInventory.Product_Rate_Plan__r.zqu__Product__r.Name + ' - ' + currentInventory.Product_Rate_Plan__r.Name + '.' + 
                      '<br/><br/>They will be available to sell until ' + formattedDate +
                      ' to create a quote, after which the next Account on the waitlist will be notified.';

    onDeckEmail.setSubject(Label.Waitlist_Move_On_Deck_Notifications_Subject);
    onDeckEmail.setHTMLBody(createEmailBody(subtitle, title, bodyText));
    onDeckEmail.setTargetObjectId(currentInventory.Waitlist_Account__r.OwnerId);
    onDeckEmail.saveAsActivity = false;

    return onDeckEmail;
  }

  public static String createEmailBody(String subtitle, String title, String bodyText) {
    String htmlBody;

    htmlBody = '<div style="text-align: center; background-color: grey; padding: 20px 0px;">'
                + '<div style="display: inline-block; width: 70%; background-color: white; border-radius: 4px 4px 4px 4px; -moz-border-radius: 4px 4px 4px 4px; -webkit-border-radius: 4px 4px 4px 4px;">'
                  /* HEADER SECTION */
                  + '<div style="background-color: black; padding: 20px 10px 15px 20px; border-radius: 4px 4px 0px 0px; -moz-border-radius: 4px 4px 0px 0px; -webkit-border-radius: 4px 4px 0px 0px;">'
                    /* SUB TITLE SECTION */
                    + '<div style="color: white; text-align: left; letter-spacing: 1px; font-family: sans-serif; font-weight: 100;">'
                      + subtitle
                    + '</div>'
                    /* TITLE SECTION */
                    + '<div style="color: rgb(178,204,133); text-align: left; font-size: 24px; letter-spacing: 0.75px; font-family: sans-serif;">'
                      + title
                    + '</div>'
                  + '</div>'
                /* BODY SECTION */
                + '<div style="text-align: left; padding: 20px;">'
                  + bodyText
                + '</div>'
              + '</div>'
            + '</div>';

    System.debug(htmlBody);
    return htmlBody;
  }

  public static String createEmailBody(String title, String bodyText) {
    String htmlBody;

    htmlBody = '<div style="text-align: center; background-color: grey; padding: 20px 0px;">'
                + '<div style="display: inline-block; width: 70%; background-color: white; border-radius: 4px 4px 4px 4px; -moz-border-radius: 4px 4px 4px 4px; -webkit-border-radius: 4px 4px 4px 4px;">'
                  /* HEADER SECTION */
                  + '<div style="background-color: black; padding: 20px 10px 15px 20px; border-radius: 4px 4px 0px 0px; -moz-border-radius: 4px 4px 0px 0px; -webkit-border-radius: 4px 4px 0px 0px;">'
                    /* TITLE SECTION */
                    + '<div style="color: rgb(178,204,133); text-align: left; font-size: 24px; letter-spacing: 0.75px; font-family: sans-serif;">'
                      + title
                    + '</div>'
                  + '</div>'
                /* BODY SECTION */
                + '<div style="text-align: left; padding: 20px;">'
                  + bodyText
                + '</div>'
              + '</div>'
            + '</div>';

    return htmlBody;
  }

 /**
   * @purpose Create email for the live subs charge that the related charge is removed from zuora
   * @author Tony
   * @date   2018-10-19
   * @param  String  userIdString    receipt user Id
   * @param  Map<String,list<Live_Subscription_Product_and_Charge__c>> mapSubZuoraIdLiveCharges  Subscription ZuoraId as key,and live charge as values
   * @return list<Messaging.SingleEmailMessage>  listEmails
   */
  public static List<Messaging.SingleEmailMessage> createLiveChargeEmail(String userIdString, 
                      Map<String,List<Live_Subscription_Product_and_Charge__c>> mapSubZuoraIdLiveCharges) {

   List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();

    for(String subZuoraId : mapSubZuoraIdLiveCharges.keySet()) {
      if(!mapSubZuoraIdLiveCharges.get(subZuoraId).isEmpty()) {

        String liveSubName = mapSubZuoraIdLiveCharges.get(subZuoraId)[0].Live_Subscription__r.Subscription_Name__c;
        Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
        String subjectString = liveSubName + ': Live Charges need fix';
        String emailBody = '<div>Hi</div><br />'
                     + '<div>The following charges have been removed directly in zuora. Please refer to <a href="https://wiki.xogrp.com/pages/viewpage.action?spaceKey=tw&title=Update+Live+Charge+for+removing+service+in+Zuora">'
                     + 'wiki instruction</a> to fix.</div>'
                     + '<div>Zuora Subscription link: <a href="https://www.zuora.com/apps/Subscription.do?method=view&id='+ subZuoraId +'">'+ liveSubName + '</a></div>'
                     + '<div><table cellspacing="0" border="1" cellpadding="0" >'
                     + '<tr><th align="left">Charge Num </th>'
                     + '<th align="left">Live Charge ID </th></tr>';
                                          
          for(Live_Subscription_Product_and_Charge__c liveCharge : mapSubZuoraIdLiveCharges.get(subZuoraId)) {
              emailBody += '<tr><td align="left" width="100px">'+ liveCharge.Zuora_ChargeNumber__c +'</td>'
                        +'<td align="left" width="160px">'+liveCharge.Id+'</td></tr>';
          }                            

          emailBody += '</table></div><br />';
                      
        System.debug(LoggingLevel.INFO, '*** emailBody: ' + emailBody);
        mailMessage.setTargetObjectId(Id.valueOf(userIdString));
        mailMessage.setSubject(subjectString);
        mailMessage.setHtmlBody(emailBody);
        mailMessage.setSaveAsActivity(false);
        listEmails.add(mailMessage);
      }
    }
    return listEmails;
  }

  /**
 * @purpose generate email 
 * @author  Steven
 * @date    2018-10-22
 * @param   Id  templateId              The ID of the template used to create the outgoing email.
 * @param   Id  whatId                  The salesforce record Id associated with the outgoing email.
 * @param   Id  targetObjectId          The ID of the contact, lead, or user to which the email will be sent.
 * @param   Boolean saveAsActivity      The boolean value if we need to set the email as activity record
 * @param   Id  orgWideEmailAddressId   The ID of the organization-wide email address associated with the outgoing email.
 * @param   String  replyToAddress      The replyTo email address associated with the outgoing email.
 * @param   String  senderDisplayName   The display name of sender associated with the outgoing email.
 * @return  Messaging.SingleEmailMessage 
 */
  public static Messaging.SingleEmailMessage generateEmail (Id templateId, Id whatId, Id targetObjectId, Boolean saveAsActivity, Id orgWideEmailAddressId, String replyToAddress, String senderDisplayName){
    Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
    newEmail.setTemplateId(templateId);
    newEmail.setWhatId(whatId);
    newEmail.setTargetObjectId(targetObjectId);
    newEmail.setSaveAsActivity(saveAsActivity);
    if(String.isNotBlank(orgWideEmailAddressId)){
      newEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
    }
    if(String.isNotBlank(replyToAddress)){
      newEmail.setReplyTo(replyToAddress);
    }
    if(String.isNotBlank(senderDisplayName)){
      newEmail.setSenderDisplayName(senderDisplayName);
    }

    return newEmail;
  }


  /**
   * @purpose Send email to system admin when there are too many subs(Greater than 2000) under the accounts updated owner at once
   * @author Tony
   * @date   2019-1-5
   * @param  Set<Id>  setAccountId    the account id set which need manual update the subscription sales rep and rsd
   * @param  String   userFullName    the operation user name
   */
  public static List<XO_Exception__c> sendSalesRepRSDEmail(Set<Id> setAccountId, String userFullName) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    email.setSubject('Request to adjust Subscription Sales rep and RSD rep');
    
    String emailBody = '<div>Hey</div><br />'
                      + userFullName 
                      + ' was trying to update the account owner to AM. All the accounts have been updated but need to adjust the subscription info as wiki instruction.';
    
    email.setHtmlBody(emailBody);

    // send email to the special user
    email.setTargetObjectId(Id.valueOf(Label.Live_Charge_Error_Message_User_ID));

    email.setSaveAsActivity(false);

    // Build out the Excel File Blob String
    String stringBlob = 'Account_Id\r\n';
    for(Id accId : setAccountId) {
      stringBlob += accId + '\r\n';
    }

    Messaging.EmailFileAttachment excelFile = new Messaging.EmailFileAttachment();
    excelFile.setBody(Blob.valueOf(stringBlob));
    excelFile.setFilename('Manual Update Subscription Sales Rep and RSD.xls');
    excelFile.setContentType('application/vnd.ms-excel');

    email.setFileAttachments(new List<Messaging.EmailFileAttachment>{excelFile});

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

    return ExceptionUtility.consumeException(results);
  }
}