/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-20-2016
* 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
* Ticket # 06638015 - Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
* 08-01-2016: Ticket # 06638016 - Updated the QueryString parameter value to fix the "URL No Longer Exists" error.
* 
*/

public with sharing class AddToPaymentPlanLightning {
    public String guarantorRecordId {get; set;}
    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String paymentPlanId {get; set;}
    public String paymentPlanExtId {get; set;}
    public List<String> chargeGroupsIds{get;set;}
	public String errorMessage{get;set;}
	
    // Constructor of a class and initialize the variables.
    public AddToPaymentPlanLightning(String gId) {
        chargeGroupsIds = new List<String>();
        errorMessage = '';
        paymentPlanExtId = null;
        paymentPlanId = null;

        guarantorRecordId = gId;
        
	    if (guarantorRecordId != null) {
            Contact gc = PayStaffWSUtillLightning.fetchGuarantorContactWithCGConstraints(guarantorRecordId);
            for (ChargeGroupWrapper cgw : PayStaffWSUtillLightning.fetchChargeGroupList(gc)) {
		if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupsIds.add(String.ValueOf(cgw.cg.Sirono_ID__c));
                }
            }
        }

        //Mohan Kumar 08-16-2016: launch Add to Payment Plan from contact Guarantor record 
        if (String.isBlank(paymentPlanExtId)) {
			System.debug('guarantorRecordId:'+guarantorRecordId);
            Payment_Plan__c currentPaymentPlan = PaymentPlanService.getActivePaymentPlan(guarantorRecordId);
			if(currentPaymentPlan != null){
				paymentPlanExtId = currentPaymentPlan.Sirono_ID__c.format();
			}
			if (String.isBlank(paymentPlanExtId)) {
                errorMessage += 'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.';
            }
        }
    }
   
    //call addToPaymentPlanCall and send the request to end point.
    public String submit() {
	paymentPlanExtId = paymentPlanExtId.replace(',', '');
	PaymentPlanService.addChargeGroups(paymentPlanExtId, chargeGroupsIds);
	return null;
    }   
    
    /*
    * 09-16-2016: Viraj Rana 
    *  Call this method to test
    */
    Public void doTesting() {
        String str = PaymentPlanJSONParsing.testResponse();
       // parseResponse(str);
    }
    
}