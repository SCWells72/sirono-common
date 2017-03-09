/**
 * This Test class use to test the logic of SecurityUtils and SecurityContext class.
 **/

@isTest
public class SecurityUtilsTest {

    /**
     * This method tests Create Rights for provided CREATE_CONTEXT for Valid/Not-Valid User.
     **/
    @isTest
    static void checkCreateRightsAllowed() {
        // Check Create Rights for Read Only User using runAs.
	System.runAs(TestUtility.generateReadOnlyUser()) {
	    try {
	        CaseSecurityContext.CREATE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Create rights'), 'Check Create Rights');
	    }
	}
		
        // Check Create Rights without runAs Read Only User.
        Boolean hasCreateRights = CaseSecurityContext.CREATE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasCreateRights, 'Check create rights');
    }

    /**
     * This method tests Update Rights for provided UPDATE_CONTEXT for Valid/Not-Valid User.
     **/
    @isTest
    static void checkUpdateRightsAllowed() {
        // Check Update Rights for Read Only User using runAs.
        System.runAs(TestUtility.generateReadOnlyUser()) {
	    try {
	        CaseSecurityContext.UPDATE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Update rights'), 'Check Update Rights');
	    }
        }
        
        // Check Update Rights without runAs Read Only User.
        Boolean hasUpdateRights = CaseSecurityContext.UPDATE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasUpdateRights, 'Check Update rights');
    }

    /**
     * This method tests Delete Rights for provided DELETE_CONTEXT for Valid/Not-Valid User.
     **/
    @isTest
    static void checkDeleteRightsAllowed() {
        // Check Delete Rights for Read Only User using runAs.
        System.runAs(TestUtility.generateReadOnlyUser()) {
	    try {
	        CaseSecurityContext.DELETE_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	        // Check System assert
	        System.assert(ex.getMessage().contains('You do not have Delete rights'), 'Check Delete Rights');
	    }
        }
        
        // Check Delete Rights without runAs Read Only User.
        Boolean hasDeleteRights = CaseSecurityContext.DELETE_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasDeleteRights, 'Check Delete rights');
    }

    /**
     * This method tests Upsert Rights for provided UPSERT_CONTEXT for Valid/Not-Valid User.
     **/
    @isTest
    static void checkUpsertRightsAllowed() {
        // Check Upsert Rights for Read Only User using runAs.
        System.runAs(TestUtility.generateReadOnlyUser()) {
	    try {
	        CaseSecurityContext.UPSERT_CONTEXT.actionAllowed();
	    }
	    catch (exception ex) {
	    	// Check System assert.
	        System.assert(ex.getMessage().contains('You do not have Upsert rights'), 'Check Upsert Rights');
	    }
        }
        
        // Check Upsert Rights without runAs Read Only User.
        Boolean hasUpsertRights = CaseSecurityContext.UPSERT_CONTEXT.actionAllowed();
        // Check System assert
        System.assert(hasUpsertRights, 'Check Upsert rights');
    }
}