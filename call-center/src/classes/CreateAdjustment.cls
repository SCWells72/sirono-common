/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class CreateAdjustment {

    public String amount { get; set; }
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String chargeGroupId { get; set; }
    public Boolean isAdmin { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }

    public List<SelectOption> adjustmentTypeOptions { get; set; }
    public String selectedAdjType { get; set; }

    /*Constructor initializing variables ,check login user is admin or not.
     * Fetch Adjustment_Type__mdt records.
     */
    public CreateAdjustment(ApexPages.StandardController sc) {
        /*
         * The Add Adjustment button should only appear when the user has the appropriate permission.
         * Check for permission and set the isAdmin flag.
         */

        // Assume the user is not allowed to do this
        isAdmin = false;

        // First make sure that the user is allowed to create
        try {
            if (AdjustmentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                isAdmin = true;
            }
        } catch (SecurityException e) {
            System.debug('User: ' + UserInfo.getUserId() + ' cannot create adjustments.');
        }

        // If so, also check for the Add Adjustment custom permission
        if (isAdmin) {
            isAdmin &= CustomPermissionUtil.hasPermission(CustomPermissionUtil.ADD_ADJUSTMENT);
            if (!isAdmin) {
                System.debug('User: ' + UserInfo.getUserId() + ' does not have the Add Adjustment permission.');
            }
        }

        if (!isAdmin) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Adjustment_for_Admin));
        }

        chargeGroupsSelected = false;
        guarantorName = '';
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();

        //Fetch only enabled AdjustmentType metadata
        adjustmentTypeOptions = new List<SelectOption>();
        adjustmentTypeOptions.add(new SelectOption('', '--None--'));
        if (AdjustmentTypeMdtSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Adjustment_Type__mdt aType : [
                SELECT a.Id, a.Enabled__c, a.Description__c, a.Code__c
                FROM Adjustment_Type__mdt a
                WHERE Enabled__c = TRUE
            ]) {
                adjustmentTypeOptions.add(new SelectOption(aType.Code__c, aType.Description__c));
            }
        }

        if (guarantorRecordId != null) {
            Contact gt = GuarantorService.getGuarantorWithActiveCG(guarantorRecordId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gt);
            guarantorId = gt.Profile_Pointer_Id__c.toPlainString();
            chargeGroupList = ChargeGroupWrapper.buildList(gt);
            chargeGroupId = '';
        }
    }

    /**
     * Controller Method invoked from Visualforce page to get the chargegroup Id selected
     * also check is any chargegroup is selected or not.
     */
    public PageReference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (String.isNotBlank(chargeGroupId)) {
            chargeGroupsSelected = true;
        }
        return null;
    }

    //Verify all information is entered & then call the AdjustmentService to create the adjustment
    public PageReference submit() {

        if (String.isBlank(amount) || String.isBlank(chargeGroupId) || String.isBlank(selectedAdjType) || String.isBlank(guarantorRecordId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide all details.'));
        } else {
            try {
                AdjustmentService.AdjustmentRequest req = new AdjustmentService.AdjustmentRequest(guarantorRecordId,
                    Decimal.valueOf(chargeGroupId), selectedAdjType, Decimal.valueOf(amount));

                AdjustmentService.createAdjustment(req);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Adjustment created successfully'));
                return VisualforceControllerUtil.getRecordPageReference(guarantorRecordId);

            } catch (Exception e) {
                // Debug error response
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));
            }
        }

        return null;
    }
}