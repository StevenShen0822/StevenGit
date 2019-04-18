public with sharing class QuotaDomain extends Domain {
    public QuotaDomain() {}

    //trigger functions

    public override void onAfterInsert() {
        this.summarizeQuotas(Trigger.new, null);
    }

    public override void onAfterUpdate() {
        this.summarizeQuotas(Trigger.new, (Map<Id, Quota__c>)Trigger.oldMap);
    }

    // business logic


    /**
    * @description driver for calculating the summary of quota amounts for a
    * complete quota hierarchy.
    *
    * @param List<Quota__c> quotas that have been updated OR need recalculating
    * @param Map<Id, Quota__c> map of ids to quota. Should be null if not called
    * update trigger context
    *
    * @return void
    */
    public void summarizeQuotas(List<Quota__c> quotas, Map<Id, Quota__c> oldQuotas) {
        Set<Id> recalculateQuotaIds = new Set<Id>();

        for(Quota__c quota : quotas) {
            Quota__c oldQuota = oldQuotas == null ? null : oldQuotas.get(quota.Id);
            if(shouldRecalculateQuota(quota, oldQuota)) {
                recalculateQuotaIds.add(quota.Id);
            }
        }

        if(!recalculateQuotaIds.isEmpty()) {
            List<Quota__c> quotaRoots = getRoots(recalculateQuotaIds);
            List<QuotaNode> quotaTrees = buildQuotaTrees(quotaRoots);

            Set<Quota__c> updateQuotas = new Set<Quota__c>();
            for(QuotaNode root : quotaTrees) {
                Set<QuotaNode> leafs = findLongestPath(root);
                updateQuotas.addAll(this.traverseAndSummarize(leafs));
            }

            if(!updateQuotas.isEmpty()) {
                List<Quota__c> quotaList = new List<Quota__c>();
                quotaList.addAll(updateQuotas);
                System.enqueueJob(new AsyncDMLService(quotaList, DMLOperation.DML_UPDATE));
            }
        }
    }

    /**
    * @description container of logic to determine if quota has changed in a way
    * that will require recalculation of the entire tree
    * @param Quota__c the new state of the Quota
    * @param Quota__c the old state of the Quota
    *
    * @return Boolean true if it requires recalculation otherwise false
    */
    private Boolean shouldRecalculateQuota(Quota__c newQuota, Quota__c oldQuota) {
        return oldQuota == null ||
               newQuota.Direct_Amount__c != oldQuota.Direct_Amount__c ||
               newQuota.Quota__c != oldQuota.Quota__c;
    }

    /**
    * @description get the root quota in each quota tree that is passed
    * @param Set<Id> quoteIds - list of quota ids to find parents for
    *
    * @return List<Quota__c> the parent Quota records
    */
    public List<Quota__c> getRoots(Set<Id> quotaIds) {
        Set<Id> quotasWithParentsIds = new Set<Id>();
        List<Quota__c> parentQuotas = new List<Quota__c>();

        //NOTE: this query will get called recursively exactly once per level
        // of tallest hierarchy
        for(Quota__c quota : [SELECT Id, 
                                     Quota__c,
                                     Name,
                                     (SELECT Id,
                                             Name,
                                             Direct_Amount__c,
                                             Indirect_Amount__c
                                      FROM Child_Quotas__r)
                              FROM Quota__c 
                              WHERE Id IN :quotaIds]) {
            if(quota.Quota__c != null) {
                quotasWithParentsIds.add(quota.Quota__c);
            }
            else {
                parentQuotas.add(quota);
            }
        }

        if(!quotasWithParentsIds.isEmpty()) {
            parentQuotas.addAll(getRoots(quotasWithParentsIds));
        }
       
        return parentQuotas;
    }

    /**
    * @description build the entire tree out starting from the top parent quota    
    * @param List<Quota__c> - all the relevant top level quotas with Child_Quotas__r
    *
    * @return List<QuotaNode> - all of the quota trees
    */
    //NOTE: this deliberately uses a query in a loop in order to build a 
    // hierarchy of unknown depth
    public List<QuotaNode> buildQuotaTrees(List<Quota__c> quotas) {
        Set<Id> childQuotaIds = new Set<Id>();
        List<QuotaNode> parentQuotaNodes = new List<QuotaNode>();

        for(Quota__c quota : quotas) {
            QuotaNode parentNode = new QuotaNode(quota);
            parentQuotaNodes.add(parentNode);
            for(Quota__c childQuota : quota.Child_Quotas__r) {
                childQuotaIds.add(childQuota.Id);
            }
        }

        Map<Id, List<QuotaNode>> parentIdToChildQuotas = new Map<Id, List<QuotaNode>>();
        
        if(!childQuotaIds.isEmpty()) {
            //NOTE: this query is called exactly 1 * height of the tallest root
            List<Quota__c> childQuotas = [SELECT Id, 
                                     Quota__c,
                                     Name,
                                     Indirect_Amount__c,
                                     Direct_Amount__c,                      
                                     (SELECT Id,
                                             Name,
                                             Direct_Amount__c,
                                             Indirect_Amount__c
                                      FROM Child_Quotas__r)
                              FROM Quota__c 
                              WHERE Id IN :childQuotaIds];
            List<QuotaNode> childQuotaNodes = buildQuotaTrees(childQuotas);

            for(QuotaNode quotaNode : childQuotaNodes) {
                if(!parentIdToChildQuotas.containsKey(quotaNode.record.Quota__c)) {
                    parentIdToChildQuotas.put(quotaNode.record.Quota__c, 
                        new List<QuotaNode>());
                }

                parentIdToChildQuotas.get(quotaNode.record.Quota__c).add(quotaNode);
            }
        
            for(QuotaNode quotaNode : parentQuotaNodes) {
                if(parentIdToChildQuotas.containsKey(quotaNode.record.Id)) {
                    for(QuotaNode childQuotaNode : 
                        parentIdToChildQuotas.get(quotaNode.record.Id)) {
                        quotaNode.addChildQuotaNode(childQuotaNode);
                    }
                }
            }
        }

        return parentQuotaNodes;
    }


    /**
    * @description traverse the quotas tree to find the longest path to a leaf
    *
    * @param QuotaNode the root quota node
    * 
    * @return QuotaNode the leaf at the end of the longest path 
    */
    public Set<QuotaNode> findLongestPath(QuotaNode node) {
        Set<QuotaNode> quotaNodes = new Set<QuotaNode>();
        for(QuotaNode childNode : node.getChildren()) {
            quotaNodes.addAll(findLongestPath(childNode));
        }

        if(node.getChildren().isEmpty()) {
            quotaNodes.add(node);
        }

        return quotaNodes;
    }

    /**
    * @description Bottom up traversal of the quota trees, summarizing direct + 
    * indirect all the way up to the top of the hierarchy
    * @param QuotaNode the leaf quota node at the end of the longest path
    * 
    * @return List<Quota__c> list of quota records that will need to be updated
    */
    public Set<Quota__c> traverseAndSummarize(Set<QuotaNode> quotaNodes) {
        Set<QuotaNode> parentNodes = new Set<QuotaNode>();
        Set<Quota__c> updateQuotas = new Set<Quota__c>();
        for(QuotaNode quotaNode : quotaNodes) {
            //NOTE: defer processing if all children haven't been visited
            //OR skip if this node has been visited
            if(quotaNode.canSummarize()) {
                for(QuotaNode childNode : quotaNode.getChildren()) {
                    quotaNode.record.Indirect_Amount__c+=(
                        childNode.record.Direct_Amount__c + childNode.record.Indirect_Amount__c
                    );
                }

                if(quotaNode.getParent() != null) {
                    parentNodes.add(quotaNode.getParent());
                }

                //NOTE: using a set here managed the deduplication of records
                //as the tree is traversed
                updateQuotas.add(quotaNode.record);

                quotaNode.visited = true;
            }
        }

        if(!parentNodes.isEmpty()) {
            updateQuotas.addAll(this.traverseAndSummarize(parentNodes));
        }
        
        return updateQuotas;
    }
}