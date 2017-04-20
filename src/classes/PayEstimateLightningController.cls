/**
 * PayEstimateLightningController class is lightning controller used in MakeAPaymentController class.
 * It is used to make a Payment of Encounter based on Guarantor Contact.
 * User can only make payment for one Encounter at a time.
 * Only display those Encounters whose balance is greater than zero.
 * Based on selected Encounter, Create a Payment Record.
 **/ 
public with sharing class PayEstimateLightningController extends PayEstimateController {

    public String message;

    /**
     * Constructor of Class with standard controller.
     *
     * @param ApexPages.StandardController controller - That contains Contact/Id.
     * @param String encounterId - Encounter record ID.
     **/
    public PayEstimateLightningController(ApexPages.StandardController controller, String encounterId) {
        super();
        guarantorRecordId = controller.getId();
        init(encounterId);
    }

    protected override void loadEncounters(String recordId) {
        Encounter__c[] encounterList = EncounterService.getEncounterRecordsById(recordId);
        encounters = EncounterWrapper.buildList(encounterList);
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * It is create record when all validations are successfully pass out.
     * @return String - error/success message
     **/
    public String submit() {
        try {
            if (isValidCard() && isValidAmount()) {
                addPayment('credit');
                message = Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY;
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
     * This method is use to check credit card validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    protected override Boolean isValidCard() {
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
    protected override Boolean isValidAmount() {
        // Call amountValidation method that validate amount.
        errorMessages.addAll(VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c)));

        if (errorMessages.size() > 0) {
            message = String.join(errorMessages, '');
            return false;
        }
        return true;
    }
}