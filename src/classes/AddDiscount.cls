public with sharing class AddDiscount {
	public String username {get; set;}
	public String password {get; set;}
	
	public String guarantorRecordId {get; set;}
	public String guarantorName {get;set;}
	public Boolean chargeGroupsSelected {get; set;} 
	
	public String chargegroupId {get;set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}
    
    public String messageToShow {get; set;}
    
    public AddDiscount(ApexPages.StandardController sc){
	    username = PayStaffWSUtill.un;
	    password = PayStaffWSUtill.pw;
	    chargeGroupsSelected = false;
	    messageToShow = 'Please select Charge Group(s) to add Discount.';
	    chrageGroupList = new List<ChargeGroupWrapper>();
	    String guarantorRecordId = sc.getId();
	    guarantorName = '';
	 	if(guarantorRecordId != null){
	 		Contact gc = PayStaffWSUtill.fetchGuarantorContact(guarantorRecordId);
	 		guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);
	 		//chrageGroupList = PayStaffWSUtill.fetchChargeGroupList(gc);
			for(ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc)){
				if(cgw.cg.Active__c && cgw.cg.Reported_Selfpay_Balance__c != 0){
					chrageGroupList.add(cgw);
				}
			}
			chargegroupId = '';
	 	}
	}
	
	public Pagereference doNext(){
		messageToShow = 'Please select Charge Group(s) to add Discount.';
		chargeGroupsSelected = false;
		chargegroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);
		if(!isEmpty(chargegroupId)){
			chargeGroupsSelected = true;
			Decimal totalAmount = 0, discountToApply = 0;
			for(ChargeGroupWrapper cgw : chrageGroupList){
				if(cgw.isSelected){
					totalAmount += Math.abs(cgw.cg.Reported_Selfpay_Balance__c);
				}
			}
			totalAmount = totalAmount.setScale(2);
			//Mohan Kumar 2016-08-02: Changed the below calculation to multiply by 0.15 rather then 0.0015
			discountToApply = (totalAmount*0.15).setScale(2); // 0.15 %
			
			messageToShow = 'Clicking add discount will apply a $'+discountToApply+' discount. '
			+ 'The total will be adjusted from $'+totalAmount+' to $'+(totalAmount-discountToApply)+'.';
		}/*else{
			chargeGroupsSelected = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please select atleast one Charge Group'));
		}*/
		return null;
	}
	
	private Boolean isEmpty(String str){
  		return (str == null || str.trim().equals(''));
  	}
  
	public void submit(){ 
    	try {
    		if(!isEmpty(chargegroupId)){
				String jwt_token = PayStaffWSUtill.getJWT_Token(username, password);
				String csrf_token = PayStaffWSUtill.getCSRF_Token();
				if(csrf_token != null && jwt_token != null){
	    			addDiscount(csrf_token, jwt_token);
				}
    		}else{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please provide all details.'));
    		}
  		} catch(Exception e) { 
     		// Debug error response
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
  		}
	}	
  
  	private void addDiscount(String csrfToken, String jwtToken) {
    	String request_data = '{"csrfmiddlewaretoken":"' + csrfToken + '",' +
        	'"code":"DIS",' + 
            '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargegroupId) + '}';
            
		HttpRequest req = new HttpRequest();
    	HttpResponse res = new HttpResponse();
    
	    Http http = new Http();
	    String responseBody;
     
	    req.setMethod('POST');
	    req.setHeader('Authorization', 'JWT ' + jwtToken);
    	req.setHeader('Content-type', 'application/json');
    	req.setEndpoint(SironoSettingsUtil.getServerEndpoint()+'/paystaff/api/adjustments/create-discount/');
    
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
			System.debug('RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Discount has been added!'));
			chargeGroupsSelected = false;
		}else{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'CSRF_Token : '+ csrfToken));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'JWT_Token : '+ jwtToken));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'RESPONSE : '+ res.toString() + '  RESPONSE BODY::' + responseBody));
			chargeGroupsSelected = true;
		}
	}
}