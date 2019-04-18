public class UserQuotaSyncQueueable implements Queueable {
    private List<User> users;
    private Map<Id, User> oldUsers;
    private DMLOperation operation;

    /**
     *@class UserQuotaSyncQueuable
     *
     * @description facilitates running dml operations for non setup objects from a user
     * dml context. Specifically for User / Quota syncing. Recieves requests from the
     * UserQuotaManagement domain and delegates back to the domain in an async context (new transaction)
    */

    public UserQuotaSyncQueueable(List<User> users, Map<Id, User> oldUsers, DMLOperation operation) {
        this.users = users;
        this.oldUsers = oldUsers;
        this.operation = operation;
    }

    /**
     * @description execute in the async context, delegating back to the correct domain
     * function based on the operation
    */
    public void execute(QueueableContext context) {
        UserQuotaManagementDomain domain = new UserQuotaManagementDomain();
        if(this.operation == DMLOperation.DML_INSERT) {
            domain.createQuotasForNewUsers(this.users);
        }
        else if(this.operation == DMLOperation.DML_UPDATE) {
            domain.syncUserUpdatesToQuotas(this.users, this.oldUsers);
        }
    }
}