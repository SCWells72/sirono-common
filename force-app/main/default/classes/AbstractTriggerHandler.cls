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
 * Shared base class for [trigger handlers](TriggerHandler). Derived classes should override all methods required to
 * handle registered DML timing and events.
 *
 * @see Trigger
 * @see TriggerHandler
 * @see TriggerHandlerDispatcher
 */
public abstract with sharing class AbstractTriggerHandler implements TriggerHandler {

    // Default/no-op implementations of the trigger event handler methods

    public virtual void beforeInsert() {
    }

    public virtual void afterInsert() {
    }

    public virtual void beforeUpdate() {
    }

    public virtual void afterUpdate() {
    }

    public virtual void beforeDelete() {
    }

    public virtual void afterDelete() {
    }

    public virtual void afterUndelete() {
    }

    /**
     * Extracts the value for the specified field from the provided object.
     *
     * @param obj the SObject from which the value should be extracted
     * @param field the field for which the value should be extracted
     *
     * @return the requested field value, or `null` if either the object or the field is `null`
     */
    @TestVisible protected Object getFieldValue(SObject obj, SObjectField field) {
        Object fieldValue = (obj != null) && (field != null) ? obj.get(field) : null;
        return fieldValue;
    }

    /**
     * Determines whether the specified field value has changed from the old object to the new object.
     *
     * @param oldObject the old object, typically from {@link Trigger.oldMap}
     * @param newObject the new object, typically from {@link Trigger.new}
     * @param field the field which should be checked for a value change
     *
     * @return `true` if the value has changed; otherwise `false`
     */
    @TestVisible protected Boolean fieldValueChanged(SObject oldObject, SObject newObject, SObjectField field) {
        Object oldValue = getFieldValue(oldObject, field);
        Object newValue = getFieldValue(newObject, field);
        return oldValue != newValue;
    }

    /**
     * Determines whether the specified field value has been set (changed from `null` to non-`null`)
     * on the new object.
     *
     * @param oldObject the old object, typically from {@link Trigger.oldMap}
     * @param newObject the new object, typically from {@link Trigger.new}
     * @param field the field which should be checked as being set
     *
     * @return `true` if the value has been set; otherwise `false`
     */
    @TestVisible protected Boolean fieldValueSet(SObject oldObject, SObject newObject, SObjectField field) {
        Object oldValue = getFieldValue(oldObject, field);
        Object newValue = getFieldValue(newObject, field);
        return (oldValue == null) && (newValue != null);
    }
}