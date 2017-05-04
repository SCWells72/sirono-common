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
 * 10-17-2016: Viraj Rana - Tracker # 129073861: Take Discount/Adjustment in SF
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
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}

    //Mohan Kumar 2016-08-16: 127328707 to show the adjustment type from the metadata type which are only enabled
    public List<SelectOption> adjustmentTypeOptions {get; set;}
    public String adjustmentTypeSelected {get; set;}
    private Payment__c objPayment = new Payment__c();
    private List<Transaction__c> lsttransaction = new List<Transaction__c>();
    private List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
    private List<Payment_Plan__c> lstPaymentPlan = new List<Payment_Plan__c>();

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
        if (UserSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<User> lstUser = new List<User>(
            [
                    SELECT Id, ProfileId
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    AND Profile.Name = 'System Administrator'
            ]
            );
            if (lstUser.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,
                        System.Label.Adjustment_for_Admin));
                isAdmin = false;
            }
        }

        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        guarantorName = '';
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();

        //Mohan Kumar 2016-08-16: fetch only those metadata type which are marked as enabled
        adjustmentTypeOptions = new List<SelectOption>();
        adjustmentTypeOptions.add(new SelectOption('', '--None--'));
        if (AdjustmentTypeMdtSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Adjustment_Type__mdt aType: [
                    SELECT a.Id, a.Enabled__c, a.Description__c, a.Code__c
                    FROM Adjustment_Type__mdt a
                    WHERE Enabled__c = true
            ]) {
                adjustmentTypeOptions.add(new SelectOption(aType.Code__c, aType.Description__c));
            }
        }
        if (guarantorRecordId != null) {
            Contact gc = GuarantorService.getGuarantorWithActiveCG(guarantorRecordId);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
            chargeGroupList = ChargeGroupWrapper.buildList(gc);
            chargeGroupId = '';
        }
    }

    /*Controller Method invoked from Visualforce page and get the chargegroup Id
     * also check is any chargegroup is selected or not.
     */
    public Pagereference doNext() {
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
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
                '"amount":' + PaymentPlanService.convertToCents(amount) + ',' +
                '"code":"' + adjustmentTypeSelected + '"}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/adjustments/');

        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            if(Test.IsRunningTest()){
                TestUtility.generateException();
            }
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
            //Call Payment, Transaction, ChargeGroups, Payment Plan Request.
            PayStaffWSUtill.parsePaymentReponse(csrfToken, jwtToken, responseBody, false);
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'csrfToken : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'jwtToken : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody));
        }
    }
}