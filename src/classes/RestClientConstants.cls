/**
 * Class used to hold constants related to the *RestClient Classes.
 */
public with sharing class RestClientConstants {

    // Specific call constants
    public final static String SIRONO_NAMED_CREDS_ID = 'sirono_server';
    public final static String ADD_CHARGEGROUP_KEY = 'add_chargegroup';
    public final static String ADD_PAYMENTPLAN_KEY = 'add_paymentplan';    
    public final static String CHARGEGROUP_KEY = 'chargegroup';
    public final static String CSRF_KEY = 'csrf';
    public final static String GUARANTOR_KEY = 'guarantor';
    public final static String PAY_CHARGEGROUPS_KEY = 'pay_chargegroups';
    public final static String PAYMENT_KEY = 'payment';
    public final static String PAYMENT_TXNS_KEY = 'payment_txns';

    public final static String PAYMENT_PLAN_KEY = 'payment_plan';
    public final static String SIRONO_BASE_URL = 'callout:sirono_server';
    public final static String STATEMENTS = 'statements';
    public final static String TOKEN_KEY = 'token';


    public final static Map<String, String> CHARGE_GROUP_URLS = new Map<String, String>{
            // 0 - the chargegroup sirono id
            CHARGEGROUP_KEY => 'callout:sirono_server/paystaff/api/chargegroups/{0}/'

    };

    public final static Map<String, String> GUARANTOR_URLS = new Map<String, String>{
            // 0 - the guarantor's sirono id
            GUARANTOR_KEY => 'callout:sirono_server/paystaff/api/guarantors/{0}/',
            // 0 - the guarantor's sirono id
            STATEMENTS => 'callout:sirono_server/paystaff/api/guarantors/{0}/statements/'
    };

    public final static Map<String, String> PAYMENT_PLAN_URLS = new Map<String, String>{
            // 0 - the payment plan sirono id
            ADD_CHARGEGROUP_KEY => 'callout:sirono_server/paystaff/api/paymentplan/{0}/add_chargegroups/',
            ADD_PAYMENTPLAN_KEY => 'callout:sirono_server/paystaff/api/paymentplan/',
            // 0 - playmentPlanExtId
            PAYMENT_PLAN_KEY => 'callout:sirono_server/paystaff/api/paymentplan/{0}/'
    };

    public final static Map<String, String> PAYMENT_URLS = new Map<String, String>{
            PAY_CHARGEGROUPS_KEY => 'callout:sirono_server/paystaff/api/paychargegroups/',
            // 0 - payment sirono Id
            PAYMENT_TXNS_KEY => 'callout:sirono_server/paystaff/api/payments/{0}/transactions/'
    };

    public final static Map<String, String> AUTH_URLS = new Map<String, String>{
            CSRF_KEY => 'callout:sirono_server/portal/account/forgot-password/',
            TOKEN_KEY => 'callout:sirono_server/paystaff/token-auth/'
    };

    // JSON and body values
    public final static String CHARGE_GROUPS = 'chargegroups';
    public final static String CSRF_BODY_KEY = '<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
    public final static String CSRF_JSON_KEY = 'csrfmiddlewaretoken';
    public final static String TOKEN_BODY = 'username={!$Credential.Username}&password={!$Credential.Password}';

    // 0 - The JWT token
    public final static String JWT_HEADER = 'JWT {0}';
    public final static String STATEMENTS_JSON =
            '[{"statement_date": "2016-10-07", "pdf_url": "https://accudoc-dev.s3.amazonaws.com/20161007/13_55_13_sir.0x1355137f.pdf?Signature=E5pZzByCMFcRraYK102YGi6lbhE%3D&Expires=1497709690&AWSAccessKeyId=AKIAIG3KNVYUQ4EURDHA"}, '+
            '{"statement_date": "2016-11-07", "pdf_url": "https://accudoc-dev.s3.amazonaws.com/20161107/13_b6_4f_sir.0x13b64f16.pdf?Signature=wMNtKw8X7YepSUH%2FNiJyHE%2FEKBE%3D&Expires=1497709690&AWSAccessKeyId=AKIAIG3KNVYUQ4EURDHA"}, '+
            '{"statement_date": "2016-12-07", "pdf_url": "https://accudoc-dev.s3.amazonaws.com/20161207/14_22_ad_sir.0x1422ad09.pdf?Signature=DQ0kcBk0qnGYo1h7eCjqWrYsg6Q%3D&Expires=1497709690&AWSAccessKeyId=AKIAIG3KNVYUQ4EURDHA"}, ' +
            '{"statement_date": "2017-01-07", "pdf_url": "https://accudoc-dev.s3.amazonaws.com/20170107/14_8c_c7_sir.0x148cc7bb.pdf?Signature=RxHWw3DmeRO9jqpVX4%2FutuCiLiY%3D&Expires=1497709690&AWSAccessKeyId=AKIAIG3KNVYUQ4EURDHA"}, ' +
            '{"statement_date": "2017-02-07", "pdf_url": null}]';

    // HTTP Status Code constants
    public final static Integer HTTP_SUCCESS = 200;
    public final static Integer HTTP_CREATED = 201;
    public final static Integer HTTP_DELETED = 204;
    public final static Integer HTTP_BAD_REQUEST = 400;

    // HTTP types.
    public final static String GET = 'GET';
    public final static String POST = 'POST';
    public final static String PUT = 'PUT';
    public final static String REMOVE = 'DELETE';

    // Header keys and values
    public final static String APPLICATION_JSON = 'application/json';
    public final static String AUTHORIZATION = 'Authorization';
    public final static String CONTENT_TYPE = 'Content-type';
    public final static Integer DEFAULT_TIMEOUT = 120000;

    // Test Constants
    public final static String CHARGE_GROUP_ID = 'charg3gr0up1d';
    public final static String GUARANTOR_ID = String.valueOf(TestUtility.PROFILE_POINTER);
    public final static String PAYMENT_PLAN_EXT_ID = 'paym3ntplan1d';
    public final static String PAYMENT_EXT_ID = 'paym3nt1d';
}