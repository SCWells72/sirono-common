/*
* Controller for adding selected chargegroups to a payment plan
*
*/

public with sharing class AddToPaymentPlan {

    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String[] chargeGroupIds {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}

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
            Contact gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraints);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            //TODO move this out of PayStaffWSUtil into some sort of VF-Specific util class?
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            for (ChargeGroupWrapper cgw : ChargeGroupWrapper.buildList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupIds = new String[]{};
        }

        if (String.isBlank(paymentPlanExtId)) {
            paymentPlanExtId = getActivePaymentPlanId(guarantorRecordId);
            if (String.isBlank(paymentPlanExtId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        'No active Payment Plan exists for this Guarantor. Please click Cancel to go previous page.'));
            }
        }
    }

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
        chargeGroupIds = getSelectedChargeGroupIds();
        chargeGroupsSelected = !chargeGroupIds.isEmpty();

        return null;
    }

    private List<String> getSelectedChargeGroupIds() {
        Set<String> idSet = new Set<String>();
        for (ChargeGroupWrapper cgw : chargeGroupList) {
            if (cgw.isSelected) {
                idSet.add(cgw.cg.Sirono_ID__c.toPlainString());
            }
        }
        return new List<String>(idSet);
    }

    //Get the current guarantor's active PaymentPlan id
    private String getActivePaymentPlanId(String guarantorRecordId) {

        Payment_Plan__c activePaymentPlan = PaymentPlanDao.getActivePaymentPlan(guarantorRecordId);
        if (activePaymentPlan != null) {
            return activePaymentPlan.Sirono_ID__c.toPlainString();
        }
        return null;
    }

    /**
     * Add the chargeGroup to the paymentplan.
     */
    public void submit() {
        try {
            if (String.isBlank(paymentPlanExtId) || String.isBlank(guarantorId) || !chargeGroupsSelected) {
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
     * Call the PaymentPlanService to add the selected chargegroups to the payment plan
     */
    private void addChargeGroup() {
        try {
            PaymentPlanService.addChargeGroups(paymentPlanExtId, chargeGroupIds);
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
