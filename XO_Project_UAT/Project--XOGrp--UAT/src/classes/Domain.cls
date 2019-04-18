public abstract with sharing class Domain {
    public Boolean execute;

    /**
     * trigger context handlers available to implement
     */
    public virtual void onBeforeInsert() {}
    public virtual void onBeforeUpdate() {}
    public virtual void onBeforeDelete() {}

    public virtual void onAfterInsert() {}
    public virtual void onAfterUpdate() {}
    public virtual void onAfterDelete() {}
    public virtual void onAfterUndelete() {}

    /**
     * @description execute the necessary context functions based on derived
     * trigger context
     *
     * @return void
    */
    public void execute() {
        if(this.shouldExecute()) {
            if(Trigger.isBefore) {

                if(Trigger.isInsert) {
                    this.onBeforeInsert();
                }

                if(Trigger.isUpdate) {
                    this.onBeforeUpdate();
                }

                if(Trigger.isDelete) {
                    this.onBeforeDelete();
                }
            }
            else if(Trigger.isAfter) {

                if(Trigger.isInsert) {
                    this.onAfterInsert();
                }

                if(Trigger.isUpdate) {
                    this.onAfterUpdate();
                }

                if(Trigger.isDelete) {
                    this.onAfterDelete();
                }

                if(Trigger.isUndelete) {
                    this.onAfterUpdate();
                }
            }
        }
    }

    /**
     * @description Returns the name of the class
     *
     * @return String the class name i.e Domain
    */
    protected String getDomainName() {
        return String.valueOf(this).split(':')[0];
    }

    /**
     * @description check if a trigger should fire based on the custom setting
     * and test class utility static boolean. Assumes a custom setting record
     * exists
     * 
     * return Boolean true if should execute otherwise false
    */
    protected Boolean shouldExecute() {
        TriggerHandlerAccess__c triggerHandler = TriggerHandlerAccess__c.getInstance(this.getDomainName());
        return (triggerHandler == null || triggerHandler.Active__c)
               && !TestClassUtility.DISABLE_TRIGGERS;
    }
}