/*
* @author Sirono
* @version 1.0.1
* @Date: 05-02-2016
* @ Unit class  for the AddNote class.     
* Do the code coverage for the AddNote class
*/

@isTest
private class AddNoteTest {
    /*Coverage the code for the AddNote class and init the variable call the doSubmit*/
    static testMethod void SubmitElse() {
        AddNote conOb = new AddNote();
        /*Test.startTest();
        TestUtility objUtility = new TestUtility();

        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
		
        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        //Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        
         /* Call Submit method and It will give an error "Please provide all details".
         * beacuse of we can't enter charge group Id and note.
         * It will cover code coverage of Else part in submit method.
         *
        conOb.doSubmit();

        /* Check System Assert.
         * It will give an error "Please provide all details" beacuse of we can't enter charge group Id and note.
         *
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Please provide all details.')) isError  = true;
    }
        Test.stopTest();*/
    }
	/*
    static testMethod void noParameterTest() {
        Test.startTest();
        TestUtility objUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;


        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.doSubmit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    /* Coverage the code for the AddNote class and init the variable,
     * call if condition of doSubmit Method and call if conditon of doAddNote method
     *
    static testMethod void webServiceCallout() {
        TestUtility objUtility = new TestUtility();

        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);

        //Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        //Set charge group Id and note value.
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Created Successfully!".
         *
        conOb.doSubmit();
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully!')) isError  = true;
        }
    }

    /* Coverage the code for the AddNote class and init the variable,
     * call if condition of doSubmit Method and call else conditon of doAddNote method
     *
    static testMethod void submit() {
        TestUtility objUtility = new TestUtility();

        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);

        //Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        //Set charge group Id and note value.
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        /* Call Submit method and It will give an error.
         * Beacuse of we can't set the parameter for webservice to cover code of Else part in Submit method.
         *
        conOb.doSubmit();
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(4, msgList.size());
        Test.stopTest();

    }*/
}