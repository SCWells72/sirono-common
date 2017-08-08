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

//    public static List<Adjustment__c> parse(String json) {
//        if (!json.contains('[')) {
//            json = '[' + json + ']';
        
//
//        List<PaymentAdjustmentJSONParsing> lstPaymentAdjustmentJson =
//                (List<PaymentAdjustmentJSONParsing>) System.JSON.deserialize(json, List<PaymentAdjustmentJSONParsing>.class);
//
//        List<Adjustment__c> lstPaymentAdjustment = new List<Adjustment__c>();
//        Map<Decimal, string> mapCode = new Map<Decimal, string>();
//
//        if (lstPaymentAdjustmentJson.size() > 0) {
//            for (PaymentAdjustmentJSONParsing objJson : lstPaymentAdjustmentJson) {
//                Adjustment__c objPaymentAdjustment = new Adjustment__c();
//
//                objPaymentAdjustment.Sirono_Id__c = Integer.valueof(parseSironoId(objJson.url, 'adjustments'));
//
//                objPaymentAdjustment.Amount__c = PayStaffWSUtill.convertToDollars(objJson.amount);
//                objPaymentAdjustment.Description__c = objJson.description;
//                if (!String.isBlank(objJson.post_date)) {
//                    objPaymentAdjustment.Post_Date__c = Date.valueof(objJson.post_date);
                
//                mapCode.put(objPaymentAdjustment.Sirono_ID__c, objJson.code);
//
//                lstPaymentAdjustment.add(objPaymentAdjustment);
//            }
//            return lstPaymentAdjustment;
//        }
    
//
//
//    public static String  testResponse() {
//
//        String responseBody =        '[{'+
//        '   "url": "https://toledo.stage.sirono.com/paystaff/api/adjustments/3151479/", ' +
//        '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/51724/",'+
//        '   "amount":100,'+
//        '   "code":"ADM",'+
//        '   "description":null,'+
//        '   "display_kind":"",'+
//        '   "post_date":"2016-10-13"' +
        
//
//        return responseBody;
//    }
}