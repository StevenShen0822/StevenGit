global class DelayCampaignMemberNotification implements Schedulable {

    Set<Id> campaignMemberIdSet;
    
    public DelayCampaignMemberNotification(Set<Id> campaignMemberIdSet) {
        this.campaignMemberIdSet = campaignMemberIdSet;
    }
    
    global void execute(SchedulableContext ctx) {

       List<CampaignMember> campMembersToUpdate = new List<CampaignMember>();
        
       List<CampaignMember> campaignMemberList = [Select Id, DelayCampaignMemNotification__c from CampaignMember where Id IN: this.campaignMemberIdSet];
        
       for(CampaignMember campMember: campaignMemberList) {
          if(campMember != null && campMember.DelayCampaignMemNotification__c == false) {
             campMember.DelayCampaignMemNotification__c = true;
             campMembersToUpdate.add(campMember);
          }
       }

       if(campMembersToUpdate.size() > 0) {
          upsert campMembersToUpdate;
       }
    }
}