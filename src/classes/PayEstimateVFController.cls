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
        init(EncounterDao.ConditionObject.GUARANTOR.name(), guarantorRecordId);
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
}