/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-20-2016
* 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
* Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
* 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
* 
*/

public with sharing class AddToPaymentPlanLightning extends AddToPaymentPlan {
    /**
     * Constructor of a class and initialize the variables. Get list of ChargeGroups and Id of active plan
     **/
    public AddToPaymentPlanLightning(String gId) {
        super();
        errorMessage = '';
        paymentPlanExtId = null;
        paymentPlanId = null;

        guarantorRecordId = gId;

        if (guarantorRecordId != null) {
            Contact gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId);
            chargeGroupList = ChargeGroupWrapper.buildList(gc);
            chargeGroupIds = new String[]{};
        }

        if (String.isBlank(paymentPlanExtId)) {
            Payment_Plan__c currentPaymentPlan = PaymentPlanService.getActivePaymentPlan(guarantorRecordId);
            if(currentPaymentPlan != null){
                paymentPlanExtId = currentPaymentPlan.Sirono_ID__c.toPlainString();
            }
            if (String.isBlank(paymentPlanExtId)) {
                errorMessage += 'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.';
            }
        }
    }

    /**
     * Call addChargeGroups and send the request to end point.
     **/
    public String submit() {
        String returnMessage = '';
        try {
            paymentPlanExtId = paymentPlanExtId.replace(',', '');
            PaymentPlanService.addChargeGroups(paymentPlanExtId, chargeGroupIds);
            returnMessage = 'Added Successfully!';
        } catch (Exception e) {
            // Debug error response
            returnMessage = 'ERROR: ' + e.getMessage();
        }
        return returnMessage;
    }
}