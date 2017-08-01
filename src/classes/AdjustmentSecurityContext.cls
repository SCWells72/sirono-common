/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class AdjustmentSecurityContext extends SecurityContext {

    /**
     * The context used to create an Adjustment__c
     **/
    public static final AdjustmentSecurityContext CREATE_CONTEXT = new AdjustmentSecurityContext(ACTION.OBJ_CREATE);

    /**
     * The update context for Adjustment__c
     **/
    public static final AdjustmentSecurityContext UPDATE_CONTEXT = new AdjustmentSecurityContext(ACTION.OBJ_UPDATE);

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param the Object's Fields
     * @param Action Name (Create/Update/Delete/Undelete)
     **/
    private AdjustmentSecurityContext(ACTION actionToPerform) {
        this.fieldsToCheck = new Set<String>();
        this.objectAction = actionToPerform;
    }

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Adjustment__c.class;
    }
}
