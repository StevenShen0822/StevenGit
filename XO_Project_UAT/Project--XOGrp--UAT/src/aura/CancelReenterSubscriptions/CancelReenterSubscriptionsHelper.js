({  getSubscriptionsData : function(component) {

        // Get Opportunity Id from component
        var oppId = component.get('v.oppId');
        var accId = component.get('v.accId');
        // Create the action
        var action = component.get('c.getSubscriptionsData');

        // Add parameters to action handler that are being sent to server controller
        action.setParams({
            'oppId' : oppId,
            'accId' : accId,
        });

        // Add callback behavior for when the response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            // Check to make sure component is still valid and that the response was a success
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.subscriptions', result);
                
            }
            else {
                console.log('Failed with response state: ' + state);
            }
        });

        // Send action off to be executed
        $A.enqueueAction(action);
    },
    checkAllSubscriptions : function(component, event) { 
        var errorMessage = document.getElementById('error-Message');
        errorMessage.value = "";
        errorMessage.style.display = 'none';
        
        var subs = component.get('v.subscriptions');
        if(event.target.checked){
            for(var i=0; i<subs.length;i++){
                subs[i].isSelected = true;
                var mycheckbox = document.getElementById('Subscription-Check-' + subs[i].zuoraSub.Name);
                mycheckbox.checked = true;
                
                var billingAccountSection = document.getElementById('Billing-Account-' + subs[i].zuoraSub.Name);
                billingAccountSection.style.display = 'table-row';
            }
        }else{
            for(var i=0; i<subs.length;i++){
                subs[i].isSelected = false;
                var mycheckbox = document.getElementById('Subscription-Check-' + subs[i].zuoraSub.Name);
                mycheckbox.checked = false;
                
                var billingAccountSection = document.getElementById('Billing-Account-' + subs[i].zuoraSub.Name);
                billingAccountSection.style.display = 'none';
                
                var billAccount = document.getElementsByClassName('slds-checkbox-' + subs[i].zuoraSub.Name);
                for(var j=0;j<billAccount.length;j++){
                    billAccount[j].checked = false;
                }
                
                for(var j=0;j<subs[i].listBillingAccWrap.length;j++){
                    subs[i].listBillingAccWrap[j].isSelectedBillingAcc = false
                }
            }
        }
        component.set('v.subscriptions',subs);
    },
    showBillingAccount : function(component, event) {
        var errorMessage = document.getElementById('error-Message');
        errorMessage.value = "";
        errorMessage.style.display = 'none';
        
        var subs = component.get('v.subscriptions');
        if(event.target.checked){
            var subName = event.target.value;
            var billingAccountTable = document.getElementById('Billing-Account-' + subName);
            billingAccountTable.style.display = 'table-row';
            for(var i=0; i<subs.length;i++){
                if(event.target.value == subs[i].zuoraSub.Name){
                    subs[i].isSelected = true;
                }
            }
        }else{
            var subName = event.target.value;
            var billingAccountTable = document.getElementById('Billing-Account-' + subName);
            billingAccountTable.style.display = 'none';
            var billingAccount = document.getElementsByClassName('slds-checkbox-' + subName);
            for(var i=0;i<billingAccount.length;i++){
                billingAccount[i].checked = false;
            }
            
            for(var i=0; i<subs.length;i++){
                if(event.target.value == subs[i].zuoraSub.Name){
                    subs[i].isSelected = false;
                    for(var j=0;j<subs[i].listBillingAccWrap.length;j++){
                        subs[i].listBillingAccWrap[j].isSelectedBillingAcc = false
                    }
                }
            }
        }
        component.set('v.subscriptions',subs);
        
    },
    disSelectOtherBA : function(component, event) {
        var errorMessage = document.getElementById('error-Message');
        errorMessage.value = "";
        errorMessage.style.display = 'none';
        
        var subName = event.target.value;
        var billingAccount = document.getElementsByClassName('slds-checkbox-' + subName);
        for(var i=0; i<billingAccount.length;i++){
            if(billingAccount[i].id != event.target.id){
                billingAccount[i].checked = false;
            }
        }
        
        var subs = component.get('v.subscriptions');
        if(event.target.checked){
            for(var i=0; i<subs.length;i++){
                if(event.target.value == subs[i].zuoraSub.Name){
                    for(var j=0; j<subs[i].listBillingAccWrap.length;j++){
                        var zuoraAccNumber = '';
                        if(subs[i].listBillingAccWrap[j].ZuoraBillingAcc.Zuora__AccountNumber__c == null){
                            zuoraAccNumber = subs[i].zuoraSub.Name;
                        }else{
                            zuoraAccNumber = subs[i].zuoraSub.Name + subs[i].listBillingAccWrap[j].ZuoraBillingAcc.Zuora__AccountNumber__c;
                        }
                        if(zuoraAccNumber == event.target.id){
                            subs[i].listBillingAccWrap[j].isSelectedBillingAcc = true;
                        }else{
                            subs[i].listBillingAccWrap[j].isSelectedBillingAcc = false;
                        }
                    }
                }
            }

        }else{
            for(var i=0; i<subs.length;i++){
                if(event.target.value == subs[i].zuoraSub.Name){
                    for(var j=0; j<subs[i].listBillingAccWrap.length;j++){
                        var zuoraAccNumber = '';
                        if(subs[i].listBillingAccWrap[j].ZuoraBillingAcc.Zuora__AccountNumber__c == null){
                            zuoraAccNumber = subs[i].zuoraSub.Name;
                        }else{
                            zuoraAccNumber = subs[i].zuoraSub.Name + subs[i].listBillingAccWrap[j].ZuoraBillingAcc.Zuora__AccountNumber__c;
                        }
                        
                        if(zuoraAccNumber == event.target.id){
                            subs[i].listBillingAccWrap[j].isSelectedBillingAcc = false;
                        }
                    }
                }
            }
        }

        component.set('v.subscriptions',subs);
    },
    updatePaymentMethod : function(component, event) {
        
        var paymendMethod = event.target.value;
        var subName = event.target.id;
        subName = subName.replace('paymentMethod','');
        
        var subs = component.get('v.subscriptions');
		console.log();
        for(var i=0; i<subs.length;i++){
            if(subs[i].zuoraSub.Name == subName){
                for(var j=0; j<subs[i].listBillingAccWrap.length;j++){
                    if(subs[i].listBillingAccWrap[j].selectNewBillingAcc == 'Create New Billing Account'){
                        subs[i].listBillingAccWrap[j].ZuoraBillingAcc.Zuora__DefaultPaymentMethod__c = paymendMethod;
                    }
                        
                }
            }
        }
        component.set('v.subscriptions',subs);
        console.log(subs);
    },
    cancelData : function(component, event) {
        component.set('v.hideLoading', false);
        var oppId = component.get('v.oppId');
        if(sforce.console.isInConsole()){
            var pTabId = sforce.console.getEnclosingPrimaryTabId(function getOpenTabResult(result){
                console.log(result.id);
                sforce.console.closeTab(result.id);
            });
            sforce.console.openPrimaryTab(null, oppId, true);
        }else{
            window.open("/"+component.get("v.oppId"),'_self');
        }
    },
    saveData : function(component, event) {
        component.set('v.hideLoading', false);
        // Get Opportunity Id from component
        var oppId = component.get('v.oppId');
        var accId = component.get('v.accId');
        var subs = component.get('v.subscriptions');
        var newOppId = '';
        var checkedSub = false;
        
        var errorMessage = document.getElementById('error-Message');
        for(var i=0;i<subs.length;i++){
            if(subs[i].isSelected == true){ 
                checkedSub = true;
              if(subs[i].zuoraSub.Zuora__SubscriptionEndDate__c > subs[i].zuoraSub.Zuora__TermEndDate__c){
                errorMessage.value = "The canceled date must be erlier than Term End Date";
                errorMessage.style.display = 'block';
                  
                component.set('v.hideLoading', true);
                return;
              }
                
                var checkedBillingAcc = false;
                for(var j = 0; j<subs[i].listBillingAccWrap.length;j++ ){
                    if(subs[i].listBillingAccWrap[j].isSelectedBillingAcc == true){
                        checkedBillingAcc = true;
                    }
                }
                
                if(checkedBillingAcc == false){
                    errorMessage.value = "No billing account was selected. Please select a billing account or choose to create a new one.";
                    errorMessage.style.display = 'block';
                    
                    component.set('v.hideLoading', true);
                    return;
                }
            }
        }
        if(checkedSub == false){
            errorMessage.value = "No quote was selected. Please select at least one quote to cancel and reenter.";
            errorMessage.style.display = 'block';
            
            component.set('v.hideLoading', true);
            return;
        }
        // Create the action
        var action = component.get('c.createOpportunitAndQuote');
        
        // Add parameters to action handler that are being sent to server controller
        var subWrappersString = JSON.stringify(subs); 
        action.setParams({
            'subWrappersString' : subWrappersString,
            'oppId' : oppId,
            'accId' : accId,
        });
        
        // Add callback behavior for when the response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            var callbackNoteRecord = response.getReturnValue();
            var status = true;
            if (state === 'SUCCESS') {
                if(callbackNoteRecord.indexOf('Successed') >= 0){
                    newOppId = callbackNoteRecord.replace('Successed', '');              
                }else if(callbackNoteRecord.indexOf('Please contact your admin team') >= 0){
                    errorMessage.value = callbackNoteRecord;
                    errorMessage.style.display = 'block';
                    component.set('v.hideLoading', true);
                    status = false;
                }
            }else{
                errorMessage.value = 'Failed with response state: ' + state +', Please contact your admin team';
                errorMessage.style.display = 'block';
                component.set('v.hideLoading', true);
                status = false;
            }
            
            if(status){
                if(sforce.console.isInConsole()){
                    var pTabId = sforce.console.getEnclosingPrimaryTabId(function getOpenTabResult(result){
                        sforce.console.closeTab(result.id);
                    });
                    
                    var newDate = new Date().toLocaleString("en-US", {timeZone: $A.get("$Locale.timezone")});
                    var myDate = $A.localizationService.formatDate(newDate, "YYYY-MM-DD");
                    
                    sforce.console.openPrimaryTab(null, component.get('v.oppId'), true,'');
                    sforce.console.openPrimaryTab(null, newOppId, false,'Cancel Reenter(New) Subscription ' + myDate);
                }else{
                    window.open("/"+ component.get('v.oppId'), "_blank");
                    window.open("/"+ newOppId ,"_self");
                }
            }
                
            
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);  
    }
})