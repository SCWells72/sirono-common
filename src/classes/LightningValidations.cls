public with sharing class LightningValidations {
	
    public static String blnIsAmountError = '';
    public static String blnIsCCError = '';
    public static String blnIsError = '';

    /**
     * This method is use to check String is empty or null for Validation.
     *
     * @Param String str - That contains String value.
     * @returns Boolean - That contains true or false based on parameter.
     **/
    public static Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }
    
    /**
     * This method is used to check Amount validations.
     *
     * @param String amount - That contains amount.
     * @param String balance - That contains balance.
     * @returns String blnIsAmountError - That contains error messages.
     **/
    public static String amountValidation(String amount, String balance) {
        blnIsAmountError = '';
        
        // Call checkAmountNotEmpty method to check amount is empty or not.
        blnIsAmountError = checkAmountNotEmpty(amount);
        
        if (String.isEmpty(blnIsAmountError)) {
            // Call checkAmountGreaterThanZero method to check amount is greater than zero or not.
            blnIsAmountError = checkAmountGreaterThanZero(amount);
            // Call checkAmountExceedBalance method to check amount is exceed the balance or not.
            blnIsAmountError = checkAmountExceedBalance(amount, balance);
        }
        return blnIsAmountError.removeEnd('\n');
    }
    
    /**
     * This method is used to check amount is empty or not and it is numeric or not.
     *
     * @param String amount - That contains amount.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkAmountNotEmpty(String amount) {
        blnIsError = blnIsAmountError;        
        if (isEmpty(amount) || (amount.isNumeric() && Decimal.valueOf(amount) == 0)) {
            blnIsError += Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check amount is greater than zero or not.
     *
     * @param String amount - That contains amount.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkAmountGreaterThanZero(String amount) {
        blnIsError = blnIsAmountError;
        if (Decimal.valueOf(amount) < 0) {
            blnIsError += Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check amount is exceed the balance or not.
     *
     * @param String amount - That contains amount.
     * @param String balance - That contains balance.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkAmountExceedBalance(String amount, String balance) {
        blnIsError = blnIsAmountError;
        if (Decimal.valueOf(amount) > Decimal.valueOf(balance)) {
            blnIsError += Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check Card validations.
     *
     * @param String ccNumber - That contains credit card number.
     * @param String expirationYear - That contains expiration Year of card.
     * @param String expirationMonth - That contains expiration Month of card.
     * @param String zip - That contains zip code.
     * @param String cardHolderName - That contains card holder name.
     * @param String cvv - That contains cvv number of card.
     * @param String address - That contains address.
     * @returns String blnIsError - That contains true or false.
     **/
    public static String creditCardValidation(String ccNumber, String expirationYear, String expirationMonth, String zip,
                String cardHolderName, String cvv, String address) {
        blnIsCCError = '';
        
        // Call checkCcNumberDigit method to check cc number is 12 to 19 digit or not.
        blnIsCCError = checkCcNumberDigit(ccNumber);
        // Call checkCcNumberNotEmpty method to check cc number is empty or not.
        blnIsCCError = checkCcNumberNotEmpty(ccNumber);
        // Call checkExpirationDate method to check expiration year and expiration month of card.
        blnIsCCError = checkExpirationDate(expirationYear, expirationMonth);
        // Call checkZipCodeDigit method to check zip code number is 5 digit or not.
        blnIsCCError = checkZipCodeDigit(zip);
        // Call checkZipCodeIsNumeric method to check zip code number is numeric or not.
        blnIsCCError = checkZipCodeIsNumeric(zip);
        // Call checkCardHolderNameNotEmpty method to check card holder name is empty or not.
        blnIsCCError = checkCardHolderNameNotEmpty(cardHolderName);
        // Call checkCvvDigit method to check cvv number is 3 or 4 digit or not.
        blnIsCCError = checkCvvDigit(cvv);
        // Call checkCvvNotEmpty method to check cvv number is empty or not.
        blnIsCCError = checkCvvNotEmpty(cvv);
        // Call checkAddressNotEmpty method to check address is empty or not.
        blnIsCCError = checkAddressNotEmpty(address);
        // Call checkZipNotEmpty method to check zip is empty or not.
        blnIsCCError = checkZipNotEmpty(zip);
        return blnIsCCError.removeEnd('\n');
    }
    
    /**
     * This method is used to check cc number is 12 to 19 digit or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkCcNumberDigit(String ccNumber) {
        blnIsError = blnIsCCError;
        if (ccNumber.length() < 12 || ccNumber.Length() > 19) {
            blnIsError += Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cc number is empty or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkCcNumberNotEmpty(String ccNumber) {
        blnIsError = blnIsCCError;
        if (isEmpty(ccNumber)) {
            blnIsError += Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check expiration year and expiration month of card.
     *
     * @param String expirationYear - That contains expiration year of card.
     * @param String expirationMonth - That contains expiration month of card.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkExpirationDate(String expirationYear, String expirationMonth) {
        blnIsError = blnIsCCError;
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            blnIsError += Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code number is 5 digit or not.
     *
     * @param String zip - That contains zip code.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkZipCodeDigit(String zip) {
        blnIsError = blnIsCCError;
        if (!isEmpty(zip) && zip.length() != 5) {
            blnIsError += Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code number is numeric or not.
     *
     * @param String zip - That contains zip code.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkZipCodeIsNumeric(String zip) {
        blnIsError = blnIsCCError;
        if (!isEmpty(zip) && !zip.isNumeric()) {
            blnIsError += Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check card holder name is empty or not.
     *
     * @param String cardHolderName - That contains card holder name.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkCardHolderNameNotEmpty(String cardHolderName) {
        blnIsError = blnIsCCError;
        if (isEmpty(cardHolderName)) {
            blnIsError += Constants.PAGE_MESSAGE_CC_NAME_REQUIRE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cvv number is 3 or 4 digit or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkCvvDigit(String cvv) {
        blnIsError = blnIsCCError;
        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            blnIsError += Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cvv number is empty or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkCvvNotEmpty(String cvv) {
        blnIsError = blnIsCCError;
        if (isEmpty(cvv)) {
            blnIsError += Constants.PAGE_MESSAGE_CC_CVV_REQUIRE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check address is empty or not.
     *
     * @param String address - That contains address.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkAddressNotEmpty(String address) {
        blnIsError = blnIsCCError;
        if (isEmpty(address)) {
            blnIsError += Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE +'\n';
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code is empty or not.
     *
     * @param String zip - That contains zip code.
     * @returns String blnIsError - That contains error messages.
     **/
    public static String checkZipNotEmpty(String zip) {
        blnIsError = blnIsCCError;
        if (isEmpty(zip)) {
            blnIsError += Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE +'\n';
        }
        return blnIsError;
    }
}