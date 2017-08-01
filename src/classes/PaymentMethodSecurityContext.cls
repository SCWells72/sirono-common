/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class PaymentMethodSecurityContext extends SecurityContext {

    // Field constants for Payment_Method__c object.
    private static final String ACCOUNT_NUMBER = 'Account_Number__c';
    private static final String CARD_HOLDER_NAME = 'Card_Holder_Name__c';
    private static final String CARD_TYPE = 'Card_Type__c';
    private static final String DISPLAY_NAME = 'Display_Name__c';
    private static final String EXPIRATION_DATE = 'Expiration_Date__c';
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String ID = 'Id';
    private static final String ID_C = 'ID__c';
    private static final String LAST_4 = 'Last_4__c';
    private static final String ROUTING_NUMBER = 'Routing_Number__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';
    private static final String TOKEN = 'Payment_Method_Token__c';
    private static final String TYPE = 'Type__c';

    // Guarantor Select fields
    private static final Set<String> GUARANTOR_SELECT_FIELDS = new Set<String> {
        ID, ACCOUNT_NUMBER, CARD_HOLDER_NAME, CARD_TYPE, DISPLAY_NAME, EXPIRATION_DATE, ID_C, LAST_4,
        TOKEN, ROUTING_NUMBER, SIRONO_ID, TYPE, GUARANTOR
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private PaymentMethodSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The select context for Guarantors.
     **/
    public static final PaymentMethodSecurityContext GUARANTOR_SELECT = new PaymentMethodSecurityContext(GUARANTOR_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Payment_Method__c.class;
    }
}