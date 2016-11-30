/*
* @author: Sirono
* @version  1.0.1
* @date: 05-05-2016
* @description Handler class for CaseCommentTrigger
* 23/09/2016 Tracker # 130687155  Get the Charge Groups from Case Charge Group object.
*/

public with sharing class CaseCommentTriggerHandler {
    //PUBLIC METHOD CALLED FROM TRIGGER
    public static void afterInsert(List<CaseComment> newList) {
        //ONLY DOING CALLOUT WHEN BATCH SIZE IS ONE (It's Created from UI)
        if (newList.size() == 1) {
            checkAndDoAddNoteCallout(newList.get(0));
        }
    }

    //PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
    private static void checkAndDoAddNoteCallout(CaseComment cc) {
        //CHECK IF COMMENT BODY IS NOT NULL
        if (cc.CommentBody != null) {
            //CHECK IF CASE OF NOES RECORD TYPE AND DID NOT CREATED BY SIRONO INTEGRATION USER
            //AND Have ChargeGroups ASSOCIATED with Case
            Id caseId;
            string caseCommentBody = '';
            //Removed Internal Case record type check in the query 
            for (CaseComment ob : [Select Id, CommentBody, ParentId From CaseComment Where Id = :cc.Id AND CreatedBy.Name != 'Sirono Integration']) {
                caseId = ob.ParentId;
                caseCommentBody = ob.CommentBody;
            }
            List<String> chargeGroupIds = new List<String>();
            //Tracker # 130687155  Query to get the Charge Groups from Case Charge Group object.
            for( Charge_Group__c cg : [Select Id, Sirono_ID__c From Charge_Group__c Where Id IN (Select Charge_Group__c from Case_Charge_Group_Junction__c Where Case__c = :caseId)]) {         
                if (cg != null) {
                    chargeGroupIds.add(cg.Sirono_ID__c + '');
                }
            }
            //CALL FUTURE METHOD FOR ADD NOTE CALLOUT
            PayStaffWSUtill.addNoteFuture(chargeGroupIds, caseCommentBody);
        }
    }
}