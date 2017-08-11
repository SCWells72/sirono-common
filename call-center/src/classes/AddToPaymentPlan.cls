/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public abstract class AddToPaymentPlan {

    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String[] chargeGroupIds { get; set; }
    public String paymentPlanId { get; set; }
    public String paymentPlanExtId { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }

   /**
    * Set the proper page on cancel
    */
    public PageReference cancel() {
        return String.isNotBlank(paymentPlanId) ?
            VisualforceControllerUtil.getRecordPageReference(paymentPlanId) :
            VisualforceControllerUtil.getRecordPageReference(guarantorRecordId);
    }

    //Check Charge group is selected or not.
    public PageReference doNext() {

        chargeGroupsSelected = false;
        // getSelectedChargeGroupIds method created in ChargeGroupWrapper class because of it is use in more than one class.
        chargeGroupIds = ChargeGroupWrapper.getSelectedChargeGroupIds(chargeGroupList);
        chargeGroupsSelected = !chargeGroupIds.isEmpty();

        return null;
    }
}