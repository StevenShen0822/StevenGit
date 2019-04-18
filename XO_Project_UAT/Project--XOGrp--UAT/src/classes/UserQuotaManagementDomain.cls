public with sharing class UserQuotaManagementDomain extends Domain {
    private final Map<String, Integer> MONTHS = new Map<String, Integer>{
        'January'   => 1,
        'February'  => 2,
        'March'     => 3, 
        'April'     => 4,
        'May'       => 5,
        'June'      => 6,
        'July'      => 7,
        'August'    => 8,
        'September' => 9,
        'October'   => 10,
        'November'  => 11,
        'December'  => 12
    };

    private final List<String> EXCLUDE_PROFILES = new List<String> {
        'System Support', 
        'Read Only', 
        'Service Accounts', 
        'Chatter Free User', 
        'Service Accounts Hubspot', 
        'Local Sales Data Team', 
        'Local Core Marketing', 
        'National Users', 
        'XO Read Only', 
        'Local Core Finance - ARR', 
        'Local Core Strategy Specialist', 
        ''
    };

    public override void onAfterInsert() {
        System.enqueueJob(new UserQuotaSyncQueueable((List<User>)Trigger.new, null, DMLOperation.DML_INSERT));
    }

    public override void onBeforeUpdate() {
        System.enqueueJob(new UserQuotaSyncQueueable((List<User>)Trigger.new, (Map<Id, User>)Trigger.oldMap, DMLOperation.DML_UPDATE));
    }

    /**
     * @description creates quotas for remaining months of year for a new user
     *
     * @param List<User> list of users to potentially create quotas for
     *
     * @return List<Quota__c> quotas need to be updated
    */
    public void createQuotasForNewUsers(List<User> users) {
        List<User> quotaUsers = new List<User>();
        Set<Id> managerIds = new Set<Id>();
        for(User user : users) {
            if(!this.EXCLUDE_PROFILES.contains(user.Profile.Name)) {
                quotaUsers.add(user);
                if(user.ManagerId != null) {
                    managerIds.add(user.ManagerId);
                }
            }
        }

        Map<String, Quota__c> quotasByUserId = this.getManagerQuotas(managerIds);
        
        this.createQuotasFromUsers(quotaUsers, 
                                   new Set<String>(this.getMonthsLeftInYear(Date.today())), 
                                   new Set<String>{String.valueOf(Date.today().year())}, 
                                   quotasByUserId
                                  );
    }

    /**
     * @description handle updates to user records that would need to be synced to
       corresponding quotas
     * 
     * @param List<User> users (generally Trigger.new)
     * @param Map<Id, User> (generally Trigger.oldMap)
     *
     * @return void
    */
    public void syncUserUpdatesToQuotas(List<User> users, Map<Id, User> oldUsers) {
        List<Id> deactivatedUserIds = new List<Id>();
        List<Id> changedManagerUserIds = new List<Id>();
        Set<Id> newManagerIds = new Set<Id>();

        for(User user : users) {
            if(!this.getExcludeProfileIds().contains(user.ProfileId)) {
                if(!user.IsActive && oldUsers.get(user.Id).IsActive) {
                    deactivatedUserIds.add(user.Id);
                }

                if(user.ManagerId != oldUsers.get(user.Id).ManagerId) {
                    changedManagerUserIds.add(user.Id);
                    newManagerIds.add(user.ManagerId);
                }
            }
        }

        List<Quota__c> updateQuotas = new List<Quota__c>();

        if(!deactivatedUserIds.isEmpty()) {
            updateQuotas.addAll(this.zeroQuotasForDeactivatedUsers(deactivatedUserIds));
        }

        if(!changedManagerUserIds.isEmpty()) {
            updateQuotas.addAll(this.updateQuotaManagers(changedManagerUserIds, newManagerIds));
        }
        
        update updateQuotas;
    }

    /**
     * @description update the parent quota of all open quotas when a users 
     * manager is changed
     * 
     * @param List<Id> userIds list of user ids that have changed managers
     * @param Set<Id> managerIds the set of new manager ids
    */
    private List<Quota__c> updateQuotaManagers(List<Id> userIds, Set<Id> managerIds) {
        Map<String, Quota__c> managerQuotas = this.getManagerQuotas(managerIds);
        List<Quota__c> updateQuotas = new List<Quota__c>();

        for(Quota__c q : this.getUsersOpenQuotas(userIds)) {
            q.Quota__c = (managerQuotas.containsKey(q.User__r.ManagerId + q.Product_Family__c + q.Month__c + q.Year__c) ? managerQuotas.get(q.User__r.ManagerId + q.Product_Family__c + q.Month__c + q.Year__c).Id : null);
            updateQuotas.add(q);
        }

        return updateQuotas;
    }

    /**
     * @description set all open quotas to 0 for any deactivated user
     * 
     * @param List<Id> deactivatedUserIds list of user ids that are deactivated
    */
    private List<Quota__c> zeroQuotasForDeactivatedUsers(List<Id> deactivatedUserIds) {
        List<Quota__c> updateQuotas = new List<Quota__c>();
        for(Quota__c quota : this.getUsersOpenQuotas(deactivatedUserIds)) {
            quota.Direct_Amount__c = 0;
            updateQuotas.add(quota);
        }

        return updateQuotas;
    }

    /**
     * @description drive function for create Quota records from appropriate
     * user records
     *
     * @param List<String> array of string years to create quotas for
     * 
     * @return void
    */
    public void generateQuotasFromUserHierarchy(Set<String> months, Set<String> years) {
        List<User> rootUsers = this.retrieveSalesRootUsers();

        this.createQuotasFromUsers(rootUsers, months, years, new Map<String, Quota__c>());
    }

    /**
     * @description function to start at a top set of users in a hierarchy
     * and create the necessary set of Quotas per month, year and product family
     *
     * @param List<User> the list of users to create quotas for
     * @param List<String> the list of years to create quotas for
     * @param Map<Id, Quota__c> map of unique strings to parent quotas
     * 
     * @return void
    */
    private void createQuotasFromUsers(List<User> users, Set<String> months, Set<String> years, Map<String, Quota__c> quotasByUserId) {
        List<Quota__c> insertQuotas = new List<Quota__c>();
        for(User u : users) {
            for(String year : years) {
                for(String month : months) {
                    for(String productFamily : this.getProductFamilies()) {
                        Id parentId = quotasByUserId.containsKey(u.ManagerId + productFamily + month + year) ? quotasByUserId.get(u.ManagerId + productFamily + month + year).Id : null;
                        insertQuotas.add(this.getQuota(u, year, month, productFamily, parentId));
                    }
                }
            }
        }

        insert insertQuotas;

        quotasByUserId.clear();
        for(Quota__c quota : insertQuotas) {
            quotasByUserId.put(quota.User__c + quota.Product_Family__c + quota.Month__c + quota.Year__c, quota);
        }

        List<Id> childUserIds = new List<Id>();
        for(User user : users) {
            for(User childUser : user.ManagedUsers) {
                childUserIds.add(childUser.Id);
            }
        }

        if(!childUserIds.isEmpty()) {
            this.createQuotasFromUsers(this.retrieveChildUsers(childUserIds), months, years, quotasByUserId);
        }
    }

    /**
     * @description create a new quota with the passed data
     * 
     * @param User u the user the quota is for
     * @param String year
     * @param String month
     * @param String productFamily
     * @param Id parentId the parent quota
     *
     * @return Quota__c 
    */
    private Quota__c getQuota(User u, String year, String month, 
                              String productFamily, Id parentId) {
        return new Quota__c(
                User__c           = u.Id,
                Year__c           = year,
                Month__c          = month,
                Product_Family__c = productFamily,
                Quota__c          = parentId,
                Quota_Date__c     = Date.newInstance(Integer.valueOf(year), this.MONTHS.get(month), 1)
            );
    }

    /**
     * @description find all the users that are the top of the quota(sales) hierarchy
     *
     * @return List<User>
    */
    private List<User> retrieveSalesRootUsers() {
        return [SELECT Id,
                       ManagerId,
                       Profile.Name,
                       (SELECT Id FROM ManagedUsers WHERE IsActive = true AND Profile.Name NOT IN :EXCLUDE_PROFILES)
                FROM User 
                WHERE Profile.Name NOT IN :EXCLUDE_PROFILES
                      AND IsActive = true
                      AND ManagerId = null];
    }

    /**
     * @description retrieve child users for passed parent ids
     *
     * List<Id> userIds
     *
     * @return List<User>
    */
    private List<User> retrieveChildUsers(List<Id> userIds) {
        return [SELECT Id,
                       ManagerId,
                       Profile.Name,
                       (SELECT Id FROM ManagedUsers WHERE IsActive = true AND Profile.Name NOT IN :EXCLUDE_PROFILES)
                FROM User
                WHERE Profile.Name NOT IN :EXCLUDE_PROFILES
                      AND IsActive = true
                      AND Id IN :userIds];
    }

    /**
     * @description dynamically retrieve the possible product families from schema
     *
     * @return Set<String>
    */
    @testVisible
    private Set<String> getProductFamilies() {
        Set<String> productFamilies = new Set<String>();
        for(Schema.PicklistEntry picklistEntry : Quota__c.Product_Family__c.getDescribe().getPicklistValues()) {
            productFamilies.add(picklistEntry.getValue());
        }

        return productFamilies;
    }

    /**
     * @description get the manager quotas into a map from provided ids
     *
     * @param Set<Id> array of manager user ids
     * 
     * @return Map<String, Quota__c> map of quota concatenated string to quota record
    */
    @testVisible
    private Map<String, Quota__c> getManagerQuotas(Set<Id> managerIds) {
        Date startOfMonth = Date.today().toStartOfMonth();
        Map<String, Quota__c> quotasByUserId = new Map<String, Quota__c>();
        for(Quota__c quota : [SELECT Id, User__c, User__r.ManagerId, Product_Family__c, Quota__c, Year__c, Month__c FROM Quota__c WHERE User__c IN :managerIds AND Quota_Date__c >= :startOfMonth]) {
            quotasByUserId.put(quota.User__c + quota.Product_Family__c + quota.Month__c + quota.Year__c, quota);
        }

        return quotasByUserId;
    }

    /**
     * @description get all of the quotas for the current month and future months
     * for passed users
     *
     * List<Id> userIds the ids of the users to retrieve quotas for
     *
     * List<Quota__c>
    */
    private List<Quota__c> getUsersOpenQuotas(List<Id> userIds) {
        List<String> monthsLeftInYear = this.getMonthsLeftInYear(Date.today());
        system.debug('months left in year -> ' + monthsLeftInYear);
        return [SELECT Product_Family__c, Year__c, Month__c,Direct_Amount__c, User__r.ManagerId, Quota__c FROM Quota__c WHERE User__c IN :userIds AND Month__c IN :monthsLeftInYear];
    }

    /**
     * @description using the current month, get a string list of the remaining month names
     *
     * @param Date startDate the date to calculate months remaining based on
     *
     * @return List<String> string list of month names i.e [January, February...]
    */
    @testVisible
    private List<String> getMonthsLeftInYear(Date startDate) {
        List<String> monthsInYear = new List<String>();
        monthsInYear.addAll(MONTHS.keySet());

        return this.slice(monthsInYear, startDate.month(), 12);
    } 

    /**
     * @description standard slice implementation, takes a string array and returns
     * a portion of it using the upper and lower bounds
     * 
     * @param List<String> array to slice
     * @param Integer lower the lower index
     * @param Integer upper the upper index
     * 
     * @return List<String> the resulting array
    */
    private List<String> slice(List<String> arr, Integer lower, Integer upper) {
        List<String> slicedArray = new List<String>();
        for(Integer i = lower - 1; i < upper; i++) {
            slicedArray.add(arr[i]);
        }

        return slicedArray;
    }

    private Set<Id> getExcludeProfileIds() {
        Set<Id> excludeProfileIds = new Set<Id>();
        for(Profile profile : [SELECT Id FROM Profile WHERE Name IN :this.EXCLUDE_PROFILES]) {
            excludeProfileIds.add(profile.Id);
        }

        return excludeProfileIds;
    }
}