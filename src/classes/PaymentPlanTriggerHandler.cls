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

    public static void afterInsert(List<Payment_Plan__c> paymentPlans) {
        checkCallListRemove(paymentPlans, null);
        callDelinquentPaymentPlanCaseCreation(paymentPlans, null);
        createCasesForPaymentPlansWithNewErrors(paymentPlans, null);
    }

    public static void afterUpdate(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        checkCallListRemove(paymentPlans, oldPaymentPlansById);
        callDelinquentPaymentPlanCaseCreation(paymentPlans, oldPaymentPlansById);
        createCasesForPaymentPlansWithNewErrors(paymentPlans, oldPaymentPlansById);
        callPaymentPlanErrorCaseAutoCloser(paymentPlans, oldPaymentPlansById);
    }

    public static void beforeInsert(List<Payment_Plan__c> paymentPlans) {
        callPopulateNextPaymentDate(paymentPlans, null, true);
    }

    public static void beforeUpdate(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        callPopulateNextPaymentDate(paymentPlans, oldPaymentPlansById, false);
        resetChargesAdded(paymentPlans, oldPaymentPlansById);
    }

    private static void checkCallListRemove(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        Set<Id> contactIds = new Set<Id>();
        for (Payment_Plan__c paymentPlan : paymentPlans) {
            if (!paymentPlan.Active__c && paymentPlan.Delinquent_Date__c == null && paymentPlan.Guarantor__c != null
                && (oldPaymentPlansById == null || paymentPlan.Delinquent_Date__c != oldPaymentPlansById.get(paymentPlan.Id).Delinquent_Date__c
                || paymentPlan.Active__c != oldPaymentPlansById.get(paymentPlan.Id).Active__c || paymentPlan.Guarantor__c != oldPaymentPlansById.get(paymentPlan.Id).Guarantor__c)) {
                contactIds.add(paymentPlan.Guarantor__c);
            }
        }

        if (contactIds.size() > 0) {
            callListUtilities.DelinquentPaymentPlanCallListRemoval(contactIds);
        }
    }

    //Mohan Kumar (Sirono) 09-23-2016 : 127404425 Set/Reset the NextPaymentDate when Execute_on_day__c, Skip_Payment_Until__c, or Plan_Type__c fields are changed.
    public static void callPopulateNextPaymentDate(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById, Boolean isNew) {
        List<Payment_Plan__c> newListToSetDate = new List<Payment_Plan__c>();
        for (Payment_Plan__c paymentPlan : paymentPlans) {
            if (isNew) {
                newListToSetDate.add(paymentPlan);
            } else {
                Payment_Plan__c oldValue = oldPaymentPlansById.get(paymentPlan.Id);
                if (paymentPlan.Execute_on_Day__c != oldValue.Execute_on_Day__c || paymentPlan.Skip_Payment_Until__c != oldValue.Skip_Payment_Until__c
                    || paymentPlan.Plan_Type__c != oldValue.Plan_Type__c) {
                    // || pp.NextPaymentDate__c != oldValue.NextPaymentDate__c
                    newListToSetDate.add(paymentPlan);
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
    public static void populateNextPaymentDate(List<Payment_Plan__c> paymentPlans, Boolean fromPaymentPlanTrigger) {
        List<Payment_Plan__c> newListToUpdate = new List<Payment_Plan__c>();
        Set<Id> setContactId = new Set<Id>();
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();

        for (Payment_Plan__c paymentPlan : paymentPlans) {
            //System.assert(plan.Guarantor__c != null);
            if (paymentPlan.Guarantor__c != null) {
                setContactId.add(paymentPlan.Guarantor__c);
            }
        }

        mapContacts = new Map<Id, Contact>(GuarantorService.getGuarantorsWithInvoiceOffsetDt(setContactId));

        for (Payment_Plan__c plan: paymentPlans) {
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
    Private static void callDelinquentPaymentPlanCaseCreation(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        Set<Id> contactToCreateCaseIds = new Set<Id>();
        Set<Id> contactToCloseCase = new Set<Id>();
        Set<Id> paymentPlanId = new Set<Id>();
        for (Payment_Plan__c paymentPlan : paymentPlans) {
            if (trigger.IsInsert && paymentPlan.Guarantor__c != null && paymentPlan.active__c == true && paymentPlan.Delinquent__c == true) {
                contactToCreateCaseIds .add(paymentPlan.Guarantor__c);
            } else if (trigger.IsUpdate && paymentPlan.Guarantor__c != null && (paymentPlan.active__c == true && paymentPlan.Delinquent__c == true && (oldPaymentPlansById.get(paymentPlan.id).active__c == false || oldPaymentPlansById.get(paymentPlan.id).Delinquent__c == false))) {
                contactToCreateCaseIds.add(paymentPlan.Guarantor__c);
            }

            if (trigger.IsUpdate && paymentPlan.Guarantor__c != null && ((paymentPlan.active__c == false && oldPaymentPlansById.get(paymentPlan.id).active__c == true) || (paymentPlan.Delinquent__c == false && oldPaymentPlansById.get(paymentPlan.id).Delinquent__c == true))) {
                contactToCloseCase.add(paymentPlan.Guarantor__c);
                paymentPlanId.add(paymentPlan.Id);
            }
        }

        if (contactToCreateCaseIds.Size() > 0) {
            CaseUtil.createDelinquentPaymentCase(contactToCreateCaseIds);
        }

        if (contactToCloseCase.Size() > 0) {
            CaseUtil.closeDelinquentPaymentCase(contactToCloseCase, paymentPlanId);
        }
    }

    private static void createCasesForPaymentPlansWithNewErrors(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        // Only if we're configured to auto-create payment plan error cases
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        if (!sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c) {
            return;
        }

        // Look for new payment plans with errors or existing payment plans that were modified to have errors
        List<Payment_Plan__c> paymentPlansWithErrors = new List<Payment_Plan__c>();
        for (Payment_Plan__c paymentPlan : paymentPlans) {
            Payment_Plan__c oldPaymentPlan = oldPaymentPlansById != null ? oldPaymentPlansById.get(paymentPlan.Id) : null;
            if (paymentPlan.Has_Error__c && ((oldPaymentPlan == null) || !oldPaymentPlan.Has_Error__c)) {
                paymentPlansWithErrors.add(paymentPlan);
            }
        }

        // Create cases for those that now have errors
        List<Case> paymentPlanErrorCases = new List<Case>();
        for (Payment_Plan__c paymentPlanWithError : paymentPlansWithErrors) {
            Case paymentPlanErrorCase = new Case(
                ContactId = paymentPlanWithError.Guarantor__c,
                Guarantor_Information__c = paymentPlanWithError.Guarantor__c,
                RecordTypeId = RecordTypeUtil.automatedCaseRt,
                Status = Constants.CASE_STATUS_NEW,
                Subject = Constants.CASE_SUBJECT_PAYMENT_PLAN_ERROR,
                Type = Constants.CASE_TYPE_PAYMENT_PLAN_ERROR
            );
            paymentPlanErrorCases.add(paymentPlanErrorCase);
        }

        if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            if (!paymentPlanErrorCases.isEmpty()) {
                insert paymentPlanErrorCases;
            }
        }
    }

    // Close open cases for payment plans which no longer have errors
    private static void callPaymentPlanErrorCaseAutoCloser(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
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
                CaseUtil.closePaymentPlanErrorCase(closeCaseGuarantorIds, paymentPlanId);
            }
        }
    }

    // If the plan value modified date changes, then set the charges added since start field to 0
    private static void resetChargesAdded(List<Payment_Plan__c> paymentPlans, Map<Id, Payment_Plan__c> oldPaymentPlansById) {
        List<Id> planIds = new List<Id>();

        for (Payment_Plan__c paymentPlan : paymentPlans) {
            Datetime newDate = paymentPlan.Plan_Value_Modified_Date__c;
            Datetime oldDate = oldPaymentPlansById.get(paymentPlan.Id).Plan_Value_Modified_Date__c;

            if (newDate != oldDate) {
                paymentPlan.Charges_Added_Since_Start__c = 0;
            }
        }
    }
}