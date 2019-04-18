public class AsyncDMLService implements Queueable {    
    private DMLOperation operation;
    private List<SObject> records;
    private final Integer MAX_RECORDS = 9999;

    public AsyncDMLService(List<SObject> records, DMLOperation operation) {
        this.records = records;
        this.operation = operation;
    }

    /**
     * @description executes async - loops through an array of records, 
     * inserting or updating up to 9,999 and then chaining a job to take
     * care of the rest
    */
    public void execute(QueueableContext context) {
        List<SObject> dmlRecords = new List<SObject>();
        Integer arraySize = this.records.size();
        for(Integer i = 0; i < arraySize && i < this.MAX_RECORDS; i++) {
            dmlRecords.add(this.records[0]);
            this.records.remove(0);
        }

        List<Database.SaveResult> saveResult;
        if(this.operation == DMLOperation.DML_INSERT) {
            saveResult = Database.insert(dmlRecords, false);
        }
        else if(this.operation == DMLOperation.DML_UPDATE) {
            saveResult = Database.update(dmlRecords, false);
        }

        //cannot chain jobs in test context
        if(!this.records.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new AsyncDMLService(this.records, this.operation));
        }
    }
}