public with sharing class TestDataFactory {
    public static Quota__c getQuota(Id quotaId) {
        return new Quota__c(
            Quota__c = quotaId
        );
    }

    public static User getUser(String alias, Id managerId, Id profileId) {
    	return new User(
        	FirstName         = 'Test',
        	LastName          = 'User',
        	Alias             = alias,
        	Email             = 'testuser@xogrp.com',
        	Username          = alias + '@asdasfaf.com',
        	TimeZoneSidKey    = 'America/Panama',
        	LocaleSidKey      = 'en_US',
        	EmailEncodingKey  = 'UTF-8',
        	ProfileId         = profileId,
        	LanguageLocaleKey = 'en_US',
        	ManagerId         = managerId,
        	SalesRepId__c     = '12345'
        );
    }
}