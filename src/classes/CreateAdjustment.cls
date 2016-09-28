/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-12-2016
 *
 * Mohan Kumar 08-16-2016: 127328707 - 
 * To show the adjustment type from the metadata type which are only enabled
 * 08-26-2016: Sirono - Tracker # 127767953 
 * The Add Adjustment button should only appear 
 * when the user has Admin profile. do the Query and set the flag isAdmin.
 * 
 */

public with sharing class CreateAdjustment {
    public String username {get; set;}
    public String password {get; set;}
    public String amount {get; set;}
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargeGroupId {get; set;}
    public Boolean isAdmin {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}

    //Mohan Kumar 2016-08-16: 127328707 to show the adjustment type from the metadata type which are only enabled
    public List<SelectOption> adjustmentTypeOptions {get; set;}
    public String adjustmentTypeSelected {get; set;}

    /*Constructor initializing variables ,check login user is admin or not.
     * Fetch Adjustment_Type__mdt records.
     */
    public CreateAdjustment(ApexPages.StandardController sc) {
        /*
         * 08-26-2016: Sirono - Tracker # 127767953
         * The Add Adjustment button should only appear when the user has Admin profile. 
         * Do the Query and set the flag isAdmin.
         */

        isAdmin = true;
        List<User> lstUser = new List<User>(
        [
                Select Id, ProfileId
                From User
                Where id = :UserInfo.getUserId()
                and Profile.Name = 'System Administrator'
        ]
        );
        if (lstUser.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                    System.Label.Adjustment_for_Admin));
            isAdmin = false;
        }

        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        guarantorName = '';
        chrageGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();

        //Mohan Kumar 2016-08-16: fetch only those metadata type which are marked as enabled
        adjustmentTypeOptions = new List<SelectOption>();
        adjustmentTypeOptions.add(new SelectOption('', '--None--'));
        for (Adjustment_Type__mdt aType : [
                Select a.Id, a.Enabled__c, a.Description__c, a.Code__c
                From Adjustment_Type__mdt a
                Where Enabled__c = true
        ]) {
            adjustmentTypeOptions.add(new SelectOption(aType.Code__c, aType.Description__c));
        }
        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            chargeGroupId = '';
        }
    }

    /*Controller Method invoked from Visualforce page and get the chargegroup Id
     * also check is any chargegroup is selected or not.
     */
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
        }/*else {
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 
                                        'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    //Check pass string is empty or not.
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //Check All information is enter or not and call the method createAdjustmetWSCall
    public void submit() {
        try {
            if (!isEmpty(amount) && !isEmpty(chargeGroupId) && !isEmpty(adjustmentTypeSelected)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    createAdjustmetWSCall(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                        'Please provide all details.'));
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'ERROR: ' + e.getMessage()));
        }
    }

    //Send request to the endpoint.
    private void createAdjustmetWSCall(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroup":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroups/' + chargeGroupId + '/",' +
                '"amount":' + PayStaffWSUtill.convertToCents(amount) + ',' +
                '"code":"' + adjustmentTypeSelected + '"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/adjustments/');

        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody +
                            ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                    'Created Successfully!'));
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'csrfToken : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'jwtToken : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody));
        }
    }
}