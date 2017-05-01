/*
* @author Sirono 
* @version 1.0.1
* @Date: 06-06-2016
* @ContactTriggerHandler Class used as a ContactTrigger Handler.
* 
* 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
*
* 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
*
* 10/31/2016: Sirono - Tracker #127517419  Callout to verify phone numbers
*/

public with sharing class ContactTriggerHandler {

    // Call checkCallListRemove method when the contact is inserted.        
    public static void afterInsert(List<Contact> newList) {
        checkCallListRemove(newList, null);
        //10/31/2016 tracker #127517419  after Insert verify Guarantor phone number
        validatePhoneNumbers(newList, null);
    }

    // Call checkCallListRemove, caseEarlyOutClose methods when the contact is updated.
    public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        checkCallListRemove(newList, oldMap);
        caseEarlyOutClose(newList, oldMap);
        callPopulateNextPaymentDate(newList, oldMap);
        //10/31/2016 tracker #127517419  after Update verify Guarantor phone number
        validatePhoneNumbers(newList,oldMap);
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
            CallListUtilities.PreCollectionCallListRemoval(contactMap.KeySet());
            CallListUtilities.EarlyOutCallListRemoval(contactMap.values());
        }
    }

    /*
     * Call caseEarlyOutClose method when the contact is updated.
     * 
     * 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
     *
     * 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign
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
     * 09-26-2016: Viraj Rana - Tracker # 127404425 
     * If contacts Offset is changed then we have to update the next payment date of playment plan object.
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
                                Execute_on_Day__c, NextPaymentDate__c,
                                Skip_Payment_Until__c
                        FROM Payment_Plan__c
                        WHERE Guarantor__c IN :contactId
                ];
                if (!paymentPlan.IsEmpty()) {
                    PaymentPlanTriggerHandler.populateNextPaymentDate(paymentPlan, false);
                }
            }
        }
    }
    
    //10/31/2016 tracker #127517419  after Insert or Update verify Guarantor phone number
    private static void validatePhoneNumbers(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : newContacts) {
            //Check Contact Record Type is Guarantor.
            if (con.RecordTypeId.equals(RecordTypeUtil.guarantorRt)) {
            	/* We change below conditions based on below criteria.
        	 * 1. If Contact is inserted check only number is not empty.
        	 * 2. If Contact is Updated Check Old and Updated number is different?
        	 * 3. We do this changes bz of If Contact have Phone number and update the contact with Phone number is empty.
        	 * at that time we need to change Pick List Value becomes Null/Empty.
        	 */
        	if (oldMap == null) {
        	    if (!String.isEmpty(con.MobilePhone) || !String.isEmpty(con.OtherPhone) || !String.isEmpty(con.HomePhone)) {
			contactIds.add(con.Id);
        	    }
        	} else if (oldMap.get(con.Id).MobilePhone != con.MobilePhone ||
				oldMap.get(con.Id).OtherPhone != con.OtherPhone ||
                        	oldMap.get(con.Id).HomePhone != con.HomePhone) {
		    contactIds.add(con.Id);
        	}
            }
        }
        if (contactIds.size() > 0) {
            verifyNumber(contactIds);
        }
    }
    
    //10/31/2016 tracker #127517419 future method that perfoms a callout to verify Guarantor phone number
    /*
    	This method get the numbers and phone types of Contacts based on given(Inserted, Updated) contact Ids.
    	After get contact list, we call methods to verify number and assign number into CTINumber field based on
    	    conditions for contacts.
	    When process was completed than update contact list. 
     */
    @future(callout = true)
    public static void verifyNumber(Set<Id> ids) {
        try {
            //12-09-2016: Viraj Rana : Check Sirono Settings is exists or not. If empty than create default Setting.
            SironoSettingsUtil.generatePhoneNumVerification();
            if (ContactSecurityContext.CTH_SELECT_CONTEXT.actionAllowed()) {
                List<Contact> contacts = [
                                          SELECT 
                                          Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c, 
                                          Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c, 
                                          CTINumber3__c 
                                          FROM Contact WHERE Id IN :ids
                                         ];

                for (Contact con: contacts) {
                    verifyContactPhoneNumbers(con);
                    setCTINumbers(con);
                }
                UPDATE contacts;
                System.debug('===:landline ' + contacts[0].CTINumber1__c);
            }
        } catch(Exception ex) {
        	System.debug('ex.getMessage(): ' + ex.getMessage());
        }
    }

    /*
        Send each of the contact's numbers to NumVerify to determine if the number is valid and what type it is
        (ie landline or mobile or invalid)
        TODO Should we be checking for duplicate numbers somewhere?
        We make Pick List value Null, based on NumVerifyValidator response we set Pick List value.
        NumVerifyValidator verify the number and return the line types and based on it we assign this value in pick list.
        If any one number(Home) is there in Contact at that time it will make request for all. (Home, Mobile, Other)
        	thats why we need to check particular number is empty or not.
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
        Based on the this algorithm:
            IF HomePhone Type = "Landline"
	        THEN Number1 = HomePhone
	    IF MobilePhone Type = "Mobile"
	        THEN Number2 = MobilePhone
	    IF OtherPhone Type = "Landline"
	        Then Number3 = OtherPhone
	    IF HomePhone Type = "Mobile" and Number2 is empty
		THEN Number2 = HomePhone
	    IF MobilePhone Type = "Landline"
	    	IF Number1 is empty
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

        if(con.Home_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            con.CTINumber1__c = con.HomePhone;
            System.debug('===:landline ' + con.CTINumber1__c);
        }

        if(con.Mobile_Phone_Type__c == NumVerifyValidator.MOBILE) {
            con.CTINumber2__c = con.MobilePhone;
            System.debug('===:mobile ' + con.CTINumber2__c);
        }

        if(con.Other_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            con.CTINumber3__c = con.OtherPhone;
            System.debug('===:other ' + con.CTINumber3__c);
        }

        if(con.Home_Phone_Type__c == NumVerifyValidator.MOBILE && String.isEmpty(con.CTINumber2__c)) {
            con.CTINumber2__c = con.HomePhone;
            System.debug('home-->mobile ' + con.CTINumber2__c);
        }

        if(con.Mobile_Phone_Type__c == NumVerifyValidator.LANDLINE) {
            if(String.isEmpty(con.CTINumber1__c)) {
                con.CTINumber1__c =  con.MobilePhone;
                System.debug('mobile-->landline ' + con.CTINumber1__c);
            } else if(String.isEmpty(con.CTINumber3__c)) {
                con.CTINumber3__c = con.MobilePhone;
                System.debug('other-->mobile ' + con.CTINumber3__c);
            }
        }

        if(con.Other_Phone_Type__c == NumVerifyValidator.MOBILE && String.isEmpty(con.CTINumber2__c)) {
            con.CTINumber2__c = con.OtherPhone;
            System.debug('mobile-->other' + con.CTINumber2__c);
        }
    }
}