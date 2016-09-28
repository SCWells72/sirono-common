/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 08-17-2016
 * @description page open from the Encounter record when user click on the "New Payment Arrangement" button.
 * Class will create a new payment arrangement record, also it will create a new payment method from button "Add new payment method".
 *
 * 08-17-2016: Sirono - Tracker # 127398743
 */

public with sharing class PaymentArrangement {

    public Payment_Arrangement__c paymentArrangement {get; set;}
    public Payment_Method__c newPaymentMethod {get; set;}
    public List<PaymentMethodWrapper> paymentMethodList {get; set;}
    public String paymentMethodType {get; set;}
    public List<SelectOption> paymentMethodTypeOptions {get; set;}
    public Encounter__c encounter {get; set;}
    public Contact guarantor {get; set;}
    public String encounterId {get; set;}
    public Boolean createPaymentMethod {get; set;}
    public String creditCardRecordID = '';

    /*
     * Constructor of class,declare the variables.
     */
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
        encounter = [
                Select Id, Guarantor__c
                From Encounter__c
                Where Id = :encounterId
        ];

        if (encounter != null && encounter.Guarantor__c != null) {
            guarantor = PayStaffWSUtill.fetchContact(encounter.Guarantor__c);
            getGuarantorPaymentMethods(guarantor.Id);
        }
    }

    /*
     * get all the payment record type list.
     */
    private List<SelectOption> getPaymentRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (RecordType rt : [
                Select SobjectType, Name, IsActive, Id
                From RecordType
                where SobjectType = 'Payment_Method__c'
                and (Name = 'Check/Cash' or Name = 'Credit Card')
        ]) {
            options.add(new SelectOption(rt.Id, rt.Name));

            if (rt.Name == 'Credit Card') {
                creditCardRecordID = rt.id;
            }
        }
        return options;
    }

    /*
     * get list of payment methods.
     */
    private void getGuarantorPaymentMethods(String gId) {
        for (Payment_Method__c p : [
                Select p.Routing_Number__c, p.RecordTypeId,
                        p.Payment_Method_Token__c, p.Name,
                        p.Last_4__c, p.Id, p.ID__c, p.Guarantor__c,
                        p.Expiration_Date__c, p.Card_Type__c,
                        p.Card_Holder_Name__c,
                        p.Account_Number__c
                From Payment_Method__c p
                Where Guarantor__c = :gId
        ]) {
            paymentMethodList.add(new PaymentMethodWrapper(p, false));
        }
    }

    /*
     * Insert new Payment Arrangement record and set the lookup.
     */
    public PageReference submitPaymentArrangement() {
        for (PaymentMethodWrapper objPM : paymentMethodList) {
            if (objPM.isSelected) {
                paymentArrangement.Payment_Method__c = objPM.pm.Id;
            }
        }
        insert paymentArrangement;
        return new PageReference('/' + encounterId);
    }

    /*
     * Initilize the Payment Method object record and set the record values.
     */
    public void createNewPaymentMethod() {
        createPaymentMethod = true;
        newPaymentMethod = new Payment_Method__c();
        newPaymentMethod.Guarantor__c = guarantor.Id;
        newPaymentMethod.RecordTypeID = creditCardRecordID;
    }

    /*
     * Initilize the Payment Method object record with null
     */
    public void cancelNewPaymentMethod() {
        createPaymentMethod = false;
        newPaymentMethod = null;
    }

    /*
     * Insert a payment method record.    
     */
    public void saveNewPaymentMethod() {
        insert newPaymentMethod;
        for (PaymentMethodWrapper pml : paymentMethodList) {
            pml.isSelected = false;
        }
        paymentMethodList.add(new PaymentMethodWrapper(newPaymentMethod, true));
        createPaymentMethod = false;
    }

    /*
     * wrapper class for the payment method.  
     */
    public class PaymentMethodWrapper {
        public Boolean isSelected {get; set;}
        public Payment_Method__c pm {get; set;}

        public PaymentMethodWrapper(Payment_Method__c pmObj, Boolean isSelect) {
            isSelected = isSelect;
            pm = pmObj;
        }
    }
}