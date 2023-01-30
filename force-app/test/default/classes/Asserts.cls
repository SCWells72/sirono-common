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
 * Additional high-level assertions beyond those offered by {@link System.Assert}.
 */
@IsTest
public with sharing class Asserts {

    private Asserts() {
        // Utility class
    }

    /**
     * Verifies that the provided exception's message starts with the expected message up to any embedded
     * formatting specifiers.
     *
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual exception which should be verified against the expected message
     */
    public static void hasExceptionMessage(String expectedMessage, Exception actualException) {
        Assert.isNotNull(expectedMessage, 'Null expected message.');
        Assert.isNotNull(actualException, 'Null actual exception.');
        Assert.isNotNull(actualException.getMessage(), 'Null actual exception message.');
        Assert.isTrue(checkExceptionMessage(expectedMessage, actualException.getMessage()), '"' + actualException.getMessage() + '" does not contain "' + expectedMessage + '".');
    }

    /**
     * Verifies that the provided {@link DmlException}'s message starts with the expected message up to any embedded
     * formatting specifiers. If the optional field is specified, the message is verified specifically for that field.
     * Otherwise the object-level message is verified.
     *
     * @param expectedField the optional field which should be verified for the message
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual DML exception which should be verified against the expected message
     *
     * @see DmlException
     */
    public static void hasDmlExceptionMessage(SObjectField expectedField, String expectedMessage, DmlException actualException) {
        Assert.isNotNull(expectedMessage, 'Null expected message.');
        Assert.isNotNull(actualException, 'Null actual exception.');

        Boolean matched = false;
        for (Integer i = 0; i < actualException.getNumDml() && !matched; i++) {
            List<SObjectField> dmlFields = actualException.getDmlFields(i);
            if (((expectedField == null) && CollectionUtil.isEmpty(dmlFields)) ||
                dmlFields.contains(expectedField)) {
                String actualMessage = actualException.getDmlMessage(i);
                matched = checkExceptionMessage(expectedMessage, actualMessage);
            }
        }

        Assert.isTrue(matched, 'Failed to find "' + expectedMessage + '" in the provided DmlException.');
    }

    /**
     * Verifies that the provided {@link DmlException}'s object-level message for starts with the expected message up
     * to any embedded formatting specifiers.
     *
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     * @param actualException the actual DML exception which should be verified against the expected message
     *
     * @see DmlException
     */
    public static void hasDmlExceptionMessage(String expectedMessage, DmlException actualException) {
        hasDmlExceptionMessage(null, expectedMessage, actualException);
    }

    /**
     * Verifies that the specified field has an error with the specified message via page messages (which were
     * populated via adding errors to the fields during DML or via validation rules). This is done instead of
     * checking the {@link DmlException} directly because when those exceptions are nested--typically from
     * a trigger handler performing additional DML--we can't get at the original exception details.
     *
     * @param expectedField the optional field which should be verified for the message
     * @param expectedMessage the expected message which may include embedded formatting specifiers
     *
     * @see ApexPages.Message
     * @see DmlException
     */
    public static void hasPageMessage(SObjectField expectedField, String expectedMessage) {
        Assert.isNotNull(expectedField, 'Null expected field.');
        Assert.isNotNull(expectedMessage, 'Null expected message.');

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

        Assert.isTrue(matched, 'Failed to find "' + expectedMessage + '" for field "' + expectedFieldName + '" in the page messages.');
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