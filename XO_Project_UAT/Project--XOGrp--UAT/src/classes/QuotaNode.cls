public with sharing class QuotaNode {
    private List<QuotaNode> children;
    private QuotaNode parent;
    public Quota__c record;
    public Boolean visited;

    /**
     * @description node of a tree representing a hierarchy of Quotas
     * with functions enabling easy traversal and summarization of values
    */

    public QuotaNode(Quota__c quota) {
        this.record = quota;
        this.children = new List<QuotaNode>();
        this.visited = false;
    
        //reset the indirect amount to 0, since it will be recalculated
        this.record.Indirect_Amount__c = 0;
    }

    public void addChildQuotaNode(QuotaNode quotaNode) {
        quotaNode.setParent(this);
        this.children.add(quotaNode);
    }

    public List<QuotaNode> getChildren() {
        return this.children;
    }

    public void setParent(QuotaNode quotaNode) {
        this.parent = quotaNode;
    } 

    public QuotaNode getParent() {
        return this.parent;
    }

    /**
     * @description Determine if a node is ready to be summarized, either it has no children
     * or all children have already been visited AND it has not been visited
     *
     * @return Boolean true if it is ready to be summarized false if not
    */
    public Boolean canSummarize() {
        Boolean allChildrenVisited = true;

        Integer index = 0;
        while(!this.visited && allChildrenVisited == true && index < this.children.size()) {
            allChildrenVisited = this.children[index].visited;
            index++;
        }

        return (allChildrenVisited && !this.visited);
    }
}