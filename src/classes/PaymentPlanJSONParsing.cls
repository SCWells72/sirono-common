/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Request. 
 */
public class PaymentPlanJSONParsing {

    public String url;
    public Boolean active;
    public Integer installment_amount;
    public Integer number_installments;
    public Integer plan_value;
    public String plan_type;
    public Integer payable_amount;
    public Integer execute_on_day;
    public String guarantor;
    public String next_payment_date;
    public Integer installments_paid;
    public Integer installments_total;
    public Credit_card credit_card;
    public Boolean has_error;
    public String charges_added_since_start;
    public Date error_date;
    public List<String> chargegroups;
    public Boolean delinquent;
    public Date delinquent_date;
    public List<Encounters> encounters;
    public Integer authorized_amount;
    public String skip_payment_until;
    public String status;

    public class Encounters {
    }

    public class Credit_card {
        public String card_type;
        public String last_4;
    }

    public class PaymentPlanWrapper {
        public List<Charge_Group__c> chargeGroupRecords { get; set; }
        public Payment_Plan__c paymentPlanRecord { get; set; }
        public List<Encounter__c> encounterRecords { get; set; }

        Public PaymentPlanWrapper() {
            chargeGroupRecords = new List<Charge_Group__c>();
            paymentPlanRecord = new Payment_Plan__c();
            encounterRecords = new List<Encounter__c>();
        }
    }

    public static PaymentPlanJSONParsing parse(String json) {
        return (PaymentPlanJSONParsing) System.JSON.deserialize(json, PaymentPlanJSONParsing.class);
    }

    //TODO when do we pass in a chargegroupId? why don't we just always retrieve all that were sent back with the plan?
    public static PaymentPlanWrapper createPaymentPlanRecord(String json, String contactId,
        String paymentPlanId, String chargeGroupId) {

        List<String> lstString = new list<String>();
        Set<Decimal> setchargeGroupID = new Set<Decimal>();
        if (!String.isBlank(chargeGroupId)) {
            lstString = chargeGroupId.Split(',');
            for (String str : lstString) {
                if (str.isNumeric()) {
                    setchargeGroupID.add(Decimal.valueOf(str));
                }
            }
        }
        PaymentPlanWrapper objPaymentPlanWrapper = new PaymentPlanWrapper();
        PaymentPlanJSONParsing objJson = parse(json);

        Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
        paymentPlanObj.Active__c = objJson.active;
        paymentPlanObj.Installment_Amount__c = PayStaffWSUtill.convertToDollars(objJson.installment_amount);
        paymentPlanObj.Original_Installment_Count__c = objJson.number_installments;
        paymentPlanObj.Original_Balance__c = PayStaffWSUtill.convertToDollars(objJson.plan_value);
        paymentPlanObj.Plan_Type__c = objJson.plan_type;
        if (objJson.plan_type == 'auto') {
            paymentPlanObj.Plan_Type__c = Constants.AUTOMATIC;
        } else if (objJson.plan_type == 'promise') {
            paymentPlanObj.Plan_Type__c = 'Manual';
        }

        paymentPlanObj.Remaining_Balance__c = PayStaffWSUtill.convertToDollars(objJson.payable_amount);
        paymentPlanObj.Execute_on_Day__c = objJson.execute_on_day;
        if (!String.isBlank(objJson.next_payment_date)) {
            paymentPlanObj.NextPaymentDate__c = Date.valueof(objJson.next_payment_date);
        }
        if (!String.isBlank(objJson.skip_payment_until)) {
            paymentPlanObj.Skip_Payment_Until__c = Date.valueof(objJson.skip_payment_until);
        }
        paymentPlanObj.Has_Error__c = objJson.has_error;
        if (!String.isBlank(String.valueof(objJson.error_date))) {
            paymentPlanObj.Error_Date__c = Date.valueof(objJson.error_date);
        } else {
            paymentPlanObj.Error_Date__c = null;
        }
        paymentPlanObj.Delinquent__c = objJson.delinquent;
        if (objJson.delinquent_date != null) {
            paymentPlanObj.Delinquent_Date__c = objJson.delinquent_date;
        } else {
            paymentPlanObj.Delinquent_Date__c = null;
        }

        if (!String.isBlank(contactId)) {
            paymentPlanObj.Guarantor__c = contactId;
        } else {
            String gtId = getExternalId(objJson.guarantor, 'guarantors');
            Contact gt = GuarantorService.getGuarantorBySironoId(gtId);
            paymentPlanObj.Guarantor__c = gt.Id;
        }

        paymentPlanObj.Status__c = objJson.status;
        if (!String.isBlank(objJson.url)) {
            String strPaymentPlan = getExternalID(String.valueof(objJson.url), 'paymentplan');
            Decimal paymentPlanExternalID = Decimal.valueOf(strPaymentPlan);
            if (!String.isBlank(strPaymentPlan)) {
                paymentPlanObj.Sirono_ID__c = paymentPlanExternalID;
                paymentPlanObj.Name = String.valueof(paymentPlanObj.Sirono_ID__c);
                if (PaymentPlanSecurityContext.PP_SELECT_CONTEXT.actionAllowed()) {
                    List<Payment_Plan__c> paymentPlan = [SELECT Id, Sirono_ID__c FROM Payment_Plan__c WHERE Sirono_ID__c = :paymentPlanExternalID];
                    if (paymentPlan.Size() > 0) {
                        paymentPlanObj.Id = paymentPlan[0].Id ;
                    }
                }
            }
        }

        //Get chargeGroup id from SF.
        System.debug('chargeGroupId' + chargeGroupId);
        if (String.isBlank(chargeGroupId)) {
            System.debug('objJson.chargegroups' + objJson.chargegroups);
            for (String str : objJson.chargegroups) {
                String strChargeGroupID = getExternalID(String.valueof(str), 'chargegroups');
                if (strChargeGroupID.isNumeric()) {
                    setchargeGroupID.add(Decimal.valueOf(strChargeGroupID));
                }
            }
        }

        System.debug('setchargeGroupID' + setchargeGroupID);
        if (setchargeGroupID.Size() > 0) {
            List<Charge_Group__c> chargeGroups = ChargeGroupService.getBySironoIds(new List<Decimal>(setchargeGroupID));
            for (Charge_Group__c objCG: chargeGroups) {
                objCG.Payment_Plan__c = paymentPlanObj.ID;
            }
            objPaymentPlanWrapper.chargeGroupRecords = chargeGroups;
        }

        objPaymentPlanWrapper.paymentPlanRecord = paymentPlanObj;
        return objPaymentPlanWrapper;
    }

    //Split the URL and return the last number which is external id.
    //TODO this should be in a superclass for all the JSON parsers
    public Static String getExternalID(String url, string splitWith) {
        String[] externalID = url.split(splitWith);
        return externalID[externalID.Size() - 1].replaceAll('/', '');
    }

    private static String testGuarantorSironoId = '23232323';

    /**
     *  Test response for the test class and testing.
     */
    Public Static String testResponse() {

        String responseBody = '{' +
            '   "url": "' + TestUtility.url + '",' +
            '   "active": true,' +
            '   "installment_amount": 5000,' +
            '   "number_installments": 7,' +
            '   "plan_value": 32772,' +
            '   "plan_type": "' + TestUtility.planType + '",' +
            '   "payable_amount": 32772,' +
            '   "execute_on_day": 13,' +
            '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/' + testGuarantorSironoId + '/",' +
            '   "next_payment_date": "2016-05-13",' +
            '   "installments_paid": 0,' +
            '   "installments_total": 7,' +
            '   "credit_card": {' +
            '       "card_type": "Visa",' +
            '       "last_4": "1881"' +
            '   },' +
            '   "has_error": false,' +
            '   "charges_added_since_start": null,' +
            '   "error_date": "' + TestUtility.errorDate + '",' +
            '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/1321212/", "http://127.0.0.1:8000/paystaff/api/chargegroups/10283475/"],' +
            '   "delinquent": false,' +
            '   "delinquent_date": "' + TestUtility.delinquentDate + '",' +
            '   "encounters": [],' +
            '   "authorized_amount": 0,' +
            '   "skip_payment_until":"2016-12-01",' +
            '   "status":"started"' +
            '}';
        return responseBody;
    }
    
    
    /*
    * 08-17-2016: Sirono - Tracker # 127940071
    *  Test response for the test class and testing.
    */
    Public Static String testResponse1() {

        String responseBody = '{' +
            '   "url": "' + TestUtility.url + '",' +
            '   "active": true,' +
            '   "installment_amount": 5000,' +
            '   "number_installments": 7,' +
            '   "plan_value": 32772,' +
            '   "plan_type": "' + TestUtility.planType + '",' +
            '   "payable_amount": 32772,' +
            '   "execute_on_day": 13,' +
            '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/23232323/",' +
            '   "next_payment_date": "2016-05-13",' +
            '   "installments_paid": 0,' +
            '   "installments_total": 7,' +
            '   "credit_card": {' +
            '       "card_type": "Visa",' +
            '       "last_4": "1881"' +
            '   },' +
            '   "has_error": false,' +
            '   "charges_added_since_start": null,' +
            '   "error_date": null, ' +
            '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/1321212/", "http://127.0.0.1:8000/paystaff/api/chargegroups/10283475/"],' +
            '   "delinquent": false,' +
            '   "delinquent_date": null, ' +
            '   "encounters": [],' +
            '   "authorized_amount": 0,' +
            '   "skip_payment_until":"2016-12-01",' +
            '   "status":"started"' +
            '}';

        return responseBody;
    }
}