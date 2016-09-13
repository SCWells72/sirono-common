public with sharing class SkipPaymentPlan {
	public String username {get; set;}
	public String password {get; set;}
	
	public String guarantorId {get;set;}
	public String paymentPlanId {get;set;}
	public String messageToShow {get; set;}
	public String paymentPlanExtId {get; set;}
	
	public Boolean isAutomatic {get;set;}
	
	public SkipPaymentPlan(){
		username = PayStaffWSUtill.un;
	    password = PayStaffWSUtill.pw;
	    guarantorId = null;
	    paymentPlanId = null;
	    paymentPlanExtId = null;
	    messageToShow = '';
	    isAutomatic = false;
	    
	 	if(Apexpages.currentPage().getParameters().containsKey('guarantorId')){
	 		guarantorId = Apexpages.currentPage().getParameters().get('guarantorId');
	 	}
	 	if(Apexpages.currentPage().getParameters().containsKey('paymentPlanId')){
	 		paymentPlanId = Apexpages.currentPage().getParameters().get('paymentPlanId');
	 	}
	 	if(Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')){
	 		paymentPlanExtId = Apexpages.currentPage().getParameters().get('paymentPlanExtId');
	 	}
	 		
	 	Date instDate = System.Today().addDays(7);
	 	messageToShow = 'Clicking skip payment installment will skip the next installment due to charge in '
	 		+ System.today().daysBetween(instDate)+' days on '+instDate.format()+'. The next installment will charge on '
	 		+ instDate.addMonths(1).format() + '.';
	 		
	 	validatePaymentPlanType();
	}
	
	//Mohan Kumar 2016-08-17: (127324647) Validate the Payment is of type Automatic to process the skip payment else return a message user
	private void validatePaymentPlanType() {
		List<test__c> automaticPaymentPlans = [Select Id, Sirono_ID__c From test__c Where Id =: paymentPlanId and Plan_Type__c = 'Automatic'];
  		if(automaticPaymentPlans.size() > 0) isAutomatic = true;
  		else ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Sorry, the Skip Payment Plan is not of type Automatic. Please click Cancel to go previous page.'));
	}
	
	private Boolean isEmpty(String str){
  		return (str == null || str.trim().equals(''));
  	}
  	
  	//Mohan Kumar 2016-08-01: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
  	public Pagereference cancel(){
  		Pagereference pg = null;
		if(!isEmpty(paymentPlanId)){
			pg = new Pagereference('/'+paymentPlanId);
		}else if(!isEmpty(guarantorId)){
			pg = new Pagereference('/'+guarantorId);
		}else{
			pg = new Pagereference('/home/home.jsp');
		}
		pg.setRedirect(true);
		return pg;
  	}
  	
	public void doSubmit(){ 
		try {
			if(!isEmpty(paymentPlanExtId)){
	    		String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
				String csrf_token = PayStaffWSUtill.getCSRF_Token();
				if(csrf_token != null && jwt_token != null){
	    			doSkipPaymentPlan(csrf_token, jwt_token);
				}
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Payment Plan Id is missing.'));
			}
  		} catch(Exception e) { 
     		// Debug error response
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
  		}
	}
	
	//Mohan Kumar 2016-08-02: Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
	private void doSkipPaymentPlan(String csrfToken, String jwtToken) {
    	String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '"}';
        
    	HttpRequest req = new HttpRequest();
    	HttpResponse res = new HttpResponse();
    
	    Http http = new Http();
	    String responseBody;
     
	    req.setMethod('POST');
	    req.setHeader('Authorization', 'JWT ' + jwtToken);
    	req.setHeader('Content-type', 'application/json');
    	req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/paymentplan/'+PayStaffWSUtill.trimCommas(paymentPlanExtId)+'/skip_payment/');
    	req.setBody(request_data);
    	System.debug('req: '+ req);
    	System.debug('req: '+request_data);
    	//For APEX Test
	    if (!Test.isRunningTest()){
	      	try {
				res = http.send(req);
				responseBody = res.getBody();
	        } catch(Exception e) {
	        	// Debug error response
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
	      	}
		}else{
			res.setStatus('CREATED');
			res.setStatusCode(200);
		}
		
		if(res.getStatusCode() != null && res.getStatusCode() == 200){
			System.debug('RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Skipped Successfully.'));
		}else{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody));
		}
	}
}