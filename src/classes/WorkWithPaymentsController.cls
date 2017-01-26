//TODO remove without sharing
public without sharing class WorkWithPaymentsController {
	public static final Integer SWAP_TRUE 	= 1;
	public static final Integer SWAP_FALSE 	= 2;
	public static final Integer SWAP_EQUALS = 0;

    public static final String QUERY            = 'SELECT Id, Charge_Date__c, Payment_Method__r.Last_4__c, Processor_Transaction_Id__c, Amount__c FROM Payment__c';
    public static final String ORDER_BY         = ' ORDER BY ';
    public static final String DEFAULT_ORDER    = 'Charge_Date__c DESC';
    public static final String LIMIT_SUFFIX     = ' LIMIT 50000';


    @AuraEnabled
    public static List<Payment__c> getPaymentHistory(String criteria, String orderType) {
        if(String.isBlank(criteria)) {
            criteria = DEFAULT_ORDER;
        } else {
        	criteria += orderType.center(orderType.length() + 2);
        }
		List<Payment__c> result;
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
        String whereQuery = ' WHERE  Guarantor__c =\'' + currentUser.ContactId + '\'';

        String finalQuery = QUERY + whereQuery + ORDER_BY + criteria + LIMIT_SUFFIX; 
        result = Database.query(finalQuery);
        if(criteria == DEFAULT_ORDER) {
        	sortList(result);
        }
        return result;
    }

	//Items should be also sort by Amount (not only by date)
	private static void sortList(List<Payment__c> paymentList) {
		for(Integer i = 0; i < paymentList.size(); i++) {
			for(Integer j = paymentList.size() - 1; j > i; j--) {
				if(swapValues(paymentList.get(j), paymentList.get(j - 1))) {
					Payment__c temp = paymentList.get(j);
					paymentList[j] = paymentList[j - 1];
					paymentList[j - 1] = temp;
				}
			}
		}
	}

	//DESC
	private static Boolean swapValues(Payment__c first, Payment__c second) {
		Integer compareDate = compareDateTime(first.Charge_Date__c, second.Charge_Date__c);
		if(compareDate == SWAP_EQUALS) {
			return compareAmount(first.Amount__c, second.Amount__c);
		}
		if(compareDate == SWAP_TRUE) {
			return true;
		}
		return false;
	}
	//DESC    1 - true; 2 - false; 0 - equals
	private static Integer compareDateTime(Datetime first, Datetime second) {
		if(first == null && second != null) {
			return SWAP_TRUE;
		}
		if(first != null && second == null) {
			return SWAP_FALSE;
		}
		if(first == null && second == null) {
			return SWAP_EQUALS;
		}
		//accurate to minutes
		//Long dt1Long = first.getTime();
		//Long dt2Long = second.getTime();
		//Long milliseconds = dt2Long - dt1Long;
		//Long seconds = milliseconds / 1000;
		//Long minutes = seconds / 60;
		//Long hours = minutes / 60;
		//if(minutes == 0) {
		//	return SWAP_EQUALS;
		//}
		//if(minutes < 0) {
		//	return SWAP_TRUE;
		//}
		//return SWAP_FALSE;

		if(first.date() == second.date()) {
			return SWAP_EQUALS;
		}
		if(first.date() < second.date()) {
			return SWAP_TRUE;
		}
		return SWAP_FALSE;


	}
	//DESC
	private static Boolean compareAmount(Decimal second, Decimal first) {
		
		if(first == null) {
			return true;
		}
		if(second == null) {
			return false;
		}
		return first < second;
	}
}