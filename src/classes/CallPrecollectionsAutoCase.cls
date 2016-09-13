//THis Scheduled Class is Executed Every Day and it will create a case for the Pre collections and close the cases for the Pre collections. 

global class CallPrecollectionsAutoCase implements Schedulable {
   global void execute(SchedulableContext SC) {
        CaseUtil.CallPrecollectionsAutoCase();
        CaseUtil.CallPrecollectionsAutoCaseCloser();
   }
}