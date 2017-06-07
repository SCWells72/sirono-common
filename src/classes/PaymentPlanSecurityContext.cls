/**
 * This class is use for Security Context of Payment_Plan__c object
 **/

public with sharing class PaymentPlanSecurityContext extends SecurityContext {

    // Field constants for Payment_Plan__c object
    private static final String ACTIVE = 'Active__c';
    private static final String CANCELLATION_DATE = 'Cancellation_Date__c';
    private static final String DELINQUENT = 'Delinquent__c';
    private static final String DELINQUENT_DATE = 'Delinquent_Date__c';
    private static final String ERROR_DATE = 'Error_Date__c';
    private static final String EXECUTE_ON_DAY = 'Execute_on_Day__c';
    private static final String GUARANTOR = 'Guarantor__c';
    private static final String HAS_ERROR = 'Has_Error__c';
    private static final String INSTALLMENT_AMOUNT = 'Installment_Amount__c';
    private static final String NAME = 'Name';
    private static final String NEXTPAYMENTDATE = 'NextPaymentDate__c';
    private static final String ORIGINAL_BALANCE = 'Original_Balance__c';
    private static final String ORIGINAL_INSTALLMENT_COUNT = 'Original_Installment_Count__c';
    private static final String PLAN_TYPE = 'Plan_Type__c';
    private static final String PLAN_VALUE_MODIFIED_DATE = 'Plan_Value_Modified_Date__c';
    private static final String REMAINING_BALANCE = 'Remaining_Balance__c';
    private static final String SIRONO_ID = 'Sirono_ID__c';
    private static final String SKIP_PAYMENT_UNTIL = 'Skip_Payment_Until__c';
    private static final String STATUS = 'Status__c';

    // Below field(s) are use for Select/Read permission.
    private static final String ID = 'Id';
    private static final String REMAINING_INSTALLMENT_COUNT = 'Remaining_Installment_Count__c';

    // The fields for upserting a Payment_Plan__c in AddToPaymentPlan, AddCreditCard, EditPaymentPlan, PaymentPlanGoodStanding & SkipPaymentPlan
    private static final Set<String> UPSERT_FIELDS = new Set<String>{
        ACTIVE, DELINQUENT, DELINQUENT_DATE, ERROR_DATE, EXECUTE_ON_DAY, GUARANTOR, HAS_ERROR, INSTALLMENT_AMOUNT, 
        NAME, NEXTPAYMENTDATE, ORIGINAL_BALANCE, ORIGINAL_INSTALLMENT_COUNT, PLAN_TYPE, REMAINING_BALANCE,
        SIRONO_ID, SKIP_PAYMENT_UNTIL, STATUS, PLAN_VALUE_MODIFIED_DATE
    };

    // The fields for updating a Payment_Plan__c in PayStaffWSUtill
    private static final Set<String> UPDATE_FIELDS = UPSERT_FIELDS;
    
    // The fields for updating a Payment_Plan__c in PaymentPlanUtil
    private static final Set<String> PPU_UPDATE_FIELDS = new Set<String>{
    	REMAINING_BALANCE
    };

    // The fields for updating a Payment_Plan__c in PaymentPlanTriggerHandler
    private static final Set<String> PP_UPDATE_DATES = new Set<String>{
            NEXTPAYMENTDATE, SKIP_PAYMENT_UNTIL, EXECUTE_ON_DAY
    };

    // The fields for updating a Payment_Plan__c in DeletePaymentPlan
    private static final Set<String> DP_UPDATE_FIELDS = new Set<String>{
		ACTIVE, DELINQUENT, DELINQUENT_DATE, ERROR_DATE, EXECUTE_ON_DAY, GUARANTOR, HAS_ERROR, INSTALLMENT_AMOUNT, 
        NAME, NEXTPAYMENTDATE, ORIGINAL_BALANCE, ORIGINAL_INSTALLMENT_COUNT, PLAN_TYPE, REMAINING_BALANCE,
        SIRONO_ID, SKIP_PAYMENT_UNTIL, STATUS, CANCELLATION_DATE
    };

    // The fields for selecting a Payment_Plan__c in PaymentPlanDao
    private static final Set<String> SELECT_FIELDS = new Set<String>{
        ID, SIRONO_ID, ACTIVE, GUARANTOR
    };

    // The fields for selecting a Payment_Plan__c in CallListUtilities
    private static final Set<String> CLU_SELECT_FIELDS = new Set<String>{
        ID, DELINQUENT_DATE, ACTIVE
    };

    // The fields for selecting a Payment_Plan__c in ContactTriggerHandler, PopulateNextPaymentDateBatch
    private static final Set<String> CTH_SELECT_FIELDS = new Set<String>{
        ID, GUARANTOR, PLAN_TYPE, EXECUTE_ON_DAY, NEXTPAYMENTDATE, SKIP_PAYMENT_UNTIL
    };

    // The fields for selecting a Payment_Plan__c in DelinquentPaymentPlansSchedulerBatch
    private static final Set<String> DPPSB_SELECT_FIELDS = new Set<String>{
        ID, NAME, GUARANTOR, DELINQUENT_DATE, REMAINING_BALANCE, ACTIVE
    };

    // The fields for selecting a Payment_Plan__c in EditPaymentPlan
    private static final Set<String> EPP_SELECT_FIELDS = new Set<String>{
        ID, NAME, ORIGINAL_INSTALLMENT_COUNT, REMAINING_BALANCE, NEXTPAYMENTDATE,
        PLAN_TYPE, REMAINING_INSTALLMENT_COUNT, EXECUTE_ON_DAY, SIRONO_ID
    };

    // The fields for selecting a Payment_Plan__c in SkipPaymentPlan
    private static final Set<String> SPP_SELECT_FIELDS = new Set<String>{
        ID, SIRONO_ID, NEXTPAYMENTDATE
    };

    // The fields for selecting a Payment_Plan__c in PaymentPlanJSONParsing
    private static final Set<String> PP_SELECT_FIELDS = new Set<String>{
        ID, SIRONO_ID
    };

    // The fields for selecting a Payment_Plan__c in CaseUtil
    private static final Set<String> CU_SELECT_FIELDS = new Set<String>{
        ID, GUARANTOR, ACTIVE, DELINQUENT
    };

    // The fields for selecting a Payment_Plan__c in CaseUtil
    private static final Set<String> SELECT_FIELDS_FOR_CLOSE = new Set<String>{
        ID, GUARANTOR, ACTIVE, HAS_ERROR, REMAINING_BALANCE
    };

    /**
     * Constructor of class that assign variables based on parameters
     *
     * @param Set<String> fields - That contains Object's Fields
     * @param ACTION actionToPerform - That contains Action Name (Create/Update/Delete/Undelete)
     **/
    private PaymentPlanSecurityContext(Set<String> fields, ACTION actionToPerform) {
        this.fieldsToCheck = fields;
        this.objectAction = actionToPerform;
    }

    /**
     * The upsert context for Payment_Plan__c in AddToPaymentPlan, AddCreditCard, EditPaymentPlan, PaymentPlanGoodStanding & SkipPaymentPlan
     **/
    public static final PaymentPlanSecurityContext UPSERT_CONTEXT = new PaymentPlanSecurityContext(UPSERT_FIELDS, ACTION.OBJ_UPSERT);
    
    /**
     * The update context for Payment_Plan__c in PayStaffWSUtill
     **/
    public static final PaymentPlanSecurityContext UPDATE_CONTEXT = new PaymentPlanSecurityContext(UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * The update context for Payment_Plan__c in DeletePaymentPlan
     **/
    public static final PaymentPlanSecurityContext DP_UPDATE_CONTEXT = new PaymentPlanSecurityContext(DP_UPDATE_FIELDS, ACTION.OBJ_UPDATE);
    
    /**
     * The update context for Payment_Plan__c in PaymentPlanUtil
     **/
    public static final PaymentPlanSecurityContext PPU_UPDATE_CONTEXT = new PaymentPlanSecurityContext(PPU_UPDATE_FIELDS, ACTION.OBJ_UPDATE);


    /**
     * The update context for Payment_Plan__c in PaymentPlanTriggerHandler
     **/
    public static final PaymentPlanSecurityContext PP_UPDATE_DATES_CONTEXT = new PaymentPlanSecurityContext(PP_UPDATE_DATES, ACTION.OBJ_UPDATE);

    /**
     * The select context for Payment_Plan__c in PaymentPlanDao
     **/
    public static final PaymentPlanSecurityContext SELECT_CONTEXT = new PaymentPlanSecurityContext(SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in CallListUtilities
     **/
    public static final PaymentPlanSecurityContext CLU_SELECT_CONTEXT = new PaymentPlanSecurityContext(CLU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in ContactTriggerHandler, PopulateNextPaymentDateBatch
     **/
    public static final PaymentPlanSecurityContext CTH_SELECT_CONTEXT = new PaymentPlanSecurityContext(CTH_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in DelinquentPaymentPlansSchedulerBatch
     **/
    public static final PaymentPlanSecurityContext DPPSB_SELECT_CONTEXT = new PaymentPlanSecurityContext(DPPSB_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in EditPaymentPlan
     **/
    public static final PaymentPlanSecurityContext EPP_SELECT_CONTEXT = new PaymentPlanSecurityContext(EPP_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in SkipPaymentPlan
     **/
    public static final PaymentPlanSecurityContext SPP_SELECT_CONTEXT = new PaymentPlanSecurityContext(SPP_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in PaymentPlanJSONParsing
     **/
    public static final PaymentPlanSecurityContext PP_SELECT_CONTEXT = new PaymentPlanSecurityContext(PP_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in CaseUtil
     **/
    public static final PaymentPlanSecurityContext CU_SELECT_CONTEXT = new PaymentPlanSecurityContext(CU_SELECT_FIELDS, ACTION.OBJ_READ);

    /**
     * The select context for Payment_Plan__c in CaseUtil
     **/
    public static final PaymentPlanSecurityContext SELECT_CONTEXT_FOR_CLOSE = new PaymentPlanSecurityContext(SELECT_FIELDS_FOR_CLOSE, ACTION.OBJ_READ);

    /**
     * Override getObjectType method of SecurityContext class
     **/
    public override System.Type getObjectType() {
        return Payment_Plan__c.class;
    }
}