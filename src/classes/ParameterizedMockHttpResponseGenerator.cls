/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
global class ParameterizedMockHttpResponseGenerator implements HttpCalloutMock {
    public static String ADJUSTMENT_KEY = 'adjustment';
    public static String GUARANTOR_KEY = 'guarantor';
    public static String CHARGEGROUP_KEY = 'chargegroup';
    public static String PAYMENTPLAN_KEY = 'paymentplan';
    public static String TRANSACTION_KEY = 'transaction';

    private static Map<String, List<String>> ADJUSTMENT_MAP = new Map<String, List<String>> {
        GUARANTOR_KEY => new String[]{MockHttpResponseGenerator.guarantorSironoId},
        CHARGEGROUP_KEY => new String[]{RestClientConstants.CHARGE_GROUP_ID},
        ADJUSTMENT_KEY => new String[]{'3151479'},
        TRANSACTION_KEY => new String[]{'3874992'},
        PAYMENTPLAN_KEY => new String[]{MockHttpResponseGenerator.planSironoId}
    };

    public static ParameterizedMockHttpResponseGenerator ADJUSTMENT_MOCK = new ParameterizedMockHttpResponseGenerator(ADJUSTMENT_MAP);

    public class TestSironoRestClient extends SironoRestClient {
        /**
         * Provides the URL map to the SironoRestClient class for looking up urls.
         */
        private Map<String, String> getUrls() {
            return RestClientConstants.ADJUSTMENT_URLS;
        }
    }

    //The number of chargegroupIds and the number of Transaction Ids in the idMap need to match
    global ParameterizedMockHttpResponseGenerator(Map<String, List<String>> idMap) {
        this.sironoIdMap = idMap;
    }

    private Map<String, List<String>> sironoIdMap;

    /**
     * This method generates & returns HttpResponse for provided HTTPRequest.
     **/
    global HttpResponse respond(HttpRequest req) {

        if (req.getEndpoint().contains('/paystaff/token-auth/') ||
                req.getEndpoint().contains('/portal/account/forgot-password/')) {
            AuthRestClientMock authMock = new AuthRestClientMock();
            return authMock.respond(req);
        }

        System.debug('ParameterizedMockHttpResponseGenerator HttpRequest:\n'+req);
        // Create a mock response based off the sironoIdMap
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (req.getEndpoint().contains('/paymentplan')) {
            res.setBody(buildPaymentPlanResponse());
        } else if (req.getEndpoint().contains('api/chargegroups')) {
            String[] parts = req.getEndpoint().split('/');
            res.setBody(buildChargeGroupResponse(parts[parts.size()-1]));
        } else if (req.getEndpoint().contains('api/adjustments')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(buildTransactionResponse('adjustment'));
            } else {
                res.setBody(buildAdjustmentResponse());
            }
        } else if (req.getEndpoint().contains('api/paychargegroups')) {
            if (req.getEndpoint().contains('/transactions/')) {
                res.setBody(buildTransactionResponse('payment'));
            } else {
                res.setBody(buildPaymentResponse());
            }
        } else {
            res.setBody(TestUtility.body);
        }

        if (req.getMethod() == 'DELETE') {
            res.setStatusCode(204);
        } else {
            res.setStatusCode(TestUtility.statusCode);
        }

        res.setStatus(TestUtility.status);

        // Check system assert, HttpResponse should not be null.
        System.assertNotEquals(res, null, 'HttpResponse is not generated for submitted HTTPRequest');
        System.debug('ParameterizedMockHttpResponseGenerator response body:\n'+res.getBody());
        return res;
    }

    private String buildAdjustmentURL() {
        return RestClientConstants.ADJUSTMENT_URLS.get(RestClientConstants.ADJUSTMENT_KEY)+sironoIdMap.get(ADJUSTMENT_KEY)[0]+'/';
    }

    private String buildChargeGroupURL(String cgId) {
        return new TestSironoRestClient().asChargeGroupURL(cgId);
    }

    private String buildGuarantorURL() {
        return new TestSironoRestClient().asGuarantorURL(sironoIdMap.get(GUARANTOR_KEY)[0]);
    }

    private String buildPaymentPlanURL() {
        return new TestSironoRestClient().asPaymentPlanURL(sironoIdMap.get(PAYMENTPLAN_KEY)[0]);
    }

    private String buildTransactionURL(String txnId) {
        return String.format(RestClientConstants.TRANSACTION_URLS.get(TRANSACTION_KEY), new String[]{txnId});
    }

    private PaymentPlanService.PaymentPlanSironoJSON buildDefaultPlan() {
        PaymentPlanService.PaymentPlanSironoJSON jw = new PaymentPlanService.PaymentPlanSironoJSON();
        jw.active = true;
        jw.installment_amount = 5000;
        jw.number_installments = 7;
        jw.plan_value = 45000;
        jw.plan_type = 'auto';
        jw.payable_amount = jw.plan_value;
        jw.execute_on_day = 13;
        jw.next_payment_date = '2016-05-13';
        jw.installments_paid = 0;
        jw.installments_total = 7;
        jw.credit_card = new PaymentPlanService.Credit_Card();
        jw.credit_card.card_type = 'Visa';
        jw.credit_card.last_4 = '1881';
        jw.has_error = false;
        jw.charges_added_since_start = null;
        jw.delinquent = false;
        jw.encounters = new List<PaymentPlanService.Encounters>();
        jw.authorized_amount = 0;
        jw.skip_payment_until = '2016-12-01';
        jw.status = 'started';

        return jw;
    }

    private String buildPaymentPlanResponse() {
        PaymentPlanService.PaymentPlanSironoJSON jw = buildDefaultPlan();
        jw.url = buildPaymentPlanURL();
        jw.guarantor = buildGuarantorURL();

        List<String> cgUrls = new List<String>();
        for (String cgId : sironoIdMap.get(CHARGEGROUP_KEY)) {
            cgUrls.add(buildChargeGroupURL(cgId));
        }
        jw.chargegroups = cgUrls;

        return System.JSON.serializePretty(jw);
    }

    private String buildAdjustmentResponse() {
        AdjustmentService.AdjJsonWrapper aw = new AdjustmentService.AdjJsonWrapper();
        aw.url = buildAdjustmentURL();
        aw.chargegroup = buildChargeGroupURL(sironoIdMap.get(CHARGEGROUP_KEY)[0]);
        aw.amount = 125;
        aw.code = 'ADM';
        aw.description = 'BC/BS adjustment';
        aw.post_date = '2016-10-13';

        return System.JSON.serializePretty(aw);
    }

    private String buildDiscountResponse() {
        List<AdjustmentService.AdjJsonWrapper> aws = new List<AdjustmentService.AdjJsonWrapper>();
        for (String cgId : sironoIdMap.get(CHARGEGROUP_KEY)) {
            AdjustmentService.AdjJsonWrapper aw = new AdjustmentService.AdjJsonWrapper();
            aw.url = buildAdjustmentURL();
            aw.chargegroup = buildChargeGroupURL(cgId);
            aw.amount = 125;
            aw.code = 'DIS';
            aw.description = 'Prompt Payment Discount';
            aw.post_date = '2016-10-13';

            aws.add(aw);
        }

        return System.JSON.serializePretty(aws);
    }

    private String buildTransactionResponse(String method) {
        List<TransactionJSONParser.TransactionJSON> txnList = new List<TransactionJSONParser.TransactionJSON>();
        for (Integer i=0; i < sironoIdMap.get(TRANSACTION_KEY).size(); i++) {
            TransactionJSONParser.TransactionJSON tj = new TransactionJSONParser.TransactionJSON();
            tj.url = buildTransactionURL(sironoIdMap.get(TRANSACTION_KEY)[i]);
            tj.amount = 125;
            tj.post_date = '2016-10-13T12:41:22.562824';
            tj.fail_date = null;
            tj.export_date = null;
            tj.created_at = '2016-10-13T12:41:22.562824';
            tj.modified_at = '2016-10-13T12:41:22.562824';
            tj.method = method;
            tj.notes = null;
            tj.credit_balance = false;
            tj.chargegroup = buildChargeGroupURL(sironoIdMap.get(CHARGEGROUP_KEY)[i]);

            txnList.add(tj);
        }

        return System.JSON.serializePretty(txnList);
    }

    private String buildChargeGroupResponse(String cgId) {
        return JSON.serializePretty(buildChargeGroupJSON(cgId));
    }

    private ChargeGroupJSONParser.ChargeGroupJSON buildChargeGroupJSON(String cgId) {
        ChargeGroupJSONParser.ChargeGroupJSON cgJson = new ChargeGroupJSONParser.ChargeGroupJSON();
        cgJson.url = buildChargeGroupURL(cgId);
        cgJson.account_type = 'HB';
        cgJson.account_number = 'A1322100179';
        cgJson.active = true;
        cgJson.status = 'Paid';
        cgJson.extended_status = 'Paid';
        cgJson.pas_specific_origin_code = 'HBO';
        cgJson.balance = 0;
        cgJson.invoice = new ChargeGroupJSONParser.Invoice();
        cgJson.invoice.invoice_date = '2015-08-20';
        cgJson.invoice.due_date = '2015-09-10';
        cgJson.bad_debt_status = false;
        cgJson.date_of_service_start = '2013-08-09';
        cgJson.date_of_service_end = '2013-08-09';
        cgJson.charges_since_paymentplan = false;
        cgJson.mapped_location_or_provider = 'MakanaHealth Science Center';
        cgJson.processed_charges_details = 'Nationwide has finished processing these charges.';
        cgJson.patient_data = new ChargeGroupJSONParser.Patient_data();
        cgJson.patient_data.mrn = 'MH01026426';
        cgJson.patient_data.patient_name = 'PEYTON MANNING';
        cgJson.guarantor_data = new ChargeGroupJSONParser.Guarantor_data();
        cgJson.guarantor_data.url = buildGuarantorURL();
        cgJson.guarantor_data.display_id = 'MH'+sironoIdMap.get(GUARANTOR_KEY)[0];
        cgJson.guarantor_data.full_name = 'Peyton Manning';
        cgJson.account_status = 'Billed';
        cgJson.account_sub_status = 'Billed';
        if (sironoIdMap.containsKey(PAYMENTPLAN_KEY)) {
            cgJson.paymentplan = buildPaymentPlanURL();
        }

        return cgJson;
    }

    private String buildPaymentResponse() {
        return PaymentJSONParsing.testResponse();
    }
}