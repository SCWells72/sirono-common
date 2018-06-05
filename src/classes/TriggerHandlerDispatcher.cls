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
public with sharing class TriggerHandlerDispatcher {
    private static final Logger LOG = Logger.getInstance(TriggerHandlerDispatcher.class);

    /**
     * Dispatch the current trigger event to a trigger handler created using the specified factory.
     *
     * @param factoryType the class for the trigger handler factory used to create the trigger handler
     */
    public static void dispatch(Type factoryType) {
        // Make sure this is running in the context of a trigger
        if (!Trigger.isExecuting) {
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
        TriggerHandler handler = factory.create(Trigger.isDelete ? Trigger.old : Trigger.new, Trigger.oldMap);
        if (handler == null) {
            String message = 'The trigger handler factory must create a trigger handler.';
            LOG.error(message);
            throw new IllegalStateException(message);
        }

        // Call the appropriate trigger handler method
        // TODO: Update this to use switch once Summer '18 is available
        if (Trigger.isBefore && Trigger.isInsert) {
            handler.beforeInsert();
        } else if (Trigger.isAfter && Trigger.isInsert) {
            handler.afterInsert();
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            handler.beforeUpdate();
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            handler.afterUpdate();
        } else if (Trigger.isBefore && Trigger.isDelete) {
            handler.beforeDelete();
        } else if (Trigger.isAfter && Trigger.isDelete) {
            handler.afterDelete();
        } else if (Trigger.isAfter && Trigger.isUndelete) {
            handler.afterUndelete();
        }
    }
}