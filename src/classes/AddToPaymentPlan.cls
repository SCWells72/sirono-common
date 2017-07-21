/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public abstract class AddToPaymentPlan{

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String[] chargeGroupIds {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}
    public String errorMessage{get;set;}

   /**
    * Set the proper page on cancel
    */
    public PageReference cancel() {
        PageReference pg = null;
        if (String.isNotBlank(paymentPlanId)) {
            pg = new PageReference('/' + paymentPlanId);
        } else if (String.isNotBlank(guarantorRecordId)) {
            pg = new PageReference('/' + guarantorRecordId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
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