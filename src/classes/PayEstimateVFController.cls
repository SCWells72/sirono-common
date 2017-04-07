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
        errorMessages = addPayment(null);
        if (errorMessages != null) {
            ApexPages.addMessage(new ApexPages.Message((errorMessages.contains('ERROR')) ? ApexPages.SEVERITY.ERROR : ApexPages.SEVERITY.INFO, errorMessages));
        }
    }

    /**
     * This method is used to check selected record
     * @return Boolean - return result of credit card validation
     **/
    protected override Boolean isValidCard() {
        // Call creditCardValidation method that validate all informations/values for Credit Card.
        Boolean blnIsCCError = VisualForceValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
                zip, cardHolderName, cvv, address);
        return !blnIsCCError;
    }

    /**
     * This method is used to check selected record
     * @return Boolean - return result of amount validation
     **/
    protected override Boolean isValidAmount() {
        // Call amountValidation method that validate amount.
        Boolean blnIsAmountError = VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c));
        return !blnIsAmountError;
    }
}