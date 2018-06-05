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
private class CollectionUtilTest {

    private static final List<Integer> NULL_LIST = null;
    private static final Integer[] NULL_ARRAY = null;
    private static final List<Integer> EMPTY_LIST = new List<Integer>();
    private static final Integer[] EMPTY_ARRAY = new Integer[0];
    private static final List<Integer> TEST_LIST = new List<Integer> { 10, 20, 30 };
    private static final Integer[] TEST_ARRAY = new Integer[] { 10, 20, 30 };

    // TODO: These are disabled for now because of issues with proper polymorphic behavior with type parameters of
    // TODO: Set and Map. Once those issues are resolved by Salesforce these can be restored.

//    private static final Set<Integer> NULL_SET = null;
//    private static final Set<Integer> EMPTY_SET = new Set<Integer>();
//    private static final Set<Integer> TEST_SET = new Set<Integer> { 10, 20, 30 };
//
//    private static final Map<Integer, Integer> NULL_MAP = null;
//    private static final Map<Integer, Integer> EMPTY_MAP = new Map<Integer, Integer>();
//    private static final Map<Integer, Integer> TEST_MAP = new Map<Integer, Integer> { 10 => 100, 20 => 200, 30 => 300 };

    @IsTest
    static void testIsEmpty_List() {
        Assert.isTrue(CollectionUtil.isEmpty(NULL_LIST), 'Expected true for null list.');
        Assert.isTrue(CollectionUtil.isEmpty(NULL_ARRAY), 'Expected true for null array.');
        Assert.isTrue(CollectionUtil.isEmpty(EMPTY_LIST), 'Expected true for empty list.');
        Assert.isTrue(CollectionUtil.isEmpty(EMPTY_ARRAY), 'Expected true for empty array.');
        Assert.isFalse(CollectionUtil.isEmpty(TEST_LIST), 'Expected false for list with values.');
        Assert.isFalse(CollectionUtil.isEmpty(TEST_ARRAY), 'Expected false for array with values.');
    }

    @IsTest
    static void testIsNotEmpty_List() {
        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_LIST), 'Expected false for null list.');
        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_ARRAY), 'Expected false for null array.');
        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_LIST), 'Expected false for empty list.');
        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_ARRAY), 'Expected false for empty array.');
        Assert.isTrue(CollectionUtil.isNotEmpty(TEST_LIST), 'Expected true for list with values.');
        Assert.isTrue(CollectionUtil.isNotEmpty(TEST_ARRAY), 'Expected true for array with values.');
    }

//    @IsTest
//    static void testIsEmpty_Set() {
//        Assert.isTrue(CollectionUtil.isEmpty(NULL_SET), 'Expected true for null set.');
//        Assert.isTrue(CollectionUtil.isEmpty(EMPTY_SET), 'Expected true for empty set.');
//        Assert.isFalse(CollectionUtil.isEmpty(TEST_SET), 'Expected false for set with values.');
//    }
//
//    @IsTest
//    static void testIsNotEmpty_Set() {
//        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_SET), 'Expected false for null set.');
//        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_SET), 'Expected false for empty set.');
//        Assert.isTrue(CollectionUtil.isNotEmpty(TEST_SET), 'Expected true for set with values.');
//    }
//
//    @IsTest
//    static void testIsEmpty_Map() {
//        Assert.isTrue(CollectionUtil.isEmpty(NULL_MAP), 'Expected true for null map.');
//        Assert.isTrue(CollectionUtil.isEmpty(EMPTY_MAP), 'Expected true for empty map.');
//        Assert.isFalse(CollectionUtil.isEmpty(TEST_MAP), 'Expected false for map with values.');
//    }
//
//    @IsTest
//    static void testIsNotEmpty_Map() {
//        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_MAP), 'Expected false for null map.');
//        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_MAP), 'Expected false for empty map.');
//        Assert.isTrue(CollectionUtil.isNotEmpty(TEST_MAP), 'Expected true for map with values.');
//    }

    @IsTest
    static void testAddIfNotNull_List() {
        try {
            CollectionUtil.addIfNotNull((List<Object>) null, null);
            Assert.fail('Expected an IllegalArgumentException for a null list.');
        } catch (IllegalArgumentException e) {
            // Expected
        }

        List<Integer> ints = new List<Integer> { 1, 2, 3 };
        CollectionUtil.addIfNotNull(ints, null);
        Assert.equals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        CollectionUtil.addIfNotNull(ints, 4);
        Assert.equals(4, ints.size(), 'Expected the list size to increase by one.');
        Assert.isTrue(ints.contains(4), 'Expected the list to contain the new value.');
    }

//    @IsTest
//    static void testAddIfNotNull_Set() {
//        try {
//            CollectionUtil.addIfNotNull((List<Object>) null, null);
//            AssertUtil.fail('Expected an IllegalArgumentException for a null set.');
//        } catch (IllegalArgumentException e) {
//            // Expected
//        }
//
//        Set<Integer> ints = new Set<Integer> { 1, 2, 3 };
//        CollectionUtil.addIfNotNull(ints, null);
//        Assert.equals(3, ints.size(), 'Expected the set size to be unchanged.');
//        AssertUtil.assertFalse(ints.contains(null), 'Expected the set not to contain a null value.');
//
//        CollectionUtil.addIfNotNull(ints, 4);
//        Assert.equals(4, ints.size(), 'Expected the set size to increase by one.');
//        Assert.isTrue(ints.contains(4), 'Expected the set to contain the new value.');
//    }

    @IsTest
    static void testAddAllNotNull_List() {
        try {
            CollectionUtil.addAllNotNull((List<Object>) null, null);
            Assert.fail('Expected an IllegalArgumentException for a null list.');
        } catch (IllegalArgumentException e) {
            // Expected
        }

        List<Integer> ints = new List<Integer> { 1, 2, 3 };
        CollectionUtil.addAllNotNull(ints, null);
        Assert.equals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        CollectionUtil.addAllNotNull(ints, null);
        Assert.equals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        List<Integer> moreIntsAndSomeNulls = new List<Integer> { 4, null, 5, null, 6 };
        CollectionUtil.addAllNotNull(ints, moreIntsAndSomeNulls);
        Assert.equals(6, ints.size(), 'Expected the list size to increase by three.');
        Assert.isTrue(ints.contains(4) && ints.contains(5) && ints.contains(6),
            'Expected the list to contain the non-null values.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        List<Integer> allNulls = new List<Integer> { null, null, null, null };
        CollectionUtil.addAllNotNull(ints, allNulls);
        Assert.equals(6, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');
    }

    @IsTest
    static void testGetFirstItem() {
        Assert.isNull(CollectionUtil.getFirstItem(null), 'Expected a null first item for a null list.');
        Assert.isNull(CollectionUtil.getFirstItem(new List<String>()), 'Expected a null first item for an empty list.');
        Assert.isNull(CollectionUtil.getFirstItem(new String[0]), 'Expected a null first item for an empty array.');
        Assert.equals('Foo', CollectionUtil.getFirstItem(new List<String> { 'Foo' }));
        Assert.equals('Foo', CollectionUtil.getFirstItem(new String[] { 'Foo' }));
        Assert.equals('Foo', CollectionUtil.getFirstItem(new List<String> { 'Foo', 'Bar' }));
        Assert.equals('Foo', CollectionUtil.getFirstItem(new String[] { 'Foo', 'Bar' }));
    }

    @IsTest
    static void testGetLastItem() {
        Assert.isNull(CollectionUtil.getLastItem(null), 'Expected a null last item for a null list.');
        Assert.isNull(CollectionUtil.getLastItem(new List<String>()), 'Expected a null last item for an empty list.');
        Assert.isNull(CollectionUtil.getLastItem(new String[0]), 'Expected a null last item for an empty array.');
        Assert.equals('Foo', CollectionUtil.getLastItem(new List<String> { 'Foo' }));
        Assert.equals('Foo', CollectionUtil.getLastItem(new String[] { 'Foo' }));
        Assert.equals('Bar', CollectionUtil.getLastItem(new List<String> { 'Foo', 'Bar' }));
        Assert.equals('Bar', CollectionUtil.getLastItem(new String[] { 'Foo', 'Bar' }));
    }

    @IsTest
    static void testToIdsBaseCases() {
        // Null for list signature should return an empty set
        Set<Id> ids = CollectionUtil.toIds((List<Object>) null);
        Assert.isNotNull(ids);
        Assert.isTrue(ids.isEmpty());

        // Null for set signature should return an empty set
        ids = CollectionUtil.toIds((Set<Object>) null);
        Assert.isNotNull(ids);
        Assert.isTrue(ids.isEmpty());

        // Null for list signature should return an empty set
        ids = CollectionUtil.toIds(new List<Object>());
        Assert.isNotNull(ids);
        Assert.isTrue(ids.isEmpty());

        // Null for set signature should return an empty set
        ids = CollectionUtil.toIds(new Set<Object>());
        Assert.isNotNull(ids);
        Assert.isTrue(ids.isEmpty());
    }

    @IsTest
    static void testToIdsInvalid() {
        // Null entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new List<Object> { null });
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Null entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new Set<Object> { null });
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Wrong type entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new List<Object> { 10 });
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Wrong type entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new Set<Object> { 10 });
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }
    }

    @IsTest
    static void testToTypedList() {
        // Bad args
        try {
            CollectionUtil.toTypedList(null, null);
            Assert.fail('Expected an IllegalArgumentException for a null list.');
        } catch (IllegalArgumentException e) {
            // Expected
        }

        // Nothing begets nothing, null flavor
        List<Object> typedStringList = CollectionUtil.toTypedList(null, new List<String>());
        Assert.isTrue(typedStringList instanceof List<String>, 'Expected a list of strings.');
        Assert.isTrue(typedStringList.isEmpty(), 'Expected the list of strings to be empty.');

        // Nothing begets nothing, empty flavor
        List<Object> typedStringList2 = CollectionUtil.toTypedList(new List<String>(), new List<String>());
        Assert.isTrue(typedStringList2 instanceof List<String>, 'Expected a list of strings.');
        Assert.isTrue(typedStringList2.isEmpty(), 'Expected the list of strings to be empty.');

        // General happy path
        List<Object> untypedList = new List<Object> { 1, 2, 3, null };
        List<Object> typedIntList = CollectionUtil.toTypedList(untypedList, new List<Integer>());
        Assert.isTrue(typedIntList instanceof List<Integer>, 'Expected a list of integers.');
        Assert.equals(untypedList.size(), typedIntList.size(), 'Expected the lists to have the same size.');
        for (Object intValue : untypedList) {
            Assert.isTrue(typedIntList.contains(intValue), 'Expected the typed list to contain the value ' + intValue + '.');
        }
    }

    @IsTest
    static void testToIds() {
        // Create a few dummy objects to give us IDs to work with
        List<User> users = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            String username = UserInfo.getOrganizationId() + i + '@test.com';
            User user = new User(
                Username = username,
                Email = username,
                LastName = 'McTest',
                Alias = 'test' + i,
                ProfileId = UserInfo.getProfileId(),
                TimeZoneSidKey = UserInfo.getTimeZone().toString(),
                LocaleSidKey = UserInfo.getLocale(),
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = UserInfo.getLocale()
            );
            users.add(user);
        }
        insert users;

        // List signature
        List<Object> rawIdList = new List<Object>();
        for (User usr : users) {
            rawIdList.add(usr.Id);
        }

        Set<Id> ids = CollectionUtil.toIds(rawIdList);
        Assert.equals(ids.size(), rawIdList.size());
        for (Object rawId : rawIdList) {
            Assert.isTrue(ids.contains((Id) rawId));
        }

        // Set signature
        Set<Object> rawIdSet = new Set<Object>();
        for (User usr : users) {
            rawIdSet.add(usr.Id);
        }

        ids = CollectionUtil.toIds(rawIdSet);
        Assert.equals(ids.size(), rawIdSet.size());
        for (Object rawId : rawIdSet) {
            Assert.isTrue(ids.contains((Id) rawId));
        }
    }

    @IsTest
    static void testToStrings_Set() {
        Set<Object> rawValues = new Set<Object> {
            'Foobar',
            10,
            20.0,
            true,
            LoggingLevel.DEBUG
        };

        Set<String> stringValues = CollectionUtil.toStrings(rawValues);
        Assert.equals(rawValues.size(), stringValues.size());
        for (Object rawValue : rawValues) {
            Assert.isTrue(stringValues.contains(String.valueOf(rawValue)));
        }
    }

    @IsTest
    static void testToStringsWithNulls_Set() {
        Set<Object> rawValues = new Set<Object> {
            'Foobar',
            null
        };

        try {
            CollectionUtil.toStrings(rawValues);
            Assert.fail('Expected an IllegalArgumentException');
        } catch (IllegalArgumentException e) {
        }
    }

    @IsTest
    static void testToStrings_List() {
        List<Object> rawValues = new List<Object> {
            'Foobar',
            10,
            20.0,
            true,
            LoggingLevel.DEBUG
        };

        List<String> stringValues = CollectionUtil.toStrings(rawValues);
        Assert.equals(rawValues.size(), stringValues.size());
        for (Integer i = 0; i < stringValues.size(); i++) {
            Object rawValue = rawValues.get(i);
            String stringValue = stringValues.get(i);
            Assert.equals(String.valueOf(rawValue), stringValue);
        }
    }

    @IsTest
    static void testToStringsWithNulls_List() {
        List<Object> rawValues = new List<Object> {
            'Foobar',
            null
        };

        try {
            CollectionUtil.toStrings(rawValues);
            Assert.fail('Expected an IllegalArgumentException');
        } catch (IllegalArgumentException e) {
        }
    }

    @IsTest
    static void testGetIds() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Account ' + (i + 1)
            ));
        }
        insert accounts;

        List<Id> accountIds = CollectionUtil.getIds(accounts);
        Assert.equals(accounts.size(), accountIds.size());
        for (Integer i = 0; i < accounts.size(); i++) {
            Account account = accounts.get(i);
            Id accountId = accountIds.get(i);
            Assert.equals(account.Id, accountId);
        }
    }

    @IsTest
    static void testGetIdSet() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Account ' + (i + 1)
            ));
        }
        insert accounts;

        // Create a list with duplicate entries
        List<Account> duplicateAccounts = new List<Account>();
        duplicateAccounts.addAll(accounts);
        duplicateAccounts.addAll(accounts);

        Set<Id> accountIds = CollectionUtil.getIdSet(duplicateAccounts);
        Assert.equals(accounts.size(), accountIds.size());
        for (Account account : accounts) {
            Id accountId = account.Id;
            Assert.isTrue(accountIds.contains(accountId));
            accountIds.remove(accountId);
        }
        Assert.isTrue(accountIds.isEmpty());
    }

    @IsTest
    static void testHasField() {
        Assert.isFalse(CollectionUtil.hasField(new Account(), Contact.FirstName), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(null, Contact.FirstName), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(new Account(), null), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(new Account(), Contact.Id), 'Unexpected field');
        Assert.isTrue(CollectionUtil.hasField(new Account(), Account.AccountNumber));
    }

    @IsTest
    static void testMapByIdField() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            accounts.add(new Account(
                Name = 'Account ' + (i + 1)
            ));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User ' + (i + 1),
                AccountId = accounts.get(i).Id
            ));
        }
        insert contacts;

        Map<Id, SObject> contactsByAccountId = CollectionUtil.mapByIdField(contacts, Contact.AccountId);
        Assert.equals(contacts.size(), contactsByAccountId.size());
        for (Id accountId : contactsByAccountId.keySet()) {
            Contact contact = (Contact) contactsByAccountId.get(accountId);
            Assert.equals(accountId, contact.AccountId);
        }
    }

    @IsTest
    static void testMapByIdFieldWithDupes() {
        Account account = new Account(
            Name = 'Account'
        );
        insert account;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User ' + (i + 1),
                AccountId = account.Id
            ));
        }
        insert contacts;

        try {
            CollectionUtil.mapByIdField(contacts, Contact.AccountId);
            Assert.fail('Expected IllegalStateException');
        } catch (IllegalStateException e) {
        }
    }

    @IsTest
    static void testMapByField() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User ' + (i + 1)
            ));
        }
        insert contacts;

        Map<Object, SObject> contactsByAccountId = CollectionUtil.mapByField(contacts, Contact.LastName);
        Assert.equals(contacts.size(), contactsByAccountId.size());
        for (Object lastName : contactsByAccountId.keySet()) {
            Contact contact = (Contact) contactsByAccountId.get(lastName);
            Assert.equals(lastName, contact.LastName);
        }
    }

    @IsTest
    static void testMapByFieldWithDupes() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User ' + (i + 1)
            ));
        }
        insert contacts;

        try {
            CollectionUtil.mapByField(contacts, Contact.FirstName);
            Assert.fail('Expected IllegalStateException');
        } catch (IllegalStateException e) {
        }
    }

    @IsTest
    static void testMapByFieldWithNullFieldValues() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            accounts.add(new Account(
                Name = 'Account ' + (i + 1),
                AccountNumber = (i == 0) ? null : '12345'
            ));
        }
        insert accounts;

        Map<Object, SObject> accountsByAccountNumber = CollectionUtil.mapByField(accounts, Account.AccountNumber);
        Assert.equals(accounts.size() - 1, accountsByAccountNumber.size());
        for (Object accountNumber : accountsByAccountNumber.keySet()) {
            Account account = (Account) accountsByAccountNumber.get(accountNumber);
            Assert.isNotNull(account.AccountNumber);
            Assert.equals(accountNumber, account.AccountNumber);
        }
    }

    @IsTest
    static void testMultiMapByField() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            accounts.add(new Account(
                Name = 'Account ' + (i + 1)
            ));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Account account = accounts.get(Math.mod(i, 2));
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'User ' + (i + 1),
                AccountId = account.Id
            ));
        }
        insert contacts;

        MultiMap contactsByAccountId = CollectionUtil.multiMapByField(contacts, Contact.AccountId);
        Assert.equals(accounts.size(), contactsByAccountId.keySet().size());
        Assert.equals(contacts.size(), contactsByAccountId.values().size());
        for (Object key : contactsByAccountId.keySet()) {
            Id accountId = (Id) key;
            List<Object> values = contactsByAccountId.getValues(accountId);
            Assert.equals(contacts.size() / 2, values.size());
            for (Object value : values) {
                Contact contact = (Contact) value;
                Assert.equals(accountId, contact.AccountId);
            }
        }
    }
}