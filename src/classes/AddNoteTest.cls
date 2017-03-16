/**
 * This class is use to test the logic of Add Note Class.
 **/

@isTest
private class AddNoteTest {
	
    /**
     * This method tests the logic of Error message when necessary parameters are not pass.
     **/
    static testMethod void SubmitElse() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        INSERT paymentPlan;

        Test.startTest();
        // Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        
        // Call Submit method and It will give an error "Please provide all details".
        // beacuse of we can't enter charge group Id and note.
        // It will cover code coverage of Else part in submit method.
        conOb.doSubmit();
        Test.stopTest();

        // Check System Assert.
        // It will give an error "Please provide all details" beacuse of we can't enter charge group Id and note.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Please provide all details.'))
            	isError = true;
        }
        System.assert(isError, 'Expected error message Please provide all details.');
    }

    /**
     * This method tests the logic submit method without Parameter.
     **/
    static testMethod void noParameterTest() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

	// Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

	// Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        paymentPlan.active__c = true;
        paymentPlan.Delinquent__c = true;
        INSERT paymentPlan;

        Test.startTest();
        // Create object of class and call doSubmit method.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        conOb.doSubmit();
        Test.stopTest();

	// Check system assert. It will give an exception beacuse of we can't pass charge group Id and note.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Divide by 0'))
            	isError = true;
        }
        System.assert(isError, 'Missing required details & arithmetic rule violation throws an Exception during doSubmit');
    }

    /**
     * This method tests the logic of Add Note functionality with necessary parameter and Web Request. 
     **/
    static testMethod void webServiceCallout() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
        
        // Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        // Set charge group Id and note value.
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        // Call Submit method and It will successfully save the record.
        conOb.doSubmit();
        Test.stopTest();
        
        // Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully!'))
            	isSuccess = true;
        }
        System.assert(isSuccess, 'Successfully Note Create');
    }

    /**
     * This method test/code coverage of "doAddNote" method's else part.
     * We have passed all necessary parameters but not set web service related parameter (Status, Status Code)
     * so we got error message like Web Request fail.
     **/
    static testMethod void doAddNoteElse() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);

        // Create Add Note object and Call Add Note constructor.
        AddNote conOb = new AddNote(new ApexPages.StandardController(paymentPlan));
        // Set charge group Id and note value.
        conOb.chargegroupId = 'test';
        conOb.noteText = 'test class';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        // Call Submit method and It will give an error.
        conOb.doSubmit();
        Test.stopTest();
        
        // Check System Assert, Exception occures during payment process because missing and bad requires.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('JWT_Token'))
            	isError = true;
        }
        System.assert(isError, 'JWT_Token Exception during Payment Process');
    }
}
