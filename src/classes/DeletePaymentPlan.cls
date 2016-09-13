public with sharing class DeletePaymentPlan {
	public String username {get; set;}
	public String password {get; set;}
	
	public String guarantorId {get;set;}
	public String paymentPlanId {get;set;}
	public String paymentPlanExtId {get; set;}
	
	public DeletePaymentPlan(){
		username = PayStaffWSUtill.un;
	    password = PayStaffWSUtill.pw;
	    guarantorId = null;
	    paymentPlanId = null;
	    paymentPlanExtId = null;
	    
	 	if(Apexpages.currentPage().getParameters().containsKey('guarantorId')){
	 		guarantorId = Apexpages.currentPage().getParameters().get('guarantorId');
	 	}
	 	if(Apexpages.currentPage().getParameters().containsKey('paymentPlanId')){
	 		paymentPlanId = Apexpages.currentPage().getParameters().get('paymentPlanId');
	 	}
	 	if(Apexpages.currentPage().getParameters().containsKey('paymentPlanExtId')){
	 		paymentPlanExtId = Apexpages.currentPage().getParameters().get('paymentPlanExtId');
	 	}	
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
	    			doDeletePaymentPlan(csrf_token, jwt_token);
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
	private void doDeletePaymentPlan(String csrfToken, String jwtToken) {
    	HttpRequest req = new HttpRequest();
    	HttpResponse res = new HttpResponse();
    
	    Http http = new Http();
	    String responseBody;
     
	    req.setMethod('DELETE');
	    req.setHeader('Authorization', 'JWT ' + jwtToken);
    	req.setHeader('Content-type', 'application/json');
    	req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/paymentplan/'+PayStaffWSUtill.trimCommas(paymentPlanExtId)+'/');
    	//For APEX Test
	    if (!Test.isRunningTest()){
	      	try {
				System.debug('req: '+ req);
				res = http.send(req);
				responseBody = res.getBody();
	        } catch(Exception e) {
	        	// Debug error response
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'PROCESS PAYMENT EXCEPTION RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage()));
	      	}
		}else{
			res.setStatus('CREATED');
			res.setStatusCode(204);
		}
		
		if(res.getStatusCode() != null && res.getStatusCode() == 204){
			System.debug('RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Payment plan was successfully cancelled.'));
		}else{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody));
		}
	}
}