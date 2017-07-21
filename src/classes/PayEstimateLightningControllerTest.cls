/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
public class PayEstimateLightningControllerTest {

    @isTest
    public static void payEstimatePortalUser() {

        User usr = TestUtility.getGuarantorCommunityUser();
        Contact gt = GuarantorService.getPortalGuarantor(usr.Id);
        Contact pt = TestUtility.generatePatientContact();

        System.assert(gt != null, 'No valid GT found');

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(gt.Id, 500, System.today());
        encounter.Patient__c = pt.Id;
        INSERT encounter;

        System.runAs(usr) {
            // Create PayEstimate class object with guarantorContact.
            PayEstimateLightningController objPayEstimate = new PayEstimateLightningController(new ApexPages.StandardController(gt), encounter.Id);

            // Call doNext Method.
            objPayEstimate.doNext();

            // Set page level variables based on criteria.
            objPayEstimate.expirationYear = String.valueof(System.today().Year() + 1);
            objPayEstimate.expirationMonth = '07';
            objPayEstimate.creditCardNumber = '1234567891113';
            objPayEstimate.cardHolderName = 'Test Name';
            objPayEstimate.zip = '07895';
            objPayEstimate.amount = '100';
            objPayEstimate.cvv = '1234';
            objPayEstimate.state = 'Test State';
            objPayEstimate.address = 'Test Address';
            objPayEstimate.city = 'Test City';

            // Call submit method. that take/create payment for Encounter Record.
            String message = objPayEstimate.submit();
            System.assert(!message.contains('ERROR'), 'Error paying estimate: '+message);
        }


        // Get List of Payment based on Encounter.
        List<Payment__c> payments = [
                SELECT Id, Amount__c, Guarantor__c, Encounter__c
                FROM Payment__c
                WHERE Encounter__c = :encounter.Id
        ];

        System.assert(payments.size() == 1, 'Expected 1 payment, but found '+payments.size());
        // Check system assert, Encounter Look up set in Payment Record or not.
        System.assertEquals(payments[0].Encounter__c, encounter.Id);
        // Check system assert, Guarantor is same for Payment and Encounter.
        System.assertEquals(payments[0].Guarantor__c, gt.Id);
        // Check system assert, We insert/set amount in object/record is assign into Payment.
        System.assertEquals(payments[0].Amount__c, 100.00, 'Expected payment of $100.00, but got: '+payments[0].Amount__c);

        // Get List of Encounter based on Id.
        List<Encounter__c> encounters = [
                SELECT Id, Balance__c
                FROM Encounter__c
                WHERE Id = :encounter.Id
        ];
        // Set variable 500(Existing Balance in Encounter) minus Amount of Payment.
        Decimal encounterAmount = 500 - payments[0].Amount__c;
        // Check system assert, Encounter balance decreased by the Amount of Payment.
        System.assertEquals(encounters[0].Balance__c, encounterAmount);
    }

    /**
     * This method test the whole scenario of Pay Estimate Process.
     **/
    @isTest
    static void checkPayEstimateProcess() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();

        // Create PayEstimate class object with guarantorContact.
        PayEstimateLightningController objPayEstimate = new PayEstimateLightningController(new ApexPages.StandardController(guarantorContact), encounter.Id);

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
     * This method test/cover the else part of Submit method.
     **/
    @isTest
    static void submitElsePart() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();
        // Create PayEstimateLightningController class object with guarantorContact.
        PayEstimateLightningController objPayEstimate = new PayEstimateLightningController(new ApexPages.StandardController(guarantorContact), encounter.Id);
        objPayEstimate.guarantorRecordId = guarantorContact.Id;

        Encounter__c[] encounterList = EncounterService.getEncounterRecordsByGuarantorId(guarantorContact.id);
        objPayEstimate.encounters = EncounterWrapper.buildList(encounterList);

        // Based on Encounter List, Select Encounter record.
        for (EncounterWrapper enw: objPayEstimate.encounters) {
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

    /**
     * Verify the encounter associated with the estimatePayment gets selected.
     **/
    @isTest
    static void verifyEncounterIsSelected() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();

        // Create PayEstimate class object with guarantorContact.
        PayEstimateLightningController objPayEstimate = new PayEstimateLightningController(new ApexPages.StandardController(guarantorContact), encounter.Id);
        Test.stopTest();

        // Verify that the encounter is selected
        System.assert(objPayEstimate.encounters != null, 'Should have populated the encounters object');
        System.assert(objPayEstimate.encounters.size() == 1, 'Should have found a single encounter.');
        System.assert(objPayEstimate.encounters.get(0).isSelected, 'Encounter should be selected.');
    }

    /**
     * This method tests the logic of errorMessages/message is empty or not.
     **/
    @isTest
    static void errorMessageTest() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();
        // Create PayEstimateLightningController class object with guarantorContact.
        PayEstimateLightningController objPayEstimate = new PayEstimateLightningController(new ApexPages.StandardController(guarantorContact), encounter.Id);
        objPayEstimate.guarantorRecordId = guarantorContact.Id;

        Encounter__c[] encounterList = EncounterService.getEncounterRecordsByGuarantorId(guarantorContact.id);
        objPayEstimate.encounters = EncounterWrapper.buildList(encounterList);

        // Based on Encounter List, Select Encounter record.
        for (EncounterWrapper enw: objPayEstimate.encounters) {
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

        System.assert(String.isEmpty(objPayEstimate.message), 'Default message is empty/null.');

        // Call submit method.
        objPayEstimate.submit();

        Test.stopTest();

        // Check system assert.
        System.assert(!String.isEmpty(objPayEstimate.message), 'Expected message is not empty/null.');

        // Check Amount validation related error.
        System.assert(objPayEstimate.message.contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO),
            'Expected ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO + ' error message.');

        // Check Credit Card validation related error.
        System.assert(objPayEstimate.message.contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO),
            'Expected ' + Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS + ' error message.');
    }
}