/**
 * This class is use for Security Context of Case Comment object
 **/

public with sharing class CaseCommentSecurityContext extends SecurityContext {
	
    // Field constants for CaseComment object
    private static final String	COMMENTBODY = 'CommentBody';
    private static final String	PARENTID = 'ParentId';

    // The fields for upserting a CaseComment in CreateCaseManual
    private static final Set<String> UPSERT_FIELDS = new Set<String>{
    	PARENTID, COMMENTBODY
    };
    
    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private CaseCommentSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The context used to upsert a CaseComment in CreateCaseManual
     **/
    public static final CaseCommentSecurityContext UPSERT_CONTEXT = new CaseCommentSecurityContext(UPSERT_FIELDS, ACTION.OBJ_UPSERT);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return CaseComment.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return CaseComment.sObjectType.getDescribe().isDeletable();
    }
}