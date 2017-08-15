/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Mock object for the HeaderWrapper.  Allows for testings of logic in the controller without having to
 * create many levels of SF objects.
 */
public with sharing class HeaderWrapperMock extends HeaderWrapper {

    public String guarantorStatus { get; set; }
    public Boolean addPaymentPlan { get; set; }
    public Boolean paymentPlanExists { get; set; }
    public Boolean paymentPlanActive { get; set; }
    public String paymentPlanStanding { get; set; }
    public String planType { get; set; }

    public HeaderWrapperMock() {
    }

    public override String getGuarantorStatus() {
        return this.guarantorStatus;
    }

    public override Boolean hasAddToPaymentPlan() {
        return addPaymentPlan;
    }

    public override Boolean getPaymentPlanActive() {
        return paymentPlanActive;
    }

    public override Boolean hasPaymentPlan() {
        return paymentPlanExists;
    }

    public override String getPaymentPlanType() {
        return planType;
    }

    public override String getPaymentPlanStanding() {
        return paymentPlanStanding;
    }
}