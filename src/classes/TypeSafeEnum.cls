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
 * Shared base class for type-safe enums.
 */
public with sharing abstract class TypeSafeEnum {
    // This contains the values for all type-safe enums keyed by derived enum type
    private static final Map<Type, Map<String, TypeSafeEnum>> INSTANCE_MAPS_BY_ENUM_TYPE = new Map<Type, Map<String, TypeSafeEnum>>();

    private final String value;
    private final Integer ordinal;

    /**
     * Creates a new type-safe enum entry for the specified derived type and unique value within that type.
     *
     * @param enumType the derived type-safe enum type to which the value should be added
     * @param value the distinct string value within the type
     */
    protected TypeSafeEnum(Type enumType, String value) {
        this.value = value;
        Map<String, TypeSafeEnum> instanceMap = getInstanceMap(enumType);
        this.ordinal = instanceMap.size();
        instanceMap.put(value.toUpperCase(), this);
    }

    private static Map<String, TypeSafeEnum> getInstanceMap(Type enumType) {
        Map<String, TypeSafeEnum> instanceMap = INSTANCE_MAPS_BY_ENUM_TYPE.get(enumType);
        if (instanceMap == null) {
            instanceMap = new Map<String, TypeSafeEnum>();
            INSTANCE_MAPS_BY_ENUM_TYPE.put(enumType, instanceMap);
        }

        return instanceMap;
    }

    /**
     * Returns the string value of the type-safe enum entry.
     *
     * @return the enum entry's string value
     */
    public String value() {
        return value;
    }

    /**
     * Returns the ordinal value of the type-safe enum entry based on the order in which it was added.
     *
     * @return the enum entry's ordinal
     */
    public Integer ordinal() {
        return ordinal;
    }

    /**
     * Determines whether the specified string value is equivalent (case-insensitive) to this type-safe enum entry.
     *
     * @param testValue the value to be tested for equivalence
     *
     * @return <code>true</code> if the specified value matches this entry; otherwise <code>false</code>
     */
    public Boolean equalTo(String testValue) {
        return value().equalsIgnoreCase(testValue);
    }

    /**
     * Determines whether the specified string value is different from this type-safe enum entry.
     *
     * @param testValue the value to be tested for difference
     *
     * @return <code>true</code> if the specified value is different from this entry; otherwise <code>false</code>
     */
    public Boolean notEqualTo(String testValue) {
        return !equalTo(testValue);
    }

    /**
     * Returns the string value of this type-safe enum entry.
     *
     * @return the enum entry's string value
     */
    public override String toString() {
        return value;
    }

    // These facilitate strongly-typed class methods in the derived types. Unfortunately Apex doesn't allow
    // "protected static", so they all have to be public to be accessed.

    /**
     * Returns the enum entry that matches the provided value (case-insensitive).
     *
     * @param enumType the enum type for which the value should be returned
     * @param value the value for which an enum entry should be returned
     *
     * @return the enum entry that matches the provided value; otherwise <code>null</code> is returned
     */
    public static TypeSafeEnum valueOf(Type enumType, String value) {
        return value != null ? getInstanceMap(enumType).get(value.toUpperCase()) : null;
    }

    /**
     * Returns all values for the type-safe enum ordered by ordinal values ascending.
     *
     * @param enumType the enum type for which the values should be returned
     * @param stronglyTypedValues an empty list of strongly-typed values of the derived enum type
     *
     * @return all type-safe enum values in a strongly-typed list
     */
    public static List<TypeSafeEnum> values(Type enumType, List<TypeSafeEnum> stronglyTypedValues) {
        List<TypeSafeEnum> values = getInstanceMap(enumType).values();

        // Add to the provided list in ordinal value ascending
        Map<Integer, TypeSafeEnum> valuesByOrdinal = new Map<Integer, TypeSafeEnum>();
        for (TypeSafeEnum value : values) {
            valuesByOrdinal.put(value.ordinal(), value);
        }
        List<Integer> ordinals = new List<Integer>(valuesByOrdinal.keySet());
        ordinals.sort();
        for (Integer ordinal : ordinals) {
            CollectionUtil.addIfNotNull(stronglyTypedValues, valuesByOrdinal.get(ordinal));
        }

        return stronglyTypedValues;
    }

    /**
     * Determines whether the specified string value matches (case-insensitive) any of the provided type-safe enum values.
     *
     * @param values the enum values against which the provided string value should be checked
     * @param testValue the value to be tested
     *
     * @return <code>true</code> if the specified value matches any of the enum values; otherwise <code>false</code>
     */
    public static Boolean matchesAny(TypeSafeEnum[] values, String testValue) {
        if (CollectionUtil.isEmpty(values)) {
            return false;
        }

        for (TypeSafeEnum value : values) {
            if (value.equalTo(testValue)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Determines whether the specified string value matches (case-insensitive) none of the provided type-safe enum values.
     *
     * @param values the enum values against which the provided string value should be checked
     * @param testValue the value to be tested
     *
     * @return <code>true</code> if the specified value matches none of the enum values; otherwise <code>false</code>
     */
    public static Boolean matchesNone(TypeSafeEnum[] values, String testValue) {
        return !matchesAny(values, testValue);
    }
}