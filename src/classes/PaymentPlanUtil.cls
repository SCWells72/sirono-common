/* 
 * @author Sirono
 * @version 1.0.1
 * @date: 09-01-2016
*/
public with sharing class PaymentPlanUtil {

    /*
     * setBalanceAndCharges is a gateway method to setAmounts, which does the actual object modifications.
     *
     * @param Set<Id> planIds - Ids from payment plans that need to be calculated
     * @return Map<Id, Payment_Plan__c>
     */
    public static Map<Id, Payment_Plan__c> setBalanceAndCharges(Set<Id> planIds) {
            AggregateResult[] results;
            AggregateResult[] chargeResults;

            //update the paymentplan with the sum of its chargegroup balances
            // Get the SUM of the associated chargegroup balances
            if (ChargeGroupSecurityContext.PPU_SELECT_CONTEXT.actionAllowed()) {
                results = [
                        SELECT Payment_Plan__c pp, SUM(Balance__c) planBalance
                        FROM Charge_Group__c
                        WHERE Payment_Plan__c IN :planIds
                        GROUP BY Payment_Plan__c
                ];
            }

            // get the sum of all charge txns added since the payment_plan value was last modified
            if (TransactionSecurityContext.PPU_SELECT_CONTEXT.actionAllowed()) {
                chargeResults = [
                        SELECT Charge_Group__r.Payment_Plan__c pp, SUM(Amount__c) chargesAdded
                        FROM Transaction__c
                        WHERE Charge_Group__r.Payment_Plan__c IN :planIds
                        AND Charge_added_since_plan_start__c = TRUE
                        AND Txn_Method__c = :Constants.SERVICE
                        GROUP BY Charge_Group__r.Payment_Plan__c
                ];
            }

            return setAmounts(results, chargeResults);
    }

    /*
     * setAmounts takes the query results, if any, from setBalanceAndCharges and puts the values into a map that
     * updates appropriate fields on the Payment Plan object. The results are returned through setBalanceAndCharges and
     * updated in whichever method or class called setBalanceAndCharges.
     *
     * @param AggregateResult[] balanceResults - query results to set plan balance
     * @param AggregateResult[] chargeResults - query results to set charges added sine plan start
     * @return Map<Id, Payment_Plan__c>
     */
    private static Map<Id, Payment_Plan__c> setAmounts(AggregateResult[] balanceResults, AggregateResult[] chargeResults) {
        Map<Id, Payment_Plan__c> ppMap = new Map<Id, Payment_Plan__c>();

        for (AggregateResult ar : balanceResults) {
            System.debug('Updating balance in Payment Plan [Id: ' + ar.get('pp') + ', New balance: ' + ar.get('planBalance') + ']');
            Payment_Plan__c pp = new Payment_Plan__c(Id = (Id) ar.get('pp'));
            pp.Remaining_Balance__c = (Decimal) ar.get('planBalance');
            ppMap.put(pp.Id, pp);
        }

        for (AggregateResult ar : chargeResults) {
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