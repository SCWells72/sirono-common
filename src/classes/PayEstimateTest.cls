/**
 * Test class for the PayEstimate Class.
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
     * This method test/cover the else part of Submit method.
     **/
    @isTest
    static void submitElsePart() {
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
        
        // Set variables to generate errors.
        objPayEstimate.amount = '';
        objPayEstimate.cvv = '';
        objPayEstimate.creditCardNumber = '1234';
        objPayEstimate.expirationYear = String.valueof(System.today().Year());
        objPayEstimate.expirationMonth = String.valueof(System.today().Month() - 1);
        
        // Call submit method.
        objPayEstimate.submit();
        
        Test.stopTest();
        
        // Get List of Payment based on Encounter.
        List<Payment__c> payments = [SELECT Id, Amount__c, Guarantor__c, Encounter__c
                        FROM Payment__c
                        WHERE Encounter__c = :encounter.Id
        ];
        // Check system assert, Payment is not create for encounter.
        System.assertEquals(payments.size(), 0);
    }
}