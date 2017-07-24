/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@RestResource(urlMapping='/SummaryWidget/*')
global with sharing class HiMSS_SummaryWidgetRESTService {
    @HttpGet
    global static void getGuarantor() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        String getNewUser = req.params.get('getNewUser');

        List<Guarantor> portalGuarantorList = HiMSS_SummaryWidgetRESTService.getPortalGuarantor(getNewUser);
        if (!portalGuarantorList.isEmpty()) {
            res.responseBody = Blob.valueOf(JSON.serialize(portalGuarantorList));
        }
    }

    public static List<Guarantor> getPortalGuarantor(String getNewUser) {
        List<Guarantor> guarantorList = new List<Guarantor>();
        Map<Id, Guarantor.GuarantorUser> userMap = HiMSS_SummaryWidgetRESTService.getUsers(getNewUser);
        if (!userMap.isEmpty()) {
            Map<Id, Guarantor.GuarantorContact> grtContactMap = HiMSS_SummaryWidgetRESTService.getGrtContact(userMap.keySet());
            Map<Id, Guarantor.Invoice> grtInvoiceMap = HiMSS_SummaryWidgetRESTService.getGuarantorInvoice(userMap.keySet());
            Map<Id, Guarantor.PaymentPlan> grtPaymentPlanMap = HiMSS_SummaryWidgetRESTService.getGuarantorPaymentPlan(userMap.keySet());
            Map<Id, Integer> newEstimatesCountMap = HiMSS_SummaryWidgetRESTService.getEstimatesCount(userMap.keySet());

            for (Id contactId : userMap.keySet()) {
                guarantorList.add(new Guarantor(userMap.get(contactId), grtContactMap.get(contactId),
                    grtInvoiceMap.get(contactId), grtPaymentPlanMap.get(contactId), newEstimatesCountMap.get(contactId)));
            }
            return guarantorList;
        } else {
            return null;
        }
    }

    public static Map<Id, Guarantor.GuarantorUser> getUsers(String getNewUser) {
        Map<Id, Guarantor.GuarantorUser> guarantorUserMap = new Map<Id, Guarantor.GuarantorUser>();
        Map<Id, User> usrMap = new Map<Id, User>([
            SELECT Id,
                ContactId,
                UserName,
                Community_Password__c,
                Is_Demo_Active__c,
                Contact.Invoiced_Balance__c
            FROM User
            WHERE Name = 'Charles Green' AND
            Is_Demo_Locked__c = false
            // Id='00511000004rIxJAAU'//AB 2/14 Setting default user
            ORDER BY CreatedDate ASC
        ]);

        for (Id id : usrMap.keySet()) {
            System.debug(' user id: ' + id + ' User: ' + usrMap.get(id));
        }

        User usr = getUntouchedUser(usrMap, getNewUser);
        // for (User usr : usrList) {
        guarantorUserMap.put(usr.ContactId, new Guarantor.GuarantorUser(usr.UserName, usr.Community_Password__c, usr.ContactId));
        // }

        return guarantorUserMap;
    }

    public static User getUntouchedUser(Map<Id, User> usrMap, String getNewUser) {
        User activeUser = checkActiveUser(usrMap, getNewUser);
        System.debug(':::activeUser:::' + activeUser);
        System.debug(':::getNewUser:::' + getNewUser);
        if (activeUser == null) {
            Map<Id, Id> contactUserIds = new Map<Id, Id>();
            for (User usr : usrMap.values()) {
                contactUserIds.put(usr.ContactId, usr.Id);
            }

            Map<Id, Datetime> lastActivityMap = new Map<Id, Datetime>();
            Set<Id> paymentPlanSet = new Set<Id>();
            List<Payment_Plan__c> paymentPlanList = [
                SELECT Id, Guarantor__c, LastModifiedDate
                FROM Payment_Plan__c
                WHERE Guarantor__c IN :contactUserIds.keySet() AND
                Active__c = true
                ORDER BY LastModifiedDate DESC
            ];
            for (Payment_Plan__c paymentPlan : paymentPlanList) {
                paymentPlanSet.add(paymentPlan.Guarantor__c);
            }

            List<Payment__c> paymentList = [
                SELECT Id, Guarantor__c, LastModifiedDate
                FROM Payment__c
                WHERE Guarantor__c IN :contactUserIds.keySet()
                ORDER BY LastModifiedDate DESC
            ];
            for (Payment__c payment : paymentList) {
                if (!lastActivityMap.containsKey(payment.Guarantor__c) && !paymentPlanSet.contains(payment.Guarantor__c)) {
                    lastActivityMap.put(payment.Guarantor__c, payment.LastModifiedDate);
                }
            }
            System.debug(':::lastActivityMap:::' + lastActivityMap);

            for (User usr : usrMap.values()) {
                if (!lastActivityMap.containsKey(usr.ContactId) && !paymentPlanSet.contains(usr.ContactId)) {
                    lastActivityMap.put(usr.ContactId, usr.CreatedDate);
                }
            }

            Datetime lastActivityDate;
            Id lastActivityDateContactId;
            for (Id contactId : lastActivityMap.keySet()) {
                if (lastActivityDate == null || (lastActivityMap.get(contactId) < lastActivityDate)) {
                    lastActivityDate = lastActivityMap.get(contactId);
                    lastActivityDateContactId = contactId;
                }
            }

            User untouchedUser = usrMap.get(contactUserIds.get(lastActivityDateContactId));
            untouchedUser.Is_Demo_Active__c = true;
            update untouchedUser;
            System.debug(':::untouchedUser:::' + untouchedUser);

            return (lastActivityDateContactId != null) ? untouchedUser : null;
        } else {
            return activeUser;
        }
    }

    private static User checkActiveUser(Map<Id, User> usrMap, String getNewUser) {
        User activeUser;
        for (User usr : usrMap.values()) {
            if (usr.Is_Demo_Active__c) {
                activeUser = usr;
                break;
            }
        }
        if (activeUser != null) {
            Integer paymentPlanCount = [SELECT COUNT() FROM Payment_Plan__c WHERE Guarantor__c = :activeUser.ContactId AND Active__c = true];
            if (activeUser.Contact.Invoiced_Balance__c == 0 || (paymentPlanCount >= 1 && getNewUser == 'true')) {
                activeUser.Is_Demo_Active__c = false;
                update activeUser;
                return null;
            }
        }

        return activeUser;
    }

    public static Map<Id, Guarantor.GuarantorContact> getGrtContact(Set<Id> contactIds) {
        Map<Id, Guarantor.GuarantorContact> guarantorContactMap = new Map<Id, Guarantor.GuarantorContact>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>(GuarantorService.getContactsForLightning(contactIds));

        for (Id contactId : contactIds) {
            if (contactMap.containsKey(contactId)) {
                Contact currContact = contactMap.get(contactId);
                guarantorContactMap.put(contactId, new Guarantor.GuarantorContact(currContact.Guarantor_Status__c, currContact.Outstanding_Invoices__c,
                    currContact.Overdue_Invoices__c, currContact.Delinquent_Invoices__c, currContact.Add_to_Payment_Plan__c, currContact.Invoiced_Balance__c));
            } else {
                guarantorContactMap.put(contactId, null);
            }
        }
        return guarantorContactMap;
    }

    public static Map<Id, Guarantor.Invoice> getGuarantorInvoice(Set<Id> contactIds) {
        Map<Id, Guarantor.Invoice> guarantorInvoiceMap = new Map<Id, Guarantor.Invoice>();
        List<Invoice__c> listInvoices = [
            SELECT
                Id,
                Due_Date__c,
                Guarantor__c
            FROM Invoice__c
            WHERE Guarantor__c IN :contactIds
            AND Invoice_Status__c = :Constants.DUE
            ORDER BY CreatedDate
        ];
        Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>();
        for (Invoice__c invoice : listInvoices) {
            if (!invoiceMap.containsKey(invoice.Guarantor__c)) {
                invoiceMap.put(invoice.Guarantor__c, invoice);
            }
        }

        for (Id contactId : contactIds) {
            if (invoiceMap.containsKey(contactId)) {
                guarantorInvoiceMap.put(contactId, new Guarantor.Invoice(invoiceMap.get(contactId).Due_Date__c));
            } else {
                guarantorInvoiceMap.put(contactId, null);
            }
        }
        return guarantorInvoiceMap;
    }

    public static Map<Id, Guarantor.PaymentPlan> getGuarantorPaymentPlan(Set<Id> contactIds) {
        Map<Id, Guarantor.PaymentPlan> guarantorPaymentPlanMap = new Map<Id, Guarantor.PaymentPlan>();
        List<Payment_Plan__c> paymentPlans = [
            SELECT
                Id,
                Payment_Plan_Standing__c,
                NextPaymentDate__c,
                Installment_Amount__c,
                Installments_Completed__c,
                Original_Installment_Count__c,
                Active__c,
                Plan_Type__c,
                Guarantor__c
            FROM Payment_Plan__c
            WHERE Guarantor__c IN :contactIds
            ORDER BY Active__c DESC, LastModifiedDate DESC
        ];
        Map<Id, Payment_Plan__c> paymentPlanMap = new Map<Id, Payment_Plan__c>();
        for (Payment_Plan__c paymentPlan : paymentPlans) {
            if (!paymentPlanMap.containsKey(paymentPlan.Guarantor__c)) {
                paymentPlanMap.put(paymentPlan.Guarantor__c, paymentPlan);
            }
        }

        for (Id contactId : contactIds) {
            if (paymentPlanMap.containsKey(contactId)) {
                Payment_Plan__c pPlan = paymentPlanMap.get(contactId);
                guarantorPaymentPlanMap.put(contactId, new Guarantor.PaymentPlan(pPlan.NextPaymentDate__c, pPlan.Active__c,
                    pPlan.Payment_Plan_Standing__c, pPlan.Plan_Type__c));
            } else {
                guarantorPaymentPlanMap.put(contactId, null);
            }
        }

        return guarantorPaymentPlanMap;
    }

    public static Map<Id, Integer> getEstimatesCount(Set<Id> contactIds) {
        Map<Id, Integer> estimatesCountMap = new Map<Id, Integer>();
        AggregateResult[] newEstimatesByGuarantor = [
            SELECT
                Guarantor__c, COUNT(Id) total
            FROM Encounter__c
            WHERE Guarantor__c IN :contactIds AND
            CreatedDate >= :Datetime.now().addDays(-30)
            GROUP BY Guarantor__c
        ];
        for (AggregateResult ar : newEstimatesByGuarantor) {
            estimatesCountMap.put((Id) ar.get('Guarantor__c'), (Integer) ar.get('total'));
        }

        return estimatesCountMap;
    }
}