/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * PayEstimateLightningController class is lightning controller used in MakeAPaymentController class.
 * It is used to make a Payment of Encounter based on Guarantor Contact.
 * User can only make payment for one Encounter at a time.
 * Only display those Encounters whose balance is greater than zero.
 * Based on selected Encounter, Create a Payment Record.
 **/
public with sharing class PayEstimateLightningController {
    // Page Level Variables.
    public String address { get; set; }
    public String amount { get; set; }
    public String cardHolderName { get; set; }
    public String city { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public List<EncounterWrapper> encounters { get; set; }
    public String expirationMonth { get; set; }
    public String expirationYear { get; set; }
    public Contact guarantorContact { get; set; }
    public String guarantorRecordId { get; set; }
    public Encounter__c selectedEncounter { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public List<String> errorMessages { get; set; }
    public String message;

    /**
     * Constructor of Class with standard controller.
     *
     * @param ApexPages.StandardController controller - That contains Contact/Id.
     * @param String encounterId - Encounter record ID.
     **/
    public PayEstimateLightningController(ApexPages.StandardController controller, String encounterId) {
        guarantorRecordId = controller.getId();
        errorMessages = new List<String>();
        if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = GuarantorService.getGuarantor(guarantorRecordId);

            // Call getEncounterRecords method.
            loadEncounters(encounterId);
        }
    }

    private void loadEncounters(String encounterRecordId) {
        Encounter__c[] encounterList = EncounterService.getEncounterRecordsById(encounterRecordId);
        encounters = EncounterWrapper.buildList(encounterList);

        // We just selected encounters by Id, there should only be one.  Make it selected.
        if (encounters != null && encounters.size() == 1) {
            encounters.get(0).isSelected = true;
        } else {
            System.debug('WARNING: Found more then a single encounter with id: ' + encounterRecordId + ' in PayEstimateLightningController. Size: ' + encounters.size());
        }
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * It is create record when all validations are successfully pass out.
     * @return String - error/success message
     **/
    public String submit() {
        try {
            errorMessages = new List<String>();
            message = '';
            Boolean validAmount = isValidAmount();
            Boolean validCard = isValidCard();
            if (validAmount && validCard) {
                message = addPayment('credit');
            }
        } catch (SironoServiceException se) {
            message = 'SERVER ERROR RESPONSE:: ' + String.join(se.errors, '');
        } catch (Exception e) {
            // Debug error response
            message = 'ERROR: ' + e.getMessage();
        }

        return message;
    }

    /**
     * This method is used to get selected record
     **/
    public void doNext() {
        EncounterWrapper checkEncounter = checkNext(encounters);
        selectedEncounter = (checkEncounter.en != null) ? checkEncounter.en : selectedEncounter;
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * @param String paymentMethod - payment method
     **/
    public String addPayment(String paymentMethod) {
        // Call createNewPayment method.
        Payment__c payment = PaymentService.createNewPayment(guarantorRecordId, Decimal.valueOf(amount), selectedEncounter.Id, System.now(), paymentMethod);
        return (payment == null) ? 'ERROR: ' + PortalConstants.PAGE_MESSAGE_CREATED_FAIL : 'Success;' + payment.Name + ';$' + amount;
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
            for (EncounterWrapper enw : encounters) {
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

    /**
     * This method is use to check credit card validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    private Boolean isValidCard() {
        // Call creditCardValidation method that validate all informations/values for Credit Card.
        errorMessages.addAll(VisualForceValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
            zip, cardHolderName, cvv, address));

        if (errorMessages.size() > 0) {
            message = String.join(errorMessages, '');
            return false;
        }
        return true;
    }

    /**
     * This method is use to check amount validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    private Boolean isValidAmount() {
        // Call amountValidation method that validate amount.
        errorMessages.addAll(VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c)));

        if (errorMessages.size() > 0) {
            message = String.join(errorMessages, '');
            return false;
        }
        return true;
    }
}