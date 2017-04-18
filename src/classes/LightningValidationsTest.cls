@isTest
private class LightningValidationsTest {
    static testMethod void amountValidationTest() {
        Test.startTest();
        String checkAmountValidation = LightningValidations.amountValidation('123', '200');
        System.assertEquals(checkAmountValidation, '');
        
        checkAmountValidation = LightningValidations.amountValidation('345', '200');
        System.assertEquals(checkAmountValidation, Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE);
        
        checkAmountValidation = LightningValidations.amountValidation('-25', '200');
        System.assertEquals(checkAmountValidation, Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO);

        checkAmountValidation = LightningValidations.amountValidation('0', '200');
        System.assertEquals(checkAmountValidation, Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO);

        Test.stopTest();
    }

    static testMethod void creditCardValidationTest() {
    	Test.startTest();
    	String checkCreditCardValidation = LightningValidations.creditCardValidation('1234123412341234', '2100', '8', '12345', 'Holder Name', '1234', 'test@mail.com');
    	System.assertEquals(checkCreditCardValidation, '');

    	checkCreditCardValidation = LightningValidations.creditCardValidation('1234', '2008', '8', '12', 'Holder Name', '12', 'test@mail.com');
    	System.assertEquals(checkCreditCardValidation, Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS +'\n' + 
                                                        Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE +'\n' +
                                                        Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT);

    	checkCreditCardValidation = LightningValidations.creditCardValidation('', String.valueOf(Date.today().year()), String.valueOf(Date.today().month() - 1), 'qwert', '', '', '');
    	System.assertEquals(checkCreditCardValidation, Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS +'\n' + 
                                                        Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE +'\n' +
                                                        Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_NAME_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_CVV_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE);

    	checkCreditCardValidation = LightningValidations.creditCardValidation('', String.valueOf(Date.today().year()), String.valueOf(Date.today().month() - 1), '', '', '', '');
    	System.assertEquals(checkCreditCardValidation, Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS +'\n' + 
                                                        Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_NAME_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_CC_CVV_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE +'\n' +
                                                        Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE);

    	Test.stopTest();
    }
}