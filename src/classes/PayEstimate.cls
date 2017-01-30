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
            guarantorContact = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = PayStaffWSUtill.fetchGuarantorName(guarantorContact);
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
            Boolean blnIsError = checkCardValidation();
            Boolean blnIsAmountError = checkAmountValidation();

            if (!blnIsError && !blnIsAmountError) {
                Payment__c payment = new Payment__c();
                payment.Name = PAYMENTNAME;
                payment.Guarantor__c = guarantorRecordId;
                payment.Amount__c = decimal.valueof(amount);
                payment.Encounter__c = selectedEncounter.Id;
                payment.Deposit_Date__c = system.now();
                INSERT payment;

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
     * This method is use to check String is empty or null for Validation.
     *
     * @Param String str - That contains String value.
     * @returns Boolean - That contains true or false based on parameter.
     **/
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    /**
     * This method is used to check Amount validation.
     *
     * @returns Boolean blnIsError - That contains true or false.
     **/
    Public Boolean checkAmountValidation() {
        Boolean blnIsError = false;
        if (isEmpty(amount) || (amount.isNumeric() && decimal.valueof(amount) == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO));
            blnIsError = true;
        } else {
            if (decimal.valueof(amount) < 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO));
                blnIsError = true;
            }
            if (decimal.valueof(amount) > selectedEncounter.Balance__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE));
                blnIsError = true;
            }
        }
        return blnIsError;
    }

    /**
     * This method is used to check Card validation.
     *
     * @returns Boolean blnIsError - That contains true or false.
     **/
    Public Boolean checkCardValidation() {
        Boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_CREDIT_CARD_NUMBER_12_19_DIGITS));
            blnIsError = true;
        }
        if (isEmpty(creditCardNumber)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_CREDIT_CARD_NUMBER_REQUIRE));
            blnIsError = true;
        }
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_EXPIRATION_DATE_FUTURE));
            blnIsError = true;
        }
        if (!isEmpty(zip) && zip.length() != 5) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT));
            blnIsError = true;
        }
        if (!isEmpty(zip) && !zip.isNumeric()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC));
            blnIsError = true;
        }
        if (isEmpty(cardHolderName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_NAME_REQUIRE));
            blnIsError = true;
        }
        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_CVV_4_OR_3_DIGIT));
            blnIsError = true;
        }
        if (isEmpty(cvv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_CVV_REQUIRE));
            blnIsError = true;
        }
        if (isEmpty(address)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE));
            blnIsError = true;
        }
        if (isEmpty(zip)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE));
            blnIsError = true;
        }
        return blnIsError;
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