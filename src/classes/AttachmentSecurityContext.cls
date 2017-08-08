/*
 * Copyright (c) 2017present Sirono LLC, All rights reserved
 */

public with sharing class AttachmentSecurityContext extends SecurityContext {

    // Field constants for Attachment
    private static final String NAME = 'Name';
    private static final String BODY = 'Body';
    private static final String OWNER = 'OwnerId';
    private static final String PARENT = 'ParentId';
    private static final String CONTENT_TYPE = 'ContentType';


    // The fields for inserting an Attachment
    private static final Set<String> CREATE_FIELDS = new Set<String>{
            NAME, BODY, OWNER, PARENT, CONTENT_TYPE
    };
    
    
        /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields  That contains Object's Fields
     * @param ACTION actionToPerform  That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private AttachmentSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
        /**
     * The create context for Attachment
     **/
    public static final AttachmentSecurityContext CREATE_CONTEXT = new AttachmentSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    
        /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Attachment.class;
    }
}