public with sharing class PaymentArrangement {
    
    public Payment_Arrangement__c paymentArrangement {get;set;}
    public Payment_Method__c newPaymentMethod {get;set;}
    public List<PaymentMethodWrapper> paymentMethodList {get;set;}
    public String paymentMethodType {get;set;}
    public List<SelectOption> paymentMethodTypeOptions{get;set;}
    public Encounter__c encounter {get;set;}
    public Contact guarantor {get;set;}
    public String encounterId {get;set;}
    public Boolean createPaymentMethod {get;set;}
    public String CreditCardRecordID = '';
    public PaymentArrangement(ApexPages.StandardController sc) {
    
        paymentMethodTypeOptions = new List<SelectOption>();
        encounterId = sc.getId();
        encounter = new Encounter__c();
        guarantor = new Contact();
        createPaymentMethod = false;
        paymentArrangement = new Payment_Arrangement__c();
        newPaymentMethod = new Payment_Method__c();
        paymentMethodList = new List<PaymentMethodWrapper>();
        
        paymentMethodTypeOptions = getPaymentRecordTypes();     
        paymentArrangement.Encounter__c = encounterId;
        encounter = [Select Id, Guarantor__c From Encounter__c Where Id =: encounterId];
        if(encounter != null && encounter.Guarantor__c != null) {
            guarantor = PayStaffWSUtill.fetchContact(encounter.Guarantor__c);
            getGuarantorPaymentMethods(guarantor.Id);
            
        }
    }
    
    private List<SelectOption> getPaymentRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType rt : [Select SobjectType, Name, IsActive, Id From RecordType where SobjectType = 'Payment_Method__c' 
                                and (Name = 'Check/Cash' or Name = 'Credit Card')]) {
            options.add(new SelectOption(rt.Id, rt.Name));
            
            if(rt.Name  == 'Credit Card' ){
                CreditCardRecordID = rt.id;
            }
            
        }
        return options;
    }
    
    private void getGuarantorPaymentMethods(String gId) {
        for(Payment_Method__c p : [Select p.Routing_Number__c, p.RecordTypeId, p.Payment_Method_Token__c, p.Name, p.Last_4__c, p.Id, 
                                p.ID__c, p.Guarantor__c, p.Expiration_Date__c, p.Card_Type__c, p.Card_Holder_Name__c, p.Account_Number__c 
                                From Payment_Method__c p Where Guarantor__c =: gId]) {
            paymentMethodList.add(new PaymentMethodWrapper(p, false));
        }
    }
    
    public PageReference submitPaymentArrangement() {
        for(PaymentMethodWrapper objPM : paymentMethodList){
            if(objPM.isSelected){            
                paymentArrangement.Payment_Method__c = objPM.pm.Id; 
            }
        }
        insert paymentArrangement;
        return new PageReference('/' + encounterId);
    }
    
    public void createNewPaymentMethod() {
        createPaymentMethod = true;
        newPaymentMethod = new Payment_Method__c();
        newPaymentMethod.Guarantor__c = guarantor.Id;
        newPaymentMethod.RecordTypeID =CreditCardRecordID;
    }
    
    public void cancelNewPaymentMethod() {
        createPaymentMethod = false;
        newPaymentMethod = null;
    }
    
    public void saveNewPaymentMethod() {
        insert newPaymentMethod;
        for(PaymentMethodWrapper pml : paymentMethodList) {
            pml.isSelected = false;
        }
        paymentMethodList.add(new PaymentMethodWrapper(newPaymentMethod, true));
        createPaymentMethod = false;
    }
    
    public class PaymentMethodWrapper {
        public Boolean isSelected {get;set;}
        public Payment_Method__c pm {get;set;}
        
        public PaymentMethodWrapper(Payment_Method__c pmObj, Boolean isSelect) {
            isSelected = isSelect;
            pm = pmObj;
        }
    }
}