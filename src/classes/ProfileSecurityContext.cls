/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Profile object
 **/
public with sharing class ProfileSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String NAME = 'name';

    // The fields for selecting a Profile in SironoSettingsUtil
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        ID, NAME
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ProfileSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Profile in SironoSettingsUtil
     **/
    public static final ProfileSecurityContext SELECT_CONTEXT = new ProfileSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Profile.class;
    }
}