/*
* @author: Sirono
* @version 1.0.1
* @Date: 10-17-2016
* JSON Parsing Class for the response which comes from Payment Request.
*/

public class PaymentJSONParsing {

    public PaymentJSONParsing() {
    
    }
	/*
	public string url;
    public string guarantor;
    public integer amount;
    public string transaction_number;
    public string payment_date;
    public string method;
    public string last_4;
    public string processor_transaction_id;
    public string receipt_link;
    public string payment_info;
    public string payment_type;
    public string account_number;
    public string routing_number;
    public string bank_account_type;
    public string is_voidable;
    public string post_date;

    public static Payment__c parse(String json) {
        if(json.contains('[')){
            json = json.replace('[','');
            json = json.replace(']','');
        }
        PaymentJSONParsing objJson = (PaymentJSONParsing) System.JSON.deserialize(json, PaymentJSONParsing.class);

        Payment__c objPayment = new Payment__c();
                
        integer guarantor = Integer.valueof(getExternalID(objJson.guarantor,'guarantors'));
        
        contact guarantorContact = [select id from contact where Profile_Pointer_ID__c =: guarantor limit 1];    
        objPayment.Guarantor_Name__c = guarantorContact.Id;
        
        if (!String.Isblank(objJson.payment_date)) {
            objPayment.Charge_Date__c = Date.valueof(objJson.payment_date);
        }
        objPayment.Method__c = objJson.method;
        objPayment.Last_4__c = objJson.last_4;
        objPayment.Processor_Transaction_ID__c = objJson.processor_transaction_id;            
        
        objPayment.Amount__c = PayStaffWSUtill.convertToDollars(objJson.amount);
        objPayment.ID__c = Integer.valueof(getExternalID(objJson.url,'payments'));
        objPayment.Name = getExternalID(objJson.url,'payments');

        return objPayment;
    }

    public Static String getExternalID(String url,string splitWith){
        String[] externalID = url.split(splitWith);
        return externalID[externalID.Size() - 1].replaceAll('/','');
    }
    
    Public Static String  testResponse() {
    
        String responseBody =        '[{'+
        '   "url": "https://toledo.stage.sirono.com/paystaff/api/payments/20690/", ' +
        '   "guarantor":"https://toledo.stage.sirono.com/paystaff/api/guarantors/123/",'+
        '   "amount":100,'+
        '   "transaction_number":"TD-0000020690",'+
        '   "payment_date":"2016-10-13",'+
        '   "method":"credit",'+
        '   "last_4":"0005",'+
        '   "processor_transaction_id":"3f8ex1ft",'+
        '   "receipt_link":"https://toledo.stage.sirono.com/portal/staff/guarantor-mask/72407/?next=/portal/receipt/20690/",'+
        '   "payment_info":"Credit Card | Last Digits: 0005",'+
        '   "payment_type":"Online",'+
        '   "account_number":null,'+
        '   "routing_number":null,'+
        '   "bank_account_type":null,'+
        '   "is_voidable":null'+
        '}]';
        
        return responseBody;
    }*/
}