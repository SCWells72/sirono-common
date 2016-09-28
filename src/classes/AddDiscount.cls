/*
* @author Sirono
* @version 1.0.1
* @Date: 05-16-2016
* @AddDiscount Class for the Add Discount.
*/

public with sharing class AddDiscount {
    public String username {get; set;}
    public String password {get; set;}
    public String guarantorRecordId {get; set;}
    public String guarantorName {get; set;}
    public Boolean chargeGroupsSelected {get; set;}
    public String chargeGroupId {get; set;}
    public List<ChargeGroupWrapper> chargeGroupList {get; set;}
    public String messageToShow {get; set;}

    // Constructor of a class and initialize the variables.
    public AddDiscount(ApexPages.StandardController sc) {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupsSelected = false;
        messageToShow = 'Please select Charge Group(s) to add Discount.';
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();
        guarantorName = '';
        if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
            //chargeGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }
    }

    //Check Charge group is selected or not and do the sum of the balance
    public Pagereference doNext() {
        messageToShow = 'Please select Charge Group(s) to add Discount.';
        chargeGroupsSelected = false;
        chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);
        if (!isEmpty(chargeGroupId)) {
            chargeGroupsSelected = true;
            Decimal totalAmount = 0, discountToApply = 0;
            for (ChargeGroupWrapper cgw : chargeGroupList) {
                if (cgw.isSelected) {
                    totalAmount += cgw.cg.Balance__c;
                }
            }
            totalAmount = totalAmount.setScale(2);
            //Mohan Kumar 08-02-2016: Changed the below calculation to multiply by 0.15 rather then 0.0015
            discountToApply = (totalAmount * 0.15).setScale(2); // 0.15 %

            messageToShow = 'Clicking add discount will apply a $' + discountToApply + ' discount. '
                    + 'The total will be adjusted from $' + totalAmount + ' to $' + (totalAmount - discountToApply) + '.';
        }/*else {
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                     'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    //Check String is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //call addDiscount and send the request to end point.
    public void submit() {
        try {
            if (!isEmpty(chargeGroupId)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    addDiscountRequest(csrfToken, jwtToken);
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

    //call addDiscount and send the request to end point.
    private void addDiscountRequest(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"code":"DIS",' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + '}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        Http http = new Http();
        String responseBody;

        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/adjustments/create-discount/');

        req.setBody(requestData);
        //For APEX Test
        //if (!Test.isRunningTest()) {
        try {
            res = http.send(req);
            responseBody = res.getBody();
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' +
                            e.getMessage()));
        }
        /*}else {
            res.setStatus('CREATED');
            res.setStatusCode(201);
        }*/

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
                && res.getStatusCode() != null && res.getStatusCode() == 201) {
            System.debug('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Discount has been added!'));
            chargeGroupsSelected = false;
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                    'RESPONSE : ' + res.toString() +
                            '  RESPONSE BODY::' + responseBody));
            chargeGroupsSelected = true;
        }
    }
}