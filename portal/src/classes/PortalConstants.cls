/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class PortalConstants {

    public static final String ACCT_SUBSTATUS_PREINVOICED = 'Pre-Invoiced';

    // Generic Status values
    public static final String DELINQUENT = 'Delinquent';
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

    // Constant variables for Encounter Substatus values.

    // Constant variables for Page Level Messages.
    public static final String PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO = 'Amount must be greater than zero.';
    public static final String PAGE_MESSAGE_CREATED_FAIL = 'Payment was not created.';

    // Constant variables for Credit Card Validation Messages.
    public static final String PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS = 'Credit card number must be 12-19 digits.';

    // Constant variables for transaction method (txn_method) values.
    public static final String SERVICE = 'Service';
    public static final String UNKNOWN = 'Unknown';

    //Constants for PaymentPlans
    public static final String AUTOMATIC = 'Automatic';
    public static final String DUE = 'Due';
    public static final String IN_ERROR = 'In Error';
    public static final String MANUAL = 'Manual';
    public static final String PAST_DUE = 'Past Due';
    public static final String PLANTYPE_AUTO = 'auto';
    public static final String PLANTYPE_GOOD_STANDING = 'Good Standing';
    public static final String PLANTYPE_PROMISE = 'promise';

    public static final String CREDIT_CARD = 'Credit Card';
    public static final String MONTHS = 'MONTHS';
    public static final String PAID = 'Paid';
    public static final String UNPAID = 'Unpaid';
    public static final String YEARS = 'YEARS';

    // Guarantor Status Overdue
    public static final Set<String> GuarantorStatusOverdue = new Set<String> {
        GUARANTOR_STATUS_DUE,
        GUARANTOR_STATUS_DELINQUENT,
        GUARANTOR_STATUS_OVERDUE
    };

    // Invoice status groups
    public static final Set<String> INVOICE_UNPAID_STATUSES = new Set<String> {
        DELINQUENT,
        OVERDUE,
        DUE,
        ON_PAYMENT_PLAN
    };

    public static final Set<String> INVOICE_PAID_STATUSES = new Set<String> {
        PAID,
        INVOICE_VOIDED
    };

    //Constants for Guarantor profile
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
    
    public static final String RECORD_TYPE_GUARANTOR = 'Guarantor';
    public static final String RECORD_TYPE_PATIENT = 'Patient';
    public static final String RECORD_TYPE_EXTERNAL_GUARANTOR = 'External Guarantor';
}
