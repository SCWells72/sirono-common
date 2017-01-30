/**
 * Unit class for the PayEstimate Class.
 * It tests the Pay Estimate Process.
 * If Encounter balance is greater than zero and it's associate with Guarantor Contact than create/make a payment record for this encounter.
 * Check Amount and Card related validations.
 **/
@isTest
private class PayEstimateTest {
    
    /**
     * This method test the whole scenario of Pay Estimate Process.
     **/
    @isTest
    static void checkPayEstimateProcess() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, system.today());
        INSERT encounter;
        
        Test.startTest();
        
        // Create PayEstimate class object with guarantorContact.
        PayEstimate objPayEstimate = new PayEstimate(new ApexPages.StandardController(guarantorContact));        
        // Call getEncounterRecords method to Populate Encounter List.
        objPayEstimate.getEncounterRecords();
        
        // Based on Encounter List, Select Encounter record.
        for (PayEstimate.EncounterWrapper enw: objPayEstimate.encounters) {
            enw.isSelected = true;
        }
        
        // Call doNext Method.
        objPayEstimate.doNext();
        
        // Set page level variables based on criteria.
        objPayEstimate.expirationYear = String.valueof(System.today().Year() + 1);
        objPayEstimate.expirationMonth = '07';
        objPayEstimate.creditCardNumber= '1234567891113';
        objPayEstimate.cardHolderName= 'Test Name';
        objPayEstimate.zip = '07895';
        objPayEstimate.amount = '100';
        objPayEstimate.cvv = '1234';
        objPayEstimate.state = 'Test State';
        objPayEstimate.address = 'Test Address';
        objPayEstimate.city = 'Test City';
        // Call below parameters for Code Coverage.
        List<SelectOption> expYearOptions = objPayEstimate.expYearOptions;
        List<SelectOption> expMonthOptions = objPayEstimate.expMonthOptions;
        
        // Call checkAmountValidation method. That checks the Amount related Validation.
        objPayEstimate.checkAmountValidation();
        // Call checkCardValidation method. That checks the Card related validation.
        objPayEstimate.checkCardValidation();
        // Call submit method. that take/create payment for Encounter Record.
        objPayEstimate.submit();
        
        Test.stopTest();
        
        // Get List of Payment based on Encounter.
        List<Payment__c> payments = [SELECT Id, Amount__c, Guarantor__c, Encounter__c
                        FROM Payment__c
                        WHERE Encounter__c = :encounter.Id
        ];
        // Check system assert, Encounter Look up set in Payment Record or not.
        System.assertEquals(payments[0].Encounter__c, encounter.Id);
        // Check system assert, Guarantor is same for Payment and Encounter.
        System.assertEquals(payments[0].Guarantor__c, guarantorContact.Id);
        // Check system assert, We insert/set amount in object/record is assign into Payment.
        System.assertEquals(payments[0].Amount__c, decimal.valueof(objPayEstimate.amount));
        
        // Get List of Encounter based on Id.
        List<Encounter__c> encounters = [SELECT Id, Balance__c
                        FROM Encounter__c
                        WHERE Id = :encounter.Id
        ];
        // Set variable 500(Existing Balance in Encounter) minus Amount of Payment.
        Decimal encounterAmount = 500 - payments[0].Amount__c;
        // Check system assert, Enconter balance is decreases by the Amount of Payment.
        System.assertEquals(encounters[0].Balance__c, encounterAmount);
    }
    
    /**
     * This method test the FillNameAndAddress method functionality.
     * Based on Contact populate address, city, pincode, etc...
     **/
    @isTest
    static void checkFillNameAndAddress() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Test.startTest();
        
        // Create PayEstimate class object with guarantorContact.
        PayEstimate objPayEstimate = new PayEstimate(new ApexPages.StandardController(guarantorContact));
        
        // Check system asserts, all fields are null of objPayEstimate.
        System.assertEquals(objPayEstimate.cardHolderName, null);
        System.assertEquals(objPayEstimate.address, null);
        System.assertEquals(objPayEstimate.city, null);
        System.assertEquals(objPayEstimate.state, null);
        System.assertEquals(objPayEstimate.zip, null);
        
        // Update contact to set city, postal code.
        guarantorContact.MailingCity = 'Test City';
        guarantorContact.MailingPostalCode = '12345';
        UPDATE guarantorContact;
        
        // Create PayEstimate class object with updated guarantorContact.
        objPayEstimate = new PayEstimate(new ApexPages.StandardController(guarantorContact));
        // Call fillNameAndAddress method that set/assign address, city, zip, etc in Page Level variables.
        objPayEstimate.fillNameAndAddress();
        
        Test.stopTest();
        
        // Get Contact record.
        List<Contact> contacts = [SELECT Id, Name, MailingCity, MailingPostalCode
                    FROM Contact
                    WHERE Id = :guarantorContact.Id
        ];
        
        // Check system asserts that set/assign Page Level Variables based on Contact fields value.
        System.assertEquals(objPayEstimate.cardHolderName, contacts[0].name);
        System.assertEquals(objPayEstimate.city, contacts[0].MailingCity);
        System.assertEquals(objPayEstimate.zip, contacts[0].MailingPostalCode);
    }
    
    /**
     * This method test the Amount Validation functionality.
     **/
    @isTest
    static void checkAmountValidation() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, system.today());
        INSERT encounter;
        
        Test.startTest();
        // Create PayEstimate class object with guarantorContact.
        PayEstimate objPayEstimate = new PayEstimate(new ApexPages.StandardController(guarantorContact));
        
        // Based on Encounter List, Select Encounter record.
        for (PayEstimate.EncounterWrapper enw: objPayEstimate.encounters) {
            enw.isSelected = true;
        }
        
        // Call doNext Method.
        objPayEstimate.doNext();
        
        // Set Amount equals to 100.
        objPayEstimate.amount = '100';        
        // Call checkAmountValidation to Validate Amount Value.
        objPayEstimate.checkAmountValidation();
        
        Test.stopTest();
        
        //Check System Assert. We do not get any error message because of we pass amount equals to 100.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 0);
        
        // Set Amount equals to 0.
        objPayEstimate.amount = '0';        
        // Call checkAmountValidation to Validate Amount Value.
        objPayEstimate.checkAmountValidation();
        
        //Check System Assert. We got Error message Amount must be Greater than Zero.
        msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set Amount equals to 0.
        objPayEstimate.amount = '1000';        
        // Call checkAmountValidation to Validate Amount Value.
        objPayEstimate.checkAmountValidation();
        
        //Check System Assert. We got Error message Amount cannot exceed balance.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set Amount equals to less than 0.
        objPayEstimate.amount = '-100';        
        // Call checkAmountValidation to Validate Amount Value.
        objPayEstimate.checkAmountValidation();
        
        //Check System Assert. We got Error message Amount must be Greater than Zero.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test the Card Validation functionality.
     **/
    @isTest
    static void checkCardValidation() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Test.startTest();
        
        // Create PayEstimate class object with guarantorContact.
        PayEstimate objPayEstimate = new PayEstimate(new ApexPages.StandardController(guarantorContact));
        
        objPayEstimate.expirationYear = String.valueof(System.today().Year() + 1);
        objPayEstimate.expirationMonth = '07';
        objPayEstimate.creditCardNumber= '1234567891113';
        objPayEstimate.cardHolderName= 'Test Name';
        objPayEstimate.zip = '07895';
        objPayEstimate.amount = '';
        objPayEstimate.cvv = '1234';
        objPayEstimate.state = 'Test State';
        objPayEstimate.address = 'Test Address';
        objPayEstimate.city = 'Test City';
        
        Test.stopTest();
        
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        // Check system assert. All values are true, so we don't get any Error message.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 0);
        
        // Set creditCardNumber wrong.
        objPayEstimate.creditCardNumber = '1234';        
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        //Check System Assert. We got Error message Card number is 12 to 19 digits.
        msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CREDIT_CARD_NUMBER_12_19_DIGITS)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set creditCardNumber equals to empty.
        objPayEstimate.creditCardNumber = '';        
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        //Check System Assert. We got Error message Card number is require.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CREDIT_CARD_NUMBER_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set expirationYear less than to Current year and expirationMonth less than to Current month.
        objPayEstimate.expirationYear = String.valueof(System.today().Year());
        objPayEstimate.expirationMonth = String.valueof(System.today().Month() - 1);        
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        //Check System Assert. We got Error message Expiration Date must be in the future.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_EXPIRATION_DATE_FUTURE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set expirationYear less than to Current year for code coverage.
        objPayEstimate.expirationYear = String.valueof(System.today().Year() - 1);        
        
        // Set zip less than to five digit.
        objPayEstimate.zip = '0785';        
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        //Check System Assert. We got Error message Zip code must be 5 digits.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // Set zip as a string value.
        objPayEstimate.zip = 'test';
        objPayEstimate.cvv = '';
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        //Check System Assert. We got Error message Zip code can only contain numeric values.
        msgList = ApexPages.getMessages();
        isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
        
        // We simply set all variables for Code Coverage.        
        objPayEstimate.cardHolderName = '';
        objPayEstimate.cvv = '123456';
        objPayEstimate.address = '';
        objPayEstimate.zip = '';
        // Call checkCardValidation to Validate Card Fields.
        objPayEstimate.checkCardValidation();
        
        // Call submit method for Else Part code coverage.
        objPayEstimate.submit();
    }
}