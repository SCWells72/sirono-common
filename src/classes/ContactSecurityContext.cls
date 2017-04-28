/**
 * This class is use for Security Context of Contact object
 **/

public with sharing class ContactSecurityContext extends SecurityContext {

    // Field constants for Contact object
    private static final String ESTIMATE_BALANCE = 'Estimate_Balance__c';
    private static final String RECORDTYPEID = 'RecordTypeId';

    // Below field(s) are use for Select/Read permission.
    private static final String BIRTHDATE = 'Birthdate';
    private static final String FIRSTNAME = 'FirstName';
    private static final String HOMEPHONE = 'HomePhone';
    private static final String ID = 'Id';
    private static final String LASTNAME = 'LastName';
    private static final String MAILINGCITY = 'MailingCity';
    private static final String MAILINGCOUNTRY = 'MailingCountry';
    private static final String MAILINGPOSTALCODE = 'MailingPostalCode';
    private static final String MAILINGSTATE = 'MailingState';
    private static final String MAILINGSTREET = 'MailingStreet';
    private static final String MEDICAL_RECORD_NUMBER = 'Medical_Record_Number__c';
    private static final String MIDDLENAME = 'MiddleName';
    private static final String MOBILEPHONE = 'MobilePhone';
    private static final String NAME = 'Name';
    private static final String OTHERPHONE = 'OtherPhone';
    private static final String PATIENT_ID = 'Patient_Id__c';
    private static final String PROFILE_POINTER_ID = 'Profile_Pointer_Id__c';
    private static final String SALUTATION = 'Salutation';
    private static final String SOCIAL_SECURITY_NUMBER = 'Social_Security_Number__c';
    private static final String SUFFIX = 'Suffix';

    // The fields for updating a Contact in EncounterUtil
    private static final Set<String> UPDATE_FIELDS = new Set<String>{
    	ESTIMATE_BALANCE, RECORDTYPEID
    };

    // The fields for selecting a Contact in GuarantorDao
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX, BIRTHDATE, MEDICAL_RECORD_NUMBER, NAME,
        PROFILE_POINTER_ID, MAILINGSTREET, MAILINGCITY, MAILINGSTATE, MAILINGPOSTALCODE, RECORDTYPEID
    };

    // The fields for selecting a Contact with Charge Groups in GuarantorDao
    private static final Set<String> SELECT_FIELDS_WITH_CG = new Set<String>{
        ID, FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX, BIRTHDATE, MEDICAL_RECORD_NUMBER, NAME,
        PROFILE_POINTER_ID, MAILINGSTREET, MAILINGCITY, MAILINGSTATE, MAILINGPOSTALCODE, RECORDTYPEID,
        SALUTATION, SOCIAL_SECURITY_NUMBER, PATIENT_ID, HOMEPHONE, MOBILEPHONE,
        OTHERPHONE, MAILINGCOUNTRY
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private ContactSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }
    
    /**
     * The update context for Contact in EncounterUtil
     **/
    public static final ContactSecurityContext UPDATE_CONTEXT = new ContactSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);

    /**
     * The select context for Contact in GuarantorDao
     **/
    public static final ContactSecurityContext SELECT_CONTEXT = new ContactSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Contact with Charge Groups in GuarantorDao
     **/
    public static final ContactSecurityContext SELECT_CONTEXT_WITH_CG = new ContactSecurityContext(SELECT_FIELDS_WITH_CG, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Contact.class;
    }
}