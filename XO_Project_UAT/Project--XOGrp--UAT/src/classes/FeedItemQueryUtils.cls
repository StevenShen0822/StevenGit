public without sharing class FeedItemQueryUtils {
    
    public static List<FeedItem> retrieveFeedItems(Set<Id> convertedLeadIdSet){
        
        // Query all feed items from converted leads
        List<FeedItem> feedItemList = [SELECT Id, Body, LinkUrl, ParentId, HasContent, type, RelatedRecordId, IsRichText, Title
                        FROM FeedItem WHERE ParentId IN: convertedLeadIdSet];

        return feedItemList;
    }
}