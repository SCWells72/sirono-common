/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * ContactTriggerHandler - ContactTrigger Handler.
 */
public with sharing class ContactTriggerHandler {
    public static Boolean isRecursive = false;

    // Call checkCallListRemove method when the contact is inserted.        
    public static void afterInsert(List<Contact> newList) {
        System.debug('Entering ContactTriggerHandler.afterInsert: ' + UserInfo.getUserName());
        checkCallListRemove(newList, null);
        validatePhoneNumbers(newList, null);
        System.debug('Leaving ContactTriggerHandler.afterInsert: ' + UserInfo.getUserName());
    }

    // Call checkCallListRemove, caseEarlyOutClose methods when the contact is updated.
    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        System.debug('Entering ContactTriggerHandler.afterUpdate: ' + UserInfo.getUserName());
        if (isRecursive) {
            return;
        }
        checkCallListRemove(newList, oldMap);
        caseEarlyOutClose(newList, oldMap);
        callPopulateNextPaymentDate(newList, oldMap);
        validatePhoneNumbers(newList, oldMap);
        System.debug('Leaving ContactTriggerHandler.afterUpdate: ' + UserInfo.getUserName());
    }

    // Call checkCallListRemove method when the contact is inserted.
    private static void checkCallListRemove(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact c : newList) {
            if (oldMap == null || c.Overdue_Balance__c != oldMap.get(c.Id).Overdue_Balance__c
                || c.Delinquent_Balance__c != oldMap.get(c.Id).Delinquent_Balance__c) {
                contactMap.put(c.Id, c);
            }
        }

        if (contactMap.keySet().size() > 0) {
            CallListUtilities.preCollectionCallListRemoval(contactMap.keySet());
            CallListUtilities.earlyOutCallListRemoval(contactMap.values());
        }
    }

    /*
     * Call caseEarlyOutClose method when the contact is updated.
     *
     */
    private static void caseEarlyOutClose(List<Contact> newList, Map<Id, Contact> oldMap) {
        System.debug('In');
        Set<String> contactOverdueSet = new Set<String>();
        Set<String> contactDelinquentSet = new Set<String>();
        for (Contact c : newList) {
            if (c.Overdue_Balance__c != oldMap.get(c.Id).Overdue_Balance__c
                && c.Overdue_Balance__c >= 0) {
                contactOverdueSet.add(c.Id);
            }
            if (c.Delinquent_Balance__c != oldMap.get(c.Id).Delinquent_Balance__c
                && c.Delinquent_Balance__c >= 0) {
                contactDelinquentSet.add(c.Id);
            }
        }

        if (contactOverdueSet.size() > 0) {
            CaseUtil.closeEarlyOutAutoCase(contactOverdueSet);
        }
        if (contactDelinquentSet.size() > 0) {
            CaseUtil.closePrecollectionsAutoCase(contactDelinquentSet);
        }
    }
    
    /*
 
     * If contacts Offset is changed then we have to update the next payment date of payment plan object.
     */
    private static void callPopulateNextPaymentDate(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<String> contactId = new Set<String>();
        for (Contact c : newList) {
            if (c.Invoice_Offset_Date__c != oldMap.get(c.Id).Invoice_Offset_Date__c) {
                contactId.add(c.Id);
            }
        }

        if (contactId.size() > 0) {
            if (PaymentPlanSecurityContext.CTH_SELECT_CONTEXT.actionAllowed()) {
                List<Payment_Plan__c> paymentPlan = [
                    SELECT
                        Id, Guarantor__c, Plan_Type__c,
                        Execute_On_Day__c, NextPaymentDate__c,
                        Skip_Payment_Until__c
                    FROM Payment_Plan__c
                    WHERE Guarantor__c IN :contactId
                ];
                if (!paymentPlan.isEmpty()) {
                    PaymentPlanTriggerHandler.populateNextPaymentDate(paymentPlan, false);
                }
            }
        }
    }

    /*
     * Determine if oldVal and newVal are different
     */
    @TestVisible
    private static Boolean valueChanged(String oldVal, String newVal) {
        if (!String.isEmpty(oldVal) && !String.isEmpty(newVal)) {
            return !oldVal.equals(newVal);
        }

        return !String.isEmpty(oldVal) || !String.isEmpty(newVal);
    }

    /**
     * After Insert or Update, if a phone number has changed, invoke NumVerify to
     * determine what numbers to use to contact the Guarantor
     */
    private static void validatePhoneNumbers(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        System.debug('At the top of ContactTriggerHandler.validatePhoneNumbers: ' + UserInfo.getUserName());
        Set<Id> contactIds = new Set<Id>();
        for (Contact con : newContacts) {
            //Check Contact Record Type is Guarantor.
            if (con.RecordTypeId.equals(RecordTypeUtil.guarantorRt)) {
            	/* We change below conditions based on these criteria:
                 * 1. If Contact is inserted check only number is not empty.
                 * 2. If Contact is updated check old and new number are different
                 * 3. If Contact is updated with an empty number, change pickList value to Null/Empty.
                 */
                if (oldMap == null) {
                    System.debug('oldMap is empty & usrInfo: ');
                    if (!String.isEmpty(con.MobilePhone) || !String.isEmpty(con.OtherPhone) || !String.isEmpty(con.HomePhone)) {
                        contactIds.add(con.Id);
                    }
                } else if (valueChanged(oldMap.get(con.Id).MobilePhone, con.MobilePhone) ||
                    valueChanged(oldMap.get(con.Id).OtherPhone, con.OtherPhone) ||
                    valueChanged(oldMap.get(con.Id).HomePhone, con.HomePhone)) {
                    System.debug('oldMap.get(con.Id).MobilePhone: ' + oldMap.get(con.Id).MobilePhone + ' con.MobilePhone: ' + con.MobilePhone
                        + ' value changed? ' + valueChanged(oldMap.get(con.Id).MobilePhone, con.MobilePhone));
                    System.debug('oldMap.get(con.Id).OtherPhone: ' + oldMap.get(con.Id).OtherPhone + ' con.OtherPhone: ' + con.OtherPhone
                        + ' value changed? ' + valueChanged(oldMap.get(con.Id).OtherPhone, con.OtherPhone));
                    System.debug('oldMap.get(con.Id).HomePhone: ' + oldMap.get(con.Id).HomePhone + ' con.HomePhone: ' + con.HomePhone
                        + ' value changed? ' + valueChanged(oldMap.get(con.Id).HomePhone, con.HomePhone));
                    contactIds.add(con.Id);
                }
            }
        }

        if (contactIds.size() > 0) {
            System.debug('ContactTriggerHandler invoking verifyNumbers: ' + UserInfo.getUserName());
            System.debug('for id: ' + new List<Id>(contactIds)[0]);
            verifyNumbers(contactIds);
        }
    }

    /*
     * This method get the numbers and phone types of Contacts based on given contact Ids.
     * After get contact list, we call methods to verify number and assign number into CTINumber field based on
     * conditions for contacts.
     * When complete, update the contacts.
     */
    @Future(Callout = true)
    public static void verifyNumbers(Set<Id> ids) {
        System.debug('Entering @future method ContactTriggerHandler.verifyNumbers: ' + UserInfo.getUserName());
        isRecursive = true;
        try {
            List<Contact> contacts = GuarantorService.getGuarantorsWithNumbers(ids);

            for (Contact con : contacts) {
                verifyContactPhoneNumbers(con);
                setCTINumbers(con);
            }
            // Update contacts.
            GuarantorService.updateGuarantors(contacts);
            System.debug('===:landline ' + contacts[0].CTINumber1__c);
        } catch (Exception ex) {
            System.debug('ContactTriggerHandler.verifyNumber: ' + ex.getMessage());
        } finally {
            isRecursive = false;
        }
        System.debug('Leaving @future method ContactTriggerHandler.verifyNumbers: ' + UserInfo.getUserName());
    }

    /*
        Send each of the contact's numbers to NumVerify to determine if the number is valid and what type it is
        (ie landline or mobile or invalid)
        TODO Should we be checking for duplicate numbers somewhere?
        Set Pick List value based on NumVerifyValidator response.
        NumVerifyValidator verifies the number and returns the line type. Based on lineType, assign the number to pick list.
     */
    @TestVisible
    private static void verifyContactPhoneNumbers(Contact con) {

        NumVerifyValidator.VerifiedNumber nbr;

        // We need to make Pick List value Null, If Updated Number is empty.
        con.Home_Phone_Type__c = null;
        con.Mobile_Phone_Type__c = null;
        con.Other_Phone_Type__c = null;

        //We need to check number is not empty.
        //If any one number(Home) is there in Contact at that time it will make request for all. (Home, Mobile, Other)
        if (!String.isEmpty(con.HomePhone)) {
            nbr = NumVerifyValidator.verifyPhoneNumber(con.HomePhone);
            con.Home_Phone_Type__c = nbr.getLineType();
            System.debug('Home Phone: ' + con.Home_Phone_Type__c);
        }

        if (!String.isEmpty(con.MobilePhone)) {
            nbr = NumVerifyValidator.verifyPhoneNumber(con.MobilePhone);
            con.Mobile_Phone_Type__c = nbr.getLineType();
            System.debug('Mobile Phone: ' + ' ' + con.Mobile_Phone_Type__c);
        }

        if (!String.isEmpty(con.OtherPhone)) {
            nbr = NumVerifyValidator.verifyPhoneNumber(con.OtherPhone);
            con.Other_Phone_Type__c = nbr.getLineType();
        }
    }

    /*
        Based on this algorithm:
        IF HomePhone Type = "Landline"
	        THEN Number1 = HomePhone
	    IF MobilePhone Type = "Mobile"
	        THEN Number2 = MobilePhone
	    IF OtherPhone Type = "Landline"
	        THEN Number3 = OtherPhone
	    IF HomePhone Type = "Mobile" and Number2 is empty
		    THEN Number2 = HomePhone
	    IF MobilePhone Type = "Landline" and Number1 is empty
		    THEN Number1 = MobilePhone
		ELSE IF Number3 is empty
		    THEN Number3 = MobilePhone			
	    IF OtherPhone Type = "Mobile" and Number2 is empty
	        THEN Number2 = OtherPhone
        
        set the CTI numbers based on above algorithm for the given Contact
     */
    @TestVisible
    private static void setCTINumbers(Contact con) {
        con.CTINumber1__c = '';
        con.CTINumber2__c = '';
        con.CTINumber3__c = '';

        if (con.Home_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            con.CTINumber1__c = con.HomePhone;
            System.debug('===:landline ' + con.CTINumber1__c);
        }

        if (con.Mobile_Phone_Type__c == NumVerifyValidator.MOBILE) {
            con.CTINumber2__c = con.MobilePhone;
            System.debug('===:mobile ' + con.CTINumber2__c);
        }

        if (con.Other_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            con.CTINumber3__c = con.OtherPhone;
            System.debug('===:other ' + con.CTINumber3__c);
        }

        if (con.Home_Phone_Type__c == NumVerifyValidator.MOBILE && String.isEmpty(con.CTINumber2__c)) {
            con.CTINumber2__c = con.HomePhone;
            System.debug('home-->mobile ' + con.CTINumber2__c);
        }

        if (con.Mobile_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            if (String.isEmpty(con.CTINumber1__c)) {
                con.CTINumber1__c = con.MobilePhone;
                System.debug('mobile-->landline ' + con.CTINumber1__c);
            } else if (String.isEmpty(con.CTINumber3__c)) {
                con.CTINumber3__c = con.MobilePhone;
                System.debug('other-->mobile ' + con.CTINumber3__c);
            }
        }

        if (con.Other_Phone_Type__c == NumVerifyValidator.MOBILE && String.isEmpty(con.CTINumber2__c)) {
            con.CTINumber2__c = con.OtherPhone;
            System.debug('mobile-->other' + con.CTINumber2__c);
        }
    }
}