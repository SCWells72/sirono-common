/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * AddPaymentPlanController is a abstract class.
 * It is use to add payment plan from apex page or lighting.
 * This class extend/use in "AddPaymentPlanVFController" and "AddPaymentPlanLightningController" class.
 **/
public abstract class AddPaymentPlanController {
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String[] chargeGroupIds { get; set; }
    public String planType { get; set; }
    public String planValue { get; set; }
    public String amount { get; set; }
    public String promiseAmount { get; set; }
    public String executeOnDay { get; set; }
    public String cardHolderName { get; set; }
    public String expirationYear { get; set; }
    public String expirationMonth { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public Contact gc;
    public Sirono_Settings__c paymentPlanSettings = new Sirono_Settings__c();
    public Boolean isActivePaymentPlan { get; set; }
    public List<String> errorMessages;
    public UIUtils uiUtils { get; set; }

    // Adding values to the picklist
    public List<SelectOption> paymentPlanTypeOptions {
        get {
            if (paymentPlanTypeOptions == null) {
                paymentPlanTypeOptions = new List<SelectOption>();
                paymentPlanTypeOptions.add(new SelectOption(Constants.PLANTYPE_AUTO, Constants.PLANTYPE_AUTO_VALUE));
                paymentPlanTypeOptions.add(new SelectOption(Constants.PLANTYPE_PROMISE, Constants.PLANTYPE_PROMISE_VALUE));
            }
            return paymentPlanTypeOptions;
        }
        protected set;
    }

    /**
     * This method is use to initializing variables based on guarantorRecordId.
     * It is use to get contact related informations and charge groups.
     **/
    public void init() {
        errorMessages = new List<String>();
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        planType = null;
        isActivePaymentPlan = false;
        uiUtils = new UIUtils();

        if (guarantorRecordId != null) {
            gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraints);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = GuarantorService.getGuarantorSironoId(gc);
            chargeGroupList = ChargeGroupWrapper.buildList(gc);
            chargeGroupIds = new String[] {};

            // Check any payment plan is active for same guarantor or not.
            Payment_Plan__c activePaymentPlan = PaymentPlanService.getActivePaymentPlan(guarantorRecordId);
            if (activePaymentPlan != null) {
                isActivePaymentPlan = true;
                errorMessages.add(Label.Payment_Plan_Error);
            }
        }
    }

    protected abstract Boolean isValid();

    /**
     * This method checks the CG is select or not.
     **/
    public void doNext() {
        chargeGroupsSelected = false;
        chargeGroupIds = ChargeGroupWrapper.getSelectedChargeGroupIds(chargeGroupList);
        chargeGroupsSelected = !chargeGroupIds.isEmpty();
    }

    /**
     * It is used to get Payment Plan Setting.
     * It is called in VF page,
     * becuase of whenever profile is "Operations Manager or System Administrator" at that we need to create new custom setting for it.
     * If we create using class than we can't send Web Request after insert so we use this method using VF page.
     **/
    public void getPaymentPlanSettings() {
        paymentPlanSettings = SironoSettingsUtil.getPaymentPlanSettings();
    }

    /**
     * Fill the address, city, state, zip variables with the guarantor information.
     **/
    public void fillNameAndAddress() {
        cardHolderName = gc.Name;
        address = gc.MailingStreet;
        city = gc.MailingCity;
        state = gc.MailingState;
        zip = gc.MailingPostalCode;
    }

    /**
     * This method is use to call the PaymentPlanService to add payment plan.
     **/
    public void createPaymentPlan() {
        PaymentPlanInformation ppInfo = new PaymentPlanInformation();
        ppInfo.planType = planType;
        ppInfo.planValue = planValue;
        ppInfo.amount = planType.trim().equalsIgnoreCase(Constants.PLANTYPE_PROMISE) ? promiseAmount : amount;
        ppInfo.executeOnDay = executeOnDay;
        ppInfo.chargeGroupIds = chargeGroupIds;
        ppInfo.guarantorId = guarantorId;
        ppInfo.cardholderName = cardHolderName;
        ppInfo.expirationYear = expirationYear;
        ppInfo.expirationMonth = expirationMonth;
        ppInfo.creditCardNumber = creditCardNumber;
        ppInfo.cvv = cvv;
        ppInfo.state = state;
        ppInfo.zip = zip;
        ppInfo.address = address;
        ppInfo.city = city;

        // Call addPaymentPlan method to create payment plan.
        PaymentPlanService.addPaymentPlan(ppInfo);
    }
}