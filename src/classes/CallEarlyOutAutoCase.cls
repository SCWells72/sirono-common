/*
* @author: Sirono
* @version 1.0.1
* @Date: 08-12-2016
*
* 08-11-2016: Sirono - Tracker # 127398811
* this Scheduled Class is Executed Every Day and it will create a case for the Early Out
*/

global class CallEarlyOutAutoCase implements Schedulable {

    global void execute(SchedulableContext sc) {
        CaseUtil.callEarlyOutAutoCaseCloser();
    }
}