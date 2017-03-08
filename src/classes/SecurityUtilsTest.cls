/**
 * This Test class use to test the logic of SecurityUtils and SecurityContext class.
 **/

@isTest
public class SecurityUtilsTest {

    /**
     * This method tests Create Rights for provided CREATE_CONTEXT for Valid/Not-Valid User.
     **/
    static testMethod void checkCreateRightsAllowed() {

        // Create User as a Read Only Profile User.
        Profile readOnlyProf = [SELECT Id FROM Profile WHERE Name =:Constants.READ_ONLY_PROFILE];
        User readOnlyUser = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = readOnlyProf.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testjohn@acme.com');

	// Check Create Rights for Read Only Profile User using runAs.
	System.runAs(readOnlyUser) {
	    try {
	        CaseSecurityContext.CREATE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Create rights'), 'Check Create Rights');
	    }
	}
        // Check Create Rights without runAs User/System Administrator.
        Boolean hasCreateRights = CaseSecurityContext.CREATE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasCreateRights, 'Check create rights');
    }

    /**
     * This method tests Update Rights for provided UPDATE_CONTEXT for Valid/Not-Valid User.
     **/
    static testMethod void checkUpdateRightsAllowed() {

        // Create User as a Read Only Profile User.
        Profile readOnlyProf = [SELECT Id FROM Profile WHERE Name =:Constants.READ_ONLY_PROFILE];
        User readOnlyUser = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = readOnlyProf.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testjohn@acme.com');

        // Check Update Rights for Read Only Profile User using runAs.
        System.runAs(readOnlyUser) {
	    try {
	        CaseSecurityContext.UPDATE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Update rights'), 'Check Update Rights');
	    }
        }
        // Check Update Rights without runAs User/System Administrator.
        Boolean hasUpdateRights = CaseSecurityContext.UPDATE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasUpdateRights, 'Check Update rights');
    }

    /**
     * This method tests Delete Rights for provided DELETE_CONTEXT for Valid/Not-Valid User.
     **/
    static testMethod void checkDeleteRightsAllowed() {

        // Create User as a Read Only Profile User.
        Profile readOnlyProf = [SELECT Id FROM Profile WHERE Name =:Constants.READ_ONLY_PROFILE];
        User readOnlyUser = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = readOnlyProf.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testjohn@acme.com');

        // Check Delete Rights for Read Only Profile User using runAs.
        System.runAs(readOnlyUser) {
	    try {
	        CaseSecurityContext.DELETE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Delete rights'), 'Check Delete Rights');
	    }
        }
        // Check Delete Rights without runAs User/System Administrator.
        Boolean hasDeleteRights = CaseSecurityContext.DELETE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasDeleteRights, 'Check Delete rights');
    }

    /**
     * This method tests Upsert Rights for provided UPSERT_CONTEXT for Valid/Not-Valid User.
     **/
    static testMethod void checkUpsertRightsAllowed() {

        // Create User as a Read Only Profile User.
        Profile readOnlyProf = [SELECT Id FROM Profile WHERE Name =:Constants.READ_ONLY_PROFILE];
        User readOnlyUser = new User(Alias = 'admin', Email = 'adminuser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = readOnlyProf.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testjohn@acme.com');

        // Check Upsert Rights for Read Only Profile User using runAs.
        System.runAs(readOnlyUser) {
	    try {
	        CaseSecurityContext.UPSERT_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert.
	        System.assert(ex.getMessage().contains('You do not have Upsert rights'), 'Check Upsert Rights');
	    }
        }
        // Check Upsert Rights without runAs User/System Administrator.
        Boolean hasUpsertRights = CaseSecurityContext.UPSERT_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasUpsertRights, 'Check Upsert rights');
    }
}