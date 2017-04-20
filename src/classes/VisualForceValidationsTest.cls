/**
 * Test class for the VisualForceValidations Class.
 * It tests the all validations related to Amount and Credit Card.
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
        List<String> error = VisualForceValidations.checkAmountNotEmpty(amount);

        // Check System Assert. We got Error message Amount must be Greater than Zero.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO, 'Expected error message ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check amount is greater than zero or not.
     **/
    @isTest
    static void checkAmountGreaterThanZero() {
        // Set amount equals to -100.
        String amount = '-100';
        // Call checkAmountGreaterThanZero method.
        List<String> error = VisualForceValidations.checkAmountGreaterThanZero(amount);

        // Check System Assert. We got Error message Amount must be Greater than Zero.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO, 'Expected error message ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO +
        	' But we got ' + error[0]);
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
        List<String> error = VisualForceValidations.checkAmountExceedBalance(amount, balance);

        // Check System Assert. We got Error message Amount cannot exceed balance.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE, 'Expected error message ' + Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE +
        	' But we got ' + error[0]);
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
        List<String> error = VisualForceValidations.amountValidation(amount, balance);

        //Check System Assert. We got error message becuase of amount is greater than to balance.
        System.assert(error.size() > 0, 'Expected error message size greater than zero but got ' + error.size());

        // Set amount equals to 100.
        amount = '100';
        // Set balance equals to 200.
        balance = '200';
        // Call amountValidation method.
        VisualForceValidations.errorMessages = new List<String>();
        error = VisualForceValidations.amountValidation(amount, balance);

        // Check System Assert. We don't get any error message becuase of amount is less than to balance.
        System.assertEquals(error.size(), 0, 'Expected error message size equals to zero but got ' + error.size());
    }

    /**
     * This method test to check cc number is 12 to 19 digit or not.
     **/
    @isTest
    static void checkCcNumberDigit() {
        // Set ccNumber.
        String ccNumber = '123456';
        // Call checkCcNumberDigit method.
        List<String> error = VisualForceValidations.checkCcNumberDigit(ccNumber);

        // Check System Assert. We got Error message Credit card number must be 12-19 digits.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check cc number is empty or not.
     **/
    @isTest
    static void checkCcNumberNotEmpty() {
        // Set ccNumber empty.
        String ccNumber = '';
        // Call checkCcNumberNotEmpty method.
        List<String> error = VisualForceValidations.checkCcNumberNotEmpty(ccNumber);

        // Check System Assert. We got Error message Card Number is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE +
        	' But we got ' + error[0]);
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
        List<String> error = VisualForceValidations.checkExpirationDate(expirationYear, expirationMonth);

        // Check System Assert. We got Error message Expiration date must be in the future.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check zip code number is 5 digit or not.
     **/
    @isTest
    static void checkZipCodeDigit() {
        // Set zip code less than 5 digit.
        String zip = '123';
        // Call checkZipCodeDigit method.
        List<String> error = VisualForceValidations.checkZipCodeDigit(zip);

        // Check System Assert. We got Error message Zip code must be 5 digits.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT, 'Expected error message ' + Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check zip code number is numeric or not.
     **/
    @isTest
    static void checkZipCodeIsNumeric() {
        // Set zip code as a non numeric.
        String zip = 'test12';
        // Call checkZipCodeIsNumeric method.
        List<String> error = VisualForceValidations.checkZipCodeIsNumeric(zip);

        // Check System Assert. We got Error message Zip code can only contain numeric values.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC, 'Expected error message ' + Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check card holder name is empty or not.
     **/
    @isTest
    static void checkCardHolderNameNotEmpty() {
        // Set cardHolderName equals to empty.
        String cardHolderName = '';
        // Call checkCardHolderNameNotEmpty method.
        List<String> error = VisualForceValidations.checkCardHolderNameNotEmpty(cardHolderName);

        // Check System Assert. We got Error message Name is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_NAME_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_NAME_REQUIRE +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check cvv number is 3 or 4 digit or not.
     **/
    @isTest
    static void checkCvvDigit() {
        // Set cvv number less than to 3 digit.
        String cvv = '12';
        // Call checkCvvDigit method.
        List<String> error = VisualForceValidations.checkCvvDigit(cvv);

        // Check System Assert. We got Error message CVV must be 4 digits for American Express and 3 digits for other card types.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check cvv number is empty or not.
     **/
    @isTest
    static void checkCvvNotEmpty() {
        // Set cvv number equals to empty.
        String cvv = '';
        // Call checkCvvNotEmpty method.
        List<String> error = VisualForceValidations.checkCvvNotEmpty(cvv);

        // Check System Assert. We got Error message CVV is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CC_CVV_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_CC_CVV_REQUIRE +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check address is empty or not.
     **/
    @isTest
    static void checkAddressNotEmpty() {
        // Set address equals to empty.
        String address = '';
        // Call checkAddressNotEmpty method.
        List<String> error = VisualForceValidations.checkAddressNotEmpty(address);

        // Check System Assert. We got Error message Billing Address is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check zip code is empty or not.
     **/
    @isTest
    static void checkZipNotEmpty() {
        // Set zip equals to empty.
        String zip = '';
        // Call checkZipNotEmpty method.
        List<String> error = VisualForceValidations.checkZipNotEmpty(zip);

        // Check System Assert. We got Error message Zip Code is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE +
        	' But we got ' + error[0]);
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
       	List<String> error = VisualForceValidations.creditCardValidation(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address);

        // Check System Assert. We got error message size greater than zero becuase of we set variables that create erros.
        System.assert(error.size() > 0, 'Expected error message size greater than zero but got ' + error.size());

        // Set require variables positive.
        ccNumber = '1234567892345';
        expirationYear = String.valueof(System.today().Year());
        expirationMonth = String.valueof(System.today().Month());
        zip = '12345';
        cardHolderName = 'Test';
        cvv = '1234';
        address = 'Test';

        // Call creditCardValidation method.
        VisualForceValidations.errorMessages = new List<String>();
        error = VisualForceValidations.creditCardValidation(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address);

        // Check System Assert. We don't get any error message becuase of we set variables positively.
        System.assertEquals(error.size(), 0, 'Expected error message size equals to zero but got ' + error.size());
    }

    /**
     * This method test to check Minimum Installment Amount.
     **/
    @isTest
    static void checkMinInstallmentAmount() {
        // Set amount equals to 10.
        Decimal amount = 10;
        // Set Min Installment Amount equals to 20.
        Decimal MinInstallmentAmount = 20;

        // Call checkMinInstallmentAmount method.
        List<String> error = VisualForceValidations.checkMinInstallmentAmount(amount, MinInstallmentAmount);

        // Check System Assert. We got Error message Monthly amount must be equal to or greater than $20.
        String errorMessage = String.format(Constants.PAGE_MESSAGE_MONTHLY_AMOUNT, new String[]{String.valueOf(MinInstallmentAmount)});
        System.assertEquals(error[0], errorMessage, 'Expected error message ' + errorMessage +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check Maximum Installment plans based on amount.
     **/
    @isTest
    static void checkMaxInstallments() {
        // Set amount equals to 10.
        Decimal amount = 10;
        // Set dctotalAmount(Sum of Selected CGs Balance) equals to 50.
        Decimal dctotalAmount = 50;
        // Set Maximum Installments equals to 2.
        Decimal MaxInstallments = 2;

        // Call checkMaxInstallments method.
        List<String> error = VisualForceValidations.checkMaxInstallments(amount, dctotalAmount, MaxInstallments);

        // Calculate minimum installment amout.
        Decimal minimumInstallmentAmount = Integer.valueof((dctotalAmount/MaxInstallments).round(System.RoundingMode.CEILING));

        // Check System Assert. We got Error message "monthly amount would exceed 2 Installments, The minimum allowed installment amount is $25".
        String errorMessage = String.format(Constants.PAGE_MESSAGE_MAX_INSTALLMENT, new String[]{String.valueOf(MaxInstallments), String.valueOf(minimumInstallmentAmount)});
        System.assertEquals(error[0], errorMessage, 'Expected error message ' + errorMessage +
        	' But we got ' + error[0]);
    }

    /**
     * This method test the amountValidationForAddPaymentPlan method positively.
     **/
    @isTest
    static void checkAmountValidationForAddPaymentPlanPositive() {
        // Set amount equals to 20.
        String amount = '20';
        // Set cgBalance equals to 100.
        Decimal cgBalance = 100;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(Alias = 'standt', Email = 'systemuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'systemuser@testorg1212.com');

        System.runAs(u) {
            // Call amountValidationForAddPaymentPlan method.
            List<String> error = VisualForceValidations.amountValidationForAddPaymentPlan(amount, cgBalance);

            // Check System Assert. We don't get any error message because of we perform positive scenario.
            System.assertEquals(error.size(), 0, 'Expected error message size equals to zero but got ' + error.size());
        }
    }

    /**
     * This method test the amountValidationForAddPaymentPlan method negative.
     **/
    @isTest
    static void checkAmountValidationForAddPaymentPlanNegative() {
        // Set amount equals to 20.
        String amount = '20';
        // Set cgBalance equals to 10.
        Decimal cgBalance = 10;

        // Call amountValidationForAddPaymentPlan method.
        List<String> error = VisualForceValidations.amountValidationForAddPaymentPlan(amount, cgBalance);

        // Check System Assert. We got error message size greater than zero because of cgBalance is greater than amount.
        System.assert(error.size() > 0, 'Expected error message size greater than zero but got ' + error.size());
    }

    /**
     * This method test to check CG Ids are empty or not.
     **/
    @isTest
    static void checkCGIdsNotEmpty() {
        // Set CG Ids empty.
        String[] chargeGroupIds = new String[]{};

        // Call checkCGIdsNotEmpty method.
        List<String> error = VisualForceValidations.checkCGIdsNotEmpty(chargeGroupIds);

        // Check System Assert. We got Error message Charge Group is a required field.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_CG_REQUIRE, 'Expected error message ' + Constants.PAGE_MESSAGE_CG_REQUIRE +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check execute on day(date to charge).
     **/
    @isTest
    static void checkExecuteOnDay() {
        // Set executeOnDay = 35
        String executeOnDay = '35';

        // Call checkExecuteOnDay method.
        List<String> error = VisualForceValidations.checkExecuteOnDay(executeOnDay);

        // Check System Assert. We got Error message Date to Charge (each month) must be a number between 1 and 31.
        System.assertEquals(error[0], Constants.PAGE_MESSAGE_EXECUTE_ON_DAY, 'Expected error message ' + Constants.PAGE_MESSAGE_EXECUTE_ON_DAY +
        	' But we got ' + error[0]);
    }

    /**
     * This method test to check execute on day(date to charge) success.
     **/
    @isTest
    static void checkExecuteOnDaySuccess() {
        // Set executeOnDay = 2
        String executeOnDay = '2';

        // Call checkExecuteOnDay method.
        List<String> error = VisualForceValidations.checkExecuteOnDay(executeOnDay);

        // Check System Assert. We don't get any error message because of we set valid executeOnDay.
        System.assertEquals(error.size(), 0, 'Expected error message size equals to zero but got ' + error.size());
    }

    /**
     * This method test the creditCardValidationForAddPaymentPlan method positively.
     **/
    @isTest
    static void checkCreditCardValidationForAddPaymentPlanPositive() {
        // Set require variables positive.
        String ccNumber = '1234567892345';
        String expirationYear = String.valueof(System.today().Year());
        String expirationMonth = String.valueof(System.today().Month());
        String zip = '12345';
        String cardHolderName = 'Test';
        String cvv = '1234';
        String address = 'Test';
        String[] chargeGroupIds = new String[]{'123', '456'};
        String executeOnDay = '2';

        // Call creditCardValidationForAddPaymentPlan method.
        List<String> error = VisualForceValidations.creditCardValidationForAddPaymentPlan(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address, chargeGroupIds, executeOnDay);

        // Check System Assert. We don't get any error message because of we set variables positively.
        System.assertEquals(error.size(), 0, 'Expected error message size equals to zero but got ' + error.size());
    }

    /**
     * This method test the creditCardValidationForAddPaymentPlan method Negative.
     **/
    @isTest
    static void checkCreditCardValidationForAddPaymentPlanNegative() {
        // Set require variables.
        String ccNumber = '123456';
        String expirationYear = String.valueof(System.today().Year());
        String expirationMonth = String.valueof(System.today().Month() - 1);
        String zip = '123';
        String cardHolderName = '';
        String cvv = '12';
        String address = '';
        String[] chargeGroupIds = new String[]{};
        String executeOnDay = '0';

        // Call creditCardValidationForAddPaymentPlan method.
        List<String> error = VisualForceValidations.creditCardValidationForAddPaymentPlan(ccNumber, expirationYear, expirationMonth, zip,
                    cardHolderName, cvv, address, chargeGroupIds, executeOnDay);

        // Check System Assert. We got error message size greater than zero because of we set variables that create erros.
        System.assert(error.size() > 0, 'Expected error message size greater than zero but got ' + error.size());
    }
}