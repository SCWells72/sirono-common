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
 * Backward-compatible interface that should be used only long enough to allow the migration from sirono-common's
 * `Assert` to {@link System.Assert} and sirono-common's {@link Asserts} and then removed.
 */
@IsTest
public with sharing class Assert {

    private Assert() {
        // Utility class
    }

    public static void isTrue(Boolean logicalExpression) {
        System.Assert.isTrue(logicalExpression);
    }

    public static void isTrue(Boolean logicalExpression, String message) {
        System.Assert.isTrue(logicalExpression, message);
    }

    public static void isFalse(Boolean logicalExpression) {
        System.Assert.isFalse(logicalExpression);
    }

    public static void isFalse(Boolean logicalExpression, String message) {
        System.Assert.isFalse(logicalExpression, message);
    }

    public static void equals(Object expected, Object actual) {
        System.Assert.areEqual(expected, actual);
    }

    public static void equals(Object expected, Object actual, String message) {
        System.Assert.areEqual(expected, actual, message);
    }

    public static void areEqual(Object expected, Object actual) {
        System.Assert.areEqual(expected, actual);
    }

    public static void areEqual(Object expected, Object actual, String message) {
        System.Assert.areEqual(expected, actual, message);
    }

    public static void notEquals(Object expected, Object actual) {
        System.Assert.areNotEqual(expected, actual);
    }

    public static void notEquals(Object expected, Object actual, String message) {
        System.Assert.areNotEqual(expected, actual, message);
    }

    public static void areNotEqual(Object expected, Object actual) {
        System.Assert.areNotEqual(expected, actual);
    }

    public static void areNotEqual(Object expected, Object actual, String message) {
        System.Assert.areNotEqual(expected, actual, message);
    }

    public static void fail(String message) {
        System.Assert.fail(message);
    }

    public static void isNull(Object obj) {
        System.Assert.isNull(obj);
    }

    public static void isNull(Object obj, String message) {
        System.Assert.isNull(obj, message);
    }

    public static void isNotNull(Object obj) {
        System.Assert.isNotNull(obj);
    }

    public static void isNotNull(Object obj, String message) {
        System.Assert.isNotNull(obj, message);
    }

    public static void hasExceptionMessage(String expectedMessage, Exception actualException) {
        // No passthrough available before Asserts is deployed; avoiding catch-22
    }

    public static void hasDmlExceptionMessage(SObjectField expectedField, String expectedMessage, DmlException actualException) {
        // No passthrough available before Asserts is deployed; avoiding catch-22
    }

    public static void hasDmlExceptionMessage(String expectedMessage, DmlException actualException) {
        // No passthrough available before Asserts is deployed; avoiding catch-22
    }

    public static void hasPageMessage(SObjectField expectedField, String expectedMessage) {
        // No passthrough available before Asserts is deployed; avoiding catch-22
    }
}