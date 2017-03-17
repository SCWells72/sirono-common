/*
* Controller for adding selected chargegroups to a payment plan
*
*/

public with sharing class AddToPaymentPlan {

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargeGroupId {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}

    // Constructor of a class and initialize the variables.
    public AddToPaymentPlan() {
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        paymentPlanExtId = null;
        paymentPlanId = null;

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanExtId')) {
            paymentPlanExtId = ApexPages.currentPage().getParameters().get('paymentPlanExtId');
        }
        if (ApexPages.currentPage().getParameters().containsKey('paymentPlanId')) {
            paymentPlanId = ApexPages.currentPage().getParameters().get('paymentPlanId');
        }

        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorFilterCGByAcctSubStatus(guarantorRecordId, PayStaffWSUtill.CGConstraints);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }

        // Launch Add to Payment Plan from contact Guarantor record
        if (String.isBlank(paymentPlanExtId)) {
            paymentPlanExtId = getActivePaymentPlanId(guarantorRecordId);
            if (String.isBlank(paymentPlanExtId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.'));
            }
        }
    }

    /**
    * Update the QueryString parameter value to fix the "URL No Longer Exists" error.
    */
    public PageReference cancel() {
        PageReference pg = null;
        if (!isEmpty(paymentPlanId)) {
            pg = new PageReference('/' + paymentPlanId);
        } else if (!isEmpty(guarantorRecordId)) {
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
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }
        return null;
    }

    //Check String is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Get the Active Payment plan id
    private String getActivePaymentPlanId(String guarantorRecordId) {

        Payment_Plan__c activePaymentPlan = PaymentPlanDao.getActivePaymentPlan(guarantorRecordId);
        if (activePaymentPlan!= null) {
            return activePaymentPlan.Sirono_ID__c.format();
        }
        return null;
    }

    /**
     * Call addToPaymentPlanCall.
     */
    public void submit() {
        try {
            if (isEmpty(paymentPlanExtId) || isEmpty(guarantorId) || isEmpty(chargeGroupId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Please provide all details.'));
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            } else {
                addChargeGroup();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ERROR: ' + e.getMessage()));
        }
    }

    /**
     * Test enabler for submit
     */
    @TestVisible
    private void setChargeGroupId(String cgId) {
        chargeGroupId = cgId;
    }

    /**
     * Test enabler for submit
     */
    @TestVisible
    private void setGuarantorId(String gId) {
        guarantorId = gId;
    }

    /**
     * Call the sirono server to add the selected chargegroup to the payment plan then
     * update the SF copy of the data
     */
    private void addChargeGroup() {

        try {
            PaymentPlanService.addChargeGroup(paymentPlanExtId, new String[] {chargeGroupId});
        } catch (SironoServiceException se) {
            for (String err: se.errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'SERVER ERROR RESPONSE:: ' + err));
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'PROCESS PAYMENT EXCEPTION:: ' + e.getMessage()));
        }
    }
}
