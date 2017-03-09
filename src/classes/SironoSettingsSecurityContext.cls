/**
 * This class is use for Security Context of Sirono_Settings__c (Custom Setting)
 **/

public with sharing class SironoSettingsSecurityContext extends SecurityContext {

    // Field constants for Sirono_Settings__c Custom Setting
    private static final String APIKEY = 'Apikey__c';
    private static final String COUNTRY_CODE = 'Country_Code__c';
    private static final String FORMAT = 'Format__c';
    private static final String MAX_NUMBER_PLAN_INSTALLMENTS = 'Max_Number_Plan_Installments__c';
    private static final String MIN_INSTALLMENT_AMOUNT = 'Min_Installment_Amount__c';
    private static final String MIN_NUMBER_PLAN_INSTALLMENTS = 'Min_Number_Plan_Installments__c';
    private static final String SERVER_ENDPOINT_URL = 'Server_Endpoint_URL__c';

    // The fields for inserting a Sirono_Settings__c in SironoSettingsUtil
    private static final Set<String> CREATE_FIELDS = new Set<String>{
    	APIKEY, COUNTRY_CODE, FORMAT, MAX_NUMBER_PLAN_INSTALLMENTS, MIN_INSTALLMENT_AMOUNT, MIN_NUMBER_PLAN_INSTALLMENTS,
	SERVER_ENDPOINT_URL
    };

    // The fields for upserting a Sirono_Settings__c in SironoSettingsUtil
    private static final Set<String> UPSERT_FIELDS = CREATE_FIELDS;

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private SironoSettingsSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The create context for Sirono_Settings__c in SironoSettingsUtil
     **/
    public static final SironoSettingsSecurityContext CREATE_CONTEXT = new SironoSettingsSecurityContext(CREATE_FIELDS, ACTION.OBJ_CREATE);
    
    /**
     * The upsert context for Sirono_Settings__c in SironoSettingsUtil
     **/
    public static final SironoSettingsSecurityContext UPSERT_CONTEXT = new SironoSettingsSecurityContext(UPSERT_FIELDS, ACTION.OBJ_UPSERT);
    
    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Sirono_Settings__c.class;
    }
    
    /**
     * Override deleteActionAllowed method of SecurityContext class
     **/
    public override Boolean deleteActionAllowed() { 	
        return Sirono_Settings__c.sObjectType.getDescribe().isDeletable();
    }
}