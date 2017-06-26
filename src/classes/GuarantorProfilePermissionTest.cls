/**
 * Test that a Guarantor Portal user can do all the things they need to
 */

@isTest
public with sharing class GuarantorProfilePermissionTest {

    @isTest
    // If I create the user in a setup method I cannot retrieve it in the test.
    // If everything is done in one method, the user can be retrieved. Go figure.
    // Verify that the user can read the sirono server NamedCredentials
    public static void readNamedCredentialsTest() {

        User usr = TestUtility.getGuarantorCommunityUser();

        System.runAs(usr) {
            Profile prof = [Select Id, Name from Profile where Id = :UserInfo.getProfileId()];
            System.debug('Reading as User: ' + UserInfo.getUserId() + ' with profile: ' + prof);

            String endpointURL = SironoRestClient.getEndpointString();
            System.assertNotEquals(endpointURL, null, 'Expected endpointURL string but got null');
        }
    }

    @isTest
    public static void readContact() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = ContactSecurityContext.SELECT_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Contact.');
            }
            System.assert(hasAccess, 'Should have read access to the Contact fields.');
        }
    }

    @isTest
    public static void readCaseRelatedContact() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = ContactSecurityContext.CU_SELECT_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Case related Contact.');
            }
            System.assert(hasAccess, 'Should have read access to the Case related Contact fields.');
        }
    }

    @isTest
    public static void readChargeGroup() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = ChargeGroupSecurityContext.GD_SELECT_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to ChargeGroup.');
            }
            System.assert(hasAccess, 'Should have access to the ChargeGroup fields.');
        }
    }

    @isTest
    public static void readCase() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Case.');
            }
            System.assert(hasAccess, 'Should have access to the case fields.');
        }
    }

    @isTest
    public static void readTransaction() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = TransactionSecurityContext.PPU_SELECT_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Transaction.');
            }
            System.assert(hasAccess, 'Should have access to the Transaction fields.');
        }
    }

    @isTest
    public static void readInvoiceDetail() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = InvoiceSecurityContext.DETAIL_CONTEXT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Invoice details.');
            }
            System.assert(hasAccess, 'Should have access to the Invoice details fields.');
        }
    }

    @isTest
    public static void selectPaymentMethod() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to Payment_Method__c.');
            }
            System.assert(hasAccess, 'Should have read access to the Payment_Method__c fields.');
        }
    }

    @isTest
    public static void selectPaymentPlan() {
        User usr = TestUtility.getGuarantorCommunityUser();
        System.runAs(usr) {
            Boolean hasAccess = false;
            try {
                hasAccess = PaymentPlanSecurityContext.GUARANTOR_SELECT.actionAllowed();
            } catch(Exception e) {
                System.assert(hasAccess, 'Should have had read access to PaymentPlan.');
            }
            System.assert(hasAccess, 'Should have access to the PaymentPlan fields.');
        }
    }
}