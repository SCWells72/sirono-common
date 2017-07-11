/**
 * @description Tests for TaskService class.
**/

@isTest
public with sharing class TaskServiceTest {
    @testSetup
    public static void setup() {
        List<Contact> guarantorList = new List<Contact>();
        for (Integer i = 0; i < 3; i ++) {
            Contact guarantor = TestUtility.generateGuarantorContact();
            guarantorList.add(guarantor);
        }
        insert guarantorList;
    }

    /**
     * @description Test attempt to insert tasks with fake Salesforce whoIds.
    **/
    @isTest
    public static void catchInvalidTasksTest() {
        Test.startTest();
        List<Contact> guarantors = new List<Contact>([
                SELECT Id
                FROM Contact
        ]);

        List<Task> invalidTaskList = new List<Task>();

        for (Contact guarantor: guarantors) {
            Task task = new Task();
            // Alter the last letter of an existing Salesforce Id to create a fake WhoId
            task.WhoId = String.valueOf(guarantor.Id).left(17) + 'z';
            invalidTaskList.add(task);
        }

        TaskService.insertValidatedTasks(invalidTaskList);

        List<Task> insertedTasks = new List<Task>([
                SELECT Id
                FROM Task
        ]);
        test.stopTest();

        System.assertEquals(0, insertedTasks.size());

    }

    /**
     * @description Test attempt to insert valid tasks.
    **/
    @isTest
    public static void insertValidTasksTest() {
        Test.startTest();
        List<Contact> guarantors = new List<Contact>([
                SELECT Id
                FROM Contact
        ]);

        List<Task> taskList = new List<Task>();

        for (Contact guarantor: guarantors) {
            Task task = new Task();
            task.WhoId = guarantor.Id;
            taskList.add(task);
        }

        TaskService.insertValidatedTasks(taskList);

        List<Task> insertedTasks = new List<Task>([
                SELECT Id
                FROM Task
        ]);
        test.stopTest();

        System.assertEquals(taskList.size(), insertedTasks.size());
    }

    /**
     * @description Test attempt to insert tasks with and without a Session Id that already exists. Make sure only tasks
     * without an existing Session Id are returned.
    **/
    @isTest
    public static void insertTasksWithExistingSessionIds() {
        Test.startTest();
        List<Contact> guarantors = new List<Contact>([
                SELECT Id
                FROM Contact
        ]);

        List<Task> taskList = new List<Task>();

        // Create new tasks and assign them a session Id
        for (Integer i = 0; i < guarantors.size(); i++) {
            Task task = new Task();
            task.WhoId = guarantors[i].Id;
            task.Five9__Five9SessionId__c = String.valueOf(i);
            System.debug('>>>>> Five9 Session Id: ' + task.Five9__Five9SessionId__c);
            taskList.add(task);
        }

        insert taskList;

        // Create new tasks with new session Ids, add to taskList and then call getNewTasks on taskList
        List<String> stringList = new List<String>{'a', 'b', 'c'};
        for (Integer i = 0; i < guarantors.size(); i++) {
            Task task = new Task();
            task.WhoId = guarantors[i].Id;
            task.Five9__Five9SessionId__c = String.valueOf(i) + stringList[i];
            System.debug('>>>>> Five9 Session Id: ' + task.Five9__Five9SessionId__c);
            taskList.add(task);
        }

        List<Task> newTasks = TaskService.getNewTasks(taskList);

        Test.stopTest();

        System.assertEquals(3, newTasks.size());
    }
}