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
            // Passing parameter change CaseComment single record to List of CaseComment to resolve Security Scan Issue.
            checkAndDoAddNoteCallout(newList);
        }
    }

    /**
     * PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
     *
     * @param List<CaseComment> caseComments - That contains List of Case Comments.
     *
     * Parameter change CaseComment object to List of CaseComment to resolve Security Scan Issue.
     **/
    private static void checkAndDoAddNoteCallout(List<CaseComment> caseComments) {
        // TODO: Bulkify like CaseTriggerHandler

        //CHECK IF COMMENT BODY IS NOT NULL
        if (caseComments.get(0).CommentBody != null) {
            //CHECK IF CASE OF NOES RECORD TYPE AND DID NOT CREATED BY SIRONO INTEGRATION USER
            //AND Have ChargeGroups ASSOCIATED with Case
            Id caseId;
            string caseCommentBody = '';
            if (CaseCommentSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                // Removed Internal Case record type check in the query 
                for (CaseComment caseComment: [
                    SELECT Id, CommentBody, ParentId
                    FROM CaseComment
                    WHERE Id = :caseComments.get(0).Id
                    AND CreatedBy.Name != :Constants.SIRONO_INTEGRATION_USER_NAME
                ]) {
                    caseId = caseComment.ParentId;
                    caseCommentBody = caseComment.CommentBody;
                }
            }

            List<String> chargeGroupIds = ChargeGroupService.getCGIdsFromCaseCGJun(caseId);

            //CALL FUTURE METHOD FOR ADD NOTE CALLOUT
            PayStaffWSUtill.addNoteFuture(chargeGroupIds, caseCommentBody);
        }
    }
}