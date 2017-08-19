/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Validation class for Amount and Credit Card Validations.
 **/
global with sharing class VisualforceValidations {

    public static List<String> errorMessages = new List<String>();

    /**
     * This method is used to check Amount validations.
     *
     * @param String amount - That contains amount.
     * @param String balance - That contains balance.
     * @returns List<String> errorMessages - That contains error messages if any else it will be blank/size is zero.
     **/
    global static List<String> amountValidation(String amount, String balance) {
        // Call checkAmountNotEmpty method to check amount is empty or not.
        checkAmountNotEmpty(amount);

        if (errorMessages.size() == 0) {
            // Call checkAmountGreaterThanZero method to check amount is greater than zero or not.
            checkAmountGreaterThanZero(amount);
            // Call checkAmountExceedBalance method to check amount is exceed the balance or not.
            checkAmountExceedBalance(amount, balance);
        }

        return errorMessages;
    }

    /**
     * This method is use to check Amount validations for AddPaymentPlan.
     *
     * @param String amount - That contains amount.
     * @param Decimal selectedCGsBalance - That contains sum of selected CG's balance.
     * @returns List<String> errorMessages - That contains error messages if any else it will be blank/size is zero.
     **/
    public static List<String> amountValidationForAddPaymentPlan(String amount, Decimal selectedCGsBalance) {
        // Call checkAmountNotEmpty method to check amount is empty or not.
        checkAmountNotEmpty(amount);

        if (errorMessages.size() == 0) {
            // Call checkAmountGreaterThanZero method to check amount is greater than zero or not.
            checkAmountGreaterThanZero(amount);
            // Call checkAmountExceedBalance method to check amount is exceed the balance or not.
            checkAmountExceedBalance(amount, String.valueOf(selectedCGsBalance));

            // Get sirono settings/payment plan setting.
            Sirono_Call_Center_Settings__c paymentPlanSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();

            // Call checkMinInstallmentAmount method to check amount is less than minimum installment amount or not.
            checkMinInstallmentAmount(Decimal.valueOf(amount), paymentPlanSettings.Min_Installment_Amount__c);
            // Call checkMaxInstallments method to check maximum installment plans based on amount.
            if (Decimal.valueOf(amount) >= paymentPlanSettings.Min_Installment_Amount__c) {
                checkMaxInstallments(Decimal.valueOf(amount), selectedCGsBalance, paymentPlanSettings.Max_Number_Plan_Installments__c);
            }
        }

        return errorMessages;
    }

    /**
     * This method is used to check amount is empty or not and it is numeric or not.
     *
     * @param String amount - That contains amount.
     * @returns List<String> errorMessages - That contains error message if amount is null or empty else it will be blank/size is zero.
     **/
    public static List<String> checkAmountNotEmpty(String amount) {
        if (String.isBlank(amount) || (amount.isNumeric() && Decimal.valueOf(amount) == 0)) {
            errorMessages.add(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO);
        }
        return errorMessages;
    }

    /**
     * This method is used to check amount is greater than zero or not.
     *
     * @param String amount - That contains amount.
     * @returns List<String> errorMessages - That contains error message if amount is less than 0 else it will be blank/size is zero.
     **/
    public static List<String> checkAmountGreaterThanZero(String amount) {
        if (Decimal.valueOf(amount) < 0) {
            errorMessages.add(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO);
        }
        return errorMessages;
    }

    /**
     * This method is used to check amount is exceed the balance or not.
     *
     * @param String amount - That contains amount.
     * @param String balance - That contains balance.
     * @returns List<String> errorMessages - That contains error message if amount is greater than balance else it will be blank/size is zero.
     **/
    public static List<String> checkAmountExceedBalance(String amount, String balance) {
        if (Decimal.valueOf(amount) > Decimal.valueOf(balance)) {
            errorMessages.add(Constants.PAGE_MESSAGE_AMOUNT_EXCEED_BALANCE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check amount is less than minimum installment amount or not.
     *
     * @param Decimal amount - That contains amount.
     * @param Decimal MinInstallmentAmount - That contains minimum installment amount.
     * @returns List<String> errorMessages - That contains error message if amount is less than MinInstallmentAmount else it will be blank/size is zero.
     **/
    public static List<String> checkMinInstallmentAmount(Decimal amount, Decimal MinInstallmentAmount) {
        if (amount < MinInstallmentAmount) {
            errorMessages.add(String.format(Constants.PAGE_MESSAGE_MONTHLY_AMOUNT, new String[] { String.valueOf(MinInstallmentAmount) }));
        }
        return errorMessages;
    }

    /**
     * This method is used to check maximum installment plans based on amount.
     *
     * @param Decimal amount - That contains amount.
     * @param Decimal selectedCGsBalance - That contains sum of selected CG's balance.
     * @param Decimal MaxInstallments - That contains maximum number of installments.
     * @returns List<String> errorMessages - That contains error message if totalInstallment is greater than MaxInstallments else it will be blank/size is zero.
     **/
    public static List<String> checkMaxInstallments(Decimal amount, Decimal selectedCGsBalance, Decimal MaxInstallments) {
        Integer totalInstallment = Integer.valueOf((selectedCGsBalance / amount).round(System.RoundingMode.CEILING));
        Integer minimumInstallmentAmount = 0;

        if (MaxInstallments > 0) {
            minimumInstallmentAmount = Integer.valueOf((selectedCGsBalance / MaxInstallments).round(System.RoundingMode.CEILING));
        }

        if (totalInstallment > MaxInstallments) {
            errorMessages.add(String.format(Constants.PAGE_MESSAGE_MAX_INSTALLMENT, new String[] { String.valueOf(MaxInstallments), String.valueOf(minimumInstallmentAmount) }));
        }
        return errorMessages;
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
     * @returns List<String> errorMessages - That contains error messages if any else it will be blank/size is zero.
     **/
    global static List<String> creditCardValidation(String ccNumber, String expirationYear, String expirationMonth, String zip,
        String cardHolderName, String cvv, String address) {

        // Call checkCcNumberDigit method to check cc number is 12 to 19 digit or not.
        checkCcNumberDigit(ccNumber);
        // Call checkCcNumberNotEmpty method to check cc number is empty or not.
        checkCcNumberNotEmpty(ccNumber);
        // Call checkExpirationDate method to check expiration year and expiration month of card.
        checkExpirationDate(expirationYear, expirationMonth);
        // Call checkZipCodeDigit method to check zip code number is 5 digit or not.
        checkZipCodeDigit(zip);
        // Call checkZipCodeIsNumeric method to check zip code number is numeric or not.
        checkZipCodeIsNumeric(zip);
        // Call checkCardHolderNameNotEmpty method to check card holder name is empty or not.
        checkCardHolderNameNotEmpty(cardHolderName);
        // Call checkCvvDigit method to check cvv number is 3 or 4 digit or not.
        checkCvvDigit(cvv);
        // Call checkCvvNotEmpty method to check cvv number is empty or not.
        checkCvvNotEmpty(cvv);
        // Call checkAddressNotEmpty method to check address is empty or not.
        checkAddressNotEmpty(address);
        // Call checkZipNotEmpty method to check zip is empty or not.
        checkZipNotEmpty(zip);

        return errorMessages;
    }

    /**
     * This method is used to check Card validations for AddPaymentPlan.
     *
     * @param String ccNumber - That contains credit card number.
     * @param String expirationYear - That contains expiration Year of card.
     * @param String expirationMonth - That contains expiration Month of card.
     * @param String zip - That contains zip code.
     * @param String cardHolderName - That contains card holder name.
     * @param String cvv - That contains cvv number of card.
     * @param String address - That contains address.
     * @param String[] chargeGroupIds - That contains CG Ids.
     * @param String executeOnDay - That contains execute on day(date to charge).
     * @returns List<String> errorMessages - That contains error messages if any else it will be blank/size is zero.
     **/
    public static List<String> creditCardValidationForAddPaymentPlan(String ccNumber, String expirationYear, String expirationMonth, String zip,
        String cardHolderName, String cvv, String address, String[] chargeGroupIds, String executeOnDay) {

        // Call creditCardValidation method that performs all basic validations for Credit Card.
        errorMessages = creditCardValidation(ccNumber, expirationYear, expirationMonth, zip, cardHolderName, cvv, address);

        // Call checkCGIdsNotEmpty method to check CG Ids are empty or not.
        checkCGIdsNotEmpty(chargeGroupIds);
        // Call checkExecuteOnDay method to check executeOnDay is 1 to 31 or not.
        checkExecuteOnDay(executeOnDay);

        return errorMessages;
    }

    /**
     * This method is used to check cc number is 12 to 19 digit or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns List<String> errorMessages - That contains error message if ccNumber's length is not between 12 to 19 else it will be blank/size is zero.
     **/
    public static List<String> checkCcNumberDigit(String ccNumber) {
        if (ccNumber.length() < 12 || ccNumber.length() > 19) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_NUMBER_12_19_DIGITS);
        }
        return errorMessages;
    }

    /**
     * This method is used to check cc number is empty or not.
     *
     * @param String ccNumber - That contains credit card number.
     * @returns List<String> errorMessages - That contains error message if ccNumber is empty else it will be blank/size is zero.
     **/
    public static List<String> checkCcNumberNotEmpty(String ccNumber) {
        if (String.isBlank(ccNumber)) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_NUMBER_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check expiration year and expiration month of card.
     *
     * @param String expirationYear - That contains expiration year of card.
     * @param String expirationMonth - That contains expiration month of card.
     * @returns List<String> errorMessages - That contains error message if expiration date is not future date else it will be blank/size is zero.
     **/
    public static List<String> checkExpirationDate(String expirationYear, String expirationMonth) {
        if (Integer.valueOf(expirationYear) < System.today().year() ||
            (Integer.valueOf(expirationYear) == System.today().year() &&
                Integer.valueOf(expirationMonth) < System.today().month())) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_EXPIRATION_DATE_FUTURE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check zip code number is 5 digit or not.
     *
     * @param String zip - That contains zip code.
     * @returns List<String> errorMessages - That contains error message if zip digit is not five else it will be blank/size is zero.
     **/
    public static List<String> checkZipCodeDigit(String zip) {
        if (String.isNotBlank(zip) && zip.length() != 5) {
            errorMessages.add(Constants.PAGE_MESSAGE_ZIP_CODE_FIVE_DIGIT);
        }
        return errorMessages;
    }

    /**
     * This method is used to check zip code number is numeric or not.
     *
     * @param String zip - That contains zip code.
     * @returns List<String> errorMessages - That contains error message if zip code is not numeric else it will be blank/size is zero.
     **/
    public static List<String> checkZipCodeIsNumeric(String zip) {
        if (String.isNotBlank(zip) && !zip.isNumeric()) {
            errorMessages.add(Constants.PAGE_MESSAGE_ZIP_CODE_ONLY_NUMERIC);
        }
        return errorMessages;
    }

    /**
     * This method is used to check card holder name is empty or not.
     *
     * @param String cardHolderName - That contains card holder name.
     * @returns List<String> errorMessages - That contains error message if Card Holder Name is empty else it will be blank/size is zero.
     **/
    public static List<String> checkCardHolderNameNotEmpty(String cardHolderName) {
        if (String.isBlank(cardHolderName)) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_NAME_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check cvv number is 3 or 4 digit or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns List<String> errorMessages - That contains error message if cvv length is not 3 or 4 else it will be blank/size is zero.
     **/
    public static List<String> checkCvvDigit(String cvv) {
        if (String.isNotBlank(cvv) && (cvv.length() < 3 || cvv.length() > 4)) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_CVV_4_OR_3_DIGIT);
        }
        return errorMessages;
    }

    /**
     * This method is used to check cvv number is empty or not.
     *
     * @param String cvv - That contains cvv number of card.
     * @returns List<String> errorMessages - That contains error message if cvv is empty else it will be blank/size is zero.
     **/
    public static List<String> checkCvvNotEmpty(String cvv) {
        if (String.isBlank(cvv)) {
            errorMessages.add(Constants.PAGE_MESSAGE_CC_CVV_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check address is empty or not.
     *
     * @param String address - That contains address.
     * @returns List<String> errorMessages - That contains error message if address is empty else it will be blank/size is zero.
     **/
    public static List<String> checkAddressNotEmpty(String address) {
        if (String.isBlank(address)) {
            errorMessages.add(Constants.PAGE_MESSAGE_BILLING_ADDRESS_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check zip code is empty or not.
     *
     * @param String zip - That contains zip code.
     * @returns List<String> errorMessages - That contains error message if zip is empty else it will be blank/size is zero.
     **/
    public static List<String> checkZipNotEmpty(String zip) {
        if (String.isBlank(zip)) {
            errorMessages.add(Constants.PAGE_MESSAGE_ZIP_CODE_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check CG Ids are empty or not.
     *
     * @param String[] chargeGroupIds - That contains CG Ids.
     * @returns List<String> errorMessages - That contains error message if charge group Ids is empty else it will be blank/size is zero.
     **/
    public static List<String> checkCGIdsNotEmpty(String[] chargeGroupIds) {
        if (chargeGroupIds.isEmpty()) {
            errorMessages.add(Constants.PAGE_MESSAGE_CG_REQUIRE);
        }
        return errorMessages;
    }

    /**
     * This method is used to check execute on day(date to charge) is 1 to 31 or not.
     *
     * @param String executeOnDay - That contains executeOnDay value.
     * @returns List<String> errorMessages - That contains error message if executeOnDay is empty or not in between 1 to 31 else it will be blank/size is zero.
     **/
    public static List<String> checkExecuteOnDay(String executeOnDay) {
        if (String.isBlank(executeOnDay) || Integer.valueOf(executeOnDay) < 1 || Integer.valueOf(executeOnDay) > 31) {
            errorMessages.add(Constants.PAGE_MESSAGE_EXECUTE_ON_DAY);
        }
        return errorMessages;
    }
}