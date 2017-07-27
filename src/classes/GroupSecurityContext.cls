/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Group object
 **/
public with sharing class GroupSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String NAME = 'Name';
    private static final String TYPE = 'Type';

    // The fields for selecting a Group in CaseUtil
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, NAME, TYPE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private GroupSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Group in CaseUtil
     **/
    public static final GroupSecurityContext SELECT_CONTEXT = new GroupSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Group.class;
    }
}