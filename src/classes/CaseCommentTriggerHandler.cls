/*
* @author: Sirono
* @version  1.0.1
* @date: 05-05-2016
* @description Handler class for CaseCommentTrigger
* 23/09/2016 Tracker # 130687155  Get the Charge Groups from Case Charge Group object.
*/

public with sharing class CaseCommentTriggerHandler {
    //PUBLIC METHOD CALLED FROM TRIGGER
    public static void afterInsert(List<CaseComment> caseComments) {
        //ONLY DOING CALLOUT WHEN BATCH SIZE IS ONE (It's Created from UI)
        if (caseComments.size() == 1) {
            // Passing parameter change CaseComment single record to List of CaseComment to resolve Security Scan Issue.
            checkAndDoAddNoteCallout(caseComments);
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
        if (CaseCommentSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            Map<Id, String> caseCommentBodiesById = new Map<Id, String>();
            for (CaseComment caseComment : caseComments) {
                if (String.isNotBlank(caseComment.CommentBody)) {
                    caseCommentBodiesById.put(caseComment.Id, caseComment.CommentBody);
                }
            }

            if (!caseCommentBodiesById.isEmpty()) {
                // NOTE: We can't filter by CreatedBy.Name in a unit test context, so query all case comments and
                // filter by creator afterward
                List<User> sironoIntegrationUsers = [SELECT Id FROM User WHERE Name = :Constants.SIRONO_INTEGRATION_USER_NAME LIMIT 1];
                User sironoIntegrationUser = (sironoIntegrationUsers.size() == 1) ? sironoIntegrationUsers.get(0) : null;
                Id sironoIntegrationUserId = sironoIntegrationUser != null ? sironoIntegrationUser.Id : null;

                List<CaseComment> queriedCaseComments = new List<CaseComment>([
                    SELECT Id, CommentBody, ParentId
                    FROM CaseComment
                    WHERE Id IN :caseCommentBodiesById.keySet()
                    AND CreatedById != :sironoIntegrationUserId
                ]);
                // TODO: Once there's a bulk version of this API, collate all requests and invoke in bulk
                for (CaseComment queriedCaseComment : queriedCaseComments) {
                    String caseId = queriedCaseComment.ParentId;
                    String caseCommentBody = queriedCaseComment.CommentBody;

                    List<String> chargeGroupIds = ChargeGroupService.getCGIdsFromCaseCGJun(caseId);

                    //CALL FUTURE METHOD FOR ADD NOTE CALLOUT
                    PayStaffWSUtill.addNoteFuture(chargeGroupIds, caseCommentBody);
                }
            }
        }
    }
}