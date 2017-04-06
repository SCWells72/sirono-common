@isTest
private class LightningValidationsTest {
    static testMethod void amountValidationTest() {
        Test.startTest();
        Boolean checkAmountValidation = LightningValidations.amountValidation('123', '200');
        System.assertEquals(checkAmountValidation, false);
        
        checkAmountValidation = LightningValidations.amountValidation('345', '200');
        System.assertEquals(checkAmountValidation, true);
        
        checkAmountValidation = LightningValidations.amountValidation('-25', '200');
        System.assertEquals(checkAmountValidation, true);

        checkAmountValidation = LightningValidations.amountValidation('0', '200');
        System.assertEquals(checkAmountValidation, true);

        Test.stopTest();
    }

    static testMethod void creditCardValidationTest() {
    	Test.startTest();
    	Boolean checkCreditCardValidation = LightningValidations.creditCardValidation('1234123412341234', '2100', '8', '12345', 'Holder Name', '1234', 'test@mail.com');
    	System.assertEquals(checkCreditCardValidation, false);

    	checkCreditCardValidation = LightningValidations.creditCardValidation('1234', '2008', '8', '12', 'Holder Name', '12', 'test@mail.com');
    	System.assertEquals(checkCreditCardValidation, true);

    	checkCreditCardValidation = LightningValidations.creditCardValidation('', String.valueOf(Date.today().year()), String.valueOf(Date.today().month() - 1), 'qwert', '', '', '');
    	System.assertEquals(checkCreditCardValidation, true);

    	checkCreditCardValidation = LightningValidations.creditCardValidation('', String.valueOf(Date.today().year()), String.valueOf(Date.today().month() - 1), '', '', '', '');
    	System.assertEquals(checkCreditCardValidation, true);

    	Test.stopTest();
    }
}