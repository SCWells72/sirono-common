/*
* @author: Sirono
* @version 1.0.1
* @Date: 11-15-2016
* JSON Parsing Class for the response which comes from Adjustment/Discount Request.
*/

public class PaymentAdjustmentJSONParsing {

    public string url;
    public integer amount;
    public string code;
    public string description;
    public string post_date;

    public static List<Payment_Adjustments__c> parse(String json) {
        if(!json.contains('[')){
            json = '[' + json + ']';
        }
        
        List<PaymentAdjustmentJSONParsing> lstPaymentAdjustmentJson = 
            (List<PaymentAdjustmentJSONParsing>) System.JSON.deserialize(json, List<PaymentAdjustmentJSONParsing>.class);

        List<Payment_Adjustments__c> lstPaymentAdjustment = new List<Payment_Adjustments__c>();
        Map<Decimal,string> mapCode = new Map<Decimal,string>();
        
        if (lstPaymentAdjustmentJson.size() > 0) {
            for (PaymentAdjustmentJSONParsing objJson : lstPaymentAdjustmentJson) {
                Payment_Adjustments__c objPaymentAdjustment = new Payment_Adjustments__c();
                
                objPaymentAdjustment.ID__c = Integer.valueof(getExternalID(objJson.url,'adjustments'));
                objPaymentAdjustment.Name = getExternalID(objJson.url,'adjustments');
                objPaymentAdjustment.Amount__c = PayStaffWSUtill.convertToDollars(objJson.amount);
                objPaymentAdjustment.Description__c = objJson.description;                
                if (!String.Isblank(objJson.post_date)) {
                    objPaymentAdjustment.Post_Date__c = Date.valueof(objJson.post_date);
                }
                mapCode.put(objPaymentAdjustment.ID__c, objJson.code);
                
                lstPaymentAdjustment.add(objPaymentAdjustment);
            }
            
            //To Get Transaction Type Id based on Code.
            List<Transaction_Type__c> lstTransactionType = [SELECT Id, Code__c FROM Transaction_Type__c
                    where Code__c in: mapCode.values()];
                    
            map<string, string> mapTranType = new map<string, string>();
            for(Transaction_Type__c tt : lstTransactionType){
                mapTranType.put(tt.Code__c, tt.Id);
            }

            for(Payment_Adjustments__c pa : lstPaymentAdjustment) {
                string strCode = mapCode.get(pa.ID__c);
                pa.Transaction_Type__c = mapTranType.get(strCode);
            }
        }
        return lstPaymentAdjustment;
    }

    public Static String getExternalID(String url,string splitWith){
        String[] externalID = url.split(splitWith);
        return externalID[externalID.Size() - 1].replaceAll('/','');
    }
    
    Public Static String  testResponse() {
    
        String responseBody =        '[{'+
        '   "url": "https://toledo.stage.sirono.com/paystaff/api/adjustments/3151479/", ' +
        '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/51724/",'+
        '   "amount":100,'+
        '   "code":"ADM",'+
        '   "description":null,'+
        '   "display_kind":"",'+
        '   "post_date":"2016-10-13"' +
        '}]';
        
        return responseBody;
    }
}