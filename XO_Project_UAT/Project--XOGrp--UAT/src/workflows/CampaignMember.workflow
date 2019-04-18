<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_AE_Campaign_Member</fullName>
        <ccEmails>hotprospects@xogrp.com.uat</ccEmails>
        <ccEmails>kfreeman@xogrp.com</ccEmails>
        <description>Notify AE Campaign Member</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <recipient>rali@xogrp.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@xogrp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Template/Campaign_Member_Paid_Media</template>
    </alerts>
    <alerts>
        <fullName>Notify_AE_Campaign_Member2</fullName>
        <ccEmails>hotprospects@xogrp.com</ccEmails>
        <description>Notify AE Campaign Member 2</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <senderAddress>noreply@xogrp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Template/Campaign_Member_Paid_Media</template>
    </alerts>
    <alerts>
        <fullName>Notify_AE_Campaign_Member_3delay</fullName>
        <ccEmails>hotprospects@xogrp.com</ccEmails>
        <description>Notify AE Campaign Member-3delay</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <senderAddress>noreply@xogrp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Template/Campaign_Member_Paid_Media</template>
    </alerts>
    <alerts>
        <fullName>Paid_Media_Notification</fullName>
        <ccEmails>hotprospects@xogrp.com.uat</ccEmails>
        <ccEmails>paidmediaalerts@xogrp.com.uat</ccEmails>
        <ccEmails>kfreeman@xogrp.com</ccEmails>
        <description>Paid Media Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>rali@xogrp.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@xogrp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Template/Campaign_Member_Paid_Media</template>
    </alerts>
    <rules>
        <fullName>CampaignMember Notification</fullName>
        <actions>
            <name>Notify_AE_Campaign_Member</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CSP-1939 - When a CampaignMember is created for a Lead or Contact that is associated to a Campaign which has the flag notify AE checked then an email should send.
Updated for SS-5437</description>
        <formula>AND(   Campaign.Notify_Sales_Team__c = True,     OR(         DateValue(CreatedDate) &gt; DateValue(Lead.CreatedDate),        CreatedDate  &lt;&gt;  Contact.CreatedDate     ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CampaignMember Notification 3min Delay</fullName>
        <active>true</active>
        <description>CSP-1939 - When a CampaignMember is created for a Lead or Contact that is associated to a Campaign which has the flag notify AE checked then an email should send.
Updated for SS-5437</description>
        <formula>AND(
  Campaign.Notify_Sales_Team__c = True,
    OR( 
       DateValue(CreatedDate) &gt; DateValue(Lead.CreatedDate),
       CreatedDate  &lt;&gt;  Contact.CreatedDate
    )
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_AE_Campaign_Member_3delay</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CampaignMember.Delay_time_03__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CampaignMember Notification Scheduled Job</fullName>
        <actions>
            <name>Notify_AE_Campaign_Member</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>CSP-1939 - When a CampaignMember is created for a Lead or Contact that is associated to a Campaign which has the flag notify AE checked then an email should send.
Updated for SS-5437</description>
        <formula>AND(
  Campaign.Notify_Sales_Team__c = True,
DelayCampaignMemNotification__c = True,
    OR( 
       DateValue(CreatedDate) &gt; DateValue(Lead.CreatedDate),
       CreatedDate  &lt;&gt;  Contact.CreatedDate
    )
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Paid Media Notification</fullName>
        <actions>
            <name>Paid_Media_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Campaign.Type, &apos;Paid Media&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
