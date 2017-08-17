/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class Constants {

    // The name of the required Sirono Integration user
    public static final String SIRONO_INTEGRATION_USER_NAME = 'Sirono Integration';

    public static final String CALL_CENTER_PS = 'Sirono_Call_Center';
    public static final String CALL_CENTER_LOCAL_PS = 'Sirono_Call_Center_Local';

    // Constant variables for account substatus values.
    public static final String ACCT_SUBSTATUS_DUE_BY = 'Due By';
    public static final String ACCT_SUBSTATUS_PAYMENT_PLAN = Constants.ON_PAYMENT_PLAN;
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_INACTIVE = 'Inactive';
    public static final String ACCT_SUBSTATUS_OVERDUE = Constants.OVERDUE;
    public static final String ACCT_SUBSTATUS_DELINQUENT = Constants.DELIQUENT;
    public static final String ACCT_SUBSTATUS_BAD_DEBT = 'Bad Debt';
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_OPEN = 'Open';
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_DNFB = 'Pending Billing';
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_PENDING_INS = 'Pending Insurance';
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_UNKNOWN = 'Unknown';
    //noinspection ApexUnusedDeclaration
    public static final String ACCT_SUBSTATUS_INS_VERIFY = 'Insurance Verification';
    public static final String ACCT_SUBSTATUS_THIRD_PARTY = 'Third Party Payer';
    public static final String ACCT_SUBSTATUS_CREDIT = 'Credit';
    public static final String ACCT_SUBSTATUS_PAID = 'Paid';
    public static final String ACCT_SUBSTATUS_PREINVOICED = 'Pre-Invoiced';

    // Generic Status values
    public static final String DELIQUENT = 'Delinquent';
    //noinspection ApexUnusedDeclaration
    public static final String INVOICE_VOIDED = 'Invoice Voided';
    public static final String ON_PAYMENT_PLAN = 'On Payment Plan';
    public static final String OVERDUE = 'Overdue';

    // Guarantor Status
    //noinspection ApexUnusedDeclaration
    public static final String GUARANTOR_STATUS_DUE = 'Due';
    //noinspection ApexUnusedDeclaration
    public static final String GUARANTOR_STATUS_DELINQUENT = 'Delinquent';
    //noinspection ApexUnusedDeclaration
    public static final String GUARANTOR_STATUS_ON_PAYMENT_PLAN = ON_PAYMENT_PLAN;
    //noinspection ApexUnusedDeclaration
    public static final String GUARANTOR_STATUS_OVERDUE = OVERDUE;

    // Constant variables for CG account status values.
    public static final String ACCT_STATUS_BILLED = 'Billed';
    public static final String ACCT_STATUS_PENDING = 'Pending';

    // Constant variables for Encounter Substatus values.
    public static final String EN_SUBSTATUS_PAYMENT_DUE = 'Payment Due';

    // Constant variables for Case Type values.
    public static final String CASE_TYPE_ENCOUNTER = 'Encounter';
    public static final String CASE_TYPE_OVERDUE = 'Overdue';
    public static final String CASE_TYPE_PAST_DUE_PAYMENT_PLANS = 'Past Due Payment Plans';
    public static final String CASE_TYPE_PAYMENT_PLAN_ERROR = 'Payment Plan Error';
    public static final String CASE_TYPE_PRECOLLECTIONS = 'Precollections';

    //Map of CaseType to ChargeGroup substatus (TODO should this go in the metadata instead?)
    public static final Map<String, String> CASE_CG_SUBSTATUS = new Map<String, String> {
        // 0 - the chargegroup sirono id
        CASE_TYPE_OVERDUE => ACCT_SUBSTATUS_OVERDUE,
        CASE_TYPE_PRECOLLECTIONS => ACCT_SUBSTATUS_DELINQUENT,
        CASE_TYPE_PAYMENT_PLAN_ERROR => ACCT_SUBSTATUS_PAYMENT_PLAN
    };

    // Case.Status values
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';

    // Case.Origin values
    public static final String CASE_ORIGIN_EMAIL = 'Email';
    public static final String CASE_ORIGIN_PHONE = 'Phone';

    // Case.Priority values
    public static final String CASE_PRIORITY_MEDIUM = 'Medium';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_PRIORITY_NORMAL = 'Normal';

    // Case.Reason values
    public static final String CASE_REASON_BANKRUPTCY = 'Bankruptcy';
    public static final String CASE_REASON_CLOSED_AUTOMATED = 'Closed - Automated';
    public static final String CASE_REASON_COMPLIANCE_ISSUE = 'Compliance Issue';
    public static final String CASE_REASON_CASE_CLOSED_EXHAUSTED = 'Case Closed - Exhausted';
    public static final String CASE_REASON_CASE_CLOSED_FINAL = 'Case Closed - FINAL';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_INSURANCE_AGENT_CALLED = 'Insurance Agent Called';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_INSURANCE_ERROR = 'Insurance Error';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_MAILED_FORM_REQUEST_CHARITY_APPLICATION = 'Mailed Form Request: Charity Application';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_MAILED_FORM_REQUEST_RECEIPT = 'Mailed Form Request: Receipt';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_MERGE_REQUEST = 'Merge Request';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_MISSING_PAYMENT = 'Missing Payment';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_MOVE_PAYMENT = 'Move Payment';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_NEW_INSURANCE = 'New Insurance';
    //noinspection ApexUnusedDeclaration
    public static final String CASE_REASON_PATIENT_IS_DECEASED = 'Patient is Deceased';

    // Case.Subject values
    public static final String CASE_SUBJECT_ENCOUNTER = 'Encounter';
    public static final String CASE_SUBJECT_GUARANTOR_DELINQUENT = 'Guarantor: Delinquent';
    public static final String CASE_SUBJECT_GUARANTOR_OVERDUE = 'Guarantor: Overdue';
    public static final String CASE_SUBJECT_PAST_DUE_PAYMENT_PLANS = 'Past Due Payment Plans';
    public static final String CASE_SUBJECT_PAYMENT_PLAN_ERROR = 'Payment Plan Error';

    // Constant variables for Campaign values.
    public static final String CAMPAIGN_NAME_OVERDUE = OVERDUE;
    public static final String CAMPAIGN_NAME_OVERDUE_M = 'Overdue M';
    public static final String CAMPAIGN_NAME_PAST_DUE = 'Past Due';
    public static final String CAMPAIGN_NAME_PAST_DUE_M = 'Past Due M';
    public static final String CAMPAIGN_NAME_PAYMENT_PLAN_ERROR = 'Payment Plan Error';
    public static final String CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M = 'Payment Plan Error M';
    public static final String CAMPAIGN_NAME_PRECOLLECTIONS = 'PreCollections';
    public static final String CAMPAIGN_NAME_PRECOLLECTIONS_M = 'PreCollections M';
    public static final String CAMPAIGN_NAME_PRESERVICE = 'PreService';
    public static final String CAMPAIGN_NAME_PRESERVICE_M = 'PreService M';

    // Constants for Group
    public static final String GROUP_TYPE_QUEUE = 'Queue';

    // Constant variables for Page Level Messages.
    public static final String PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE = 'Amount cannot exceed balance.';
    public static final String PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO = 'Amount must be greater than zero.';
    public static final String PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE = 'Billing Address is a required field.';
    public static final String PAGE_MESSAGE_CG_REQUIRE = 'Charge Group is a required field.';
    public static final String PAGE_MESSAGE_CREATED_SUCCESSFULLY = 'Created Successfully.';
    public static final String PAGE_MESSAGE_CREATED_FAIL = 'Payment was not created.';
    public static final String PAGE_MESSAGE_EXECUTE_ON_DAY = 'Date to Charge (each month) must be a number between 1 and 31.';
    public static final String PAGE_MESSAGE_MAX_INSTALLMENT = 'This monthly amount would exceed {0} installments.' +
        ' The minimum allowed installment amount is ${1}.';
    public static final String PAGE_MESSAGE_MONTHLY_AMOUNT = 'Monthly amount must be equal to or greater than ${0}.';
    public static final String PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT = 'Zip code must be 5 digits.';
    public static final String PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC = 'Zip code can only contain numeric values.';
    public static final String PAGE_MESSAGE_ZIP_CODE_REQUIRE = 'Zip Code is a required field.';

    // Constant variables for Credit Card Validation Messages.
    public static final String PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS = 'Credit card number must be 12-19 digits.';
    public static final String PAGE_MESSAGE_CC_NUMBER_REQUIRE = 'Card Number is a required field.';
    public static final String PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT = 'CVV must be 4 digits for American Express and 3 digits for other card types.';
    public static final String PAGE_MESSAGE_CC_CVV_REQUIRE = 'CVV is a required field.';
    public static final String PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE = 'Expiration date must be in the future.';
    public static final String PAGE_MESSAGE_CC_NAME_REQUIRE = 'Name is a required field.';

    // Constant variables for transaction method (txn_method) values.
    //noinspection ApexUnusedDeclaration
    public static final String ADJUSTMENT = 'Adjustment';
    //noinspection ApexUnusedDeclaration
    public static final String PAYMENT = 'Payment';
    public static final String SERVICE = 'Service';
    //noinspection ApexUnusedDeclaration
    public static final String UNKNOWN = 'Unknown';

    //Constants for PaymentPlans
    public static final String AUTOMATIC = 'Automatic';
    //noinspection ApexUnusedDeclaration
    public static final String DUE = 'Due';
    //noinspection ApexUnusedDeclaration
    public static final String IN_ERROR = 'In Error';
    public static final String MANUAL = 'Manual';
    //noinspection ApexUnusedDeclaration
    public static final String PAST_DUE = 'Past Due';
    public static final String PLANTYPE_AUTO = 'auto';
    public static final String PLANTYPE_AUTO_VALUE = 'Auto Draft';
    //noinspection ApexUnusedDeclaration
    public static final String PLANTYPE_GOOD_STANDING = 'Good Standing';
    public static final String PLANTYPE_PROMISE = 'promise';
    public static final String PLANTYPE_PROMISE_VALUE = 'Promise To Pay';
    public static final String SENT = 'Sent';

    // Constants for record types
    public static final String RECORD_TYPE_AUTOMATED_CASES = Constants.RECORD_TYPE_AUTOMATED_CASES;

    // Constants for Task
    public static final String TASK_PRIORITY_NORMAL = 'Normal';
    public static final String TASK_STATUS_NEW = 'New';

    // Constant variable for Security Context Unit Testing Negative Profile.
    public static final String READ_ONLY_PROFILE = 'Read Only';
    public static final String CHATTER_ONLY_USER_PROFILE = 'Chatter Only User';
    public static final String STANDARD_USER = 'Standard User';
    public static final String GUARANTOR_PORTAL_PROFILE = 'Customer Community Login User';

    // Constants for permission set names
    public static final String PERMISSION_SET_GUARANTOR = 'Guarantor';
    public static final String PERMISSION_SET_GUARANTOR_LOCAL = 'Guarantor_Local';
    public static final String[] PERMISSION_SETS_GUARANTOR = new String[] {
        PERMISSION_SET_GUARANTOR,
        PERMISSION_SET_GUARANTOR_LOCAL
    };

    public static final String PERMISSION_SET_SIRONO_ADMIN = 'Sirono_Administrator';
    public static final String PERMISSION_SET_SIRONO_ADMIN_LOCAL = 'Sirono_Administrator_Local';

    public static final String[] PERMISSION_SETS_SIRONO_ADMIN = new String[] {
        PERMISSION_SET_SIRONO_ADMIN,
        PERMISSION_SET_SIRONO_ADMIN_LOCAL
    };

    public static final String CREDIT_CARD = 'Credit Card';
    //noinspection ApexUnusedDeclaration
    public static final String MONTHS = 'MONTHS';
    public static final String PAID = 'Paid';
    public static final String UNPAID = 'Unpaid';
    //noinspection ApexUnusedDeclaration
    public static final String YEARS = 'YEARS';

    // Account Substatus constraints used for Cases
    public static final Set<String> CGConstraintsForCase = new Set<String> {
        ACCT_SUBSTATUS_BAD_DEBT,
        ACCT_SUBSTATUS_DELINQUENT,
        ACCT_SUBSTATUS_DUE_BY,
        ACCT_SUBSTATUS_OVERDUE,
        ACCT_SUBSTATUS_PAYMENT_PLAN,
        ACCT_SUBSTATUS_PREINVOICED
    };

    // Account Substatus constraints used for making Payments & adding to PPlans
    public static final Set<String> CGConstraints = new Set<String> {
        ACCT_SUBSTATUS_DELINQUENT,
        ACCT_SUBSTATUS_DUE_BY,
        ACCT_SUBSTATUS_OVERDUE
    };

    // Account Substatus constraints used for adding Discounts
    public static final Set<String> CGConstraintsForDiscount = new Set<String> {
        ACCT_SUBSTATUS_DELINQUENT,
        ACCT_SUBSTATUS_DUE_BY,
        ACCT_SUBSTATUS_OVERDUE,
        ACCT_SUBSTATUS_PAYMENT_PLAN,
        ACCT_SUBSTATUS_PREINVOICED
    };

    public static final String RECORD_TYPE_GUARANTOR = 'Guarantor';
    public static final String RECORD_TYPE_PATIENT = 'Patient';
    public static final String RECORD_TYPE_EXTERNAL_GUARANTOR = 'External Guarantor';
}
