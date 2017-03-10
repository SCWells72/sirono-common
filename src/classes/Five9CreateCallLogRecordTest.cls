/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-02-2016
 */

@isTest
public class Five9CreateCallLogRecordTest {

    @isTest
    static void main() {
	    Contact guarantorContact = TestUtility.generateGuarantorContact();
	    insert guarantorContact;

	    apexpages.currentPage().getParameters().put('Five9_ANI', 'A');
	    apexpages.currentPage().getParameters().put('Five9_DNIS', 'B');
	    apexpages.currentPage().getParameters().put('Salesforce_Id', guarantorContact.Id);
	    apexpages.currentPage().getParameters().put('Call_disposition', 'C');
	    apexpages.currentPage().getParameters().put('session_id', 'D');
	    apexpages.currentPage().getParameters().put('endTimestamp', 'E');
	    apexpages.currentPage().getParameters().put('callTypeName', 'F');
	    apexpages.currentPage().getParameters().put('campaignName', 'G');
	    apexpages.currentPage().getParameters().put('startTimestamp', 'H');
	    apexpages.currentPage().getParameters().put('fullName', 'I');

	    Five9CreateCallLogRecord cc = new Five9CreateCallLogRecord();
	    cc.doAction();

		List<ApexPages.Message> msgList = ApexPages.getMessages();
		System.assertEquals(0, msgList.size());
	}
	
    @isTest
    static void main1() {
		Contact guarantorContact = TestUtility.generateGuarantorContact();
		insert guarantorContact;

		apexpages.currentPage().getParameters().put('Five9_ANI', 'A');
		apexpages.currentPage().getParameters().put('Five9_DNIS', 'B');
		apexpages.currentPage().getParameters().put('Salesforce_Id', '');
		apexpages.currentPage().getParameters().put('Call_disposition', 'C');
		apexpages.currentPage().getParameters().put('session_id', 'D');
		apexpages.currentPage().getParameters().put('endTimestamp', 'E');
		apexpages.currentPage().getParameters().put('callTypeName', 'F');
		apexpages.currentPage().getParameters().put('campaignName', 'G');
		apexpages.currentPage().getParameters().put('startTimestamp', 'H');
		apexpages.currentPage().getParameters().put('fullName', 'I');

		Five9CreateCallLogRecord cc = new Five9CreateCallLogRecord();
		cc.doAction();

		List<ApexPages.Message> msgList = ApexPages.getMessages();
		System.assertEquals(2, msgList.size());
	}
	
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<TaskSecurityContext> allContexts = new List<TaskSecurityContext>{TaskSecurityContext.CREATE_CONTEXT,
        	TaskSecurityContext.UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (TaskSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}