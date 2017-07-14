/* 
 * @author Sirono
 * @version 1.0.1
 * @date: 06-06-2016
 * @description Handler Class for PaymentPlantrigger
 *
 * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases
*/
public with sharing class PaymentPlanTriggerHandler {

    public static final Integer START_DAY = 1;
    public static final Integer START_LAST_MONTH = -1;
    public static final Integer OVERDUE_DAY_LIMIT = 21;

    //static method invoked after insert event
    public static void afterInsert(List<Payment_Plan__c> newList) {
        checkCallListRemove(newList, null);
        callDelinquentPaymentPlanCaseCreation(newList, null);
        callCCErrorCaseAutoCloser(newList, null);
    }

    //static method invoked after update event
    public static void afterUpdate(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap) {
        checkCallListRemove(newList, oldMap);
        callDelinquentPaymentPlanCaseCreation(newList, oldMap);
        callCCErrorCaseAutoCloser(newList, oldMap);
    }

    //static method invoked before insert event occurs
    public static void beforeInsert(List<Payment_Plan__c> newList) {
        callPopulateNextPaymentDate(newList, null, true);
    }

    //static method invoked before update event
    public static void beforeUpdate(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap) {
        callPopulateNextPaymentDate(newList, oldMap, false);
        resetChargesAdded(newList, oldMap);
    }

    //private staic method that collects the Guarantor IDs
    private static void checkCallListRemove(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Payment_Plan__c pp : newList) {
            if (!pp.Active__c && pp.Delinquent_Date__c == null && pp.Guarantor__c != null
                && (oldMap == null || pp.Delinquent_Date__c != oldMap.get(pp.Id).Delinquent_Date__c
                || pp.Active__c != oldMap.get(pp.Id).Active__c || pp.Guarantor__c != oldMap.get(pp.Id).Guarantor__c)) {
                contactIds.add(pp.Guarantor__c);
            }
        }

        if (contactIds.size() > 0) {
            callListUtilities.DelinquentPaymentPlanCallListRemoval(contactIds);
        }
    }

    //Mohan Kumar (Sirono) 09-23-2016 : 127404425 Set/Reset the NextPaymentDate when Execute_on_day__c, Skip_Payment_Until__c, or Plan_Type__c fields are changed.
    public static void callPopulateNextPaymentDate(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap, Boolean isNew) {
        List<Payment_Plan__c> newListToSetDate = new List<Payment_Plan__c>();
        for (Payment_Plan__c pp : newList) {
            if (isNew) {
                newListToSetDate.add(pp);
            } else {
                Payment_Plan__c oldValue = oldMap.get(pp.Id);
                if (pp.Execute_on_Day__c != oldValue.Execute_on_Day__c || pp.Skip_Payment_Until__c != oldValue.Skip_Payment_Until__c
                    || pp.Plan_Type__c != oldValue.Plan_Type__c) {
                    // || pp.NextPaymentDate__c != oldValue.NextPaymentDate__c
                    newListToSetDate.add(pp);
                }
            }
        }
        if (newListToSetDate.size() > 0) {
            PaymentPlanTriggerHandler.populateNextPaymentDate(newListToSetDate, true);
        }
    }

    //private static method that decides the nextPaymentDate
    //Mohan Kumar (Sirono) 09-23-2016 : 127404425 calculates the NextPaymentDate on the Payment Plan reccord.
    //this method is called from different places. When this method is called from other than PaymentPlanTrigger then
    //fromPaymentPlanTrigger parameter contains FALSE and we will need to run the update DML statment to the list.

    public static void populateNextPaymentDate(List<Payment_Plan__c> newList, Boolean fromPaymentPlanTrigger) {
        List<Payment_Plan__c> newListToUpdate = new List<Payment_Plan__c>();
        Set<Id> setContactId = new Set<Id>();
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();

        for (Payment_Plan__c plan:newList) {
            //System.assert(plan.Guarantor__c != null);
            if (plan.Guarantor__c != null) {
                setContactId.add(plan.Guarantor__c);
            }
        }

        mapContacts = new Map<Id, Contact>(GuarantorService.getGuarantorsWithInvoiceOffsetDt(setContactId));

        for (Payment_Plan__c plan: newList) {
            Contact guarantor = new Contact();
            if (plan.Guarantor__c != null && mapContacts.containsKey(plan.Guarantor__c)) {
                guarantor = mapContacts.get(plan.Guarantor__c);
            }

            // Find the reference date. It is either "today" (or the test version) or the Skip Until date.
            Date refDt = System.today();
            if (test.isRunningTest()) {
                refDt = Date.newInstance(TestUtility.currentYear, TestUtility.currentMonth, TestUtility.currentDay);
            }
            if (refDt < plan.Skip_Payment_Until__c) {
                refDt = plan.Skip_Payment_Until__c;
            }

            // Figure out the next payment date relative to the reference date.
            Date nextDt;
            if (plan.Plan_Type__c == Constants.AUTOMATIC) {
                if (plan.Execute_on_Day__c == null || plan.Execute_on_Day__c == 0) {
                    plan.Execute_on_Day__c = START_DAY;
                }
                nextDt = calculateNextPaymentDate(Integer.valueof(plan.Execute_on_Day__c), 0, refDt);
            } else {
                if (guarantor.Invoice_Offset_Date__c == null || guarantor.Invoice_Offset_Date__c == 0) {
                    guarantor.Invoice_Offset_Date__c = START_DAY;
                }
                nextDt = calculateNextPaymentDate(Integer.valueof(guarantor.Invoice_Offset_Date__c), OVERDUE_DAY_LIMIT, refDt);
            }
            plan.NextPaymentDate__c = nextDt;
            if (!fromPaymentPlanTrigger) {
                newListToUpdate.add(plan);
            }
        }

        if (newListToUpdate.size() > 0) {
            if (PaymentPlanSecurityContext.PP_UPDATE_DATES_CONTEXT.actionAllowed()) {
                UPDATE newListToUpdate;
            }
        }
    }

    private static Date calculateNextPaymentDate(Integer selectedDay, Integer step, Date refDt) {
        Integer addMonths = START_LAST_MONTH;
        Date nextDt = Date.newInstance(refDt.year(), refDt.month() + addMonths, checkBordersOfTheMonth(refDt.year(), refDt.month() + addMonths, selectedDay)).addDays(step);
        while (nextDt <= refDt) {
            addMonths++;
            nextDt = Date.newInstance(refDt.year(), refDt.month() + addMonths, checkBordersOfTheMonth(refDt.year(), refDt.month() + addMonths, selectedDay)).addDays(step);
        }
        return nextDt;
    }

    private static Integer checkBordersOfTheMonth(Integer year, Integer month, Integer checkDay) {
        Integer maxDay = Date.daysInMonth(year, month);
        if (checkDay < maxDay) {
            return checkDay;
        }
        return maxDay;
    }

    //Sirono 08-22-2016 : 127401841 Create a Delinquent Payment Plan Case
    Private static void callDelinquentPaymentPlanCaseCreation(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap) {
        Set<Id> contactToCreateCaseIds = new Set<Id>();
        Set<Id> contactToCloseCase = new Set<Id>();
        Set<Id> paymentPlanID = new Set<Id>();
        for (Payment_Plan__c plan : newList) {
            if (trigger.IsInsert && plan.Guarantor__c != null && plan.active__c == true && plan.Delinquent__c == true) {
                contactToCreateCaseIds .add(plan.Guarantor__c);
            } else if (trigger.IsUpdate && plan.Guarantor__c != null && (plan.active__c == true && plan.Delinquent__c == true && (oldMap.get(plan.id).active__c == false || oldMap.get(plan.id).Delinquent__c == false))) {
                contactToCreateCaseIds.add(plan.Guarantor__c);
            }

            if (trigger.IsUpdate && plan.Guarantor__c != null && ((plan.active__c == false && oldMap.get(plan.id).active__c == true) || (plan.Delinquent__c == false && oldMap.get(plan.id).Delinquent__c == true))) {
                contactToCloseCase.add(plan.Guarantor__c);
                paymentPlanID.add(plan.Id);
            }
        }

        if (contactToCreateCaseIds.Size() > 0) {
            CaseUtil.createDelinquentPaymentCase(contactToCreateCaseIds);
        }

        if (contactToCloseCase.Size() > 0) {
            CaseUtil.closeDelinquentPaymentCase(contactToCloseCase, paymentPlanID);
        }
    }

    // Close open cases for payment plans which no longer have errors
    private static void callCCErrorCaseAutoCloser(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        Set<Id> closeCaseGuarantorIds = new Set<Id>();
        Set<Id> paymentPlanId = new Set<Id>();

        if (Trigger.isUpdate) {
            for (Payment_Plan__c paymentPlan : paymentPlans) {
                Payment_Plan__c oldPaymentPlan = oldPaymentPlansById.get(paymentPlan.Id);
                if ((oldPaymentPlan != null) && oldPaymentPlan.Has_Error__c && !paymentPlan.Has_Error__c) {
                    closeCaseGuarantorIds.add(paymentPlan.Guarantor__c);
                    paymentPlanId.add(paymentPlan.Id);
                }
            }

            if (!closeCaseGuarantorIds.isEmpty()) {
                CaseUtil.closeCCErrorCase(closeCaseGuarantorIds, paymentPlanId);
            }
        }
    }

    // If the plan value modified date changes, then set the charges added since start field to 0
    private static void resetChargesAdded(List<Payment_Plan__c> newList, Map<Id, Payment_Plan__c> oldMap) {
        List<Id> planIds = new List<Id>();

        for (Payment_Plan__c plan : newList) {
            Datetime newDate = plan.Plan_Value_Modified_Date__c;
            Datetime oldDate = oldMap.get(plan.Id).Plan_Value_Modified_Date__c;

            if (newDate != oldDate) {
                plan.Charges_Added_Since_Start__c = 0;
            }
        }
    }
}