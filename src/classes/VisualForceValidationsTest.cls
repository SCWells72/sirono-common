/**
 * Test class for the VisualForceValidations Class.
 * It tests the all validations related to Visual Force page.
 **/
 
@isTest
private class VisualForceValidationsTest {
    
    /**
     * This method test to check amount is empty or not.
     **/
    @isTest
    static void checkAmountEmpty() {
        // Set amount equals to empty.
        String amount = '';
        // Call checkAmountNotEmpty method.
        VisualForceValidations.checkAmountNotEmpty(amount);
        
        //Check System Assert. We got Error message Amount must be Greater than Zero.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check amount is greater than zero or not.
     **/
    @isTest
    static void checkAmountGreaterThanZero() {
        // Set amount equals to -100.
        String amount = '-100';
        // Call checkAmountGreaterThanZero method.
        VisualForceValidations.checkAmountGreaterThanZero(amount);
        
        //Check System Assert. We got Error message Amount must be Greater than Zero.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check amount is exceed the balance or not.
     **/
    @isTest
    static void checkAmountExceedBalance() {
        // Set amount equals to 200.
        String amount = '200';
        // Set balance equals to 100.
        String balance = '100';
        // Call checkAmountExceedBalance method.
        VisualForceValidations.checkAmountExceedBalance(amount, balance);
        
        //Check System Assert. We got Error message Amount cannot exceed balance.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test the amountValidation method.
     **/
    @isTest
    static void checkAmountValidation() {
        // Set amount equals to 200.
        String amount = '200';
        // Set balance equals to 100.
        String balance = '100';
        // Call amountValidation method.
        Boolean result = VisualForceValidations.amountValidation(amount, balance);
        
        //Check System Assert. We got result true becuase of amount is greater than to balance.        
        System.assertEquals(result, true);
        
        // Set amount equals to 100.
        amount = '100';
        // Set balance equals to 200.
        balance = '200';
        // Call amountValidation method.
        result = VisualForceValidations.amountValidation(amount, balance);
        
        //Check System Assert. We got result false becuase of amount is less than to balance.        
        System.assertEquals(result, false);
    }
    
    /**
     * This method test to check cc number is 12 to 19 digit or not.
     **/
    @isTest
    static void checkCcNumberDigit() {        
        // Set ccNumber.
        String ccNumber = '123456';
        // Call checkCcNumberDigit method.
        VisualForceValidations.checkCcNumberDigit(ccNumber);
        
        //Check System Assert. We got Error message Credit card number must be 12-19 digits.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check cc number is empty or not.
     **/
    @isTest
    static void checkCcNumberNotEmpty() {        
        // Set ccNumber empty.
        String ccNumber = '';
        // Call checkCcNumberNotEmpty method.
        VisualForceValidations.checkCcNumberNotEmpty(ccNumber);
        
        //Check System Assert. We got Error message Card Number is a required field.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check expiration year and expiration month of card.
     **/
    @isTest
    static void checkExpirationDate() {
        // Set expirationYear equals to current year.
        String expirationYear = String.valueof(System.today().Year());
        // Set expirationMonth less than to current month.
        String expirationMonth = String.valueof(System.today().Month() - 1);
        // Call checkExpirationDate method.
        VisualForceValidations.checkExpirationDate(expirationYear, expirationMonth);
        
        //Check System Assert. We got Error message Expiration date must be in the future.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check zip code number is 5 digit or not.
     **/
    @isTest
    static void checkZipCodeDigit() {        
        // Set zip code less than 5 digit.
        String zip = '123';
        // Call checkZipCodeDigit method.
        VisualForceValidations.checkZipCodeDigit(zip);
        
        //Check System Assert. We got Error message Zip code must be 5 digits.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check zip code number is numeric or not.
     **/
    @isTest
    static void checkZipCodeIsNumeric() {        
        // Set zip code as a non numeric.
        String zip = 'test12';
        // Call checkZipCodeIsNumeric method.
        VisualForceValidations.checkZipCodeIsNumeric(zip);
        
        //Check System Assert. We got Error message Zip code can only contain numeric values.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check card holder name is empty or not.
     **/
    @isTest
    static void checkCardHolderNameNotEmpty() {        
        // Set cardHolderName equals to empty.
        String cardHolderName = '';
        // Call checkCardHolderNameNotEmpty method.
        VisualForceValidations.checkCardHolderNameNotEmpty(cardHolderName);
        
        //Check System Assert. We got Error message Name is a required field.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_NAME_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check cvv number is 3 or 4 digit or not.
     **/
    @isTest
    static void checkCvvDigit() {        
        // Set cvv number less than to 3 digit.
        String cvv = '12';
        // Call checkCvvDigit method.
        VisualForceValidations.checkCvvDigit(cvv);
        
        //Check System Assert. We got Error message CVV must be 4 digits for American Express and 3 digits for other card types.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check cvv number is empty or not.
     **/
    @isTest
    static void checkCvvNotEmpty() {        
        // Set cvv number equals to empty.
        String cvv = '';
        // Call checkCvvNotEmpty method.
        VisualForceValidations.checkCvvNotEmpty(cvv);
        
        //Check System Assert. We got Error message CVV is a required field.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CC_CVV_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check address is empty or not.
     **/
    @isTest
    static void checkAddressNotEmpty() {        
        // Set address equals to empty.
        String address = '';
        // Call checkAddressNotEmpty method.
        VisualForceValidations.checkAddressNotEmpty(address);
        
        //Check System Assert. We got Error message Billing Address is a required field.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test to check zip code is empty or not.
     **/
    @isTest
    static void checkZipNotEmpty() {        
        // Set zip equals to empty.
        String zip = '';
        // Call checkZipNotEmpty method.
        VisualForceValidations.checkZipNotEmpty(zip);
        
        //Check System Assert. We got Error message Zip Code is a required field.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE)) {
                isError  = true;
            }
        }
        System.assertEquals(isError, true);
    }
    
    /**
     * This method test the creditCardValidation method.
     **/
    @isTest
    static void checkCreditCardValidation() {
        // Set require variables.        
        String ccNumber = '123456';
        String expirationYear = String.valueof(System.today().Year());
        String expirationMonth = String.valueof(System.today().Month() - 1);
        String zip = '123';
        String cardHolderName = '';
        String cvv = '12';
        String address = '';
        
        // Call creditCardValidation method.
        Boolean result = VisualForceValidations.creditCardValidation(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address);
        
        //Check System Assert. We got result true becuase of we set variables that create erros.        
        System.assertEquals(result, true);
        
        // Set require variables positive.        
        ccNumber = '1234567892345';
        expirationYear = String.valueof(System.today().Year());
        expirationMonth = String.valueof(System.today().Month());
        zip = '12345';
        cardHolderName = 'Test';
        cvv = '1234';
        address = 'Test';
        
        // Call creditCardValidation method.
        result = VisualForceValidations.creditCardValidation(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address);
        
        //Check System Assert. We got result false becuase of we set variables positively.        
        System.assertEquals(result, false);
    }
}