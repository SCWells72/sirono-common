/**
 * AddPaymentPlanVFController class is controller of AddPaymentPlan VF page.
 **/
 
public with sharing class AddPaymentPlanVFController extends AddPaymentPlanController {

    public AddPaymentPlanVFController() {
        // Get guarantorId and assign into the guarantorRecordId.
        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = ApexPages.currentPage().getParameters().get('guarantorId');
        }

        // Call init method of super class.
        init();

        if (errorMessages.size() > 0) {
            for (String str: errorMessages) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING, str));
            }
        }
    }

    /**
     * This method is use to add payment plan.
     **/
    public void doSubmit() {
        try {
            if (isValid()) {
                // Call CreatePaymentPlan method of super class.
                createPaymentPlan();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY));
            }
        } catch (SironoServiceException se) {
            for (String err: se.errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'SERVER ERROR RESPONSE:: ' + err));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ADD PAYMENT PLAN EXCEPTION:: ' + e.getMessage()));
        }
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
            for (String str: errorMessages) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, str));
            }
            return false;
        }
        return true;
    }

    /**
     * This method is use to set redirect page.
     *
     * @returns PageReference pg - That contains page url.
     **/
    public PageReference doCancel() {
        PageReference pg = null;
        if (String.isNotBlank(guarantorRecordId)) {
            pg = new PageReference('/' + guarantorRecordId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }
}