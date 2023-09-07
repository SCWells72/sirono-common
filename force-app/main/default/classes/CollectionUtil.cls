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
 * Utility methods for working with collections such as {@link List}, {@link Set}, {@link Map} and arrays.
 *
 * @group Collections
 */
public with sharing class CollectionUtil {

    private CollectionUtil() {
        // Utility class
    }

    /**
     * Determines if the provided list is `null` or empty.
     *
     * @param values the list of values
     *
     * @return `true` if the provided list is `null` or empty; otherwise `false`
     *
     * @see List
     */
    public static Boolean isEmpty(List<Object> values) {
        return (values == null) || values.isEmpty();
    }

    /**
     * Determines if the provided list is non-`null` and contains at least a single value.
     *
     * @param values the list of values
     *
     * @return `true` if the provided list is non-`null` and contains at least one value;
     * otherwise `false`
     *
     * @see List
     */
    public static Boolean isNotEmpty(List<Object> values) {
        return !isEmpty(values);
    }

    // NOTE: As of Summer '23, Set implements Iterable so the following works. Oddly, though, even though List also
    // implements Iterable, things do NOT work for Lists/arrays if you remove the List-specific signatures above.

    /**
     * Determines if the provided set (as an {@link Iterable}) is `null` or empty.
     *
     * @param values the set of values
     *
     * @return `true` if the provided set is `null` or empty; otherwise `false`
     *
     * @see Set
     * @see Iterable
     */
    public static Boolean isEmpty(Iterable<Object> values) {
        return (values == null) || !values.iterator().hasNext();
    }

    /**
     * Determines if the provided set (as an {@link Iterable}) is non-`null` and contains at least a single value.
     *
     * @param values the set of values
     *
     * @return `true` if the provided set is non-`null` and contains at least one value;
     * otherwise `false`
     *
     * @see Set
     * @see Iterable
     */
    public static Boolean isNotEmpty(Iterable<Object> values) {
        return !isEmpty(values);
    }

    // TODO: These are disabled for now because of issues with proper polymorphic behavior with type parameters of Map.
    //  Once those issues are resolved by Salesforce these can be restored.

    ///**
    // * Determines if the provided map is `null` or empty.
    // *
    // * @param values the map of values
    // *
    // * @return `true` if the provided map is `null` or empty; otherwise `false`
    // *
    // * @see Map
    // */
    //public static Boolean isEmpty(Map<Object, Object> values) {
    //    return (values == null) || values.isEmpty();
    //}
    //
    ///**
    // * Determines if the provided map is non-`null` and contains at least a single value.
    // *
    // * @param values the map of values
    // *
    // * @return `true` if the provided map is non-`null` and contains at least one value;
    // * otherwise `false`
    // *
    // * @see Map
    // */
    //public static Boolean isNotEmpty(Map<Object, Object> values) {
    //    return !isEmpty(values);
    //}

    /**
     * Adds the provided value to the specified list if both are non-null.
     *
     * @param values the list of values to which the non-null value should be added
     * @param value a value which will be added to the list if non-null
     *
     * @throws IllegalArgumentException if provided a null list of values
     */
    public static void addIfNotNull(List<Object> values, Object value) {
        if (values == null) {
            throw new IllegalArgumentException('The list must be non-null.');
        }

        if (value != null) {
            values.add(value);
        }
    }

    // TODO: Similar to above, Set doesn't work properly polymorphically, and you can't add via Iterable

    ///**
    // * Adds the provided value to the specified set if both are non-null.
    // *
    // * @param values the set of values to which the non-null value should be added
    // * @param value a value which will be added to the set if non-null
    // *
    // * @throws IllegalArgumentException if provided a null list of values
    // */
    //public static void addIfNotNull(Set<Object> values, Object value) {
    //    if (values == null) {
    //        throw new IllegalArgumentException('The set must be non-null.');
    //    }
    //
    //    if (value != null) {
    //        values.add(value);
    //    }
    //}

    /**
     * Adds all non-null values from the source list to the target list. The source values list may be null.
     *
     * @param targetValues the list to which non-null values should be added
     * @param sourceValues the list from which non-null values should be added
     *
     * @throws IllegalArgumentException if provided a null target list of values
     */
    public static void addAllNotNull(List<Object> targetValues, List<Object> sourceValues) {
        if (targetValues == null) {
            throw new IllegalArgumentException('The target list must be non-null.');
        }

        if (isNotEmpty(sourceValues)) {
            for (Object sourceValue : sourceValues) {
                if (sourceValue != null) {
                    targetValues.add(sourceValue);
                }
            }
        }
    }

    /**
     * Returns the first item from the provided list of values if the list is non-null and has at least one item.
     *
     * @param values the list of values
     *
     * @return the first item in the list or `null` if the list is null or empty
     */
    public static Object getFirstItem(List<Object> values) {
        return isNotEmpty(values) ? values.get(0) : null;
    }

    /**
     * Returns the last item from the provided list of values if the list is non-null and has at least one item.
     *
     * @param values the list of values
     *
     * @return the last item in the list or `null` if the list is null or empty
     */
    public static Object getLastItem(List<Object> values) {
        return isNotEmpty(values) ? values.get(values.size() - 1) : null;
    }

    /**
     * Returns the first item from the provided set (as an {@link Iterable}) of values if the set is non-null and has
     * at least one item. Note that due to the unordered nature of sets, this method may not yield a consistent value
     * as the set's contents change over time.
     *
     * @param values the set of values
     *
     * @return the first item in the set or `null` if the set is null or empty
     */
    public static Object getFirstItem(Iterable<Object> values) {
        return isNotEmpty(values) ? values.iterator().next() : null;
    }

    /**
     * Returns the last item from the provided set (as an {@link Iterable}) of values if the set is non-null and has
     * at least one item. Note that the last item is retrieved by iterating the entire set to find it, and due to the
     * unordered nature of sets, may not yield a consistent value.
     *
     * @param values the set of values
     *
     * @return the last item in the set or `null` if the set is null or empty
     */
    public static Object iterateAndGetLastItem(Iterable<Object> values) {
        if (isEmpty(values)) {
            return null;
        }

        Object lastItem = null;
        for (Iterator<Object> iterator = values.iterator(); iterator.hasNext(); lastItem = iterator.next());
        return lastItem;
    }

    /**
     * Copies the contents of the source list into the strongly-typed target list and returns the populated copy.
     * This is useful when working with the keys or values of a {@link MultiMap}.
     *
     * @param sourceValues the untyped source list
     * @param targetValues the strongly-typed target list
     *
     * @return the populated target list
     *
     * @throws IllegalArgumentException if provided a null target list of values
     */
    public static List<Object> toTypedList(List<Object> sourceValues, List<Object> targetValues) {
        if (targetValues == null) {
            throw new IllegalArgumentException('The target list must be non-null.');
        }

        if (isNotEmpty(sourceValues)) {
            targetValues.addAll(sourceValues);
        }

        return targetValues;
    }

    /**
     * Converts a set of {@link Id} values as a set of `Object` to be strongly-typed. This is useful
     * when the keys or values from a {@link MultiMap} are used as SOQL bind parameters.
     *
     * @param rawIds the raw IDs
     *
     * @return the strongly-typed IDs
     *
     * @throws IllegalArgumentException if provided a list that contains values that are null or not of type {@link Id}
     */
    public static Set<Id> toIds(Set<Object> rawIds) {
        Set<Id> ids = new Set<Id>();

        if (rawIds != null) {
            for (Object rawId : rawIds) {
                if (rawId == null) {
                    throw new IllegalArgumentException('Provided value is null.');
                } else if (!(rawId instanceof Id)) {
                    throw new IllegalArgumentException('Provided value is not an ID.');
                } else {
                    ids.add((Id) rawId);
                }
            }
        }

        return ids;
    }

    /**
     * Converts a list of {@link Id} values as a set of `Object` to be strongly-typed. This is useful
     * when the keys or values from a {@link MultiMap} are used as SOQL bind parameters.
     *
     * @param rawIds the raw IDs
     *
     * @return the strongly-typed IDs
     */
    public static Set<Id> toIds(List<Object> rawIds) {
        Set<Object> rawIdSet = new Set<Object>();
        if (rawIds != null) {
            rawIdSet.addAll(rawIds);
        }
        return toIds(rawIdSet);
    }

    /**
     * Converts a set of {@link String} values as a set of `Object` to be strongly-typed. This is useful
     * when the keys or values from a {@link MultiMap} are used as SOQL bind parameters.
     *
     * @param rawObjects the raw objects
     *
     * @return the set of string values
     */
    public static Set<String> toStrings(Set<Object> rawObjects) {
        Set<String> strings = new Set<String>();

        if (rawObjects != null) {
            for (Object rawObject : rawObjects) {
                strings.add(toString(rawObject));
            }
        }

        return strings;
    }

    /**
     * Converts a list of {@link String} values as a list of `Object` to be strongly-typed. This is useful
     * when the keys or values from a {@link MultiMap} are used as SOQL bind parameters.
     *
     * @param rawObjects the raw objects
     *
     * @return the list of string values
     */
    public static List<String> toStrings(List<Object> rawObjects) {
        List<String> strings = new List<String>();

        if (rawObjects != null) {
            for (Object rawObject : rawObjects) {
                strings.add(toString(rawObject));
            }
        }

        return strings;
    }

    /**
     * Converts a single raw `Object` value into the corresponding {@link String} value.
     *
     * @param rawObject the raw value
     *
     * @return the corresponding string value
     *
     * @throws IllegalArgumentException if provided a null raw object
     */
    private static String toString(Object rawObject) {
        if (rawObject == null) {
            throw new IllegalArgumentException('Provided value is null.');
        } else if (rawObject instanceof String) {
            return (String) rawObject;
        } else {
            return String.valueOf(rawObject);
        }
    }

    /**
     * Extracts the IDs from a provided SObjects as a list.
     *
     * @param objects the SObjects
     *
     * @return the provided SObjects' IDs as a list
     */
    public static List<Id> getIds(List<SObject> objects) {
        List<Id> ids = new List<Id>();
        for (SObject obj : objects) {
            ids.add(obj.Id);
        }
        return ids;
    }

    /**
     * Extracts the IDs from a provided list of SObjects as a set.
     *
     * @param objects the SObjects
     *
     * @return the provided SObjects' IDs as a set
     */
    public static Set<Id> getIdSet(List<SObject> objects) {
        Set<Id> ids = new Set<Id>();
        for (SObject obj : objects) {
            ids.add(obj.Id);
        }
        return ids;
    }

    /**
     * Take the given list of {@link SObject} instances and create a map from them using the value
     * returned from {@link SObjectField} field as the key. The {@link DisplayType} of the {@link SObjectField}
     * must be `REFERENCE`.
     *
     * {@link SObject} instances of a type not corresponding to `SObjectFieldType` are ignored as
     * are null {@link SObject} instances and null keys.
     *
     * If duplicate values are found for the same key, an {@link IllegalStateException} is thrown. Use
     * {@link CollectionUtil.multiMapByField} when duplicate values are expected.
     *
     * @param sobjects the list of {@link SObject}s to map.
     * @param field the {@link SObjectField} to use as the key
     *
     * @return Map keyed by the {@link Id} values contained in the given field
     *
     * @throws IllegalArgumentException if a non-{@link Id}-type key is found
     * @throws IllegalStateException if duplicate values are found for the same key
     */
    public static Map<Id, SObject> mapByIdField(List<SObject> sobjects, SObjectField field) {
        Map<Id, SObject> sobjectsByIdFieldValue = new Map<Id, SObject>();

        DisplayType fieldType = field.getDescribe().getType();
        if ((field != null) && (DisplayType.ID.equals(fieldType) || DisplayType.REFERENCE.equals(fieldType))) {
            for (SObject sobj : sobjects) {
                if (hasField(sobj, field)) {
                    Id value = (Id) sobj.get(field);
                    if (value != null) {
                        if (sobjectsByIdFieldValue.containsKey(value)) {
                            throw new IllegalStateException('Duplicate key: ' + value);
                        }
                        sobjectsByIdFieldValue.put(value, sobj);
                    }
                }
            }
        } else {
            throw new IllegalArgumentException('SObjectField ' + field.getDescribe().name + ' must be of type Id but is: ' + fieldType);
        }

        return sobjectsByIdFieldValue;
    }

    /**
     * Take the given list of {@link SObject} instances and create a map from them using the field value
     * specified by {@link SObjectField} field as the key.
     *
     * {@link SObject} instances of a type not corresponding to `SObjectFieldType` are ignored as
     * are null {@link SObject} instances and null keys.
     *
     * If duplicate values are found for the same key, an {@link IllegalStateException} is thrown. Use
     * {@link CollectionUtil.multiMapByField} when duplicate values are expected.
     *
     * @param sobjects the list of {@link SObject}s to map
     * @param field the {@link SObjectField} to use as the key
     *
     * @return {@link Map} keyed by the values contained in the given field
     *
     * @throws IllegalStateException if duplicate values are found for the same key
     */
    public static Map<Object, SObject> mapByField(List<SObject> sobjects, SObjectField field) {
        Map<Object, SObject> sobjectsByFieldValue = new Map<Object, SObject>();

        for (SObject sobj : sobjects) {
            if (hasField(sobj, field)) {
                Object value = sobj.get(field);
                if (value != null) {
                    if (sobjectsByFieldValue.containsKey(value)) {
                        throw new IllegalStateException('Duplicate key: ' + value);
                    }
                    sobjectsByFieldValue.put(value, sobj);
                }
            }
        }

        return sobjectsByFieldValue;
    }

    /**
     * Take the given list of {@link SObject} instances and create a {@link MultiMap} from them using the field
     * value specified by {@link SObjectField} field as the key.
     *
     * {@link SObject} instances of a type not corresponding to `SObjectFieldType` are ignored as
     * are null {@link SObject} instances and null keys.
     *
     * @param sobjects the list of {@link SObject}s to map
     * @param field the {@link SObjectField} to use as the key
     *
     * @return {@link MultiMap} keyed by the values contained in the given field
     */
    public static MultiMap multiMapByField(List<SObject> sobjects, SObjectField field) {
        MultiMap sobjectsByFieldValue = MultiMap.newListInstance();

        for (SObject sobj : sobjects) {
            if (hasField(sobj, field)) {
                Object value = sobj.get(field);
                if (value != null) {
                    sobjectsByFieldValue.putValue(value, sobj);
                }
            }
        }

        return sobjectsByFieldValue;
    }

    /**
     * Return a {@link Boolean} indicating if the given {@link SObject} instance's type
     * understands this {@link SObjectField}. Returns false if either sObj or field is null
     *
     * @param sobj the {@link SObject} instance to verify
     * @param field the {@link SObjectField} to look for
     *
     * @return true/false indicating that this {@link SObject} type includes this {@link SObjectField}
     */
    @TestVisible
    private static Boolean hasField(SObject sobj, SObjectField field) {
        if ((sobj == null) || (field == null)) {
            return false;
        }

        SObjectType type = sobj.getSObjectType();
        Set<SObjectField> typeFields = new Set<SObjectField>(type.getDescribe().fields.getMap().values());
        return typeFields.contains(field);
    }

    /**
     * Sorts the provided list of objects in-place using the specified {@link Comparator}.
     *
     * @param objects the list of objects to be sorted
     * @param comparator the comparator to be used to order list entries
     *
     * @throws IllegalArgumentException if a null comparator is provided
     *
     * @see Comparator
     *
     * @deprecated as of Winter '24/API v59.0, use {@link List.sort(Comparator)} instead
     */
    public static void sort(List<Object> objects, System.Comparator<Object> comparator) {
        if (comparator == null) {
            throw new IllegalArgumentException('A non-null comparator is required.');
        }

        if (isNotEmpty(objects)) {
            objects.sort(comparator);
        }
    }
}