/*
 * Copyright 2017-present Sirono LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Dispatches trigger-based events to implementations of <code>TriggerHandler</code> based on the current trigger context.
 *
 * @see Trigger
 * @see TriggerHandlerFactory
 * @see TriggerHandler
 */
public inherited sharing class TriggerHandlerDispatcher {
    private static final Logger LOG = Logger.getInstance(TriggerHandlerDispatcher.class);

    /**
     * Dispatch the current trigger event to a trigger handler created using the specified factory.
     *
     * @param factoryType the class for the trigger handler factory used to create the trigger handler
     */
    public static void dispatch(Type factoryType) {
        // Make sure this is running in the context of a trigger
        if (!isExecuting()) {
            String message = 'Trigger handler must only be invoked in the context of an executing trigger.';
            LOG.error(message);
            throw new IllegalStateException(message);
        }

        // Make sure a factory type was provided
        if (factoryType == null) {
            String message = 'Factory type must be specified.';
            LOG.error(message);
            throw new IllegalArgumentException(message);
        }

        // Instantiate the trigger handler factory
        Object instance = factoryType.newInstance();
        if (!(instance instanceof TriggerHandlerFactory)) {
            String message = 'Trigger handler factory must implement ' + TriggerHandlerFactory.class.getName() + '.';
            LOG.error(message);
            throw new IllegalArgumentException(message);
        }
        TriggerHandlerFactory factory = (TriggerHandlerFactory) instance;

        // Create the trigger handler
        TriggerHandler handler = factory.create(isDelete() ? Trigger.old : Trigger.new, Trigger.oldMap);
        if (handler == null) {
            String message = 'The trigger handler factory must create a trigger handler.';
            LOG.error(message);
            throw new IllegalStateException(message);
        }

        // Call the appropriate trigger handler method
        switch on getOperationType() {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
            when AFTER_INSERT {
                handler.afterInsert();
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
            when BEFORE_DELETE {
                handler.beforeDelete();
            }
            when AFTER_DELETE {
                handler.afterDelete();
            }
            when AFTER_UNDELETE {
                handler.afterUndelete();
            }
        }
    }

    /**
     * Specifies the trigger event when the TriggerHandlerDispatcher is mocked.
     */
    private static TriggerOperation mockOperationType = null;

    /**
     * Mocks the TriggerHandlerDispatcher so that it operated as if it is within a trigger context.
     *
     * @param operationType the trigger event
     */
    public static void mock(TriggerOperation operationType) {
        if (!Test.isRunningTest()) {
            String message = 'TriggerHandlerDispatcher may only be mocked in a test.';
            LOG.error(message);
            throw new IllegalStateException(message);
        }

        mockOperationType = operationType;
    }

    /**
     * Gets the trigger event, either from the trigger context or as specified when mocked.
     *
     * @return the trigger event
     */
    private static TriggerOperation getOperationType() {
        return mockOperationType != null ? mockOperationType : Trigger.operationType;
    }

    /**
     * Determines whether operating in a trigger context or if mocked as if operating in a trigger context.
     *
     * @return whether operating in a trigger context or if mocked as if operating in a trigger context
     */
    private static Boolean isExecuting() {
        return mockOperationType != null ? true : Trigger.isExecuting;
    }

    /**
     * Determines whether the trigger event is a delete.
     *
     * @return whether the trigger event is a delete
     */
    private static Boolean isDelete() {
        return mockOperationType != null ?
            mockOperationType == TriggerOperation.BEFORE_DELETE || mockOperationType == TriggerOperation.AFTER_DELETE :
            Trigger.isDelete;
    }
}