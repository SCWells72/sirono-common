/*
* @author Sirono
* @version 1.0.1
* @Date: 05-16-2016
* @AddDiscount Test Class for the Code Covrege of Add Discount Class.
*/

@isTest
public class AddDiscountTest{

    /* Coverage the code for the AddDiscount class and
     * call the doNext, getDiscountRate,submit and addDiscountRequest (else condition) method
     */                    
    static testMethod void submit() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;
        
        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        
        //Create Add Discount object and Call Add Discount constructor.
        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id,patientContact.Id);
        insert invoice;
        
        //Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);        
        chargeGroup.Sirono_ID__c = 123;        
        insert chargeGroup; 

        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(chargeGroup ,100,'Automatic');
        insert transactionObj;
        
        //Create Charge Group record.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Sirono_ID__c = 124;
        insert chargeGroup;
        
        //Call Add Discount constructor with Selected charge group records.
        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for(ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList){
            cgw.isSelected = true;
        }
                
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */ 
        objAddDiscount.doNext();
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /*Call submit method.
         * It will give error when web api callout beacuse of we can't set status code.
         * It covers request else part.
         */
        objAddDiscount.submit();  
        
        //Check System Assert.
        System.assert(objAddDiscount.messageToShow.contains('Clicking add discount will app'), 'Unexpected error: '+objAddDiscount.messageToShow);
        Test.stopTest(); 
    }
    
    /* Do the unit test for the Submit method Else statement.
     *
     * Coverage the code for the AddDiscount class and
     * call the doNext Method,getDiscountRate Method,Submit method Else statement
     */                    
    static testMethod void SubmitElse() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;
        
         //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        
        //Create Add Discount object and Call Add Discount constructor and submit method.
        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        
        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter Charge Group.
         * It will cover code coverage of Else part in submit method.
         */
        objAddDiscount.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details.')) isError  = true;
        }
        System.assertEquals(isError,true);
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id,patientContact.Id);
        insert invoice;
        
        //Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);        
        chargeGroup.Sirono_ID__c = 123;        
        insert chargeGroup; 
               
        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(chargeGroup ,100,'Automatic');
        insert transactionObj;
        
        //Create Charge Group record.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Sirono_ID__c = 124;
        insert chargeGroup;
        
        //Call Add Discount constructor with Selected charge group records.
        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for(ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objAddDiscount.doNext();
        
        /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we don not provide Web service releted information.
         * It will cover code coverage of Else part in submit method.
         */
        objAddDiscount.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList1 = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg : msgList1 ) {
            if (msg.getDetail().contains('Please provide all details.')) isError  = true;
        }
        System.assertEquals(isError,true);
    }
    
    /* Do the web service call out and get the cover the if condition code = 201
     *
     * Coverage the code for the AddDiscount class and
     * call the doNext Method,getDiscountRate Method,Submit method and addDiscountRequest Method
     */                    
    public static testMethod void webServiceCallout() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;
        
        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        
        //Create Add Discount object and Call Add Discount constructor.
        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id,patientContact.Id);
        insert invoice;
        
        //Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);        
        chargeGroup.Sirono_ID__c = 123;        
        insert chargeGroup; 
               
        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(chargeGroup ,100,'Automatic');
        insert transactionObj;
        
        //Create Charge Group record.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Sirono_ID__c = 124;        
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
        
        //Call Add Discount constructor with Selected charge group records.
        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for(ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList){
            cgw.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objAddDiscount.doNext();
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());                
        
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Discount has been added!".
         */
        objAddDiscount.submit();  
        
        //Check System Assert.
        List<ApexPages.Message> msgList1 = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList1) {
            if (msg.getDetail().contains('Discount has been added!')) isError  = true;
        }
        System.assertEquals(isError,true);
        
        Test.stopTest(); 
    }
}