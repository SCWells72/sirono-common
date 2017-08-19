/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
 * Test utilities to create records.
 */
@IsTest
public class PortalTestUtility {
    public static final String ACCOUNT_NAME = 'TestAccount';
    public static final String ADMIN_EMAIL = 'bruce.wayne@wayneenterprises.com';
    public static final Decimal PROFILE_POINTER = 999;

    private PortalTestUtility() {
        // Utility class
    }

    private static Decimal getUniqueId() {
        return Decimal.valueOf(Math.random());
    }

    // Return Guarantor Contact record
    public static Contact generateGuarantorContact() {
        return generateGuarantorContactByName('Test Guarantor');
    }

    // Return Guarantor Contact record
    public static Contact generateGuarantorContactByName(String gurantorName) {
        Contact guarantorContact = new Contact();
        guarantorContact.RecordTypeId = PortalRecordTypeUtil.guarantorRt;
        guarantorContact.LastName = gurantorName;
        guarantorContact.sPRS__Guarantor_Id__c = getUniqueId();
        return guarantorContact;
    }

    // Return Patient Contact record
    public static Contact generatePatientContact() {
        Contact patientContact = new Contact();
        patientContact.RecordTypeId = PortalRecordTypeUtil.patientRt;
        patientContact.LastName = 'Test Patient';
        patientContact.sPRS__Patient_Id__c = getUniqueId();
        return patientContact;
    }

    // Return charge group record
    public static sPRS__Charge_Group__c generateChargeGroup(String guarantorContactId,
        String patientContactId,
        Decimal chargeGroupExternalId,
        String paymentplanID) {
        sPRS__Charge_Group__c chargeGroup = generateChargeGroup(guarantorContactId, patientContactId, chargeGroupExternalId);
        chargeGroup.sPRS__Payment_Plan__c = paymentplanID;
        return chargeGroup;
    }

    // Return charge group record with external Id from parameter
    public static sPRS__Charge_Group__c generateChargeGroup(String guarantorContactId,
        String patientContactId,
        Decimal chargeGroupExternalId) {
        sPRS__Charge_Group__c cg = new sPRS__Charge_Group__c();
        cg.sPRS__Guarantor__c = guarantorContactId;
        cg.sPRS__Sirono_Id__c = getUniqueId();
        cg.sPRS__Patient__c = patientContactId;
        cg.sPRS__External_Id__c = String.valueOf(chargeGroupExternalId);
        cg.Name = 'Sirono';
        cg.sPRS__Reported_Selfpay_Balance__c = 10;
        cg.sPRS__Active__c = true;
        cg.sPRS__Account_Status__c = PortalConstants.ACCT_STATUS_BILLED;
        cg.sPRS__Account_Sub_Status__c = PortalConstants.ACCT_SUBSTATUS_PREINVOICED;

        return cg;
    }

    // Return Encounter record
    public static sPRS__Encounter__c generateEncounter(String guarantorId,
        Decimal patientPortion,
        Date serviceDate) {
        sPRS__Encounter__c encounter = new sPRS__Encounter__c(sPRS__Guarantor__c = guarantorId,
            sPRS__Patient_Portion__c = patientPortion,
            sPRS__Date_Of_Service__c = serviceDate);
        return encounter;
    }

    // Return a new Statement record
    public static sPRS__Statement__c generateStatement(String contactId) {
        sPRS__Statement__c stmt = new sPRS__Statement__c();
        stmt.sPRS__Statement_Date__c = System.today();
        stmt.sPRS__Guarantor__c = contactId;
        return stmt;
    }

    // Return a new payment plan record
    public static sPRS__Payment_Plan__c generatePaymentPlan(String guarantorId) {
        sPRS__Payment_Plan__c paymentPlan = new sPRS__Payment_Plan__c();
        paymentPlan.sPRS__Sirono_Id__c = getUniqueId();
        paymentPlan.sPRS__Guarantor__c = guarantorId;
        return paymentPlan;
    }

    // Return an Active PaymentPlan record
    public static sPRS__Payment_Plan__c generatePaymentPlan(Contact guarantor) {
        sPRS__Payment_Plan__c paymentPlan = generatePaymentPlan(guarantor.Id);
        paymentPlan.sPRS__Active__c = true;
        return paymentPlan;
    }

    // Return a new Invoice record
    public static sPRS__Invoice__c generateInvoice(String guarantorId, String patientId) {
        sPRS__Invoice__c invoice = new sPRS__Invoice__c();
        invoice.sPRS__Guarantor__c = guarantorId;
        invoice.sPRS__Due_Date__c = System.today();
        invoice.sPRS__Date__c = System.today();
        invoice.sPRS__Sirono_Id__c = getUniqueId();
        invoice.sPRS__Patient__c = patientId;
        return invoice;
    }

    // Return payment method record
    public static sPRS__Payment_Method__c generatePaymentMethod(String guarantorId, String recordTypeID) {
        sPRS__Payment_Method__c paymentMethod = new sPRS__Payment_Method__c();
        paymentMethod.sPRS__Guarantor__c = guarantorId;
        paymentMethod.RecordTypeId = recordTypeID;
        return paymentMethod;
    }

    public static Decimal generateRandomCurrency() {
        Double randomDouble = Math.random() * 100;
        Decimal randomCurrencyValue = Decimal.valueOf(randomDouble).setScale(2);

        return randomCurrencyValue;
    }
    private static sPRS__Payment__c generatePayment() {
        sPRS__Payment__c payment = new sPRS__Payment__c();
        payment.sPRS__Deposit_Date__c = System.today();
        return payment;
    }

    public static sPRS__Payment__c generateSironoPayment(Id guarantorId, Decimal sironoId, Decimal amount) {
        sPRS__Payment__c payment = generatePayment();
        payment.sPRS__Guarantor__c = guarantorId;
        payment.sPRS__Sirono_Id__c = sironoId;
        payment.sPRS__Amount__c = amount;
        return payment;
    }

    // Return a payment transaction
    public static sPRS__Transaction__c generatePaymentTxn(sPRS__Charge_Group__c chargeGroup,
        Decimal amount,
        sPRS__Payment__c pmt) {
        sPRS__Transaction__c objTransaction = generateTxn(chargeGroup, amount);
        objTransaction.sPRS__Payment__c = pmt.Id;
        return objTransaction;
    }

    // Return a service transaction
    public static sPRS__Transaction__c generateServiceTxn(sPRS__Charge_Group__c chargeGroup,
        Decimal amount,
        sPRS__Service2__c svc) {
        sPRS__Transaction__c objTransaction = generateTxn(chargeGroup, amount);
        objTransaction.sPRS__Post_Date__c = System.today().addDays(-7);
        objTransaction.sPRS__Service2__c = svc.Id;
        return objTransaction;
    }

    // Return an adjustment transaction
    public static sPRS__Transaction__c generateAdjTxn(sPRS__Charge_Group__c chargeGroup,
        Decimal amount,
        sPRS__Adjustment__c adj) {
        sPRS__Transaction__c objTransaction = generateTxn(chargeGroup, amount);
        objTransaction.sPRS__Adjustment2__c = adj.Id;

        // Check system assert.
        System.assertNotEquals(objTransaction, null, 'Should have failed due to Transaction object is null.');

        return objTransaction;
    }

    //Build a skeletal transaction
    private static sPRS__Transaction__c generateTxn(sPRS__Charge_Group__c chargeGroup, Decimal amount) {
        sPRS__Transaction__c txn = new sPRS__Transaction__c();
        txn.sPRS__Amount__c = amount == null ? 0 : amount;
        txn.sPRS__Charge_Group__c = chargeGroup.Id;
        txn.sPRS__Sirono_Id__c = getUniqueId();
        txn.sPRS__Post_Date__c = Date.today();
        txn.sPRS__Transaction_Date__c = System.today();
        return txn;
    }

    // Build and return a service record
    public static sPRS__Service2__c generateService(Contact guarantor, Decimal amount) {
        sPRS__Service2__c srv = new sPRS__Service2__c();
        srv.sPRS__Amount__c = amount;
        srv.sPRS__Guarantor__c = guarantor.Id;
        return srv;
    }


    /**
     * This method is use to create/generate a User using the given profile.
     *
     * @returns User newUser - That contains User
     **/
    //TODO refactor the other generate user methods to use this
    public static User generateUser(String profileName, Id gtId) {
        Profile prof = [SELECT Id FROM Profile WHERE Name = :profileName];
        String prefix = profileName.deleteWhitespace();
        prefix = prefix.substring(0, Math.min(8, prefix.length()));
        User newUser = new User(Alias = prefix, Email = prefix + '_user@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = prof.Id,
            ContactId = gtId,
            TimeZoneSidKey = 'America/Los_Angeles', Username = prefix + '_user@testorg.com');

        // Check system assert.
        System.assertNotEquals(newUser, null, 'Expected valid user, but is null.');

        return newUser;
    }

    /**
     * Utilty for getting a Guarantor Portal Community user.
     *
     * @return User - The User object assigned the profile of a user using the Guarantor Portal.
     */
    public static User getGuarantorCommunityUser() {
        String testUsername = UserInfo.getOrganizationId() + '-' + System.now().millisecond() + '-testGTUser@test.io';
        String testAdminUsername = UserInfo.getOrganizationId() + '-' + System.now().millisecond() + '-testAdmin@test.com';

        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User portalAdminUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = adminProfile.Id,
            Username = testAdminUsername,
            Alias = 'batman',
            Email = ADMIN_EMAIL,
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Bruce',
            LastName = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );

        Account a = null;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //Create portal account owner
            Database.insert(portalAdminUser);
            assignPermissionSets(portalAdminUser, PortalConstants.PERMISSION_SETS_SIRONO_ADMIN);

            //Create account
            a = new Account(Name = ACCOUNT_NAME, OwnerId = portalAdminUser.Id);
            Database.insert(a);
        }

        User usr;

        // Sometimes the user hasn't been cleared from the previous test, so if it still exists use it.
        List<User> users = [
            SELECT Alias, Email, EmailEncodingKey, FirstName, LastName, LanguageLocaleKey,
                LocaleSidKey, ProfileId, ContactId,
                TimeZoneSidKey, Username, Contact.sPRS__Guarantor_Id__c
            FROM User
            WHERE Username = :testUsername
            LIMIT 1
        ];

        if (users.size() > 0) {
            usr = users.get(0);
        } else {

            System.runAs(portalAdminUser) {
                //Create Guarantor Contact record
                Contact gt = PortalTestUtility.generateGuarantorContact();
                gt.sPRS__Guarantor_Id__c = PROFILE_POINTER;
                gt.AccountId = a.Id;
                gt.OwnerId = portalAdminUser.Id;
                Database.insert(gt);


                System.debug('Create portalUser for contact: ' + gt.Id);
                usr = PortalTestUtility.generateUser(PortalConstants.GUARANTOR_PORTAL_PROFILE, gt.Id);
                usr.Username = testUsername;

                insert usr;

                assignPermissionSets(usr, PortalConstants.PERMISSION_SETS_GUARANTOR);

                usr = null;
                usr = [
                    SELECT Id, Alias, Email, EmailEncodingKey, FirstName, LastName, LanguageLocaleKey,
                        LocaleSidKey, ProfileId, ContactId,
                        TimeZoneSidKey, Username, Contact.sPRS__Guarantor_Id__c
                    FROM User
                    WHERE Username = :testUsername
                    LIMIT 1
                ];

                System.assertNotEquals(usr, null, 'User with username: ' + testUsername + ' not found');
            }

            System.assertNotEquals(usr, null, 'User with username: ' + testUsername + ' not found');
        }
        return usr;
    }

    /**
     * Get the admin user associated with the getGuarantorCommunityUser user.
     *
     * @return Contact - The User used to created the GuarantorCommunityUser.
     */
    public static User getPortalAdminUser() {
        List<User> admin = [SELECT Id FROM User WHERE Email = :ADMIN_EMAIL LIMIT 1];

        System.assert(admin.size() != 0, 'Could not find the admin user that created the community user.');
        return admin[0];
    }


    /**
     * Get the guarantor associated with the Guarantor Community User.
     *
     * @return Contact - The Guarantor.
     */
    public static Contact getPortalGuarantor() {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE sPRS__Guarantor_Id__c = :PROFILE_POINTER];

        System.assert(contacts.size() != 0, 'Could not find the guarantor for the community user.');
        return contacts[0];
    }

    /**
     * Get the account assoicated with the GuarantorCommunityUser.
     *
     * @return Account - The account.
     */
    public static Account getPortalAccount() {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];

        System.assert(accounts.size() != 0, 'Could not find the account for the community user.');
        return accounts[0];
    }


    public static void assignPermissionSets(User appUser, String[] permSetNames) {
        // Give the user the given permission sets
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSets = [
            SELECT Id
            FROM PermissionSet
            WHERE Name IN :permSetNames
        ];
        System.assertEquals(permSetNames.size(), permissionSets.size(), 'Not all permission sets: ' + String.join(permSetNames, ', ') + ' found.');
        for (PermissionSet permissionSet : permissionSets) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId = appUser.Id,
                PermissionSetId = permissionSet.Id
            );
            permissionSetAssignments.add(permissionSetAssignment);
        }
        insert permissionSetAssignments;
    }
}