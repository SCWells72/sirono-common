/**
 * Created by mmartin on 6/14/17.
 */

public with sharing class PaymentRequest {
    public Contact guarantor { get; set; }
    public List<Charge_Group__c> chargeGroups { get; set; }
    public String address { get; set; }
    public String amount { get; set; }
    public String cardHolderName { get; set; }
    public String city { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public String expirationMonth { get; set; }
    public String expirationYear { get; set; }
    public String state { get; set; }
    public String zip { get; set; }

    public List<String> validateAmount() {
        List<String> errors = new List<String>();
        if (String.isEmpty(amount) || (amount.isNumeric() && Decimal.valueOf(amount) <= 0)) {
            errors.add('Amount must be greater than zero.');
        } else {
            Decimal cgBalanceTotal = getCGBalanceTotal();

            if (cgBalanceTotal <= 0.0) {
                System.debug('amount: '+amount + ' cgBalanceTotal: ' + cgBalanceTotal);
                errors.add('Zero or credit balance is not payable.');
            }

            if (Decimal.valueOf(amount) > cgBalanceTotal) {
                System.debug('amount: '+amount + ' cgBalanceTotal: ' + cgBalanceTotal);
                errors.add('Amount cannot exceed balance.');
            }
        }
        return errors;
    }

    private Decimal getCGBalanceTotal(){
        Decimal cgBalanceTotal = 0.0;
        for (Charge_Group__c cg : chargeGroups) {
            cgBalanceTotal += cg.Balance__c;
        }
        return cgBalanceTotal;
    }

    public List<String> validateCardData() {
        List<String> errors = new List<String>();
        if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
            errors.add('Credit card number must be 12-19 digits.');
        }
        if (String.isEmpty(creditCardNumber)) {
            errors.add('Card Number is a required field.');
        }

        System.debug(expirationYear);
        System.debug(expirationMonth);

        String fullYear = '20' + expirationYear;

        if (Integer.valueof(fullYear) < System.today().year() ||
                (Integer.valueof(fullYear) == System.today().year() &&
                        Integer.valueof(expirationMonth) < System.today().Month())) {
            errors.add('Expiration date must be in the future.');
        }

        if (!String.isEmpty(zip) && zip.length() != 5) {
            errors.add('Zip code must be 5 digits.');
        }

        if (!String.isEmpty(zip) && !zip.isNumeric()) {
            errors.add('Zip code can only contain numeric values.');
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

        if (String.isEmpty(zip)) {
            errors.add('Zip Code is a required field.');
        }

        if (chargeGroups.isEmpty()) {
            errors.add('Charge Group is a required field.');
        }

        return errors;
    }
}