/**
 * Pay the given amount against these chargegroups with this credit card
 */

public with sharing class PaymentRequest {
    public PaymentRequest() {
        this.chargeInfo = new ChargeInfo();
    }

    public PaymentRequest(Contact guarantor, List<Charge_Group__c> chargeGroupList) {
        this.chargeInfo = new ChargeInfo();
        this.guarantor = guarantor;
        this.chargeGroups = chargeGroupList;

    }

    public class ChargeInfo {
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

        public List<String> validate() {
            List<String> errors = new List<String>();
            if (String.isEmpty(creditCardNumber)) {
                errors.add('Card Number is a required field.');
            } else if (creditCardNumber.length() < 12 || creditCardNumber.Length() > 19) {
                errors.add('Credit card number must be 12-19 digits.');
            }

            System.debug(expirationYear);
            System.debug(expirationMonth);

            String fullYear = '20' + expirationYear;

            if (Integer.valueof(fullYear) < System.today().year() ||
                    (Integer.valueof(fullYear) == System.today().year() &&
                            Integer.valueof(expirationMonth) < System.today().Month())) {
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

    public Contact guarantor { get; set; }
    public List<Charge_Group__c> chargeGroups { get; set; }
    public ChargeInfo chargeInfo {get; set;}

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

    private Decimal getCGBalanceTotal(){
        Decimal cgBalanceTotal = 0.0;
        for (Charge_Group__c cg : chargeGroups) {
            cgBalanceTotal += cg.Balance__c;
        }
        return cgBalanceTotal;
    }

    public List<String> validate() {
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