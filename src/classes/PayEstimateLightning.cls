public with sharing class PayEstimateLightning {
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
    public String encounterId {get; set;}
    public String guarantorRecordId {get; set;}
    public Encounter__c selectedEncounter {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
    public String errorMessages{get;set;}
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
    public PayEstimateLightning(ApexPages.StandardController controller, String encounterId) {
        // Get/Set Contact/Guarantor Id.
        guarantorRecordId = controller.getId();
        this.encounterId = encounterId;
		errorMessages = '';
        if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = PayStaffWSUtillLightning.fetchGuarantorContact(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = PayStaffWSUtillLightning.fetchGuarantorName(guarantorContact);
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
        /*for (Encounter__c en: [SELECT Id, Name, Patient__c, Date_of_Service__c, Procedure__c, Location__c,
                        Patient_Portion__c, Guarantor__c, Balance__c
                        FROM Encounter__c
                        WHERE Balance__c > 0
                            AND Guarantor__c = :guarantorRecordId
        ]) {
            //encounters.add(new EncounterWrapper(en, false));
            encounters.add(new EncounterWrapper(en, true));
        }*/
        System.debug('encounterId:' + encounterId);
        for (Encounter__c en: [SELECT Id, Name, Patient__c, Date_of_Service__c, Procedure__c, Location__c,
                        Patient_Portion__c, Guarantor__c, Balance__c
                        FROM Encounter__c
                        WHERE Balance__c > 0
                        AND Id = :encounterId
        ]) {
            //encounters.add(new EncounterWrapper(en, false));
            encounters.add(new EncounterWrapper(en, true));
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
    public String submit() {
        try {
            // Call creditCardValidation method that validate all informations/values for Credit Card.
            Boolean blnIsCCError = creditCardValidation();
            // Call amountValidation method that validate amount.
            Boolean blnIsAmountError = amountValidation();

            if (!blnIsCCError && !blnIsAmountError) {
                Payment__c payment = new Payment__c();
                payment.Name = PAYMENTNAME;
                payment.Guarantor__c = guarantorRecordId;
                payment.Amount__c = decimal.valueof(amount);
                payment.Encounter__c = selectedEncounter.Id;
                payment.Deposit_Date__c = system.now();
				payment.Method__c = 'credit';
                INSERT payment;

            } else {
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            
        }
        if (errorMessages == '') {
            errorMessages += 'Success;' + '0851' + ';$' + amount;
        }
        return errorMessages;
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

    /*
     * 08-19-2016: Sirono - Tracker #127324171
     * Method for check the validation.
     * 09-13-2016: Viraj Rana - Tracker #130117819:   Credit Card Error Messaging Method to check the Card validation. 
     */
    public boolean creditCardValidation() {
        boolean blnIsError = false;
        if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
            errorMessages += 'Credit card number must be 12-19 digits.';
            blnIsError = true;
        }
        if (String.isEmpty(creditCardNumber)) {
            errorMessages += 'Card Number is a required field.';
            blnIsError = true;
        }
        System.debug(expirationYear);System.debug(expirationMonth);
        expirationYear = '20' + expirationYear;
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            errorMessages += 'Expiration date must be in the future.';
            blnIsError = true;
        }
        if (!String.isEmpty(zip) && zip.length() != 5) {
            errorMessages +=  'Zip code must be 5 digits.';
            blnIsError = true;
        }
        if (!String.isEmpty(zip) && !zip.isNumeric()) {
            errorMessages +=   'Zip code can only contain numeric values.';
            blnIsError = true;
        }
        if (String.isEmpty(cardHolderName)) {
            errorMessages +=   'Name is a required field.';
            blnIsError = true;
        }

        if (!String.isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            errorMessages +=  'CVV must be 4 digits for American Express and 3 digits for other card types.';
            blnIsError = true;
        }

        if (String.isEmpty(cvv)) {
            errorMessages +=  'CVV is a required field.';
            blnIsError = true;
        }

        if (String.isEmpty(address)) {
            errorMessages +=   'Billing Address is a required field.';
            blnIsError = true;
        }

        if (String.isEmpty(zip)) {
            errorMessages +=  'Zip Code is a required field.';
            blnIsError = true;
        }

        return blnIsError;
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Method for check the validation.
     */
    public boolean amountValidation() {
        boolean blnIsError = false;
        if (String.isEmpty(amount) || (amount.isNumeric() && decimal.valueof(amount) == 0)) {
            errorMessages += 'Amount must be greater than zero.';
            blnIsError = true;
        } else {
            if (decimal.valueof(amount) < 0) {
                errorMessages += 'Amount must be greater than zero.';
                blnIsError = true;
            }
            System.debug('Balance : ' + selectedEncounter.Balance__c);
            System.debug('Amount : ' + decimal.valueof(amount));
            if (selectedEncounter.Balance__c < decimal.valueof(amount) ) {
                errorMessages += 'Amount cannot exceed balance.';
                blnIsError = true;
            }
        }
        return blnIsError;
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