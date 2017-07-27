/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * PayEstimateVFController class is controller of PayEstimate VF page.
 * It is use to make a Payment of Encounter based on Guarantor Contact.
 * User can only make payment for one Encounter at a time.
 * Only display those Encounters whose balance is greater than zero.
 * Based on selected Encounter, Create a Payment Record.
 **/
public with sharing class PayEstimateVFController extends PayEstimateController {
    /**
     * Constructor of Class with standard controller.
     *
     * @param ApexPages.StandardController controller - That contains Contact/Id.
     **/
    public PayEstimateVFController(ApexPages.StandardController controller) {
        super();
        guarantorRecordId = controller.getId();
        init(guarantorRecordId);
    }

    protected override void loadEncounters(String recordId) {
        Encounter__c[] encounterList = EncounterService.getEncounterRecordsByGuarantorId(recordId);
        encounters = EncounterWrapper.buildList(encounterList);
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * It is create record when all validations are successfully pass out.
     **/
    public void submit() {
        try {
            errorMessages = new List<String>();
            Boolean validAmount = isValidAmount();
            Boolean validCard = isValidCard();
            if (validAmount && validCard) {
                addPayment(null);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY));
            }
        } catch (SironoServiceException se) {
            for (String err : se.errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'SERVER ERROR RESPONSE:: ' + err));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'ERROR: ' + e.getMessage()));
        }
    }

    /**
     * This method is use to check credit card validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    protected override Boolean isValidCard() {
        // Call creditCardValidation method that validate all informations/values for Credit Card.
        errorMessages.addAll(VisualForceValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
            zip, cardHolderName, cvv, address));

        if (errorMessages.size() > 0) {
            for (String str : errorMessages) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, str));
            }
            return false;
        }
        return true;
    }

    /**
     * This method is use to check amount validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    protected override Boolean isValidAmount() {
        // Call amountValidation method that validate amount.
        errorMessages.addAll(VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c)));

        if (errorMessages.size() > 0) {
            for (String str : errorMessages) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, str));
            }
            return false;
        }
        return true;
    }
}