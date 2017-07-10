/**
 * AddPaymentPlanLightningController class is lightning controller of CreatePaymentPlan class.
 **/

//TODO: delete me...unused
public with sharing class AddPaymentPlanLightningController extends AddPaymentPlanController {

    public String message;

    public AddPaymentPlanLightningController(String recordId) {
        message = '';
        // Assign guarantorRecordId.
        guarantorRecordId = recordId;

        // Call init method of super class.
        init();

        if (errorMessages.size() > 0) {
            message = String.join(errorMessages, '');
        }
    }

    /**
     * This method is use to add payment plan.
     **/
    public String addPaymentPlan() {

        try {
            if (isValid()) {
                // Call CreatePaymentPlan method of super class.
                createPaymentPlan();
                message = Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY;
            }
        } catch (SironoServiceException se) {
            message = 'SERVER ERROR RESPONSE:: ' + String.join(se.errors, '');
        } catch (Exception e) {
            // Debug error response
            message = 'PROCESS PAYMENT EXCEPTION:: ' + e.getMessage();
        }
        return message;
    }

    /**
     * This method is use to check validations successfully pass out or not.
     *
     * @returns Boolean - That contains true or false based on errorMessages.
     **/
    protected override Boolean isValid() {
        errorMessages = new List<String>();

        // Calculate sum of selected CG's balance.
        Decimal selectedCGsBalance = 0;
        for (ChargeGroupWrapper cgw: chargeGroupList) {
            if (cgw.cg.Balance__c != null && cgw.IsSelected) {
                selectedCGsBalance += cgw.cg.Balance__c;
            }
        }
        planValue = String.valueOf(selectedCGsBalance);

        // Call amountValidationForAddPaymentPlan method that validate amount related validations.
        String amountValue = planType.trim().equalsIgnoreCase(Constants.PLANTYPE_PROMISE) ? promiseAmount : amount;
        errorMessages.addAll(VisualForceValidations.amountValidationForAddPaymentPlan(amountValue, selectedCGsBalance));

        if (planType.trim().equalsIgnoreCase(Constants.PLANTYPE_AUTO)) {
            // Call creditCardValidationForAddPaymentPlan method that validate credit card related validations.
            errorMessages.addAll(VisualForceValidations.creditCardValidationForAddPaymentPlan(creditCardNumber, expirationYear, expirationMonth,
                    zip, cardHolderName, cvv, address, chargeGroupIds, executeOnDay));
        }

        if (errorMessages.size() > 0) {
            message = String.join(errorMessages, '');
            return false;
        }
        return true;
    }
}