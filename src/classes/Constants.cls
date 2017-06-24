/**
 * Created by justindove on 11/29/16.
 */

public class Constants {

    public static final String CALL_CENTER_PS = 'Sirono_Call_Center';
    public static final String CALL_CENTER_LOCAL_PS = 'Sirono_Call_Center_Local';

    // Constant variables for account substatus values.
    public static final String ACCT_SUBSTATUS_DUE_BY = 'Due By';
    public static final String ACCT_SUBSTATUS_PAYMENT_PLAN = Constants.ON_PAYMENT_PLAN;
    public static final String ACCT_SUBSTATUS_INACTIVE = 'Inactive';
    public static final String ACCT_SUBSTATUS_OVERDUE = Constants.OVERDUE;
    public static final String ACCT_SUBSTATUS_DELINQUENT = Constants.DELIQUENT;
    public static final String ACCT_SUBSTATUS_BAD_DEBT = 'Bad Debt';
    public static final String ACCT_SUBSTATUS_OPEN = 'Open';
    public static final String ACCT_SUBSTATUS_DNFB = 'Pending Billing';
    public static final String ACCT_SUBSTATUS_PENDING_INS = 'Pending Insurance';
    public static final String ACCT_SUBSTATUS_UNKNOWN = 'Unknown';
    public static final String ACCT_SUBSTATUS_INS_VERIFY = 'Insurance Verification';
    public static final String ACCT_SUBSTATUS_THIRD_PARTY = 'Third Party Payer';
    public static final String ACCT_SUBSTATUS_CREDIT = 'Credit';
    public static final String ACCT_SUBSTATUS_PAID = 'Paid';
    public static final String ACCT_SUBSTATUS_PREINVOICED = 'Pre-Invoiced';

    // Generic Status values
    public static final String DELIQUENT = 'Delinquent';
    public static final String INVOICE_VOIDED = 'Invoice Voided';
    public static final String ON_PAYMENT_PLAN = 'On Payment Plan';
    public static final String OVERDUE = 'Overdue';

    // Guarantor Status
    public static final String GUARANTOR_STATUS_DUE = 'Due';
    public static final String GUARANTOR_STATUS_DELINQUENT = 'Delinquent';
    public static final String GUARANTOR_STATUS_ON_PAYMENT_PLAN = ON_PAYMENT_PLAN;
    public static final String GUARANTOR_STATUS_OVERDUE = OVERDUE;

    // Constant variables for CG account status values.
    public static final String ACCT_STATUS_BILLED = 'Billed';
    public static final String ACCT_STATUS_PENDING = 'Pending';

    // Constant variables for Encounter Substatus values.
    public static final String EN_SUBSTATUS_PAYMENT_DUE = 'Payment Due';

    // Constant variables for Case Type values.
    public static final String CASE_TYPE_OVERDUE = 'Overdue';
    public static final String CASE_TYPE_PAST_DUE_PAYMENT_PLANS = 'Past Due Payment Plans';

    // Constant variables for Campaign values.
    public static final String CAMPAIGN_NAME_OVERDUE = OVERDUE;
    public static final String CAMPAIGN_NAME_OVERDUE_M = 'Overdue M';
    public static final String CAMPAIGN_NAME_PAST_DUE = 'Past Due';
    public static final String CAMPAIGN_NAME_PAST_DUE_M = 'Past Due M';

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
    public static final String ADJUSTMENT = 'Adjustment';
    public static final String PAYMENT = 'Payment';
    public static final String SERVICE = 'Service';
    public static final String UNKNOWN = 'Unknown';

    //Constants for PaymentPlans
    public static final String AUTOMATIC = 'Automatic';
    public static final String DUE = 'Due';
    public static final String IN_ERROR = 'In Error';
    public static final String MANUAL = 'Manual';
    public static final String PAST_DUE = 'Past Due';
    public static final String PLANTYPE_AUTO = 'auto';
    public static final String PLANTYPE_AUTO_VALUE = 'Auto Draft';
    public static final String PLANTYPE_GOOD_STANDING = 'Good Standing';
    public static final String PLANTYPE_PROMISE = 'promise';
    public static final String PLANTYPE_PROMISE_VALUE = 'Promise To Pay';

    // Constant variable for Security Context Unit Testing Negative Profile.
    public static final String READ_ONLY_PROFILE = 'Read Only';
    public static final String CHATTER_ONLY_USER_PROFILE = 'Chatter Only User';
    public static final String STANDARD_USER = 'Standard User';
    public static final String GUARANTOR_PORTAL_PROFILE = 'Guarantor Community Plus';

    public static final String CREDIT_CARD = 'Credit Card';
    public static final String MONTHS = 'MONTHS';
    public static final String PAID = 'Paid';
    public static final String UNPAID = 'Unpaid';
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
            ACCT_SUBSTATUS_BAD_DEBT,
            ACCT_SUBSTATUS_DELINQUENT,
            ACCT_SUBSTATUS_DUE_BY,
            ACCT_SUBSTATUS_OVERDUE,
            ACCT_SUBSTATUS_PREINVOICED
    };

    // Account Substatus constraints used for adding Discounts
    public static final Set<String> CGConstraintsForDiscount = new Set<String> {
            ACCT_SUBSTATUS_DELINQUENT,
            ACCT_SUBSTATUS_DUE_BY,
            ACCT_SUBSTATUS_OVERDUE,
            ACCT_SUBSTATUS_PAYMENT_PLAN,
            ACCT_SUBSTATUS_PREINVOICED
    };

    // Guarantor Status Overdue
    public static final Set<String> GuarantorStatusOverdue = new Set<String> {
        GUARANTOR_STATUS_DUE,
        GUARANTOR_STATUS_DELINQUENT,
        GUARANTOR_STATUS_OVERDUE
    };

    // Invoice status groups
    public static final Set<String> INVOICE_UNPAID_STATUSES = new Set<String> {
        DELIQUENT,
        OVERDUE,
        DUE,
        ON_PAYMENT_PLAN
    };

    public static final Set<String> INVOICE_PAID_STATUSES = new Set<String> {
        PAID,
        INVOICE_VOIDED
    };
}
