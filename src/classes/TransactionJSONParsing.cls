/*
* JSON Parsing Class for the response which comes from Transaction Request. Takes the response and turns it into
* a list of Transaction__c & Charge_Group__c objects with the Charge_Group__c properly populated in the transactions.
*/

public class TransactionJSONParsing {

    public String url;
    public Integer amount;
    public String post_date;
    public String fail_date;
    public String export_date;
    public String created_at;
    public String modified_at;
    public String method;
    public String notes;
    public Boolean credit_balance;
    public String payment;
    public String chargegroup;

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

            Map<Decimal, Decimal> mapTransactionChargeGroup = new Map<Decimal, Decimal>();

            for (TransactionJSONParsing objJson : lstTransactionJson) {
                Transaction__c objTransaction = new Transaction__c();
                String transactionExternalId = getExternalID(objJson.url,'transaction');

                objTransaction.Sirono_ID__c = Decimal.valueOf(transactionExternalId);
                objTransaction.Name = objJson.method + '-' + transactionExternalId;
                objTransaction.Amount__c = PayStaffWSUtill.convertToDollarsWithNegative(objJson.amount);
                if (!String.isBlank(objJson.post_date)) {
                    objTransaction.Post_Date__c = Date.valueOf(objJson.post_date);
                }
                if (!String.isBlank(objJson.fail_date)) {
                    objTransaction.Fail_Date__c = Date.valueOf(objJson.fail_date);
                }
                if (!String.isBlank(objJson.export_date)) {
                    objTransaction.Export_Date__c = Date.valueOf(objJson.export_date);
                }
                objTransaction.Credit_Balance__c = objJson.credit_balance;

                if (objJson.chargegroup != null) {
                    Decimal chargegroup = Decimal.valueOf(getExternalID(objJson.chargegroup,'chargegroups'));
                    mapTransactionChargeGroup.put(objTransaction.Sirono_ID__c, chargegroup);
                }

                lstTransaction.add(objTransaction);
            }

            if (mapTransactionChargeGroup.size() > 0) {

                lstChargeGroup = ChargeGroupService.getBySironoIds(mapTransactionChargeGroup.values());

                Map<Decimal, String> mapChargeGroup = new Map<Decimal, String>();
                for(Charge_Group__c cg : lstChargeGroup){
                    mapChargeGroup.put(cg.Sirono_ID__c, cg.Id);
                }

                for (Transaction__c txn : lstTransaction) {
                    if (txn.Charge_Group__c == null){
                        Decimal cId = mapTransactionChargeGroup.get(txn.Sirono_ID__c);
                        txn.Charge_Group__c = mapChargeGroup.get(cId);
                    }
                }
            }

            objTransactionWrapper.transactionRecords = lstTransaction;
            objTransactionWrapper.chargeGroupRecords = lstChargeGroup;
        }
        return objTransactionWrapper;
    }

    public static String getExternalID(String url,string splitWith){
        String[] externalID = url.split(splitWith);
        return externalID[externalID.Size() - 1].replaceAll('/','');
    }
    
    public static String  testResponse() {
    
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