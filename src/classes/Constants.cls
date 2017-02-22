/**
 * Created by justindove on 11/29/16.
 */

public class Constants {

    // Constant variables for account substatus values.
    public static final String ACCT_SUBSTATUS_DUE_BY = 'Due By';
    public static final String ACCT_SUBSTATUS_PAYMENT_PLAN = 'On Payment Plan';
    public static final String ACCT_SUBSTATUS_INACTIVE = 'Inactive';
    public static final String ACCT_SUBSTATUS_OVERDUE = 'Overdue';
    public static final String ACCT_SUBSTATUS_DELINQUENT = 'Delinquent';
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
    
    // Constant variables for Page Level Messages.
    public static final String PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE = 'Amount cannot exceed balance.';
    public static final String PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO = 'Amount must be greater than zero.';
    public static final String PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE = 'Billing Address is a required field.';
    public static final String PAGE_MESSAGE_CREATED_SUCCESSFULLY = 'Created Successfully.';
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

    private Constants() {}
}