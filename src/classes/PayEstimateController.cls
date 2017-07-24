/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * PayEstimateController is a virtual class 
 * that is used by PayEstimateVFController and PayEstimateLightningController classes.
 **/ 
public abstract class PayEstimateController {
    // Page Level Variables.
    public String address {get; set;}
    public String amount {get; set;}
    public String cardHolderName {get; set;}
    public String city {get; set;}
    public String creditCardNumber {get; set;}
    public String cvv {get; set;}
    public List<EncounterWrapper> encounters {get; set;}
    public Boolean encounterSelected {get; set;}
    public String expirationMonth {get; set;}
    public String expirationYear {get; set;}
    public Contact guarantorContact {get; set;}
    public String guarantorName {get; set;}
    public String guarantorRecordId {get; set;}
    public Encounter__c selectedEncounter {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
    public List<String> errorMessages{get;set;}

    // Getter setter of expYearOptions
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = UIUtils.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    // Getter setter of expMonthOptions
    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = UIUtils.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    /**
     * Init method is used to initialize main variables from child constructors
     * @param String recordId - record Id that is used for getting encounters records
     **/
    public void init(String recordId) {
        errorMessages = new List<String>();
        if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = GuarantorService.getGuarantor(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = GuarantorService.buildGuarantorDetailString(guarantorContact);
            // Call getEncounterRecords method.
            loadEncounters(recordId);
        }
    }

    protected abstract void loadEncounters(String recordId);
    protected abstract Boolean isValidCard();
    protected abstract Boolean isValidAmount();

    /**
     * This method is used to get selected record
     **/
    public void doNext() {
        EncounterWrapper checkEncounter = checkNext(encounters);
        selectedEncounter = (checkEncounter.en != null) ? checkEncounter.en : selectedEncounter;
        encounterSelected = checkEncounter.isSelected;
    }

    /**
     * This method is use/call from VF page.
     * This method fill the data based on Contact in VF page.
     **/
    public void fillNameAndAddress() {
        cardHolderName = guarantorContact.name;
        address = guarantorContact.MailingStreet;
        city = guarantorContact.MailingCity;
        state = guarantorContact.MailingState;
        zip = guarantorContact.MailingPostalCode;
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * @param String paymentMethod - payment method
     **/
    public String addPayment(String paymentMethod) {
        // Call createNewPayment method.
        Payment__c payment = PaymentService.createNewPayment(guarantorRecordId, Decimal.valueOf(amount), selectedEncounter.Id, System.now(), paymentMethod); 
        return (payment == null) ? 'ERROR: ' + Constants.PAGE_MESSAGE_CREATED_FAIL : 'Success;' + payment.Payment_Id__c + ';$' + amount;
    }

    /**
     * This method is used to check selected record
     * @param List<EncounterWrapper> encounters - list of EncounterWrapper records
     * @return EncounterWrapper - selected EncounterWrapper record
     **/
    private EncounterWrapper checkNext(List<EncounterWrapper> encounters) {
        Encounter__c selectedEncounter;
        Boolean encounterSelected = false;
        Integer count = 0;
        if (encounters != null && encounters.size() > 0) {
            for (EncounterWrapper enw: encounters) {
                if (enw.isSelected) {
                    count++;
                    selectedEncounter = enw.en;
                }
            }
            if (count == 1) {
                encounterSelected = true;
            }
        }
        return new EncounterWrapper(selectedEncounter, encounterSelected);
    }
}