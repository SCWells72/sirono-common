/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Case Comment object
 **/
public with sharing class CaseCommentSecurityContext extends SecurityContext {

    // Field constants for CaseComment object
    private static final String COMMENTBODY = 'CommentBody';
    private static final String PARENTID = 'ParentId';

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';

    // The fields for creating a CaseComment in CreateCaseManual
    private static final Set<String> CREATE_FIELDS = new Set<String> {
        PARENTID, COMMENTBODY
    };

    // The fields for selecting a CaseComment in CaseCommentTriggerHandler
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, COMMENTBODY, PARENTID
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
     * The context used to create a CaseComment in CreateCaseManual
     **/
    public static final CaseCommentSecurityContext CREATE_CONTEXT = new CaseCommentSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);

    /**
     * The select context for CaseComment in CaseCommentTriggerHandler
     **/
    public static final CaseCommentSecurityContext SELECT_CONTEXT = new CaseCommentSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return CaseComment.class;
    }
}