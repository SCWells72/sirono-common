/* 
 * @author Sirono
 * @version 1.0.1
 * @date: 09-01-2016
*/
public with sharing class PaymentPlanUtil {

    public static Map<Id, Payment_Plan__c> setBalanceAndCharges(Set<Id> planIds) {
            //update the paymentplan with the sum of its chargegroup balances
            // Get the SUM of the associated chargegroup balances
            AggregateResult[] results = [
                    SELECT Payment_Plan__c pp, SUM(Balance__c) planBalance
                    FROM Charge_Group__c
                    WHERE Payment_Plan__c IN :planIds
                    GROUP BY Payment_Plan__c
            ];

            // get the sum of all charge txns added since the payment_plan value was last modified
            AggregateResult[] chargeResults = [
                    SELECT Charge_Group__r.Payment_Plan__c pp, SUM(Amount__c) chargesAdded
                    FROM Transaction__c
                    WHERE Charge_Group__r.Payment_Plan__c IN :planIds
                    AND Charge_added_since_plan_start__c = TRUE
                    AND Txn_Method__c = :Constants.SERVICE
                    GROUP BY Charge_Group__r.Payment_Plan__c
            ];

            return setAmounts(results, chargeResults);
    }


    private static Map<Id, Payment_Plan__c> setAmounts(AggregateResult[] balanceResults, AggregateResult[] chargeResults) {
        Map<Id, Payment_Plan__c> ppMap = new Map<Id, Payment_Plan__c>();

        for (AggregateResult ar : balanceResults) {
//            System.debug('ppId: ' + ar.get('pp'));
//            System.debug('planBalance: ' + ar.get('planBalance'));
            System.debug('Updating balance in Payment Plan [Id: ' + ar.get('pp') + ', New balance: ' + ar.get('planBalance') + ']');
            Payment_Plan__c pp = new Payment_Plan__c(Id = (Id) ar.get('pp'));
            pp.Remaining_Balance__c = (Decimal) ar.get('planBalance');
            ppMap.put(pp.Id, pp);
        }

        for (AggregateResult ar : chargeResults) {
//            System.debug('ppId: ' + ar.get('pp'));
//            System.debug('chargesAdded: ' + ar.get('chargesAdded'));
            System.debug('Updating charges added to Payment Plan [Id: ' + ar.get('pp') + ', Charges added: ' + ar.get('chargesAdded') + ']');
            Id ppId = (Id) ar.get('pp');
            Payment_Plan__c pp = ppMap.get(ppId);
            if (pp == null) {
                pp = new Payment_Plan__c(Id = ppId);
            }
            pp.Charges_Added_Since_Start__c = (Decimal) ar.get('chargesAdded');
            ppMap.put(ppId, pp);
        }

        return ppMap;
    }
}