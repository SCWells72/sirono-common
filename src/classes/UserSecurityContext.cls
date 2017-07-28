/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of User object
 **/
public with sharing class UserSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String PROFILEID = 'ProfileId';

    // The fields for selecting a User in CreateAdjustment
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, PROFILEID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private UserSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for User in CreateAdjustment
     **/
    public static final UserSecurityContext SELECT_CONTEXT = new UserSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return User.class;
    }
}