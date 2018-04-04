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

@IsTest
private class AbstractTriggerHandlerTest {
    @IsTest
    static void testGetFieldValue() {
        TestTriggerHandler triggerHandler = new TestTriggerHandler();

        // Happy path
        Contact c = new Contact(LastName = 'Foo');
        Object lastNameValue = triggerHandler.getFieldValue(c, Contact.LastName);
        Assert.equals('Foo', lastNameValue);

        // Null handling
        Assert.isNull(triggerHandler.getFieldValue(null, null));
        Assert.isNull(triggerHandler.getFieldValue(c, null));
        Assert.isNull(triggerHandler.getFieldValue(null, Contact.LastName));

        // Invalid field for type
        try {
            triggerHandler.getFieldValue(c, Account.AccountNumber);
            Assert.fail('Expected an ' + SObjectException.class.getName());
        } catch (SObjectException e) {
            // Expected
        }
    }

    @IsTest
    static void testFieldValueChanged() {
        TestTriggerHandler triggerHandler = new TestTriggerHandler();

        Contact oldContact = new Contact(FirstName = 'Baz', LastName = 'Foo');
        Contact newContact = new Contact(FirstName = 'Baz', LastName = 'Bar');

        // Happy path
        Assert.isTrue(triggerHandler.fieldValueChanged(oldContact, newContact, Contact.LastName));
        Assert.isFalse(triggerHandler.fieldValueChanged(oldContact, newContact, Contact.FirstName));

        // Null handling
        Assert.isFalse(triggerHandler.fieldValueChanged(null, null, null));
        Assert.isFalse(triggerHandler.fieldValueChanged(oldContact, null, null));
        Assert.isFalse(triggerHandler.fieldValueChanged(null, newContact, null));
        Assert.isFalse(triggerHandler.fieldValueChanged(null, null, Contact.LastName));
        Assert.isFalse(triggerHandler.fieldValueChanged(oldContact, newContact, null));
        Assert.isTrue(triggerHandler.fieldValueChanged(null, newContact, Contact.LastName));
        Assert.isTrue(triggerHandler.fieldValueChanged(oldContact, null, Contact.LastName));

        // Invalid field for type
        try {
            triggerHandler.fieldValueChanged(oldContact, newContact, Account.AccountNumber);
            Assert.fail('Expected an ' + SObjectException.class.getName());
        } catch (SObjectException e) {
            // Expected
        }
    }

    @IsTest
    static void testFieldValueSet() {
        TestTriggerHandler triggerHandler = new TestTriggerHandler();

        Contact oldContact = new Contact(FirstName = null, LastName = 'Foo');
        Contact newContact = new Contact(FirstName = 'Baz', LastName = 'Bar');

        // Happy path
        Assert.isTrue(triggerHandler.fieldValueSet(oldContact, newContact, Contact.FirstName));
        Assert.isFalse(triggerHandler.fieldValueSet(oldContact, newContact, Contact.LastName));

        // Null handling
        Assert.isFalse(triggerHandler.fieldValueSet(null, null, null));
        Assert.isFalse(triggerHandler.fieldValueSet(oldContact, null, null));
        Assert.isFalse(triggerHandler.fieldValueSet(null, newContact, null));
        Assert.isFalse(triggerHandler.fieldValueSet(null, null, Contact.FirstName));
        Assert.isFalse(triggerHandler.fieldValueSet(oldContact, newContact, null));
        Assert.isTrue(triggerHandler.fieldValueSet(null, newContact, Contact.FirstName));
        Assert.isFalse(triggerHandler.fieldValueSet(oldContact, null, Contact.FirstName));

        // Invalid field for type
        try {
            triggerHandler.fieldValueSet(oldContact, newContact, Account.AccountNumber);
            Assert.fail('Expected an ' + SObjectException.class.getName());
        } catch (SObjectException e) {
            // Expected
        }
    }

    private class TestTriggerHandler extends AbstractTriggerHandler {
    }
}