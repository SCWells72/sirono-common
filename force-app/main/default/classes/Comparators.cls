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
 * Common implementations of <code>Comparator</code> that can be used with <code>CollectionUtil.sort()</code>.
 *
 * @see Comparator
 * @see CollectionUtil
 */
public with sharing class Comparators {
    //private static final Logger LOG = Logger.getInstance(Comparators.class);

    @TestVisible private static final String VALIDATION_MESSAGE_INVALID_OPERAND = 'Comparison operand must be an SObject.';
    @TestVisible private static final String VALIDATION_MESSAGE_MISMATCHED_OPERANDS = 'Comparison operands must be of the same SObject type.';

    private Comparators() {
        // Factory class
    }

    /**
     * The common base class for comparators that support specification of sorting direction, how null values should
     * be handled, and whether textual comparisons are performed in a case-sensitive/-insensitive manner.
     */
    public abstract class ConfigurableComparator implements Comparator {
        private Boolean caseSensitive = true;
        private Boolean ascending = true;
        private Boolean nullsFirst = true;

        /**
         * Configures the current comparator to match the provided comparator.
         *
         * @param sourceComparator the comparator from which configuration should be copied
         *
         * @return the configurable comparator
         */
        public ConfigurableComparator configureFrom(ConfigurableComparator sourceComparator) {
            return caseSensitive(sourceComparator.isCaseSensitive())
                .ascending(sourceComparator.isAscending())
                .nullsFirst(sourceComparator.isNullsFirst());
        }

        /**
         * Sets the comparator's case-sensitivity for textual comparisons. The default is case-sensitive.
         *
         * @param caseSensitive true if textual comparisons should be case-sensitive; false if not
         *
         * @return the configurable comparator
         */
        public ConfigurableComparator caseSensitive(Boolean caseSensitive) {
            this.caseSensitive = caseSensitive;
            return this;
        }

        /**
         * Whether the comparator is case-sensitive or not.
         *
         * @return true if textual comparisons should be case-sensitive; false if not
         */
        protected Boolean isCaseSensitive() {
            return caseSensitive;
        }

        /**
         * Sets the comparator's sort direction, ascending or descending. The default is ascending.
         *
         * @param ascending true for ascending; false for descending
         *
         * @return the configurable comparator
         */
        public ConfigurableComparator ascending(Boolean ascending) {
            this.ascending = ascending;
            return this;
        }

        /**
         * Whether the comparator compares in ascending or descending order.
         *
         * @return true if ascending; false if descending
         */
        protected Boolean isAscending() {
            return ascending;
        }

        /**
         * Sets the comparator's policy for ordering of null values. By default null values are ordered first.
         *
         * @param nullsFirst true for nulls first; false for nulls last
         *
         * @return the configurable comparator
         */
        public ConfigurableComparator nullsFirst(Boolean nullsFirst) {
            this.nullsFirst = nullsFirst;
            return this;
        }

        /**
         * Whether the comparator orders null values first or last.
         *
         * @return true if nulls are ordered first; false if nulls are ordered last
         */
        protected Boolean isNullsFirst() {
            return nullsFirst;
        }

        /**
         * Provides a relationship if one or both values are null.
         *
         * @param value1 the first value
         * @param value2 the second value
         *
         * @return if one or both values are null, returns -1, 0, or 1 depending on the relationship between the values
         * based on how <code>nullsFirst</code> is specified; if both values are non-null, returns null
         */
        protected Integer compareNullValues(Object value1, Object value2) {
            // Both null values => equivalent
            if ((value1 == null) && (value2 == null)) {
                //LOG.debug('  Both values are null. Returning 0.');
                return 0;
            }

            // One null value => ordered based on nullsFirst
            if (value1 == null) {
                Integer relationship = nullsFirst ? -1 : 1;
                //LOG.debug('  First value is null. Returning {0}.', relationship);
                return relationship;
            } else if (value2 == null) {
                Integer relationship = nullsFirst ? 1 : -1;
                //LOG.debug('  Second value is null. Returning {0}.', relationship);
                return relationship;
            }

            // Both are non-null, so return null saying that we don't have an answer yet
            return null;
        }

        // This is required because of a bug in the Apex compiler that causes calls to the interface method not to be resolved
        public abstract Integer compare(Object value1, Object value2);
    }

    private class LongComparator extends ConfigurableComparator {
        public override Integer compare(Object value1, Object value2) {
            Integer relationship = compareNullValues(value1, value2);
            if (relationship == null) {
                Long long1 = (Long) value1;
                Long long2 = (Long) value2;
                relationship = long1 < long2 ? -1 :
                    long1 > long2 ? 1 :
                        0;
                if (!ascending) {
                    relationship = -relationship;
                }
            }
            return relationship;
        }
    }

    /**
     * Comparator for sorting lists of long values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting long values as requested
     */
    public static ConfigurableComparator longComparator() {
        return new LongComparator();
    }

    /**
     * Comparator for sorting lists of integer values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting integer values as requested
     */
    public static ConfigurableComparator integerComparator() {
        return longComparator();
    }

    private class DecimalComparator extends ConfigurableComparator {
        public override Integer compare(Object value1, Object value2) {
            Integer relationship = compareNullValues(value1, value2);
            if (relationship == null) {
                Decimal decimal1 = (Decimal) value1;
                Decimal decimal2 = (Decimal) value2;
                relationship = decimal1 < decimal2 ? -1 :
                    decimal1 > decimal2 ? 1 :
                        0;
                if (!ascending) {
                    relationship = -relationship;
                }
            }
            return relationship;
        }
    }

    /**
     * Comparator for sorting lists of decimal values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting decimal values as requested
     */
    public static ConfigurableComparator decimalComparator() {
        return new DecimalComparator();
    }

    /**
     * Comparator for sorting lists of double values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting double values as requested
     */
    public static ConfigurableComparator doubleComparator() {
        return decimalComparator();
    }

    private class DatetimeComparator extends ConfigurableComparator {
        public override Integer compare(Object value1, Object value2) {
            Integer relationship = compareNullValues(value1, value2);
            if (relationship == null) {
                Datetime datetime1 = (Datetime) value1;
                Datetime datetime2 = (Datetime) value2;
                Long millis1 = datetime1 != null ? datetime1.getTime() : null;
                Long millis2 = datetime2 != null ? datetime2.getTime() : null;
                relationship = longComparator().configureFrom(this).compare(millis1, millis2);
            }
            return relationship;
        }
    }

    /**
     * Comparator for sorting lists of date/time values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting date/time values as requested
     */
    public static ConfigurableComparator datetimeComparator() {
        return new DatetimeComparator();
    }

    /**
     * Comparator for sorting lists of date values. The comparator can be configured to sort in ascending or 
     * descending order and with null values first or last.
     *
     * @return the comparator for sorting date values as requested
     */
    public static ConfigurableComparator dateComparator() {
        return datetimeComparator();
    }

    private class StringComparator extends ConfigurableComparator {
        public override Integer compare(Object value1, Object value2) {
            Integer relationship = compareNullValues(value1, value2);
            if (relationship == null) {
                String string1 = (String) value1;
                String string2 = (String) value2;
                relationship = caseSensitive ?
                    string1.compareTo(string2) :
                    string1.toUpperCase().compareTo(string2.toUpperCase());
                if (!ascending) {
                    relationship = -relationship;
                }
            }
            return relationship;
        }
    }

    /**
     * Comparator for sorting lists of string values. The comparator can be configured to sort in ascending or 
     * descending order, with null values first or last, and with case-sensitive/-insensitive ordering of textual values.
     *
     * @return the comparator for sorting string values as requested
     */
    public static ConfigurableComparator stringComparator() {
        return new StringComparator();
    }

    // Comparator for sorting lists of SObjects by field values
    private class SObjectFieldValueComparator extends ConfigurableComparator {
        private final SObjectField field;

        public SObjectFieldValueComparator(SObjectField field) {
            this.field = field;
        }

        public override Integer compare(Object value1, Object value2) {
            if ((value1 != null) && !(value1 instanceof SObject)) {
                throw new IllegalStateException(VALIDATION_MESSAGE_INVALID_OPERAND);
            }
            SObject sobject1 = (SObject) value1;
            if ((value2 != null) && !(value2 instanceof SObject)) {
                throw new IllegalStateException(VALIDATION_MESSAGE_INVALID_OPERAND);
            }
            SObject sobject2 = (SObject) value2;

            // Check object types
            SObjectType sobjectType1 = sobject1 != null ? sobject1.getSObjectType() : null;
            SObjectType sobjectType2 = sobject2 != null ? sobject2.getSObjectType() : null;
            if ((sobjectType1 != null) && (sobjectType2 != null) && (sobjectType1 != sobjectType2)) {
                throw new IllegalStateException(VALIDATION_MESSAGE_MISMATCHED_OPERANDS);
            }

            // Get values for the specified field
            Object fieldValue1 = sobject1 != null ? sobject1.get(field) : null;
            Object fieldValue2 = sobject2 != null ? sobject2.get(field) : null;

            Integer relationship = compareNullValues(fieldValue1, fieldValue2);
            if (relationship == null) {
                // Otherwise order values as requested in a type-safe manner
                DisplayType fieldType = field.getDescribe().getType();
                // Numeric types
                if (fieldType == DisplayType.INTEGER) {
                    //LOG.debug('  Comparing values as integers.');
                    relationship = longComparator().configureFrom(this).compare(fieldValue1, fieldValue2);
                } else if ((fieldType == DisplayType.DOUBLE) || (fieldType == DisplayType.CURRENCY) || (fieldType == DisplayType.PERCENT)) {
                    //LOG.debug('  Comparing values as decimals.');
                    relationship = decimalComparator().configureFrom(this).compare(fieldValue1, fieldValue2);
                }

                // Date/time types
                else if ((fieldType == DisplayType.DATE) || (fieldType == DisplayType.DATETIME)) {
                    //LOG.debug('  Comparing values as date/time.');
                    relationship = datetimeComparator().configureFrom(this).compare(fieldValue1, fieldValue2);
                }

                // TODO: Any other types that should be handled in a first-class fashion before punting to textual?

                // Everything else is ordered as its string equivalent
                else {
                    //LOG.debug('  Comparing values as strings.');
                    relationship = stringComparator().configureFrom(this).compare(String.valueOf(fieldValue1), String.valueOf(fieldValue2));
                }
            }
            //LOG.debug('  Relationship = {0}.', relationship);
            return relationship;
        }
    }

    /**
     * Comparator for sorting lists of SObjects by values of a specific field. The comparator can be configured to
     * sort in ascending or descending order, with null values first or last, and with case-sensitive/-insensitive
     * ordering of textual values.
     *
     * @param field the SObject field from which values should be extracted from the list of SObjects for ordering
     *
     * @return the comparator for sorting SObjects as requested
     */
    public static ConfigurableComparator sobjectFieldValueComparator(SObjectField field) {
        return new SObjectFieldValueComparator(field);
    }
}