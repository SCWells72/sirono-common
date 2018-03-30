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
 * Base class for enum-like classes which provide Apex compile-time constants for picklist field values.
 */
public with sharing abstract class PicklistEnum {

    /**
     * Each entry corresponds to a single distinct value for the enum's picklist field.
     */
    public with sharing class Entry {
        private String value { get; set; }
        private String label { get; set; }
        private Boolean active { get; set; }
        private Boolean defaultValue { get; set; }

        /**
         * Creates a new picklist enum entry for the specified enum and picklist field entry.
         *
         * @param picklistEnum the parent picklist enum
         * @param picklistEntry the picklist field entry
         */
        private Entry(PicklistEnum picklistEnum, Schema.PicklistEntry picklistEntry) {
            this.value = picklistEntry.getValue();
            this.label = picklistEntry.getLabel();
            this.active = picklistEntry.isActive();
            this.defaultValue = picklistEntry.isDefaultValue();

            // Move the default entry to the front of the list
            if (this.defaultValue) {
                List<Entry> reorderedEntries = new List<Entry>();
                reorderedEntries.add(this);
                for (Entry entry : picklistEnum.entries) {
                    if (entry.defaultValue) {
                        throw new IllegalStateException('Only one entry may be designated as the default value.');
                    }
                    reorderedEntries.add(entry);
                }
                picklistEnum.entries = reorderedEntries;
            } else {
                picklistEnum.entries.add(this);
            }
        }

        /**
         * Returns the string value of the enum entry.
         *
         * @return the enum entry's string value
         */
        public String value() {
            return value;
        }

        /**
         * Returns the label of the enum entry.
         *
         * @return the enum entry's label
         */
        public String label() {
            return label;
        }

        /**
         * Returns whether the enum entry is active or not
         *
         * @return whether the enum entry is active
         */
        public Boolean isActive() {
            return active;
        }

        /**
         * Returns whether the enum entry is the enum's default value
         *
         * @return whether the enum entry is the enum's default value
         */
        public Boolean isDefaultValue() {
            return defaultValue;
        }

        /**
         * Determines whether the specified string value is equivalent (case-insensitive) to this picklist enum entry.
         *
         * @param testValue the value to be tested for equivalence
         *
         * @return <code>true</code> if the specified value matches this entry; otherwise <code>false</code>
         */
        public Boolean equalTo(String testValue) {
            return value.equalsIgnoreCase(testValue);
        }

        /**
         * Determines whether the specified string value is different from this picklist enum entry.
         *
         * @param testValue the value to be tested for difference
         *
         * @return <code>true</code> if the specified value is different from this entry; otherwise <code>false</code>
         */
        public Boolean notEqualTo(String testValue) {
            return !equalTo(testValue);
        }

        /**
         * Returns the string value of this picklist enum entry.
         *
         * @return the enum entry's string value
         */
        public override String toString() {
            return value;
        }
    }

    private Schema.SObjectField picklistField;
    private List<Entry> entries = new List<Entry>();
    private Map<String, Entry> entriesByValue = new Map<String, Entry>();

    /**
     * Creates a new picklist enum for the specified picklist-type field with an optional custom labels.
     *
     * @param picklistField the picklist field
     */
    protected PicklistEnum(Schema.SObjectField picklistField) {
        if (picklistField == null) {
            throw new IllegalArgumentException('A field must be provided.');
        }

        Schema.DescribeFieldResult fieldDescribe = picklistField.getDescribe();
        if (fieldDescribe.getType() != Schema.DisplayType.PICKLIST) {
            throw new IllegalArgumentException('The provided field ' + picklistField.getDescribe().getName() + ' is not a picklist.');
        }

        this.picklistField = picklistField;
        createEntries();
    }

    private void createEntries() {
        Schema.DescribeFieldResult picklistDescribe = picklistField.getDescribe();
        for (Schema.PicklistEntry picklistEntry : picklistDescribe.getPicklistValues()) {
            Entry entry = new Entry(this, picklistEntry);
            entriesByValue.put(entry.value, entry);
        }
    }

    /**
     * Returns the entry with the provided value parameter.
     *
     * @param value the value for which a picklist enum entry should be returned
     *
     * @return the corresponding entry or <code>null</code> if no entry exists for the specified value
     */
    public Entry getEntry(String value) {
        return entriesByValue.get(value);
    }

    /**
     * Returns all entries for the picklist enum.
     *
     * @return all entries for this picklist enum
     */
    public Entry[] getEntries() {
        return entries;
    }
}
