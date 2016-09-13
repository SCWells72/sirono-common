public with sharing class CaseCommentTriggerHandler {
	// PUBLIC METHOD CALLED FROM TRIGGER
	public static void afterInsert(List<CaseComment> newList){
		//ONLY DOING CALLOUT WHEN BATCH SIZE IS ONE (It's Created from UI)
		if(newList.size() == 1){
			checkAndDoAddNoteCallout(newList.get(0));
		} 
	}
	
	// PRIVATE METHOD TO VALIDATE AND CALL ADD NOTE FUTURE METHOD
	private static void checkAndDoAddNoteCallout(CaseComment cc){
        // CHECK IF COMMENT BODY IS NOT NULL
        if(cc.CommentBody != null){
			// CHECK IF CASE OF NOES RECORD TYPE AND DID NOT CREATED BY SIRONO INTEGRATION USER
			// AND HAVE Charge_Group_Id__c ON ASSOCIATED CHARGE GROUP RECORD
			for(CaseComment ob : [Select Id, CommentBody, Parent.Charge_Group_IDs__c 
				From CaseComment Where Id = :cc.Id AND CreatedBy.Name != 'Sirono Integration' 
					AND Parent.RecordType.Name = 'Internal Case' AND Parent.Charge_Group_IDs__c != null]){
				// CALL FUTURE METHOD FOR ADD NOTE CALLOUT
				PayStaffWSUtill.addNoteFuture(ob.Parent.Charge_Group_IDs__c, ob.CommentBody);
			}
		}
	}
}