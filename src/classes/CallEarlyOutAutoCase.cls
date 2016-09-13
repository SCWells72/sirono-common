//THis Scheduled Class is Executed Every Day and it will create a case for the Early Out

global class CallEarlyOutAutoCase implements Schedulable {
   global void execute(SchedulableContext SC) {
      CaseUtil.CallEarlyOutAutoCase();
      CaseUtil.CallEarlyOutAutoCaseCloser();
   }
}