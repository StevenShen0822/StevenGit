<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_Salessupport_to_create_a_Jira_Ticket</fullName>
        <ccEmails>salessupport@xogrp.com</ccEmails>
        <description>Email to Salessupport to create a Jira Ticket</description>
        <protected>false</protected>
        <recipients>
            <recipient>systemadmin@xogrp.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@xogrp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>System_Template/XO_Exception_Email_ZuoraTCVAndPaymentSchedule_tcvException</template>
    </alerts>
    <rules>
        <fullName>ZuoraTCVAndPaymentSchedule Errors</fullName>
        <actions>
            <name>Email_to_Salessupport_to_create_a_Jira_Ticket</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>XO_Exception__c.Type__c</field>
            <operation>equals</operation>
            <value>ZuoraTCVAndPaymentSchedule.tcvException</value>
        </criteriaItems>
        <description>This should send an email when the ZuoraTCVAndPaymentSchedule has an exception created/</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
