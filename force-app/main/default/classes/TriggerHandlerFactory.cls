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
 * Factory interface for creation of trigger handlers. Trigger handlers are created from triggers using:
 * <pre>
 * TriggerHandlerDispatcher.dispatch(<i>TriggerHandlerFactoryClassName</i>.class);
 * </pre>
 * The trigger handler dispatcher is then responsible for creating the trigger handler and determining the correct
 * method to invoke based on the trigger context.
 *
 * @see Trigger
 * @see TriggerHandler
 * @see TriggerHandlerDispatcher
 */
public interface TriggerHandlerFactory {

    /**
     * Creates a trigger handler for the current DML event.
     *
     * @param objects the list of SObjects
     * @param oldObjectsById the previous state of the SObjects (only provided when appropriate)
     *
     * @return a trigger handler instance to process the current DML event
     */
    TriggerHandler create(List<SObject> objects, Map<Id, SObject> oldObjectsById);
}