/**
 * PayEstimate class is controller of PayEstimate VF page.
 * It is use to make a Payment of Encounter based on Guarantor Contact.
 * User can only make payment for one Encounter at a time.
 * Only display those Encounters whose balance is greater than zero.
 * Based on selected Encounter, Create a Payment Record.
 **/ 

public with sharing class PayEstimate {

    // Constant variable.
    public static final String PAYMENTNAME = 'Payment';

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

    // Getter setter of expYearOptions - That gets the Year Options from PayStaffWSUtill Class.
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = PayStaffWSUtill.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    // Getter setter of expMonthOptions - That gets the Month Options from PayStaffWSUtill Class.
    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = PayStaffWSUtill.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    /**
     * Constructor of Class with standard controller.
     *
     * @param ApexPages.StandardController controller - That contains Contact/Id.
     **/
    public PayEstimate(ApexPages.StandardController controller) {
        // Get/Set Contact/Guarantor Id.
        guarantorRecordId = controller.getId();

        if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = GuarantorService.getGuarantorWithActiveCG(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = GuarantorService.buildGuarantorDetailString(guarantorContact);
            // Call getEncounterRecords method.
            getEncounterRecords();
        }
    }

    /**
     * This method is use to get Encounter Records based on Guarantor Id and Balance is greater than zero.
     * These records add into List of Encounter Wrapper Class.
     **/
    public void getEncounterRecords() {
        encounters = new List<EncounterWrapper>();
        for (Encounter__c en: [SELECT Id, Name, Patient__c, Date_of_Service__c, Procedure__c, Location__c,
                        Patient_Portion__c, Guarantor__c, Balance__c
                        FROM Encounter__c
                        WHERE Balance__c > 0
                            AND Guarantor__c = :guarantorRecordId
        ]) {
            encounters.add(new EncounterWrapper(en, false));
        }
    }

    /**
     * This method is use to refresh output panel in VF page.
     *
     * @returns Pagereference - That contains null value.
     **/
    public Pagereference doNext() {
        encounterSelected = false;
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
        return null;
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * It is create record when all validations are successfully pass out.
     **/
    public void submit() {
        try {
            // Call creditCardValidation method that validate all informations/values for Credit Card.
            Boolean blnIsCCError = VisualForceValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
                    zip, cardHolderName, cvv, address);
            // Call amountValidation method that validate amount.
            Boolean blnIsAmountError = VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c));

            if (!blnIsCCError && !blnIsAmountError) {
                Payment__c payment = new Payment__c();
                payment.Name = PAYMENTNAME;
                payment.Guarantor__c = guarantorRecordId;
                payment.Amount__c = decimal.valueof(amount);
                payment.Encounter__c = selectedEncounter.Id;
                payment.Deposit_Date__c = system.now();
                if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT payment; 
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY));
            } else {
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ERROR: ' + e.getMessage()));
        }
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
     * This Wrapper class is use to check how many Encounters select or which encounter select for Payment Process.
     **/
    public class EncounterWrapper{
        public Encounter__c en {get; set;}
        public Boolean isSelected {get; set;}

        // Constructor initializing the wrapper class variables
        public EncounterWrapper(Encounter__c en, Boolean isSelected) {
            this.en = en;
            this.isSelected = isSelected;
        }
    }
}
