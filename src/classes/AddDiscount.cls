/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class AddDiscount {

    public String guarantorRecordId { get; set; }
    public String guarantorName { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public String chargeGroupId { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public String messageToShow { get; set; }

    private Payment__c objPayment = new Payment__c();
    private List<Transaction__c> lsttransaction = new List<Transaction__c>();
    private List<Charge_Group__c> lstChargeGroup = new List<Charge_Group__c>();
    private List<Payment_Plan__c> lstPaymentPlan = new List<Payment_Plan__c>();
    // Constructor of a class and initialize the variables.
    public AddDiscount(ApexPages.StandardController sc) {

        chargeGroupsSelected = false;
        messageToShow = 'Please select Charge Group(s) to add Discount.';
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorRecordId = sc.getId();
        guarantorName = '';
        if (guarantorRecordId != null) {
            Contact gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraintsForDiscount);
            guarantorName = GuarantorService.buildGuarantorDetailString(gc);
            //chargeGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
            for (ChargeGroupWrapper cgw : ChargeGroupWrapper.buildList(gc)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupId = '';
        }
    }

    //Check Charge group is selected or not and do the sum of the balance
    public PageReference doNext() {
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
            /*Mohan Kumar 08-02-2016: Changed the below calculation to multiply by 0.15 rather then 0.0015
            * 10-03-2016: Viraj Rana - Tracker #127404597: Use custom setting for discount to calculate discount amount based on Adjustment Rate.
            */
            Decimal discountRate = 0;
            discountRate = getDiscountRate();

            if (discountRate > 0) {
                discountToApply = ((totalAmount * discountRate) / 100).setScale(2); // 0.15 %
            }

            messageToShow = 'Clicking add discount will apply a $' + discountToApply + ' discount. '
                + 'The total will be adjusted from $' + totalAmount + ' to $' + (totalAmount - discountToApply) + '.';
        }/*else {
            chargeGroupsSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,
                                     'Please select atleast one Charge Group'));
        }*/
        return null;
    }

    //10-03-2016: Viraj Rana - Tracker #127404597: Use custom setting for discount to calculate discount amount based on Adjustment Rate.
    public Decimal getDiscountRate() {
        Decimal rate = 0;
        if (DiscountTypeMdtSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Discount_Type__mdt> discountType = [SELECT Rate__c FROM Discount_Type__mdt WHERE MasterLabel = 'Adjustment'];

            if (discountType.size() > 0) {
                rate = discountType[0].Rate__c;
            }
        }

        return rate;
    }

    //Check String is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //call addDiscount and send the request to end point.
    public void submit() {
        try {
            if (!isEmpty(chargeGroupId)) {
                String jwtToken = new SironoRestClient.AuthRestClient().getJwtToken();
                String csrfToken = new SironoRestClient.AuthRestClient().getCsrfToken();
                if (csrfToken != null && jwtToken != null) {
                    addDiscountRequest(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please provide all details.'));
                if (Test.isRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
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
        req.setEndpoint('callout:sirono_server/paystaff/api/adjustments/create-discount/');

        req.setBody(requestData);
        //For APEX Test
        //if (!Test.isRunningTest()) {
        try {
            res = http.send(req);
            responseBody = res.getBody();

            if (Test.isRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Discount has been added!'));
            chargeGroupsSelected = false;

            //Call Payment, Transaction, ChargeGroups, Payment Plan Request.
            PayStaffWSUtill.parsePaymentReponse(csrfToken, jwtToken, responseBody, false);

        } else {
            System.debug('AddDiscount req: ' + req);
            System.debug('AddDiscount req body: ' + req.getBody());
            System.debug('AddDiscount response: ' + res);
            System.debug('AddDiscount res body: ' + res.getBody());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'RESPONSE : ' + res.toString() +
                    '  RESPONSE BODY::' + responseBody));
            chargeGroupsSelected = true;
        }
    }
}