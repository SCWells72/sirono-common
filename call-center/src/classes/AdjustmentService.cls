/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class AdjustmentService extends AbstractService {
    @TestVisible
    private class AdjustmentRestClient extends SironoRestClient {

        /**
         * Provides the URL map to the HttpSirono class for looking up urls.
         */
        @TestVisible
        private Map<String, String> getUrls() {
            return RestClientConstants.ADJUSTMENT_URLS;
        }

        /**
         * Make the call to add an Adjustment
         *
         * @param PaymentPlanInformation ppInfo - An object that holds the information required to create a payment plan.
         * @return HttpResponse The response to the call.
         **/
        @TestVisible
        private HttpResponse addAdjustment(AdjustmentRequest info) {

            return postRequestor()
                .url(RestClientConstants.ADJUSTMENT_KEY, new String[] {})
                .body(buildAddAdjustmentBody(info))
                .call();
        }

        /**
         * Get the transactions for the given Adjustment
         *
         * @param String Adjustment SironoId
         * @return HttpResponse The response to the call.
         **/
        @TestVisible
        private HttpResponse getTransactions(String adjSironoId) {

            return getRequestor()
                .url(RestClientConstants.ADJUSTMENT_TXNS_KEY, new String[] { adjSironoId })
                .call();
        }

        /**
         * Build the JSON structure required to add an adjustment.
          *
          * @param - info  The AdjustmentRequest
          * @return - The Json payload.
         */
        @TestVisible
        private String buildAddAdjustmentBody(AdjustmentRequest info) {
            Map<String, Object> rawData = new Map<String, Object> {
                RestClientConstants.AMOUNT => convertToCents(info.adjustmentAmount),
                RestClientConstants.CHARGE_GROUP => asChargeGroupURL(info.chargeGroupSironoId.toPlainString()),
                RestClientConstants.CODE => info.adjustmentCode,
                RestClientConstants.CSRF_JSON_KEY => getCsrf()
            };

            String body = JSON.serializePretty(rawData);
            System.debug('addAdjustmentBody: ' + body);
            return body;
        }
    }

    //TODO add the aggregateId when it is added to the response
    @TestVisible
    private class AdjJsonWrapper {
        public String url;
        public Integer amount;
        public String code;
        public String description;
        public String post_date;
        public String chargegroup;
    }

    /**
     * JSON Parsing Class for the response which comes from Adjustment/Discount Request.
     */
    @TestVisible
    private class AdjustmentResponseParser extends AbstractSironoJSONParser {

        private String jsonString;

        public Adjustment__c newAdjustment;
        public String adjSironoId;
        public String cgSironoId;

        @TestVisible
        public AdjustmentResponseParser(String jsonString) {
            this.jsonString = jsonString;
        }

        public void parse() {
            AdjJsonWrapper wrapper = (AdjJsonWrapper) System.JSON.deserialize(jsonString, AdjJsonWrapper.class);
            //TODO we need to add the aggregateId to the JSON response body
            newAdjustment = new Adjustment__c(Description__c = wrapper.description,
                Amount__c = convertToDollars(wrapper.amount),
                Post_Date__c = parseDate(wrapper.post_date));
            System.debug('adj parsed');
            adjSironoId = parseSironoId(wrapper.url, RestClientConstants.ADJUSTMENT_URL_RESOURCE_TYPE);
            System.debug('adj id: ' + adjSironoId);

            cgSironoId = parseSironoId(wrapper.chargegroup, RestClientConstants.CHARGE_GROUP_URL_RESOURCE_TYPE);
            System.debug('cg id: ' + cgSironoId);
        }
    }

    public class AdjustmentRequest {
        public AdjustmentRequest(Id gtId, Decimal cgSironoId, String adjCode, Decimal adjAmount) {
            this.guarantorId = gtId;
            this.chargeGroupSironoId = cgSironoId;
            this.adjustmentCode = adjCode;
            this.adjustmentAmount = adjAmount;
        }

        Id guarantorId;
        Decimal chargeGroupSironoId;
        String adjustmentCode;
        Decimal adjustmentAmount;

        public Boolean isValid() {
            return chargeGroupSironoId != null && !String.isBlank(adjustmentCode) && adjustmentAmount > 0 && guarantorId != null;
        }
    }

    //TODO not ready for primetime
//    public static void createDiscount(DiscountRequest request) {
//        if (!request.isValid()) {
//            throw new ServiceException('DiscountRequest is invalid');
//        }
//
//    }

    public static void createAdjustment(AdjustmentRequest request) {
        if (!request.isValid()) {
            throw new ServiceException('AdjustmentRequest is invalid');
        }

        //Create the adjustment in Sirono
        AdjustmentResponseParser parser = createSironoAdjustment(request);

        Adjustment__c adj = parser.newAdjustment;
        adj.Guarantor__c = request.guarantorId;

        Payment_Plan__c originalPaymentPlan = null;
        // Read the cg from the db to get the GTExternalId & PP Id
        List<Charge_Group__c> dbChargeGroups = ChargeGroupDao.getBySironoIds(new List<Decimal> { Decimal.valueOf(parser.cgSironoId) });
        if (dbChargeGroups[0].Payment_Plan__c != null) {
            originalPaymentPlan = PaymentPlanService.retrievePlan(dbChargeGroups[0].Payment_Plan__r.Sirono_ID__c);

            dbChargeGroups = ChargeGroupDao.getByPaymentPlanIds(new Set<Id> { dbChargeGroups[0].Payment_Plan__c });
        }

        List<Charge_Group__c> cgsToUpdate = new List<Charge_Group__c>();

        // Retrieve the affected chargegroup from sirono so that we get the proper status/substatus for them
        for (Charge_Group__c cg : dbChargeGroups) {
            ChargeGroupJSONParser.ChargeGroupJSON cgp = ChargeGroupService.retrieveBySironoId(parser.cgSironoId);
            Charge_Group__c cgToUpdate = new ChargeGroupJSONParser().asChargeGroup(cgp);
            cgToUpdate.Id = cg.Id;
            cgsToUpdate.add(cgToUpdate);
        }

        //retrieve the adjustment transactions from sirono
        List<Transaction__c> transactions = retrieveAdjustmentTransactions(parser.adjSironoId);

        //TODO hack the aggregateId
        List<String> aggregateIdStrings = new List<String>();
        if (dbChargeGroups[0].External_Guarantor_ID__r != null) {
            aggregateIdStrings.add(dbChargeGroups[0].External_Guarantor_ID__r.External_Guarantor_Id__c.toPlainString());
        } else {
            aggregateIdStrings.add('');
        }
        aggregateIdStrings.add(Datetime.newInstance(adj.Post_Date__c, Time.newInstance(0, 0, 0, 0)).format('YYYYMMdd'));
        if (adj.Payor__c != null) {
            //TODO get the payor's SironoId
        } else {
            aggregateIdStrings.add('');
        }

        String aggregateId = String.join(aggregateIdStrings, ':');
        System.debug('aggregateId: ' + aggregateId);
        adj.Aggregate_Id__c = aggregateId;

        //TODO hack until the ExternalGT is returned via the api
        adj.External_Guarantor__c = dbChargeGroups[0].External_Guarantor_ID__c;
        AdjustmentDao.save(new List<Adjustment__c> { adj });
        System.debug('Saved adj, Id: ' + adj.Id);

        if (originalPaymentPlan != null) {
            System.debug('Updated pp, Id: ' + originalPaymentPlan.Id);
            PaymentPlanDao.updateAll(new List<Payment_Plan__c> { originalPaymentPlan });
        }
        System.debug('Updating ' + cgsToUpdate.size() + ' chargegroups');
        ChargeGroupDao.updateChargeGroups(cgsToUpdate);

        for (Transaction__c txn : transactions) {
            txn.Adjustment2__c = adj.Id;
        }
        System.debug('Saving ' + transactions.size() + ' transactions');
        TransactionDao.save(transactions);
    }

    private static AdjustmentResponseParser createSironoAdjustment(AdjustmentRequest request) {
        //Create the adjustment
        AdjustmentRestClient client = new AdjustmentRestClient();
        HttpResponse response = client.addAdjustment(request);
        System.debug('addAdjustment response: ' + response.getBody());
        AdjustmentResponseParser parser = new AdjustmentResponseParser(response.getBody());
        parser.parse();
        return parser;
    }

    private static List<Transaction__c> retrieveAdjustmentTransactions(String adjSironoId) {
        //retrieve the adjustment transactions from sirono
        AdjustmentRestClient client = new AdjustmentRestClient();
        HttpResponse response = client.getTransactions(adjSironoId);

        TransactionJSONParser txnParser = new TransactionJSONParser(response.getBody());
        return txnParser.parse();
    }
}