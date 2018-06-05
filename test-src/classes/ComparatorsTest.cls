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
private class ComparatorsTest {

    // Integers

    private static final Integer[] UNSORTED_INTEGERS = new Integer[] {
        10,
        5,
        null,
        15,
        10,
        null
    };

    @IsTest
    static void testIntegerComparator_Ascending_NullsFirst() {
        List<Integer> integers = new List<Integer>(UNSORTED_INTEGERS);
        CollectionUtil.sort(integers, Comparators.integerComparator());
        verifySortOrder(new Integer[] { null, null, 5, 10, 10, 15 }, integers);
    }

    @IsTest
    static void testIntegerComparator_Descending_NullsFirst() {
        List<Integer> integers = new List<Integer>(UNSORTED_INTEGERS);
        CollectionUtil.sort(integers, Comparators.integerComparator().ascending(false));
        verifySortOrder(new Integer[] { null, null, 15, 10, 10, 5 }, integers);
    }

    @IsTest
    static void testIntegerComparator_Ascending_NullsLast() {
        List<Integer> integers = new List<Integer>(UNSORTED_INTEGERS);
        CollectionUtil.sort(integers, Comparators.integerComparator().nullsFirst(false));
        verifySortOrder(new Integer[] { 5, 10, 10, 15, null, null }, integers);
    }

    @IsTest
    static void testIntegerComparator_Descending_NullsLast() {
        List<Integer> integers = new List<Integer>(UNSORTED_INTEGERS);
        CollectionUtil.sort(integers, Comparators.integerComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Integer[] { 15, 10, 10, 5, null, null }, integers);
    }

    // Longs

    private static final Long[] UNSORTED_LONGS = new Long[] {
        10,
        5,
        null,
        15,
        10,
        null
    };

    @IsTest
    static void testLongComparator_Ascending_NullsFirst() {
        List<Long> longs = new List<Long>(UNSORTED_LONGS);
        CollectionUtil.sort(longs, Comparators.longComparator());
        verifySortOrder(new Long[] { null, null, 5, 10, 10, 15 }, longs);
    }

    @IsTest
    static void testLongComparator_Descending_NullsFirst() {
        List<Long> longs = new List<Long>(UNSORTED_LONGS);
        CollectionUtil.sort(longs, Comparators.longComparator().ascending(false));
        verifySortOrder(new Long[] { null, null, 15, 10, 10, 5 }, longs);
    }

    @IsTest
    static void testLongComparator_Ascending_NullsLast() {
        List<Long> longs = new List<Long>(UNSORTED_LONGS);
        CollectionUtil.sort(longs, Comparators.longComparator().nullsFirst(false));
        verifySortOrder(new Long[] { 5, 10, 10, 15, null, null }, longs);
    }

    @IsTest
    static void testLongComparator_Descending_NullsLast() {
        List<Long> longs = new List<Long>(UNSORTED_LONGS);
        CollectionUtil.sort(longs, Comparators.longComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Long[] { 15, 10, 10, 5, null, null }, longs);
    }

    // Doubles

    private static final Double[] UNSORTED_DOUBLES = new Double[] {
        10.0,
        5.0,
        null,
        15.0,
        10.0,
        null
    };

    @IsTest
    static void testDoubleComparator_Ascending_NullsFirst() {
        List<Double> doubles = new List<Double>(UNSORTED_DOUBLES);
        CollectionUtil.sort(doubles, Comparators.doubleComparator());
        verifySortOrder(new Double[] { null, null, 5.0, 10.0, 10.0, 15.0 }, doubles);
    }

    @IsTest
    static void testDoubleComparator_Descending_NullsFirst() {
        List<Double> doubles = new List<Double>(UNSORTED_DOUBLES);
        CollectionUtil.sort(doubles, Comparators.doubleComparator().ascending(false));
        verifySortOrder(new Double[] { null, null, 15.0, 10.0, 10.0, 5.0 }, doubles);
    }

    @IsTest
    static void testDoubleComparator_Ascending_NullsLast() {
        List<Double> doubles = new List<Double>(UNSORTED_DOUBLES);
        CollectionUtil.sort(doubles, Comparators.doubleComparator().nullsFirst(false));
        verifySortOrder(new Double[] { 5.0, 10.0, 10.0, 15.0, null, null }, doubles);
    }

    @IsTest
    static void testDoubleComparator_Descending_NullsLast() {
        List<Double> doubles = new List<Double>(UNSORTED_DOUBLES);
        CollectionUtil.sort(doubles, Comparators.doubleComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Double[] { 15.0, 10.0, 10.0, 5.0, null, null }, doubles);
    }

    // Decimals

    private static final Decimal[] UNSORTED_DECIMALS = new Decimal[] {
        10.0,
        5.0,
        null,
        15.0,
        10.0,
        null
    };

    @IsTest
    static void testDecimalComparator_Ascending_NullsFirst() {
        List<Decimal> decimals = new List<Decimal>(UNSORTED_DECIMALS);
        CollectionUtil.sort(decimals, Comparators.decimalComparator());
        verifySortOrder(new Decimal[] { null, null, 5.0, 10.0, 10.0, 15.0 }, decimals);
    }

    @IsTest
    static void testDecimalComparator_Descending_NullsFirst() {
        List<Decimal> decimals = new List<Decimal>(UNSORTED_DECIMALS);
        CollectionUtil.sort(decimals, Comparators.decimalComparator().ascending(false));
        verifySortOrder(new Decimal[] { null, null, 15.0, 10.0, 10.0, 5.0 }, decimals);
    }

    @IsTest
    static void testDecimalComparator_Ascending_NullsLast() {
        List<Decimal> decimals = new List<Decimal>(UNSORTED_DECIMALS);
        CollectionUtil.sort(decimals, Comparators.decimalComparator().nullsFirst(false));
        verifySortOrder(new Decimal[] { 5.0, 10.0, 10.0, 15.0, null, null }, decimals);
    }

    @IsTest
    static void testDecimalComparator_Descending_NullsLast() {
        List<Decimal> decimals = new List<Decimal>(UNSORTED_DECIMALS);
        CollectionUtil.sort(decimals, Comparators.decimalComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Decimal[] { 15.0, 10.0, 10.0, 5.0, null, null }, decimals);
    }

    // Date/times

    private static final Datetime EARLY_DATETIME = Datetime.newInstance(1990, 01, 01, 12, 30, 30);
    private static final Datetime MIDDLE_DATETIME = Datetime.newInstance(2000, 06, 15, 08, 00, 00);
    private static final Datetime LATE_DATETIME = Datetime.newInstance(2010, 08, 04, 09, 15, 15);
    private static final Datetime[] UNSORTED_DATETIMES = new Datetime[] {
        MIDDLE_DATETIME,
        EARLY_DATETIME,
        null,
        LATE_DATETIME,
        MIDDLE_DATETIME,
        null
    };

    @IsTest
    static void testDatetimeComparator_Ascending_NullsFirst() {
        List<Datetime> datetimes = new List<Datetime>(UNSORTED_DATETIMES);
        CollectionUtil.sort(datetimes, Comparators.datetimeComparator());
        verifySortOrder(new Datetime[] { null, null, EARLY_DATETIME, MIDDLE_DATETIME, MIDDLE_DATETIME, LATE_DATETIME }, datetimes);
    }

    @IsTest
    static void testDatetimeComparator_Descending_NullsFirst() {
        List<Datetime> datetimes = new List<Datetime>(UNSORTED_DATETIMES);
        CollectionUtil.sort(datetimes, Comparators.datetimeComparator().ascending(false));
        verifySortOrder(new Datetime[] { null, null, LATE_DATETIME, MIDDLE_DATETIME, MIDDLE_DATETIME, EARLY_DATETIME }, datetimes);
    }

    @IsTest
    static void testDatetimeComparator_Ascending_NullsLast() {
        List<Datetime> datetimes = new List<Datetime>(UNSORTED_DATETIMES);
        CollectionUtil.sort(datetimes, Comparators.datetimeComparator().nullsFirst(false));
        verifySortOrder(new Datetime[] { EARLY_DATETIME, MIDDLE_DATETIME, MIDDLE_DATETIME, LATE_DATETIME, null, null }, datetimes);
    }

    @IsTest
    static void testDatetimeComparator_Descending_NullsLast() {
        List<Datetime> datetimes = new List<Datetime>(UNSORTED_DATETIMES);
        CollectionUtil.sort(datetimes, Comparators.datetimeComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Datetime[] { LATE_DATETIME, MIDDLE_DATETIME, MIDDLE_DATETIME, EARLY_DATETIME, null, null }, datetimes);
    }

    // Dates

    private static final Date EARLY_DATE = Date.newInstance(1990, 01, 01);
    private static final Date MIDDLE_DATE = Date.newInstance(2000, 06, 15);
    private static final Date LATE_DATE = Date.newInstance(2010, 08, 04);
    private static final Date[] UNSORTED_DATES = new Date[] {
        MIDDLE_DATE,
        EARLY_DATE,
        null,
        LATE_DATE,
        MIDDLE_DATE,
        null
    };

    @IsTest
    static void testDateComparator_Ascending_NullsFirst() {
        List<Date> dates = new List<Date>(UNSORTED_DATES);
        CollectionUtil.sort(dates, Comparators.dateComparator());
        verifySortOrder(new Date[] { null, null, EARLY_DATE, MIDDLE_DATE, MIDDLE_DATE, LATE_DATE }, dates);
    }

    @IsTest
    static void testDateComparator_Descending_NullsFirst() {
        List<Date> dates = new List<Date>(UNSORTED_DATES);
        CollectionUtil.sort(dates, Comparators.dateComparator().ascending(false));
        verifySortOrder(new Date[] { null, null, LATE_DATE, MIDDLE_DATE, MIDDLE_DATE, EARLY_DATE }, dates);
    }

    @IsTest
    static void testDateComparator_Ascending_NullsLast() {
        List<Date> dates = new List<Date>(UNSORTED_DATES);
        CollectionUtil.sort(dates, Comparators.dateComparator().nullsFirst(false));
        verifySortOrder(new Date[] { EARLY_DATE, MIDDLE_DATE, MIDDLE_DATE, LATE_DATE, null, null }, dates);
    }

    @IsTest
    static void testDateComparator_Descending_NullsLast() {
        List<Date> dates = new List<Date>(UNSORTED_DATES);
        CollectionUtil.sort(dates, Comparators.dateComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new Date[] { LATE_DATE, MIDDLE_DATE, MIDDLE_DATE, EARLY_DATE, null, null }, dates);
    }

    // Strings

    private static final String[] UNSORTED_STRINGS = new String[] {
        'Foo',
        'Bar',
        null,
        'Baz',
        'BAR',
        null,
        'bar'
    };

    @IsTest
    static void testStringComparator_CaseSensitive_Ascending_NullsFirst() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator());
        verifySortOrder(new String[] { null, null, 'BAR', 'Bar', 'Baz', 'Foo', 'bar' }, strings);
    }

    @IsTest
    static void testStringComparator_CaseSensitive_Descending_NullsFirst() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().ascending(false));
        verifySortOrder(new String[] { null, null, 'bar', 'Foo', 'Baz', 'Bar', 'BAR' }, strings);
    }

    @IsTest
    static void testStringComparator_CaseSensitive_Ascending_NullsLast() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().nullsFirst(false));
        verifySortOrder(new String[] { 'BAR', 'Bar', 'Baz', 'Foo', 'bar', null, null }, strings);
    }

    @IsTest
    static void testStringComparator_CaseSensitive_Descending_NullsLast() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().ascending(false).nullsFirst(false));
        verifySortOrder(new String[] { 'bar', 'Foo', 'Baz', 'Bar', 'BAR', null, null }, strings);
    }

    @IsTest
    static void testStringComparator_CaseInsensitive_Ascending_NullsFirst() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().caseSensitive(false));
        verifySortOrder(new String[] { null, null, 'Bar', 'BAR', 'bar', 'Baz', 'Foo' }, strings);
    }

    @IsTest
    static void testStringComparator_CaseInsensitive_Descending_NullsFirst() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().caseSensitive(false).ascending(false));
        verifySortOrder(new String[] { null, null, 'Foo', 'Baz', 'Bar', 'BAR', 'bar' }, strings);
    }

    @IsTest
    static void testStringComparator_CaseInsensitive_Ascending_NullsLast() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().caseSensitive(false).nullsFirst(false));
        verifySortOrder(new String[] { 'Bar', 'BAR', 'bar', 'Baz', 'Foo', null, null }, strings);
    }

    @IsTest
    static void testStringComparator_CaseInsensitive_Descending_NullsLast() {
        List<String> strings = new List<String>(UNSORTED_STRINGS);
        CollectionUtil.sort(strings, Comparators.stringComparator().caseSensitive(false).ascending(false).nullsFirst(false));
        verifySortOrder(new String[] { 'Foo', 'Baz', 'Bar', 'BAR', 'bar', null, null }, strings);
    }

    // SObject field values

    private static final Contact[] UNSORTED_CONTACTS = new Contact[] {
        new Contact(LastName = 'Foo', Birthdate = Date.newInstance(1970, 08, 15), MailingLatitude = 19700815),
        new Contact(LastName = 'Bar', Birthdate = Date.newInstance(1965, 02, 14), MailingLatitude = 19650214),
        new Contact(LastName = null, Birthdate = null, MailingLatitude = null),
        new Contact(LastName = 'Baz', Birthdate = Date.newInstance(1968, 12, 25), MailingLatitude = 19681225),
        new Contact(LastName = 'Bar', Birthdate = Date.newInstance(1965, 02, 14), MailingLatitude = 19650214),
        new Contact(LastName = null, Birthdate = null, MailingLatitude = null)
    };

    // NOTE: Not re-testing case-insensitivity here for string values since those were testing above

    @IsTest
    static void testSObjectFieldValueComparator_StringValue_Ascending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.LastName));
        verifyContactsAscendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_StringValue_Descending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.LastName).ascending(false));
        verifyContactsDescendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_StringValue_Ascending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.LastName).nullsFirst(false));
        verifyContactsAscendingNullsLast(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_StringValue_Descending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.LastName).ascending(false).nullsFirst(false));
        verifyContactsDescendingNullsLast(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_DateValue_Ascending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.Birthdate));
        verifyContactsAscendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_DateValue_Descending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.Birthdate).ascending(false));
        verifyContactsDescendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_DateValue_Ascending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.Birthdate).nullsFirst(false));
        verifyContactsAscendingNullsLast(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_DateValue_Descending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.Birthdate).ascending(false).nullsFirst(false));
        verifyContactsDescendingNullsLast(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_NumberValue_Ascending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.MailingLatitude));
        verifyContactsAscendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_NumberValue_Descending_NullsFirst() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.MailingLatitude).ascending(false));
        verifyContactsDescendingNullsFirst(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_NumberValue_Ascending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.MailingLatitude).nullsFirst(false));
        verifyContactsAscendingNullsLast(contacts);
    }

    @IsTest
    static void testSObjectFieldValueComparator_NumberValue_Descending_NullsLast() {
        List<Contact> contacts = new List<Contact>(UNSORTED_CONTACTS);
        CollectionUtil.sort(contacts, Comparators.sobjectFieldValueComparator(Contact.MailingLatitude).ascending(false).nullsFirst(false));
        verifyContactsDescendingNullsLast(contacts);
    }

    // Verifications

    private static void verifySortOrder(List<Object> expected, List<Object> actual) {
        Assert.equals(expected.size(), actual.size());
        for (Integer i = 0; i < expected.size(); i++) {
            Assert.equals(expected.get(i), actual.get(i));
        }
    }

    private static void verifyContactsAscendingNullsFirst(List<Contact> contacts) {
        Assert.equals(null, contacts.get(0).LastName);
        Assert.equals(null, contacts.get(1).LastName);
        Assert.equals('Bar', contacts.get(2).LastName);
        Assert.equals('Bar', contacts.get(3).LastName);
        Assert.equals('Baz', contacts.get(4).LastName);
        Assert.equals('Foo', contacts.get(5).LastName);
    }

    private static void verifyContactsDescendingNullsFirst(List<Contact> contacts) {
        Assert.equals(null, contacts.get(0).LastName);
        Assert.equals(null, contacts.get(1).LastName);
        Assert.equals('Foo', contacts.get(2).LastName);
        Assert.equals('Baz', contacts.get(3).LastName);
        Assert.equals('Bar', contacts.get(4).LastName);
        Assert.equals('Bar', contacts.get(5).LastName);
    }

    private static void verifyContactsAscendingNullsLast(List<Contact> contacts) {
        Assert.equals('Bar', contacts.get(0).LastName);
        Assert.equals('Bar', contacts.get(1).LastName);
        Assert.equals('Baz', contacts.get(2).LastName);
        Assert.equals('Foo', contacts.get(3).LastName);
        Assert.equals(null, contacts.get(4).LastName);
        Assert.equals(null, contacts.get(5).LastName);
    }

    private static void verifyContactsDescendingNullsLast(List<Contact> contacts) {
        Assert.equals('Foo', contacts.get(0).LastName);
        Assert.equals('Baz', contacts.get(1).LastName);
        Assert.equals('Bar', contacts.get(2).LastName);
        Assert.equals('Bar', contacts.get(3).LastName);
        Assert.equals(null, contacts.get(4).LastName);
        Assert.equals(null, contacts.get(5).LastName);
    }

    // Negative tests

    @IsTest
    static void testSObjectFieldValueComparator_NegativeTests() {
        Comparator comparator = Comparators.sobjectFieldValueComparator(Contact.LastName);

        try {
            comparator.compare('Foo', null);
            Assert.fail('Expected an IllegalStateException for non-SObject operand.');
        } catch (IllegalStateException e) {
            Assert.hasExceptionMessage(Comparators.VALIDATION_MESSAGE_INVALID_OPERAND, e);
        }

        try {
            comparator.compare(null, 'Bar');
            Assert.fail('Expected an IllegalStateException for non-SObject operand.');
        } catch (IllegalStateException e) {
            Assert.hasExceptionMessage(Comparators.VALIDATION_MESSAGE_INVALID_OPERAND, e);
        }

        try {
            comparator.compare(new Contact(), new Account());
            Assert.fail('Expected an IllegalStateException for mismatched operands.');
        } catch (IllegalStateException e) {
            Assert.hasExceptionMessage(Comparators.VALIDATION_MESSAGE_MISMATCHED_OPERANDS, e);
        }
    }
}