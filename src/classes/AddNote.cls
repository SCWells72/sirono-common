/*
* @author: Sirono
* @version 1.0.1
* @date: 05-02-2016
* 
* Class used for add a note.
*/

public with sharing class AddNote {
    public String username {get; set;}
    public String password {get; set;}
    public String chargeGroupId {get; set;}
    public String noteText {get; set;}

    //Constructor initializing the member variables
    public AddNote(ApexPages.StandardController sc) {
        username = PayStaffWSUtill.un;
        password = PayStaffWSUtill.pw;
        chargeGroupId = '';
    }

    //private method returning a boolean value
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //method to submit details. if details not provided display error
    public void doSubmit() {
        try {
            if (!isEmpty(chargeGroupId) && !isEmpty(noteText)) {
                String jwtToken = PayStaffWSUtill.getJWTToken(username, password);
                String csrfToken = PayStaffWSUtill.getCSRFToken();
                if (csrfToken != null && jwtToken != null) {
                    doAddNote(csrfToken, jwtToken);
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
                if (Test.IsRunningTest()) {
                    TestUtility.generateException();
                }
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
    }

    //Method making Webservice callouts via POST Method
    private void doAddNote(String csrfToken, String jwtToken) {
        String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
                '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + ',' +
                '"text":"' + noteText + '"' +
                '}';

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String responseBody;
        req.setMethod('POST');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroupnotes/');
        req.setBody(requestData);

        try {
            res = http.send(req);
            responseBody = res.getBody();
            if (Test.IsRunningTest()) {
                TestUtility.generateException();
            }
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
        }

        if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED') && res.getStatusCode() != null && res.getStatusCode() == 201) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : ' + csrfToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : ' + jwtToken));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody));
        }
    }
}