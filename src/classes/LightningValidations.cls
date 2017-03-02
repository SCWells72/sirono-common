public with sharing class LightningValidations {
	
    public static Boolean blnIsAmountError = false;
    public static Boolean blnIsCCError = false;
    public static Boolean blnIsError = false;

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
     * @returns Boolean blnIsAmountError - That contains true or false.
     **/
    public static Boolean amountValidation(String amount, String balance) {
        blnIsAmountError = false;
        
        // Call checkAmountNotEmpty method to check amount is empty or not.
        blnIsAmountError = checkAmountNotEmpty(amount);
        
        if (!blnIsAmountError) {
            // Call checkAmountGreaterThanZero method to check amount is greater than zero or not.
            blnIsAmountError = checkAmountGreaterThanZero(amount);
            // Call checkAmountExceedBalance method to check amount is exceed the balance or not.
            blnIsAmountError = checkAmountExceedBalance(amount, balance);
        }
        return blnIsAmountError;
    }
    
    /**
     * This method is used to check amount is empty or not and it is numeric or not.
     *
     * @param String amount - That contains amount.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkAmountNotEmpty(String amount) {
        blnIsError = blnIsAmountError;        
        if (isEmpty(amount) || (amount.isNumeric() && Decimal.valueOf(amount) == 0)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check amount is greater than zero or not.
     *
     * @param String amount - That contains amount.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkAmountGreaterThanZero(String amount) {
        blnIsError = blnIsAmountError;
        if (Decimal.valueOf(amount) < 0) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check amount is exceed the balance or not.
     *
     * @param String amount - That contains amount.
     * @param String balance - That contains balance.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkAmountExceedBalance(String amount, String balance) {
        blnIsError = blnIsAmountError;
        if (Decimal.valueOf(amount) > Decimal.valueOf(balance)) {
            blnIsError = true;
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
     * @returns Boolean blnIsError - That contains true or false.
     **/
    public static Boolean creditCardValidation(String ccNumber, String expirationYear, String expirationMonth, String zip,
                String cardHolderName, String cvv, String address) {
        blnIsCCError = false;
        
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
        
        return blnIsCCError;
    }
    
    /**
     * This method is used to check cc number is 12 to 19 digit or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkCcNumberDigit(String ccNumber) {
        blnIsError = blnIsCCError;
        if (ccNumber.length() < 12 || ccNumber.Length() > 19) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cc number is empty or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkCcNumberNotEmpty(String ccNumber) {
        blnIsError = blnIsCCError;
        if (isEmpty(ccNumber)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check expiration year and expiration month of card.
     *
     * @param String expirationYear - That contains expiration year of card.
     * @param String expirationMonth - That contains expiration month of card.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkExpirationDate(String expirationYear, String expirationMonth) {
        blnIsError = blnIsCCError;
        if (Integer.valueof(expirationYear) < system.today().year() ||
                (Integer.valueof(expirationYear) == system.today().year() &&
                        Integer.valueof(expirationMonth) < system.today().Month())) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code number is 5 digit or not.
     *
     * @param String zip - That contains zip code.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkZipCodeDigit(String zip) {
        blnIsError = blnIsCCError;
        if (!isEmpty(zip) && zip.length() != 5) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code number is numeric or not.
     *
     * @param String zip - That contains zip code.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkZipCodeIsNumeric(String zip) {
        blnIsError = blnIsCCError;
        if (!isEmpty(zip) && !zip.isNumeric()) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check card holder name is empty or not.
     *
     * @param String cardHolderName - That contains card holder name.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkCardHolderNameNotEmpty(String cardHolderName) {
        blnIsError = blnIsCCError;
        if (isEmpty(cardHolderName)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cvv number is 3 or 4 digit or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkCvvDigit(String cvv) {
        blnIsError = blnIsCCError;
        if (!isEmpty(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check cvv number is empty or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkCvvNotEmpty(String cvv) {
        blnIsError = blnIsCCError;
        if (isEmpty(cvv)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check address is empty or not.
     *
     * @param String address - That contains address.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkAddressNotEmpty(String address) {
        blnIsError = blnIsCCError;
        if (isEmpty(address)) {
            blnIsError = true;
        }
        return blnIsError;
    }
    
    /**
     * This method is used to check zip code is empty or not.
     *
     * @param String zip - That contains zip code.
     * @returns Boolean blnIsError - That contains true or false value.
     **/
    public static Boolean checkZipNotEmpty(String zip) {
        blnIsError = blnIsCCError;
        if (isEmpty(zip)) {
            blnIsError = true;
        }
        return blnIsError;
    }
}