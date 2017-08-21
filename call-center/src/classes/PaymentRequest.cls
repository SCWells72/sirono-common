/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Pay the given amount against these chargegroups with this credit card
 */
global with sharing class PaymentRequest {
    global PaymentRequest() {
        this.chargeInfo = new ChargeInfo();
    }

    global PaymentRequest(Contact guarantor, List<Charge_Group__c> chargeGroupList) {
        this.chargeInfo = new ChargeInfo();
        this.guarantor = guarantor;
        this.chargeGroups = chargeGroupList;

    }

    global class ChargeInfo {
        global String address { get; set; }
        global String amount { get; set; }
        global String cardHolderName { get; set; }
        global String city { get; set; }
        global String creditCardNumber { get; set; }
        global String cvv { get; set; }
        global String expirationMonth { get; set; }
        global String expirationYear { get; set; }
        global String state { get; set; }
        global String zip { get; set; }

        global List<String> validate() {
            List<String> errors = new List<String>();
            if (String.isEmpty(creditCardNumber)) {
                errors.add('Card Number is a required field.');
            } else if (creditCardNumber.length() < 12 || creditCardNumber.length() > 19) {
                errors.add('Credit card number must be 12-19 digits.');
            }

            System.debug(expirationYear);
            System.debug(expirationMonth);

            String fullYear = '20' + expirationYear;

            if (Integer.valueOf(fullYear) < System.today().year() ||
                (Integer.valueOf(fullYear) == System.today().year() &&
                    Integer.valueOf(expirationMonth) < System.today().month())) {
                errors.add('Expiration date must be in the future.');
            }

            if (String.isEmpty(zip)) {
                errors.add('Zip Code is a required field.');
            } else {
                if (zip.length() != 5) {
                    errors.add('Zip code must be 5 digits.');
                }

                if (!zip.isNumeric()) {
                    errors.add('Zip code must be numeric.');
                }
            }

            if (String.isEmpty(cardHolderName)) {
                errors.add('Name is a required field.');
            }

            if (String.isEmpty(cvv)) {
                errors.add('CVV is a required field.');
            } else if (cvv.length() < 3 || cvv.length() > 4) {
                errors.add('CVV must be 4 digits for American Express and 3 digits for other card types.');
            }

            if (String.isEmpty(address)) {
                errors.add('Billing Address is a required field.');
            }


            return errors;
        }
    }

    global Contact guarantor { get; set; }
    global List<Charge_Group__c> chargeGroups { get; set; }
    global ChargeInfo chargeInfo { get; set; }

    private List<String> validateAmount() {
        List<String> errors = new List<String>();
        String amount = chargeInfo.amount;
        if (String.isEmpty(amount) || (amount.isNumeric() && Decimal.valueOf(amount) <= 0)) {
            errors.add('Amount must be greater than zero.');
        } else {
            Decimal cgBalanceTotal = getCGBalanceTotal();

            if (cgBalanceTotal <= 0.0) {
                errors.add('Zero or credit balance is not payable.');
            }

            if (Decimal.valueOf(amount) > cgBalanceTotal) {
                errors.add('Amount cannot exceed balance.');
            }
        }
        return errors;
    }

    private Decimal getCGBalanceTotal() {
        Decimal cgBalanceTotal = 0.0;
        for (Charge_Group__c cg : chargeGroups) {
            cgBalanceTotal += cg.Balance__c;
        }
        return cgBalanceTotal;
    }

    global List<String> validate() {
        List<String> errors = new List<String>();
        errors.addAll(chargeInfo.validate());
        errors.addAll(validateAmount());

        if (guarantor == null) {
            errors.add('Guarantor contact is required');
        }

        if (chargeGroups.isEmpty()) {
            errors.add('Charge Group is a required field.');
        }

        return errors;
    }
}