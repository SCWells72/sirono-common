/**
 * Test class for the PayEstimateVFController Class.
 **/
 
@isTest
private class PayEstimateVFControllerTest {
    
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
        
        // Create PayEstimateVFController class object with guarantorContact.
        PayEstimateVFController objPayEstimate = new PayEstimateVFController(new ApexPages.StandardController(guarantorContact));        
        
        // Based on Encounter List, Select Encounter record.
        for (PayEstimateController.EncounterWrapper enw: objPayEstimate.encounters) {
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
}