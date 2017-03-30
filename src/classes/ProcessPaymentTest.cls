/*
 * @author Sirono
 * @version 1.0.1
 * @date: 04-19-2016 
 * @ProcessPaymentTest Test Class for the Code Covrege of ProcessPayment Class.
 *
 * 08-19-2016: Sirono - Tracker # 127324171
 * Improve the code coverage3
 */

@isTest
private class ProcessPaymentTest {
    
    /**
     * Coverage the code for the Init the Global Veriables,Constructor, Call expYearOptions,expMonthOptions method,
     * doNext Method,Submit Method,checkAmountValidation Method and checkCardValidation Method
     */
    static testMethod void submitElse() {
    	TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Create object of ProcessPayment and call the Process Payment constructor & submit method.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        List<SelectOption> expYearOptions = objProcessPayment.expYearOptions;
        List<SelectOption> expMonthOptions = objProcessPayment.expMonthOptions;
        objProcessPayment.submit();
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;
        
        //Call Process Payment constructor with Selected charge group records and also call doNext, submit methods.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '123';
        objProcessPayment.cardholderName = '123';
        objProcessPayment.expirationYear = '123';
        objProcessPayment.expirationMonth = '123';
        objProcessPayment.cvv = '123';
        objProcessPayment.amount = '123';
        objProcessPayment.address = '123';
        objProcessPayment.city = '123';
        objProcessPayment.state = '123';
        objProcessPayment.zip = '123';
        
        /* Call Submit method and It will give an error "Amount cannot exceed balance."
         * It will cover code coverage of Else part in submit method.
         */
        objProcessPayment.submit();
        
        //Check System Assert.        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError  = true;
        }
        System.assertEquals(isError,true);
    }

     /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     *
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method.
     */
    static testMethod void checkCardValidation() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor and submit method.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.submit();

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;

        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroupWithExternalId(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup= TestUtility.generateChargeGroupWithExternalId(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records and also call doNext, submit methods.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        //Set variables based on test criteria to cover code of creadit card validations.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = '2016';
        objProcessPayment.expirationMonth = '07';
        
        /* Call Submit method and It will give an errors regarding creadit card.
         * It will cover code coverage of Creadit card validation.
         */
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number must be 12-19 digits.')) isError  = true;
        }
        System.assertEquals(isError,true);
    }
    
     /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     *
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method
     */
    static testMethod void checkAmountEmpty() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor and submit method.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.submit();

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;

        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.zip = 'avcsc';
        objProcessPayment.cvv= '07897';
        objProcessPayment.cardHolderName = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        /* Call Submit method and It will give an error "Amount must be greater than zero."
         * It will cover code coverage of checkAmountValidation method.
         */
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError  = true;
        }
        System.assertEquals(isError,true);
    }
    
     

     /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     *
     * Coverage the code for the Init the Global Veriables,Submit Method,doNext Method,
     * checkAmountValidation Method, checkCardValidation Method
     */
    static testMethod void fillNameAndAddress() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Create object of ProcessPayment and call the Process Payment constructor & fillNameAndAddress method.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.fillNameAndAddress();
        
        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        //Call Submit method and It will cover the code of fillNameAndAddress() method based on guarantor Id.
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError  = true;
        }
        System.assertEquals(isError,true);
    }
   
    /* Coverage the code for the Init the Global Veriables,Submit Method,doNext Method,
     * checkAmountValidation Method, checkCardValidation Method
     */
    static testMethod void checkExceedBalance() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '300';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';
        
        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will give an error "Amount cannot exceed balance."
         * It will cover code coverage of checkAmountValidation method.
         */
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance')) isError  = true;
        }
        System.assertEquals(isError,true);
        Test.stopTest();
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     *
     * Coverage the code for the Init the Global Veriables,Submit Method,doNext Method,
     * checkAmountValidation Method, checkCardValidation Method
     */
    static testMethod void checkAmountNegative() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;

        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.guarantorRecordId = '';
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '-1';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
        
        /* Call Submit method and It will give an error "Amount must be greater than zero."
         * It will cover code coverage of checkAmountValidation method.
         */
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError  = true;
        }
        System.assertEquals(isError,true);        
    }
    
    /* Coverage the code for the Init the Global Veriables,Submit Method,doNext Method,
     * checkCardValidation Method,processPayment Method
     */
    static testMethod void submit() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will successfully save the record.
         * Set variables for call the Webservice.
         * we get response message "Created Successfully!".
         */
        objProcessPayment.submit();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully!')) isError  = true;
        }
        System.assertEquals(isError,true);
        Test.stopTest();
         
    }
    
   /*Coverage the code for the Init the Global Veriables,checkCardValidation Method for chargeGroupId */ 
  static testMethod void checkChargeGroupId() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '77897';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';
        
        //Call checkCardValidation methods to validate the Charge Group.
        objProcessPayment.checkCardValidation();
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Charge Group is a required field.')) isError  = true;
        }
        System.assertEquals(isError,true);
  }
  
  /* Coverage the code for the Init the Global Veriables,Call DoNext method,
   * Submit Method,checkAmountValidation Method and checkCardValidation Method,
   * processPayment Method with get response
   */
  static testMethod void paymentException() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_NON_FIELD);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Generate Payments Exception throw web api.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) isError  = true;
        }
        System.assertEquals(isError,true); 
        
        Test.stopTest();
    }
    
  /* Coverage the code for the Init the Global Veriables,Call DoNext method,
   * Submit Method,checkAmountValidation Method and checkCardValidation Method,
   * processPayment Method get response where 'kind' value doesnot exist in responseBody
   */
  static testMethod void wrapperListException() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_LIST);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Generate wrapperList Exception throw web api.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) isError  = true;
        }
        System.assertEquals(isError,true); 
        
        Test.stopTest();         
    }
    
    /* Unit Test for the response code.
     * 
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method,
     * processPayment Method get response where 'kind' value doesnot exist in responseBody
     */
  static testMethod void chargeGroupException() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_CHARGEGROUPS);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Generate charge group Exception throw web api.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) isError  = true;
        }
        System.assertEquals(isError,true); 
        
        Test.stopTest();
         
    }
    
    /* Unit Test for the response code.
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method,
     * processPayment Method get response where 'kind' AND 'chargegroups' value doesnot exist in responseBody
     */
  static testMethod void ResponseElse() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = 'Error';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Cover else part of process Payment Reponse.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Error')) isError  = true;
        }
        System.assertEquals(isError, true);
        
        Test.stopTest();         
    }
    
    /* Unit Test for the response code.
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method,
     * processPayment Method get response where 'kind' AND 'chargegroups' value doesnot exist in responseBody
     */
    static testMethod void validationException() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
        
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody  = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Generate Validation Exception throw web api.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing plan')) isError  = true;
        }
        System.assertEquals(isError,true); 
        
        Test.stopTest();         
    }
    
    /* Unit Test for the response code.
     * Coverage the code for the Init the Global Veriables,Call DoNext method,
     * Submit Method,checkAmountValidation Method and checkCardValidation Method,
     * processPayment Method get response where only non_field_errors exist in responseBody
     */
    static testMethod void nonFieldException() {
        TestUtility objTestUtility = new TestUtility();
        
        //Create Guarantor Contact record with different Profile_Pointer_Id.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;        

        //Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        //Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        //Call Process Payment constructor.
        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        //Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);       
        insert invoice;
        
        //Create Charge Group records.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
        
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;
        
        //Create Transaction record.
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;

        //Call Process Payment constructor with Selected charge group records.
        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        //Set variables based on criteria.
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber= '1234567891113';
        objProcessPayment.cardHolderName= '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        /* Call doNext method.
         * check any chargegroup is selected or not.
         * We select all charge groups in above so this method is run successfully and will proceed next step. 
         */
        objProcessPayment.doNext();
              
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody  = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.NO_KIND);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        
        /* Call Submit method and It will pass the record to web api.
         * Set variables for call the Webservice.
         * Generate Validation Exception throw web api.
         */
        objProcessPayment.submit(); 
        
        //Check System Assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing plan')) isError  = true;
        }
        System.assertEquals(isError,true); 
        
        Test.stopTest();         
    }
}