public with sharing class AddNote {
	public String username {get; set;}
	public String password {get; set;}
	
	public String chargegroupId {get;set;}
	
	public String noteText {get;set;}
	
	public AddNote(ApexPages.StandardController sc){
		username = PayStaffWSUtill.un;
	    password = PayStaffWSUtill.pw;
	    chargegroupId = '';
	}
	
	private Boolean isEmpty(String str){
  		return (str == null || str.trim().equals(''));
  	}
  	
	public void doSubmit(){ 
		try {
			if(!isEmpty(chargegroupId) && !isEmpty(noteText)){
	    		String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
				String csrf_token = PayStaffWSUtill.getCSRF_Token();
				if(csrf_token != null && jwt_token != null){
	    			doAddNote(csrf_token, jwt_token);
				}
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
			}
  		} catch(Exception e) { 
     		// Debug error response
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
  		}
	}
	
	private void doAddNote(String csrfToken, String jwtToken) {
    	String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
        	'"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + ',' +
            '"text":"' + noteText + '"' +
		'}';
            
		HttpRequest req = new HttpRequest();
    	HttpResponse res = new HttpResponse();
    
	    Http http = new Http();
	    String responseBody;
     
	    req.setMethod('POST');
	    req.setHeader('Authorization', 'JWT ' + jwtToken);
    	req.setHeader('Content-type', 'application/json');
    	req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/chargegroupnotes/');
    	req.setBody(request_data);
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
			res.setStatusCode(201);
		}
		if(res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED')
			&& res.getStatusCode() != null && res.getStatusCode() == 201){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody));
		}
	}
}