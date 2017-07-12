/*
* @author: Sirono
* @version 1.0.1
* @Date: 08-12-2016
*
* 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
*This Scheduled Class is Executed Every Day and it will create a case for the Pre collections and close the cases for the Pre collections. 
*/


global class CallPrecollectionsAutoCase implements Schedulable {

    global void execute(SchedulableContext sc) {
        CaseUtil.callPrecollectionsAutoCaseCloser();
    }
}