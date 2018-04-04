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
private class MultiMapTest {

    @IsTest
    static void testContainsKeyList() {
        testContainsKey(true);
    }

    @IsTest
    static void testContainsKeySet() {
        testContainsKey(false);
    }

    static void testContainsKey(Boolean allowDuplicates) {
        MultiMap testMultiMap = createMultiMap(allowDuplicates);

        // Nothing added yet
        Assert.isFalse(testMultiMap.containsKey('key'));

        // Add a value for the key
        testMultiMap.putValue('key', 'value1');
        Assert.isTrue(testMultiMap.containsKey('key'));

        // Add a second value for the key
        testMultiMap.putValue('key', 'value2');
        Assert.isTrue(testMultiMap.containsKey('key'));

        // Remove the second value for the key
        testMultiMap.removeValue('key', 'value2');
        Assert.isTrue(testMultiMap.containsKey('key'));

        // Remove the first value for the key
        testMultiMap.removeValue('key', 'value1');
        Assert.isFalse(testMultiMap.containsKey('key'));

        // Add multiple values for the key
        testMultiMap.putValues('key', new String[] { 'value1', ' value2' });
        Assert.isTrue(testMultiMap.containsKey('key'));

        // Remove all values for the key
        testMultiMap.remove('key');
        Assert.isFalse(testMultiMap.containsKey('key'));

        // Add multiple values for the key
        testMultiMap.putValues('key', new String[] { 'value1', ' value2' });
        Assert.isTrue(testMultiMap.containsKey('key'));

        // Clear the map
        testMultiMap.clear();
        Assert.isFalse(testMultiMap.containsKey('key'));
    }

    @IsTest
    static void testPutValueList() {
        testPutValue(true);
    }

    @IsTest
    static void testPutValueSet() {
        testPutValue(false);
    }

    static void testPutValue(Boolean allowDuplicates) {
        MultiMap testMultiMap = createMultiMap(allowDuplicates);

        // Add a value
        Assert.equals(0, testMultiMap.size());
        Assert.equals(0, testMultiMap.values().size());
        Assert.equals(0, testMultiMap.getValues('key').size());
        testMultiMap.putValue('key', 'value1');
        Assert.equals(1, testMultiMap.size());
        Assert.equals(1, testMultiMap.values().size());
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add a different value
        testMultiMap.putValue('key', 'value2');
        Assert.equals(1, testMultiMap.size());
        Assert.equals(2, testMultiMap.values().size());
        Assert.equals(2, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1', 'value2' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add a value for another key
        testMultiMap.putValue('key2', 'value2_1');
        Assert.equals(2, testMultiMap.size());
        Assert.equals(3, testMultiMap.values().size());
        Assert.equals(1, testMultiMap.getValues('key2').size());
        verifyContents(new String[] { 'value2_1' }, testMultiMap.getValues('key2'), allowDuplicates);
    }

    @IsTest
    static void testPutValuesList() {
        testPutValues(true);
    }

    @IsTest
    static void testPutValuesSet() {
        testPutValues(false);
    }

    static void testPutValues(Boolean allowDuplicates) {
        MultiMap testMultiMap = createMultiMap(allowDuplicates);

        // List signature

        // Add a single value
        Assert.equals(0, testMultiMap.size());
        Assert.equals(0, testMultiMap.values().size());
        Assert.equals(0, testMultiMap.getValues('key').size());
        testMultiMap.putValues('key', new String[] { 'value1' });
        Assert.equals(1, testMultiMap.size());
        Assert.equals(1, testMultiMap.values().size());
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add multiple values
        testMultiMap.putValues('key', new String[] { 'value2', 'value3' });
        Assert.equals(1, testMultiMap.size());
        Assert.equals(3, testMultiMap.values().size());
        Assert.equals(3, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1', 'value2', 'value3' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add multiple values for another key
        testMultiMap.putValues('key2', new String[] { 'value2_1', 'value2_2' });
        Assert.equals(2, testMultiMap.size());
        Assert.equals(5, testMultiMap.values().size());
        Assert.equals(2, testMultiMap.getValues('key2').size());
        verifyContents(new String[] { 'value2_1', 'value2_2' }, testMultiMap.getValues('key2'), allowDuplicates);

        // Set signature

        testMultiMap = createMultiMap(allowDuplicates);

        // Add a single value
        Assert.equals(0, testMultiMap.size());
        Assert.equals(0, testMultiMap.values().size());
        Assert.equals(0, testMultiMap.getValues('key').size());
        testMultiMap.putValues('key', new Set<Object> { 'value1', 'value1' });
        Assert.equals(1, testMultiMap.size());
        Assert.equals(1, testMultiMap.values().size());
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add multiple values
        testMultiMap.putValues('key', new Set<Object> { 'value2', 'value3', 'value2', 'value3' });
        Assert.equals(1, testMultiMap.size());
        Assert.equals(3, testMultiMap.values().size());
        Assert.equals(3, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1', 'value2', 'value3' }, testMultiMap.getValues('key'), allowDuplicates);

        // Add multiple values for another key
        testMultiMap.putValues('key2', new Set<Object> { 'value2_1', 'value2_2', 'value2_1', 'value2_2' });
        Assert.equals(2, testMultiMap.size());
        Assert.equals(5, testMultiMap.values().size());
        Assert.equals(2, testMultiMap.getValues('key2').size());
        verifyContents(new String[] { 'value2_1', 'value2_2' }, testMultiMap.getValues('key2'), allowDuplicates);
    }

    @IsTest
    static void testPutAllValuesList() {
        testPutAllValues(true);
    }

    @IsTest
    static void testPutAllValuesSet() {
        testPutAllValues(false);
    }

    static void testPutAllValues(Boolean allowDuplicates) {
        // Create a source multi-map
        MultiMap sourceMultiMap1 = createMultiMap(allowDuplicates);
        sourceMultiMap1.putValues('key1', new String[] { 'value1_1', 'value1_2' });
        sourceMultiMap1.putValues('key2', new String[] { 'value2_1', 'value2_2' });

        // Use that to populate a new multi-map
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        testMultiMap.putAllValues(sourceMultiMap1);
        Assert.equals(sourceMultiMap1.size(), testMultiMap.size());
        Assert.equals(sourceMultiMap1.keySet(), testMultiMap.keySet());
        Assert.equals(sourceMultiMap1.values(), testMultiMap.values());

        // Create a second source multi-map
        MultiMap sourceMultiMap2 = createMultiMap(allowDuplicates);
        sourceMultiMap2.putValues('key1', new String[] { 'value1_3', 'value1_4' });
        sourceMultiMap2.putValues('key2', new String[] { 'value2_3', 'value2_4' });
        sourceMultiMap2.putValues('key3', new String[] { 'value3_1', 'value3_2' });

        // Add those as well
        testMultiMap.putAllValues(sourceMultiMap2);
        // NOTE: We only added one new key
        Assert.equals(sourceMultiMap1.size() + 1, testMultiMap.size());
        Assert.equals(sourceMultiMap1.keySet().size() + 1, testMultiMap.keySet().size());
        // Make sure that all keys were copied over
        Assert.isTrue(testMultiMap.keySet().containsAll(sourceMultiMap1.keySet()));
        Assert.isTrue(testMultiMap.keySet().containsAll(sourceMultiMap2.keySet()));
        // And all values
        Assert.equals(sourceMultiMap1.values().size() + sourceMultiMap2.values().size(), testMultiMap.values().size());
        // TODO: Apex doesn't really have a good way to do a containsAll() on lists
    }

    @IsTest
    static void testGetValuesList() {
        testGetValues(true);
    }

    @IsTest
    static void testGetValuesSet() {
        testGetValues(false);
    }

    static void testGetValues(Boolean allowDuplicates) {
        MultiMap testMultiMap = createMultiMap(allowDuplicates);

        // Shouldn't ever return null even when nothing has ever been added for a key
        Assert.isNotNull(testMultiMap.getValues('key'));
        testMultiMap.remove('key');
        Assert.isNotNull(testMultiMap.getValues('key'));
        testMultiMap.clear();
        Assert.isNotNull(testMultiMap.getValues('key'));

        // Add a single value and make sure we get that value back
        testMultiMap.putValue('key1', 'value1');
        Assert.equals(1, testMultiMap.getValues('key1').size());
        verifyContents(new String[] { 'value1' }, testMultiMap.getValues('key1'), allowDuplicates);

        // Add multiple values for a different key
        testMultiMap.putValues('key2', new String[] { 'value2_1', 'value2_2' });
        Assert.equals(1, testMultiMap.getValues('key1').size());
        verifyContents(new String[] { 'value1' }, testMultiMap.getValues('key1'), allowDuplicates);
        Assert.equals(2, testMultiMap.getValues('key2').size());
        verifyContents(new String[] { 'value2_1', 'value2_2' }, testMultiMap.getValues('key2'), allowDuplicates);

        // Remove the values for the first key and make sure we still get back an empty list
        testMultiMap.removeValue('key1', 'value1');
        Assert.isNotNull(testMultiMap.getValues('key1'));
        Assert.isTrue(testMultiMap.getValues('key1').isEmpty());

        // Same with the second
        testMultiMap.remove('key2');
        Assert.isNotNull(testMultiMap.getValues('key2'));
        Assert.isTrue(testMultiMap.getValues('key2').isEmpty());

        // And now clear the multi-map and make sure we still get back empty lists
        testMultiMap.clear();
        Assert.isNotNull(testMultiMap.getValues('key1'));
        Assert.isTrue(testMultiMap.getValues('key1').isEmpty());
        Assert.isNotNull(testMultiMap.getValues('key2'));
        Assert.isTrue(testMultiMap.getValues('key2').isEmpty());
    }

    @IsTest
    static void testGetValueSetList() {
        testGetValueSet(true);
    }

    @IsTest
    static void testGetValueSetSet() {
        testGetValueSet(false);
    }

    static void testGetValueSet(Boolean allowDuplicates) {
        MultiMap testMultiMap = createMultiMap(allowDuplicates);

        // Shouldn't ever return null even when nothing has ever been added for a key
        Assert.isNotNull(testMultiMap.getValueSet('key'));
        testMultiMap.remove('key');
        Assert.isNotNull(testMultiMap.getValueSet('key'));
        testMultiMap.clear();
        Assert.isNotNull(testMultiMap.getValueSet('key'));

        // Add a single value and make sure we get that value back
        testMultiMap.putValue('key1', 'value1');
        Assert.equals(1, testMultiMap.getValueSet('key1').size());
        Assert.equals(new Set<Object> { 'value1' }, testMultiMap.getValueSet('key1'));

        // Add the same value and make sure we only get it back once
        testMultiMap.putValue('key1', 'value1');
        // First make sure the actual storage is correct
        Assert.equals(allowDuplicates ? 2 : 1, testMultiMap.getValues('key1').size());
        verifyContents(allowDuplicates ? new String[] { 'value1', 'value1' } : new String[] { 'value1' }, testMultiMap.getValues('key1'), allowDuplicates);
        // And then verify the result of getValueSet()
        Assert.equals(1, testMultiMap.getValueSet('key1').size());
        Assert.equals(new Set<Object> { 'value1' }, testMultiMap.getValueSet('key1'));
    }

    @IsTest
    static void testRemoveList() {
        testRemove(true);
    }

    @IsTest
    static void testRemoveSet() {
        testRemove(false);
    }

    static void testRemove(Boolean allowDuplicates) {
        // Add values for multiple keys to a multi-map
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.equals(2, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Remove the first key and make sure the second still looks right
        Assert.isTrue(testMultiMap.remove('key1'));
        Assert.equals(0, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Try to remove the key again and it should return false
        Assert.isFalse(testMultiMap.remove('key1'));
        Assert.equals(0, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Remove the second key
        Assert.isTrue(testMultiMap.remove('key2'));
        Assert.equals(0, testMultiMap.getValues('key1').size());
        Assert.equals(0, testMultiMap.getValues('key2').size());

        // Try to remove the second key again and it should return false
        Assert.isFalse(testMultiMap.remove('key2'));
        Assert.equals(0, testMultiMap.getValues('key1').size());
        Assert.equals(0, testMultiMap.getValues('key2').size());
    }

    @IsTest
    static void testRemoveValueList() {
        testRemoveValue(true);
    }

    @IsTest
    static void testRemoveValueSet() {
        testRemoveValue(false);
    }

    static void testRemoveValue(Boolean allowDuplicates) {
        // Add values for multiple keys to a multi-map
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.equals(2, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Remove a value for the first key
        Assert.equals('value1_1', testMultiMap.removeValue('key1', 'value1_1'));
        Assert.equals(1, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Now try to remove the same value again and it should return null
        Assert.isNull(testMultiMap.removeValue('key1', 'value1_1'));
        Assert.equals(1, testMultiMap.getValues('key1').size());
        Assert.equals(3, testMultiMap.getValues('key2').size());

        // Remove a value for the second key
        Assert.equals('value2_3', testMultiMap.removeValue('key2', 'value2_3'));
        Assert.equals(1, testMultiMap.getValues('key1').size());
        Assert.equals(2, testMultiMap.getValues('key2').size());

        // Now try to remove the same value again and it should return null
        Assert.isNull(testMultiMap.removeValue('key2', 'value2_3'));
        Assert.equals(1, testMultiMap.getValues('key1').size());
        Assert.equals(2, testMultiMap.getValues('key2').size());
    }

    @IsTest
    static void testClearList() {
        testClear(true);
    }

    @IsTest
    static void testClearSet() {
        testClear(false);
    }

    static void testClear(Boolean allowDuplicates) {
        // Fill up a multi-map
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.isFalse(testMultiMap.isEmpty());
        Assert.equals(2, testMultiMap.keySet().size());
        Assert.equals(5, testMultiMap.values().size());

        // And now clear it
        testMultiMap.clear();
        Assert.isTrue(testMultiMap.isEmpty());
        Assert.equals(0, testMultiMap.keySet().size());
        Assert.equals(0, testMultiMap.values().size());
    }

    @IsTest
    static void testKeySetList() {
        testKeySet(true);
    }

    @IsTest
    static void testKeySetSet() {
        testKeySet(false);
    }

    static void testKeySet(Boolean allowDuplicates) {
        // Start empty
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        Assert.isTrue(testMultiMap.keySet().isEmpty());

        // Add data
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.equals(2, testMultiMap.keySet().size());
        Assert.isTrue(testMultiMap.keySet().contains('key1'));
        Assert.isTrue(testMultiMap.keySet().contains('key2'));

        // Remove all values for one key
        testMultiMap.remove('key1');
        Assert.equals(1, testMultiMap.keySet().size());
        Assert.isFalse(testMultiMap.keySet().contains('key1'));
        Assert.isTrue(testMultiMap.keySet().contains('key2'));

        // And now clear it
        testMultiMap.clear();
        Assert.isTrue(testMultiMap.keySet().isEmpty());
    }

    @IsTest
    static void testValuesList() {
        testValues(true);
    }

    @IsTest
    static void testValuesSet() {
        testValues(false);
    }

    static void testValues(Boolean allowDuplicates) {
        // Start empty
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        Assert.isTrue(testMultiMap.values().isEmpty());

        // Add data
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.equals(5, testMultiMap.values().size());

        // Remove a value for one key
        testMultiMap.removeValue('key1', 'value1_1');
        Assert.equals(4, testMultiMap.values().size());

        // Remove all values for one key
        testMultiMap.remove('key2');
        Assert.equals(1, testMultiMap.values().size());

        // And now clear it
        testMultiMap.clear();
        Assert.isTrue(testMultiMap.values().isEmpty());
    }

    @IsTest
    static void testIsEmptyList() {
        testIsEmpty(true);
    }

    @IsTest
    static void testIsEmptySet() {
        testIsEmpty(false);
    }

    static void testIsEmpty(Boolean allowDuplicates) {
        // Start empty
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        Assert.isTrue(testMultiMap.values().isEmpty());

        // Add data
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.isFalse(testMultiMap.values().isEmpty());

        // Remove a value for one key
        testMultiMap.removeValue('key1', 'value1_1');
        Assert.isFalse(testMultiMap.values().isEmpty());

        // Remove all values for one key
        testMultiMap.remove('key2');
        Assert.isFalse(testMultiMap.values().isEmpty());

        // And now clear it
        testMultiMap.clear();
        Assert.isTrue(testMultiMap.values().isEmpty());
    }

    @IsTest
    static void testSizeList() {
        testSize(true);
    }

    @IsTest
    static void testSizeSet() {
        testSize(false);
    }

    static void testSize(Boolean allowDuplicates) {
        // Start empty
        MultiMap testMultiMap = createMultiMap(allowDuplicates);
        Assert.equals(0, testMultiMap.size());

        // Add data
        testMultiMap.putValue('key1', 'value1_1');
        testMultiMap.putValue('key1', 'value1_2');
        testMultiMap.putValue('key2', 'value2_1');
        testMultiMap.putValue('key2', 'value2_2');
        testMultiMap.putValue('key2', 'value2_3');
        Assert.equals(2, testMultiMap.size());

        // Add more data
        testMultiMap.putValue('key3', 'value3_1');
        testMultiMap.putValue('key3', 'value3_2');
        testMultiMap.putValue('key3', 'value3_3');
        testMultiMap.putValue('key3', 'value3_4');
        Assert.equals(3, testMultiMap.size());

        // Remove a value for one key
        testMultiMap.removeValue('key1', 'value1_1');
        Assert.equals(3, testMultiMap.size());

        // Remove all values for one key
        testMultiMap.remove('key2');
        Assert.equals(2, testMultiMap.size());

        // And now clear it
        testMultiMap.clear();
        Assert.equals(0, testMultiMap.size());
    }

    @IsTest
    static void testListCollection() {
        // Add values for multiple keys to a list-backed multi-map
        MultiMap testMultiMap = MultiMap.newListInstance();
        testMultiMap.putValue('key', 'value1');
        testMultiMap.putValue('key', 'value2');
        // Add the same value twice
        testMultiMap.putValue('key', 'value1');
        Assert.equals(3, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1', 'value2', 'value1' }, testMultiMap.getValues('key'), true);

        // Remove the duplicate value
        Assert.equals('value1', testMultiMap.removeValue('key', 'value1'));
        Assert.equals(2, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value2', 'value1' }, testMultiMap.getValues('key'), true);

        // Remove the same value which was added in duplicate
        Assert.equals('value1', testMultiMap.removeValue('key', 'value1'));
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value2' }, testMultiMap.getValues('key'), true);

        // Now try to remove the same value again and it should return null
        Assert.isNull(testMultiMap.removeValue('key', 'value1'));
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value2' }, testMultiMap.getValues('key'), true);
    }

    @IsTest
    static void testSetCollection() {
        // Add values for multiple keys to a set-backed multi-map
        MultiMap testMultiMap = MultiMap.newSetInstance();
        testMultiMap.putValue('key', 'value1');
        testMultiMap.putValue('key', 'value2');
        // Add the same value twice
        testMultiMap.putValue('key', 'value1');
        Assert.equals(2, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value1', 'value2' }, testMultiMap.getValues('key'), false);

        // Remove the attempted duplicate value
        Assert.equals('value1', testMultiMap.removeValue('key', 'value1'));
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value2' }, testMultiMap.getValues('key'), false);

        // Now try to remove the same value again and it should return null
        Assert.isNull(testMultiMap.removeValue('key', 'value1'));
        Assert.equals(1, testMultiMap.getValues('key').size());
        verifyContents(new String[] { 'value2' }, testMultiMap.getValues('key'), false);
    }

    static MultiMap createMultiMap(Boolean allowDuplicates) {
        return allowDuplicates ? MultiMap.newListInstance() : MultiMap.newSetInstance();
    }

    static void verifyContents(List<Object> expectedValues, List<Object> actualValues, Boolean orderMatters) {
        Assert.equals(expectedValues.size(), actualValues.size(), 'The list sizes do not match.');

        if (orderMatters) {
            for (Integer i = 0, numValues = expectedValues.size(); i < numValues; i++) {
                Object expectedValue = expectedValues.get(i);
                Object actualValue = actualValues.get(i);
                Assert.equals(expectedValue, actualValue, 'Elements at index ' + i + ' do not match.');
            }
        } else {
            Set<Object> expectedValuesSet = new Set<Object>();
            expectedValuesSet.addAll(expectedValues);
            Set<Object> actualValuesSet = new Set<Object>();
            actualValuesSet.addAll(actualValues);
            Assert.equals(expectedValuesSet, actualValuesSet, 'The contents do not match.');
        }
    }
}