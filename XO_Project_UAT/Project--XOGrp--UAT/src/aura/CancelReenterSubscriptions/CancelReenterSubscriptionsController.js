({  doInit : function(component, event, helper) {
        helper.getSubscriptionsData(component);
    },
    checkAllSubscriptions : function(component, event, helper) {
        helper.checkAllSubscriptions(component, event);
    },
    showBillingAccount : function(component, event, helper) {
        helper.showBillingAccount(component, event);
    },
    disSelectOtherBA : function(component, event, helper) {
        helper.disSelectOtherBA(component, event);
    },
    updatePaymentMethod : function(component, event, helper) {
        helper.updatePaymentMethod(component, event);
    },
    cancelData : function(component, event, helper) {
        helper.cancelData(component, event);
    },
    saveData : function(component, event, helper) {
        helper.saveData(component, event);
    }
})