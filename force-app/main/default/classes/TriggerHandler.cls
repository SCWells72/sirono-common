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
 * Common interface for trigger handlers. Trigger handlers are created by the trigger handler dispatcher using trigger
 * handler factories in response to DML events. The trigger handler dispatcher is then responsible for determining the
 * correct method to invoke based on the trigger context.
 *
 * @see Trigger
 * @see TriggerHandlerFactory
 * @see TriggerHandlerDispatcher
 */
public interface TriggerHandler {

    /**
     * Called before inserting SObjects.
     */
    void beforeInsert();

    /**
     * Called after inserting SObjects.
     */
    void afterInsert();

    /**
     * Called before updating SObjects.
     */
    void beforeUpdate();

    /**
     * Called after updating SObjects.
     */
    void afterUpdate();

    /**
     * Called before deleting SObjects.
     */
    void beforeDelete();

    /**
     * Called after deleting SObjects.
     */
    void afterDelete();

    /**
     * Called after restoring SObjects.
     */
    void afterUndelete();
}