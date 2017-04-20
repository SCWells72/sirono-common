/**
 * Payment Plan Info class.
 * It is use to set all parameters which are pass or set in web request to create/edit Payment Plan.
 **/

public with sharing class PaymentPlanInformation {
    public String planType {get; set;}
    public String planValue {get; set;}
    public String amount {get; set;}
    public String executeOnDay {get; set;}
    public List<String> chargeGroupIds {get; set;}
    public String guarantorId {get; set;}
    public String cardholderName {get; set;}
    public String expirationYear {get; set;}
    public String expirationMonth {get; set;}
    public String creditCardNumber {get; set;}
    public String cvv {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
    public String address {get; set;}
    public String city {get; set;}
}