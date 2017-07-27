/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Adjustment/Discount Request.
 */
public class PaymentAdjustmentJSONParsing {

    public String url;
    public Integer amount;
    public String code;
    public String description;
    public String post_date;

    public static List<Payment_Adjustments__c> parse(String json) {
        if (!json.contains('[')) {
            json = '[' + json + ']';
        }

        List<PaymentAdjustmentJSONParsing> lstPaymentAdjustmentJson =
            (List<PaymentAdjustmentJSONParsing>) System.JSON.deserialize(json, List<PaymentAdjustmentJSONParsing>.class);

        List<Payment_Adjustments__c> lstPaymentAdjustment = new List<Payment_Adjustments__c>();
        Map<Decimal, String> mapCode = new Map<Decimal, String>();

        if (lstPaymentAdjustmentJson.size() > 0) {
            for (PaymentAdjustmentJSONParsing objJson : lstPaymentAdjustmentJson) {
                Payment_Adjustments__c objPaymentAdjustment = new Payment_Adjustments__c();

                objPaymentAdjustment.Sirono_ID__c = Integer.valueOf(getExternalID(objJson.url, 'adjustments'));
                objPaymentAdjustment.Name = getExternalID(objJson.url, 'adjustments');
                objPaymentAdjustment.Amount__c = PayStaffWSUtill.convertToDollars(objJson.amount);
                objPaymentAdjustment.Description__c = objJson.description;
                if (!String.isBlank(objJson.post_date)) {
                    objPaymentAdjustment.Post_Date__c = Date.valueOf(objJson.post_date);
                }
                mapCode.put(objPaymentAdjustment.Sirono_ID__c, objJson.code);

                lstPaymentAdjustment.add(objPaymentAdjustment);
            }

        }
        return lstPaymentAdjustment;
    }

    public static String getExternalID(String url, String splitWith) {
        String[] externalID = url.split(splitWith);
        return externalID[externalID.size() - 1].replaceAll('/', '');
    }

    public static String testResponse() {

        String responseBody = '[{' +
            '   "url": "https://toledo.stage.sirono.com/paystaff/api/adjustments/3151479/", ' +
            '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/51724/",' +
            '   "amount":100,' +
            '   "code":"ADM",' +
            '   "description":null,' +
            '   "display_kind":"",' +
            '   "post_date":"2016-10-13"' +
            '}]';

        return responseBody;
    }
}