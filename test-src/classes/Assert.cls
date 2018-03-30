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
 * Utility functions to streamline assertions in tests.
 */
@IsTest
public with sharing class Assert {

    private Assert() {
        // Utility class
    }

    /**
     * Assert that the given object is false.
     *
     * @param obj The object to check.
     */
    public static void isFalse(Object obj) {
        isFalse(obj, '');
    }

    /**
     * Assert that the given object is false.
     *
     * @param obj The object to check.
     * @param message Custom message returned as part of the error message.
     */
    public static void isFalse(Object obj, String message) {
        System.assertEquals(false, obj, message);
    }

    /**
     * Used to indicate that a test has arrived in a state where it should fail.
     *
     * @param message Custom message returned as part of the error message.
     */
    public static void fail(String message) {
        System.assert(false, message);
    }

    /**
     * Verifies that the specified value is null.
     *
     * @param obj The object to check.
     */
    public static void isNull(Object obj) {
        isNull(obj, '');
    }

    /**
     * Verifies that the specified value is null.
     *
     * @param obj The object to check.
     * @param message Custom message returned as part of the error message.
     */
    public static void isNull(Object obj, String message) {
        System.assertEquals(null, obj, message);
    }

    /**
     * Verifies that the specified value is not null.
     *
     * @param obj The object to check.
     */
    public static void notNull(Object obj) {
        notNull(obj, '');
    }

    /**
     * Verifies that the specified value is not null.
     *
     * @param obj The object to check.
     * @param message Custom message returned as part of the error message.
     */
    public static void notNull(Object obj, String message) {
        System.assertNotEquals(null, obj, message);
    }

    /**
     * Verifies that the provided exception's message starts with the expected message up to any embedded
     * formatting specifiers.
     *
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual exception which should be verified against the expected message
     */
    public static void exceptionMessage(String expectedMessage, Exception actualException) {
        Assert.notNull(expectedMessage, 'Null expected message.');
        Assert.notNull(actualException, 'Null actual exception.');
        Assert.notNull(actualException.getMessage(), 'Null actual exception message.');
        System.assert(checkExceptionMessage(expectedMessage, actualException.getMessage()), '"' + actualException.getMessage() + '" does not contain "' + expectedMessage + '".');
    }

    /**
     * Verifies that the provided DML exception's message starts with the expected message up to any embedded
     * formatting specifiers. If the optional field is specified, the message is verified specifically for that field.
     * Otherwise the object-level message is verified.
     *
     * @param expectedField the optional field which should be verified for the message
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual DML exception which should be verified against the expected message
     *
     * @see DmlException
     */
    public static void dmlExceptionMessage(SObjectField expectedField, String expectedMessage, DmlException actualException) {
        Assert.notNull(expectedMessage, 'Null expected message.');
        Assert.notNull(actualException, 'Null actual exception.');

        Boolean matched = false;
        for (Integer i = 0; i < actualException.getNumDml() && !matched; i++) {
            List<SObjectField> dmlFields = actualException.getDmlFields(i);
            if (((expectedField == null) && CollectionUtil.isEmpty(dmlFields)) ||
                dmlFields.contains(expectedField)) {
                String actualMessage = actualException.getDmlMessage(i);
                matched = checkExceptionMessage(expectedMessage, actualMessage);
            }
        }

        System.assert(matched, 'Failed to find "' + expectedMessage + '" in the provided DmlException.');
    }

    /**
     * Verifies that the provided DML exception's object-level message for starts with the expected message up to
     * any embedded formatting specifiers.
     *
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual DML exception which should be verified against the expected message
     *
     * @see DmlException
     */
    public static void dmlExceptionMessage(String expectedMessage, DmlException actualException) {
        dmlExceptionMessage(null, expectedMessage, actualException);
    }

    /**
     * Verifies that the specified field has an error with the specified message via page messages (which were
     * populated via adding errors to the fields during DML or via validation rules). This is done instead of
     * checking the <code>DmlException</code> directly because when those exceptions are nested--typically from
     * a trigger handler performing additional DML--we can't get at the original exception details.
     *
     * @param expectedField the optional field which should be verified for the message
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     *
     * @see ApexPages.Message
     * @see DmlException
     */
    public static void pageMessage(SObjectField expectedField, String expectedMessage) {
        Assert.notNull(expectedField, 'Null expected field.');
        Assert.notNull(expectedMessage, 'Null expected message.');

        Boolean matched = false;
        String expectedFieldName = expectedField.getDescribe().getLabel();
        List<ApexPages.Message> messages = ApexPages.getMessages();
        if (messages != null) {
            for (ApexPages.Message message : messages) {
                String actualFieldName = message.getComponentLabel();
                if (expectedFieldName == actualFieldName) {
                    String actualMessage = message.getDetail();
                    matched = checkExceptionMessage(expectedMessage, actualMessage);
                    if (matched) {
                        break;
                    }
                }
            }
        }

        System.assert(matched, 'Failed to find "' + expectedMessage + '" for field "' + expectedFieldName + '" in the page messages.');
    }

    private static Boolean checkExceptionMessage(String expectedMessage, String actualMessage) {
        if (String.isNotBlank(actualMessage) && String.isNotBlank(actualMessage)) {
            // Extract the portion of the provided message before the first embedded formatting specifier and make sure
            // that the actual exception message contains that string
            // TODO: Another way to do this would be to replace all "{\d+}" in the source string with ".*?" and then use
            // TODO: that as a regular expression for testing the expression message. That might be more accurate, but
            // TODO: my guess is that for these messages, it's really not going to be so much better that the change
            // TODO: is warranted.
            String expectedMessageStem = expectedMessage.replaceFirst('([^\\{]*)\\{.*', '$1');
            return actualMessage.contains(expectedMessageStem);
        } else {
            // TODO: Should this return true since we're dealing with two blank messages? Seems like you'd never want
            // TODO: that so fail and make the caller look at why that would be happening.
            return false;
        }
    }
}