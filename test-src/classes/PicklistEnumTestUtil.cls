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
 * Utility methods for simplified testing of picklist enum implementations.
 */
@IsTest
public class PicklistEnumTestUtil {

    private PicklistEnumTestUtil() {
        // Utility class
    }

    public static void verifyPicklistEnum(Schema.SObjectField picklistField, Map<String, PicklistEnum.Entry> picklistEnumEntriesByValue, PicklistEnum.Entry[] picklistEnumEntries) {
        Map<PicklistEntry, PicklistEnum.Entry> entryMap = new Map<PicklistEntry, PicklistEnum.Entry>();
        for (PicklistEntry picklistEntry : picklistField.getDescribe().getPicklistValues()) {
            PicklistEnum.Entry picklistEnumEntry = picklistEnumEntriesByValue.get(picklistEntry.getValue());
            Assert.notNull(picklistEnumEntry, 'Failed to find an entry for ' + picklistEntry.getValue());
            entryMap.put(picklistEntry, picklistEnumEntry);
        }
        System.assertEquals(picklistEnumEntriesByValue.size(), entryMap.size());

        for (PicklistEntry picklistEntry : entryMap.keySet()) {
            PicklistEnum.Entry paymentSourceEnumValue = entryMap.get(picklistEntry);

            System.assertEquals(picklistEntry.getValue(), paymentSourceEnumValue.value());
            System.assertEquals(picklistEntry.getLabel(), paymentSourceEnumValue.label());
            System.assertEquals(picklistEntry.isActive(), paymentSourceEnumValue.isActive());
            System.assertEquals(picklistEntry.isDefaultValue(), paymentSourceEnumValue.isDefaultValue());
        }

        Set<PicklistEnum.Entry> expectedPicklistEnumEntries = new Set<PicklistEnum.Entry>(picklistEnumEntriesByValue.values());
        System.assertEquals(expectedPicklistEnumEntries.size(), picklistEnumEntries.size(),
            'Expected ' + expectedPicklistEnumEntries.size() + ' entries but found ' + picklistEnumEntries.size());
        System.assert(expectedPicklistEnumEntries.containsAll(picklistEnumEntries), 'The two sets of entries differ');
    }
}