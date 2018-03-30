/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility methods for working with collections such as <code>List</code>, <code>Set</code>, <code>Map</code> and arrays.
 */
global with sharing class CollectionUtil {

    private CollectionUtil() {
        // Utility class
    }

    /**
     * Determines if the provided list is <code>null</code> or empty.
     *
     * @param values the list of values
     *
     * @return <code>true</code> if the provided list is <code>null</code> or empty; otherwise <code>false</code>
     *
     * @see List
     */
    global static Boolean isEmpty(List<Object> values) {
        return (values == null) || values.isEmpty();
    }

    /**
     * Determines if the provided list is non-<code>null</code> and contains at least a single value.
     *
     * @param values the list of values
     *
     * @return <code>true</code> if the provided list is non-<code>null</code> and contains at least one value;
     * otherwise <code>false</code>
     *
     * @see List
     */
    global static Boolean isNotEmpty(List<Object> values) {
        return !isEmpty(values);
    }

    // TODO: These are disabled for now because of what seems to be a bug in the Apex compiler where it thinks
    // TODO: the return value of is[Not]Empty() for Set and Map is void instead of Boolean

//    /**
//     * Determines if the provided set is <code>null</code> or empty.
//     *
//     * @param values the set of values
//     *
//     * @return <code>true</code> if the provided set is <code>null</code> or empty; otherwise <code>false</code>
//     *
//     * @see Set
//     */
//    global static Boolean isEmpty(Set<Object> values) {
//        return (values == null) || values.isEmpty();
//    }
//
//    /**
//     * Determines if the provided set is non-<code>null</code> and contains at least a single value.
//     *
//     * @param values the set of values
//     *
//     * @return <code>true</code> if the provided set is non-<code>null</code> and contains at least one value;
//     * otherwise <code>false</code>
//     *
//     * @see Set
//     */
//    global static Boolean isNotEmpty(Set<Object> values) {
//        return !isEmpty(values);
//    }
//
//    /**
//     * Determines if the provided map is <code>null</code> or empty.
//     *
//     * @param values the map of values
//     *
//     * @return <code>true</code> if the provided map is <code>null</code> or empty; otherwise <code>false</code>
//     *
//     * @see Map
//     */
//    global static Boolean isEmpty(Map<Object, Object> values) {
//        return (values == null) || values.isEmpty();
//    }
//
//    /**
//     * Determines if the provided map is non-<code>null</code> and contains at least a single value.
//     *
//     * @param values the map of values
//     *
//     * @return <code>true</code> if the provided map is non-<code>null</code> and contains at least one value;
//     * otherwise <code>false</code>
//     *
//     * @see Map
//     */
//    global static Boolean isNotEmpty(Map<Object, Object> values) {
//        return !isEmpty(values);
//    }

    /**
     * Adds the provided value to the specified list if both are non-null.
     *
     * @param values the list of values to which the non-null value should be added
     * @param value a value which will be added to the list if non-null
     */
    public static void addIfNotNull(List<Object> values, Object value) {
        if (values == null) {
            throw new IllegalArgumentException('The list must be non-null.');
        }

        if (value != null) {
            values.add(value);
        }
    }

    // TODO: Same issue as above. It's like the Apex compiler doesn't properly allow assignment of Set<NotObject> to Set<Object>

//    /**
//     * Adds the provided value to the specified set if both are non-null.
//     *
//     * @param values the set of values to which the non-null value should be added
//     * @param value a value which will be added to the set if non-null
//     */
//    public static void addIfNotNull(Set<Object> values, Object value) {
//        if (values == null) {
//            throw new IllegalArgumentException('The set must be non-null.');
//        }
//
//        if (value != null) {
//            values.add(value);
//        }
//    }

    /**
     * Adds all non-null values from the source list to the target list. The source values list may be null.
     *
     * @param targetValues the list to which non-null values should be added
     * @param sourceValues the list from which non-null values should be added
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
     * @return the first item in the list or <code>null</code> if the list is null or empty
     */
    public static Object getFirstItem(List<Object> values) {
        return isNotEmpty(values) ? values.get(0) : null;
    }

    /**
     * Converts a set of <code>Id</code> values as a set of <code>Object</code> to be strongly-typed. This is useful
     * when the keys or values from a <code>MultiMap</code> are used as SOQL bind parameters.
     *
     * @param rawIds the raw IDs
     *
     * @return the strongly-typed IDs
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
     * Converts a list of <code>Id</code> values as a set of <code>Object</code> to be strongly-typed. This is useful
     * when the keys or values from a <code>MultiMap</code> are used as SOQL bind parameters.
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
     * Converts a set of <code>String</code> values as a set of <code>Object</code> to be strongly-typed. This is useful
     * when the keys or values from a <code>MultiMap</code> are used as SOQL bind parameters.
     *
     * @param rawObjects the raw objects
     *
     * @return the set of Strings
     */
    public static Set<String> toStrings(Set<Object> rawObjects) {
        Set<String> stringSet = new Set<String>();

        if (rawObjects != null) {
            for (Object raw : rawObjects) {
                if (raw == null) {
                    throw new IllegalArgumentException('Provided value is null.');
                } else if (!(raw instanceof String)) {
                    stringSet.add(String.valueOf(raw));
                } else {
                    stringSet.add((String) raw);
                }
            }
        }

        return stringSet;
    }

    /**
     *
     * Take the given list of <code>SObject</code> instances and create a map from them using the value
     * returned from <code>SObjectField</code> field as the key. The <code>DisplayType</code> of the <code>SObjectField</code>
     * must be <code>REFERENCE</code>.
     *
     * <code>SObject</code> instances of a type not corresponding to <code>SObjectFieldType</code> are ignored as
     * are null <code>SObject</code> instances and null keys.
     *
     * @param sObjects the list of <code>SObject</code>s to map.
     * @param field the <code>SObjectField</code> to use as the key
     *
     * @return Map keyed by the <code>Id</code> values contained in the given field
     */
    global static Map<Id, SObject> mapByIdField(List<SObject> sobjects, SObjectField field) {
        Map<Id, SObject> sobjectsByIdFieldValue = new Map<Id, SObject>();

        DisplayType fieldType = field.getDescribe().getType();
        if (field != null && (DisplayType.ID.equals(fieldType) || DisplayType.REFERENCE.equals(fieldType))) {
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
     *
     * Take the given list of <code>SObject</code> instances and create a map from them using the field value
     * specified by <code>SObjectField</code> field as the key.
     *
     * <code>SObject</code> instances of a type not corresponding to <code>SObjectFieldType</code> are ignored as
     * are null <code>SObject</code> instances and null keys.
     *
     * @param sObjects the list of <code>SObject</code>s to map
     * @param field the <code>SObjectField</code> to use as the key
     *
     * @return Map keyed by the values contained in the given field
     */
    global static Map<Object, SObject> mapByField(List<SObject> sobjects, SObjectField field) {
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
     *
     * Take the given list of <code>SObject</code> instances and create a <code>MultiMap</code> from them using the field value
     * specified by <code>SObjectField</code> field as the key.
     *
     * <code>SObject</code> instances of a type not corresponding to <code>SObjectFieldType</code> are ignored as
     * are null <code>SObject</code> instances and null keys.
     *
     * @param sObjects the list of <code>SObject</code>s to map
     * @param field the <code>SObjectField</code> to use as the key
     *
     * @return MultiMap keyed by the values contained in the given field
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
     * Return a <code>Boolean</code> indicating if the given <code>SObject</code> instance's type
     * understands this <code>SObjectField</code>. Returns false if either sObj or field is null
     *
     * @param sobj the <code>SObject</code> instance to verify
     * @param field the <code>SObjectTypeField</code> to look for
     *
     * @return true/false indicating that this <code>SObject</code> type includes this <code>SObjectField</code>
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
}