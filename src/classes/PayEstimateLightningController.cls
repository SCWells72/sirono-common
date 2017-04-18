/**
 * PayEstimateLightningController class is lightning controller used in MakeAPaymentController class.
 * It is used to make a Payment of Encounter based on Guarantor Contact.
 * User can only make payment for one Encounter at a time.
 * Only display those Encounters whose balance is greater than zero.
 * Based on selected Encounter, Create a Payment Record.
 **/ 
public with sharing class PayEstimateLightningController extends PayEstimateController {
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
        errorMessages = addPayment('credit');
        return errorMessages;
    }

    /**
     * This method is used to check selected record
     * @return Boolean - return result of credit card validation
     **/
    protected override Boolean isValidCard() {
        // Call creditCardValidation method that validate all informations/values for Credit Card.
        String blnIsCCError = LightningValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
                zip, cardHolderName, cvv, address);
        errorMessages += blnIsCCError;
        return String.isEmpty(blnIsCCError);
    }

    /**
     * This method is used to check selected record
     * @return Boolean - return result of amount validation
     **/
    protected override Boolean isValidAmount() {
        // Call amountValidation method that validate amount.
        String blnIsAmountError = LightningValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c));
        errorMessages += blnIsAmountError;
        return String.isEmpty(blnIsAmountError);
    }
}