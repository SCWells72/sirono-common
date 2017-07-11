/**
 * @description A service class that manages Task object communication between classes and the database.
**/

public with sharing class TaskService extends AbstractService {
    /**
     * @description upsertValidatedTasks takes a list of Task objects, validates the WhoIds, and upserts Tasks that
     * have passed validation. Currently, nothing happens with Tasks that aren't validated.
     *
     * @param taskList list of tasks that need to validated and upserted
    **/
    public static void insertValidatedTasks(List<Task> taskList) {
        if (taskList.size() == 0) {
            throw new Five9ReportingException('There are no tasks to insert.');
        }

        // Put WhoIds from all Tasks into a set to be validated
        Set<Id> taskIdSet = new Set<Id>();
        for (Task task: taskList) {
            taskIdSet.add(task.WhoId);
        }

        // Validate the WhoIds and put the results into a map
        Map<Id, Contact> validTaskWhoIds = TaskDao.getValidWhoIds(taskIdSet);

        // Create a new Task list for only those Tasks that pass validation and upsert
        List<Task> validatedTaskList = new List<Task>();
        for (Task task: taskList) {
            if (validTaskWhoIds.containsKey(task.WhoId)) {
                validatedTaskList.add(task);
            }
        }

        if (validatedTaskList.size() > 0) {
            TaskDao.insertTasks(validatedTaskList);
        }
    }

    /**
     * @description getNewTasks returns only those tasks whose SessionId isn't found in the database. (The Five9 session
     * Id field is part of a managed package and therefore cannot be used as an external Id for upsert purposes.)
    **/
    public static List<Task> getNewTasks(List<Task> taskList) {
        // Put Five9 session Ids into a new Set and retrieve tasks by session Id
        Set<String> sessionIdSet = new Set<String>();
        for (Task task: taskList) {
            sessionIdSet.add(task.Five9__Five9SessionId__c);
        }

        // Get any existing tasks with session Ids and put into a map
        Map<String, Task> existingSessionIds = TaskDao.getTasksBySessionId(sessionIdSet);
        System.debug('>>>>> Existing session Ids: ' + existingSessionIds.keySet());

        // Loop through the taskList and see if any of the session Ids were returned. If not, add the task to newTaskList
        // and return.
        List<Task> newTaskList = new List<Task>();
        for (Task task: taskList) {
            if (!existingSessionIds.containsKey(task.Five9__Five9SessionId__c)) {
                newTaskList.add(task);
            }
        }

        return newTaskList;
    }


}