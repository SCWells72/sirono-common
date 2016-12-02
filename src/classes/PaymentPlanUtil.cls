/* 
 * @author Sirono
 * @version 1.0.1
 * @date: 09-01-2016
*/
public with sharing class PaymentPlanUtil {
	
	public PaymentPlanUtil() {
    
    }
	/*
    public static void updateBalances(Set<Id> planIds) {

        if (planIds.size() > 0) {
            //update the paymentplan with the sum of its chargegroup balances
            // Get the SUM of the associated chargegroup balances
            AggregateResult[] results = [
                    SELECT Payment_Plan__c pp, SUM(Balance__c) planBalance
                    FROM Charge_Group__c
                    WHERE Payment_Plan__c IN :planIds
                    GROUP BY Payment_Plan__c
            ];
            if (results.size() > 0) {
                updatePlans(results);
            } else {
                System.debug('No AggregateResults returned');
            }
        } else {
            System.debug('Empty planIds');
        }
    }

    private static void updatePlans(AggregateResult[] results) {
        List<test__c> pps = new List<test__c>();

        for (AggregateResult ar : results) {
            System.debug('ppId: ' + ar.get('pp'));
            System.debug('planBalance: ' + ar.get('planBalance'));
            test__c pp = new test__c();
            pp.Id = (Id) ar.get('pp');
            pp.Payable_Amount__c = (Decimal) ar.get('planBalance');
            pps.add(pp);
        }

        // Update the database
        if (pps.size() > 0) {
            update pps;
        }
    }*/
}