/*
* @author: Sirono
* @version 1.0.1
* @Date: 10-17-2016
* JSON Parsing Class for the response which comes from Transaction Request.
*/

public class TransactionJSONParsing {

    public string url;
    public integer amount;
    public string post_date;
    public string fail_date;
    public string export_date;
    public string created_at;
    public string modified_at;
    public string method;
    public string notes;
    public boolean credit_balance;
    public string payment;
    public string chargegroup;

    public class TransactionWrapper{
        public List<Transaction__c> transactionRecords {get;set;}
        public List<Charge_Group__c> chargeGroupRecords {get;set;}

        public TransactionWrapper(){
            transactionRecords = new List<Transaction__c>();
            chargeGroupRecords = new List<Charge_Group__c>();
        }
    }

    public static TransactionWrapper parse(String json) {
        if(!json.contains('[')){
            json = '[' + json + ']';
        }
        
        TransactionWrapper objTransactionWrapper = new TransactionWrapper();
        List<Transaction__c> lstTransaction = new List<Transaction__c>();
        List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();

        List<TransactionJSONParsing> lstTransactionJson =
            (List<TransactionJSONParsing>) System.JSON.deserialize(json.replace('_credit_balance','credit_balance'), List<TransactionJSONParsing>.class);

        if (lstTransactionJson.size() > 0) {
            List<Charge_Group__c> unallocatedChargeGroup = [SELECT Id FROM Charge_Group__c where name = 'Unallocated'];
            map<string, decimal> mapTransactionChargeGroup = new map<string, decimal>();

            for (TransactionJSONParsing objJson : lstTransactionJson) {
                Transaction__c objTransaction = new Transaction__c();
                string transactionExternalId = getExternalID(String.valueof(objJson.url),'transaction');

                objTransaction.Sirono_ID__c = Integer.valueof(transactionExternalId);
                objTransaction.Name = objJson.method + '-' + transactionExternalId;
                objTransaction.Amount__c = PayStaffWSUtill.convertToDollarsWithNegative(objJson.amount);
                if (!String.Isblank(objJson.post_date)) {
                    objTransaction.Post_Date__c = Date.valueof(objJson.post_date);
                }
                if (!String.Isblank(objJson.fail_date)) {
                    objTransaction.Fail_Date__c = Date.valueof(objJson.fail_date);
                }
                if (!String.Isblank(objJson.export_date)) {
                    objTransaction.Export_Date__c = Date.valueof(objJson.export_date);
                }
                objTransaction.Notes__c = objJson.notes;
                objTransaction.Credit_Balance__c = objJson.credit_balance;

                if (objJson.chargegroup == null) {
                    if(unallocatedChargeGroup.size() > 0){
                        objTransaction.Charge_Group__c = unallocatedChargeGroup[0].Id;
                    }
                } else {
                    decimal chargegroup = Decimal.Valueof(getExternalID(String.valueof(objJson.chargegroup),'chargegroups'));
                    mapTransactionChargeGroup.put(transactionExternalId, chargegroup);
                }

                lstTransaction.add(objTransaction);
            }

            if (mapTransactionChargeGroup.size() > 0) {

                lstChargeGroup = [SELECT Id, Sirono_ID__c, Account_Sub_Status__c,
                        Payment_Plan__c, Payment_Plan__r.Sirono_ID__c, Payment_Plan__r.Guarantor__c
                        FROM Charge_Group__c
                        where Sirono_ID__c in: mapTransactionChargeGroup.values()];

                map<decimal, string> mapChargeGroup = new map<decimal, string>();
                for(Charge_Group__c cg : lstChargeGroup){
                    mapChargeGroup.put(cg.Sirono_ID__c, cg.Id);
                }

                for(Transaction__c tran : lstTransaction) {
                    if(tran.Charge_Group__c == null){
                        decimal cId = mapTransactionChargeGroup.get(string.valueof(tran.Sirono_ID__c));
                        tran.Charge_Group__c = mapChargeGroup.get(cId);
                    }
                }
            }

            if(lstTransaction.size() > 0){
                objTransactionWrapper.transactionRecords = lstTransaction;
            }
            if(lstChargeGroup.size() > 0){
                objTransactionWrapper.chargeGroupRecords = lstChargeGroup;
            }
        }
        return objTransactionWrapper;
    }

    public Static String getExternalID(String url,string splitWith){
        String[] externalID = url.split(splitWith);
        return externalID[externalID.Size() - 1].replaceAll('/','');
    }
    
    Public Static String  testResponse() {
    
        String responseBody =        '{'+
        '   "url":"https://toledo.stage.sirono.com/paystaff/api/transaction/22923843/", ' +
        '   "amount":100,'+
        '   "post_date":"2016-10-17T00:00:00",'+
        '   "fail_date":"2016-10-17T00:00:00",'+
        '   "export_date":"2016-10-17T00:00:00",'+
        '   "created_at":"2016-10-17T12:41:22.562824",'+
        '   "modified_at":"2016-10-17T12:41:22.562843",' +
        '   "method":"adjustment",' +
        '   "notes":null,' +
        '   "credit_balance":false,' +
        '   "payment":null,' +
        '   "chargegroup":"https://toledo.stage.sirono.com/paystaff/api/chargegroups/124/" ' +
        '}';
        
        return responseBody;
    }
}