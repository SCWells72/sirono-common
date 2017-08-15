/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Adjustment/Discount Request.
 */
public class AdjustmentJSONParser extends AbstractSironoJSONParser {

    private String jsonString;

    private class JSONWrapper {
        String url;
        Integer amount;
        //noinspection ApexUnusedDeclaration
        String code;
        String description;
        String post_date;
        String chargegroup;
    }

    public class AdjustmentWrapper {
        public AdjustmentJSONParser.AdjustmentWrapper(Adjustment__c adj, Decimal sironoId, Decimal cgSironoId) {
            this.sironoId = sironoId;
            this.adjustment = adj;
            this.cgSironoId = cgSironoId;
        }

        public Decimal sironoId { set; get; }
        public Decimal cgSironoId { set; get; }
        public Adjustment__c adjustment { set; get; }
    }

    public AdjustmentJSONParser(String jsonString) {
        this.jsonString = jsonString;
    }

    public List<AdjustmentWrapper> parse() {

        List<JSONWrapper> jsonWrappers =
            (List<JSONWrapper>) System.JSON.deserialize(ensureJsonList(jsonString), List<JSONWrapper>.class);

        List<AdjustmentWrapper> adjustments = new List<AdjustmentWrapper>();

        for (JSONWrapper adjJsonWrapper : jsonWrappers) {
            Adjustment__c adj = new Adjustment__c(Description__c = adjJsonWrapper.description,
                Amount__c = convertToDollars(adjJsonWrapper.amount),
                Post_Date__c = parseDate(adjJsonWrapper.post_date));
            Decimal sironoId = Decimal.valueOf(parseSironoId(adjJsonWrapper.url, RestClientConstants.ADJUSTMENT_URL_RESOURCE_TYPE));
            Decimal cgSironoId = Decimal.valueOf(parseSironoId(adjJsonWrapper.chargegroup, RestClientConstants.CHARGE_GROUP_URL_RESOURCE_TYPE));

            AdjustmentWrapper adjWrapper = new AdjustmentWrapper(adj, sironoId, cgSironoId);
            adjustments.add(adjWrapper);
        }
        return adjustments;
    }
}