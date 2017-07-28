/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of NamedCredential object
 **/
public with sharing class NamedCredentialSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.
    private static final String DEVELOPERNAME = 'DeveloperName';
    private static final String ENDPOINT = 'Endpoint';
    private static final String ID = 'Id';

    // The fields for selecting a NamedCredential in SironoRestClient
    private static final Set<String> SELECT_FIELDS = new Set<String> {
        DEVELOPERNAME, ENDPOINT, ID
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private NamedCredentialSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for NamedCredential in SironoRestClient
     **/
    public static final NamedCredentialSecurityContext SELECT_CONTEXT = new NamedCredentialSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return NamedCredential.class;
    }
}