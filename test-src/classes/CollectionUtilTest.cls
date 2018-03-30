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
    private static final List<Integer> TEST_LIST = new List<Integer>{10, 20, 30};
    private static final List<Integer> TEST_LIST_WITH_NULL = new List<Integer>{10, 20, 30, null};
    private static final Integer[] TEST_ARRAY = new Integer[]{10, 20, 30};
    private static final Integer[] TEST_ARRAY_WITH_NULL = new Integer[]{10, 20, 30, null};

    @IsTest
    static void isEmpty_List() {
        System.assert(CollectionUtil.isEmpty(NULL_LIST), 'Expected true for null list.');
        System.assert(CollectionUtil.isEmpty(NULL_ARRAY), 'Expected true for null array.');
        System.assert(CollectionUtil.isEmpty(EMPTY_LIST), 'Expected true for empty list.');
        System.assert(CollectionUtil.isEmpty(EMPTY_ARRAY), 'Expected true for empty array.');
        Assert.isFalse(CollectionUtil.isEmpty(TEST_LIST), 'Expected false for list with values.');
        Assert.isFalse(CollectionUtil.isEmpty(TEST_ARRAY), 'Expected false for array with values.');
    }

    @IsTest
    static void isNotEmpty_List() {
        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_LIST), 'Expected false for null list.');
        Assert.isFalse(CollectionUtil.isNotEmpty(NULL_ARRAY), 'Expected false for null array.');
        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_LIST), 'Expected false for empty list.');
        Assert.isFalse(CollectionUtil.isNotEmpty(EMPTY_ARRAY), 'Expected false for empty array.');
        System.assert(CollectionUtil.isNotEmpty(TEST_LIST), 'Expected true for list with values.');
        System.assert(CollectionUtil.isNotEmpty(TEST_ARRAY), 'Expected true for array with values.');
    }

    // TODO: These are disabled for now because of what seems to be a bug in the Apex compiler where it thinks
    // TODO: the return value of is[Not]Empty() for Set and Map is void instead of Boolean

//    @IsTest
//    static void isEmpty_Set() {
//        System.assert(CollectionUtil.isEmpty(NULL_SET), 'Expected true for null set.');
//        System.assert(CollectionUtil.isEmpty(EMPTY_SET), 'Expected true for empty set.');
//        AssertUtil.assertFalse(CollectionUtil.isEmpty(TEST_SET), 'Expected false for set with values.');
//    }
//
//    @IsTest
//    static void isNotEmpty_Set() {
//        AssertUtil.assertFalse(CollectionUtil.isNotEmpty(NULL_SET), 'Expected false for null set.');
//        AssertUtil.assertFalse(CollectionUtil.isNotEmpty(EMPTY_SET), 'Expected false for empty set.');
//        System.assert(CollectionUtil.isNotEmpty(TEST_SET), 'Expected true for set with values.');
//    }
//
//    @IsTest
//    static void isEmpty_Map() {
//        System.assert(CollectionUtil.isEmpty(NULL_MAP), 'Expected true for null map.');
//        System.assert(CollectionUtil.isEmpty(EMPTY_MAP), 'Expected true for empty map.');
//        AssertUtil.assertFalse(CollectionUtil.isEmpty(TEST_MAP), 'Expected false for map with values.');
//    }
//
//    @IsTest
//    static void isNotEmpty_Map() {
//        AssertUtil.assertFalse(CollectionUtil.isNotEmpty(NULL_MAP), 'Expected false for null map.');
//        AssertUtil.assertFalse(CollectionUtil.isNotEmpty(EMPTY_MAP), 'Expected false for empty map.');
//        System.assert(CollectionUtil.isNotEmpty(TEST_MAP), 'Expected true for map with values.');
//    }

    @IsTest
    static void testAddIfNotNull_List() {
        try {
            CollectionUtil.addIfNotNull((List<Object>) null, null);
            Assert.fail('Expected an IllegalArgumentException for a null list.');
        } catch (IllegalArgumentException e) {
            // Expected
        }

        List<Integer> ints = new List<Integer>{1, 2, 3};
        CollectionUtil.addIfNotNull(ints, null);
        System.assertEquals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        CollectionUtil.addIfNotNull(ints, 4);
        System.assertEquals(4, ints.size(), 'Expected the list size to increase by one.');
        System.assert(ints.contains(4), 'Expected the list to contain the new value.');
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
//        System.assertEquals(3, ints.size(), 'Expected the set size to be unchanged.');
//        AssertUtil.assertFalse(ints.contains(null), 'Expected the set not to contain a null value.');
//
//        CollectionUtil.addIfNotNull(ints, 4);
//        System.assertEquals(4, ints.size(), 'Expected the set size to increase by one.');
//        System.assert(ints.contains(4), 'Expected the set to contain the new value.');
//    }

    @IsTest
    static void testAddAllNotNull_List() {
        try {
            CollectionUtil.addAllNotNull((List<Object>) null, null);
            Assert.fail('Expected an IllegalArgumentException for a null list.');
        } catch (IllegalArgumentException e) {
            // Expected
        }

        List<Integer> ints = new List<Integer>{1, 2, 3};
        CollectionUtil.addAllNotNull(ints, null);
        System.assertEquals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        CollectionUtil.addAllNotNull(ints, null);
        System.assertEquals(3, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        List<Integer> moreIntsAndSomeNulls = new List<Integer>{4, null, 5, null, 6};
        CollectionUtil.addAllNotNull(ints, moreIntsAndSomeNulls);
        System.assertEquals(6, ints.size(), 'Expected the list size to increase by three.');
        System.assert(ints.contains(4) && ints.contains(5) && ints.contains(6),
            'Expected the list to contain the non-null values.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');

        List<Integer> allNulls = new List<Integer>{null, null, null, null};
        CollectionUtil.addAllNotNull(ints, allNulls);
        System.assertEquals(6, ints.size(), 'Expected the list size to be unchanged.');
        Assert.isFalse(ints.contains(null), 'Expected the list not to contain a null value.');
    }

    @IsTest
    static void testGetFirstItem() {
        Assert.isNull(CollectionUtil.getFirstItem(null), 'Expected a null first item for a null list.');
        Assert.isNull(CollectionUtil.getFirstItem(new List<String>()), 'Expected a null first item for an empty list.');
        Assert.isNull(CollectionUtil.getFirstItem(new String[0]), 'Expected a null first item for an empty array.');
        System.assertEquals('Foo', CollectionUtil.getFirstItem(new List<String>{'Foo'}));
        System.assertEquals('Foo', CollectionUtil.getFirstItem(new String[]{'Foo'}));
        System.assertEquals('Foo', CollectionUtil.getFirstItem(new String[]{'Foo', 'Bar'}));
    }

    @IsTest
    static void testToIdsBaseCases() {
        // Null for list signature should return an empty set
        Set<Id> ids = CollectionUtil.toIds((List<Object>) null);
        Assert.notNull(ids);
        System.assert(ids.isEmpty());

        // Null for set signature should return an empty set
        ids = CollectionUtil.toIds((Set<Object>) null);
        Assert.notNull(ids);
        System.assert(ids.isEmpty());

        // Null for list signature should return an empty set
        ids = CollectionUtil.toIds(new List<Object>());
        Assert.notNull(ids);
        System.assert(ids.isEmpty());

        // Null for set signature should return an empty set
        ids = CollectionUtil.toIds(new Set<Object>());
        Assert.notNull(ids);
        System.assert(ids.isEmpty());
    }

    @IsTest
    static void testToIdsInvalid() {
        // Null entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new List<Object>{null});
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Null entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new Set<Object>{null});
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Wrong type entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new List<Object>{10});
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
        }

        // Wrong type entry should result in IllegalArgumentException
        try {
            CollectionUtil.toIds(new Set<Object>{10});
            Assert.fail('Expected IllegalArgumentException.');
        } catch (IllegalArgumentException e) {
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
        System.assertEquals(ids.size(), rawIdList.size());
        for (Object rawId : rawIdList) {
            System.assert(ids.contains((Id) rawId));
        }

        // Set signature
        Set<Object> rawIdSet = new Set<Object>();
        for (User usr : users) {
            rawIdSet.add(usr.Id);
        }

        ids = CollectionUtil.toIds(rawIdSet);
        System.assertEquals(ids.size(), rawIdSet.size());
        for (Object rawId : rawIdSet) {
            System.assert(ids.contains((Id) rawId));
        }
    }

    @IsTest
    static void testHasField() {
        Assert.isFalse(CollectionUtil.hasField(new Account(), Contact.FirstName), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(null, Contact.FirstName), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(new Account(), null), 'Unexpected field');
        Assert.isFalse(CollectionUtil.hasField(new Account(), Contact.Id), 'Unexpected field');
        System.assert(CollectionUtil.hasField(new Account(), Account.AccountNumber));
    }

//    @IsTest
//    static void testMapByIdField() {
//        Contact contact = new Contact(
//            FirstName = 'Test',
//            LastName = 'User'
//        );
//        insert contact;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(contact, 10);
//        Map<Id, SObject> stmtMap = CollectionUtil.mapByIdField(statements, Statement__c.Id);
//        System.assertEquals(statements.size(), stmtMap.size());
//    }

//    @IsTest
//    static void testMapByIdFieldWithDupes() {
//        Contact gt = TestUtility.generateGuarantorContact();
//        insert gt;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(gt, 10);
//
//        try {
//            CollectionUtil.mapByIdField(statements, Statement__c.Guarantor__c);
//            Assert.fail('Expected IllegalStateException');
//        } catch (IllegalStateException ex) {
//        }
//
//    }

//    @IsTest
//    static void testMapByField() {
//        Contact gt = TestUtility.generateGuarantorContact();
//        insert gt;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(gt, 10);
//        Map<Object, SObject> stmtMap = CollectionUtil.mapByField(statements, Statement__c.Statement_Date__c);
//        System.assertEquals(statements.size(), stmtMap.size());
//    }

//    @IsTest
//    static void testMapByFieldWithDupes() {
//        Contact gt = TestUtility.generateGuarantorContact();
//        insert gt;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(gt, 10);
//        try {
//            CollectionUtil.mapByField(statements, Statement__c.Guarantor__c);
//            Assert.fail('Expected IllegalStateException');
//        } catch (IllegalStateException ex) {
//        }
//    }

//    @IsTest
//    static void testMapByFieldWithNullFieldValues() {
//        Contact gt = TestUtility.generateGuarantorContact();
//        insert gt;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(gt, 10);
//        for (Integer idx = 0; idx < 5; idx++) {
//            statements[idx].Statement_Date__c = null;
//        }
//        Map<Object, SObject> stmtMap = CollectionUtil.mapByField(statements, Statement__c.Statement_Date__c);
//        System.assertEquals(statements.size() - 5, stmtMap.size());
//    }

//    @IsTest
//    static void testAsSObjectList() {
//        List<Object> contacts = new List<Object>();
//        for (Integer i = 0; i < 5; i++) {
//            contacts.add(TestUtility.generateGuarantorContactByName('Schmoe ' + String.valueOf(i)));
//        }
//
//        List<SObject> sobjectList = CollectionUtil.asSObjects(contacts);
//        System.assertEquals(contacts.size(), sobjectList.size());
//
//    }


//    @IsTest
//    static void testFilteredList() {
//        List<Contact> contacts = new List<Contact>();
//        for (Integer i = 0; i < 5; i++) {
//            Contact c = TestUtility.generateGuarantorContactByName('Schmoe ' + String.valueOf(i));
//            c.FirstName = null;
//            contacts.add(c);
//        }
//
//        List<SObject> sobjectList = CollectionUtil.filteredList(contacts, Contact.LastName, 'Schmoe 3');
//        System.assertEquals(1, sobjectList.size());
//
//
//        sobjectList = CollectionUtil.filteredList(contacts, Contact.FirstName, null);
//        System.assertEquals(5, sobjectList.size());
//    }

//    @IsTest
//    static void testMultiMapByField() {
//        Contact gt = TestUtility.generateGuarantorContact();
//        insert gt;
//
//        Statement__c[] statements = TestFixtureBuilder.createStatements(gt, 10);
//        MultiMap stmtMap = CollectionUtil.multiMapByField(statements, Statement__c.Guarantor__c);
//        System.assertEquals(1, stmtMap.keySet().size());
//
//        System.assert(stmtMap.containsKey(gt.Id), 'Expected stmtMap to contain gt.Id, but doesn\'t. stmtMap: ' + JSON.serializePretty(stmtMap));
//    }
}