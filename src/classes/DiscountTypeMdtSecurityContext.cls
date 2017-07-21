/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use for Security Context of Discount Type Metadata object
 **/
public with sharing class DiscountTypeMdtSecurityContext extends SecurityContext {

    // Below field(s) are use for Select/Read permission.    
    private static final String MASTERLABEL = 'MasterLabel';
    private static final String RATE = 'Rate__c';

    // The fields for selecting a Discount_Type__mdt in AddDiscount
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        RATE, MASTERLABEL
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private DiscountTypeMdtSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Discount_Type__mdt in AddDiscount
     **/
    public static final DiscountTypeMdtSecurityContext SELECT_CONTEXT = new DiscountTypeMdtSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Discount_Type__mdt.class;
    }
}