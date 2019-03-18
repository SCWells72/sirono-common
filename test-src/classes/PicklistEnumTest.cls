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
private class PicklistEnumTest extends PicklistEnum {

    // Test generic functionality for the base class
    @IsTest
    private static void testPicklistEnum() {
        List<Schema.PicklistEntry> picklistEntries = Opportunity.Type.getDescribe().getPicklistValues();
        for (PicklistEntry picklistEntry : picklistEntries) {
            String value = picklistEntry.getValue();
            PicklistEnum.Entry entry = PicklistEnumTest.valueOf(value);
            Assert.isNotNull(entry, 'Expected to find a picklist enum entry for ' + value);
            Assert.equals(value, entry.value(), 'Incorrect value for entry.');

            String label = picklistEntry.getLabel();
            Assert.equals(label, entry.label(), 'Incorrect label for entry.');

            Boolean active = picklistEntry.isActive();
            Assert.equals(active, entry.isActive(), 'Incorrect active state for entry.');

            Boolean defaultValue = picklistEntry.isDefaultValue();
            Assert.equals(defaultValue, entry.isDefaultValue(), 'Incorrect default value state for entry.');
        }
    }

    // Test a sample implementation of the base class
    @IsTest
    private static void testOpportunityTypeEnum() {
        PicklistEnumTestUtil.verifyPicklistEnum(
            Opportunity.Type,
            new Map<String, PicklistEnum.Entry> {
                PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE_VALUE => PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE,
                PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT_VALUE => PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT
//                ,
//                PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE_VALUE => PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE,
//                PicklistEnumTest.NEW_CUSTOMER_VALUE => PicklistEnumTest.NEW_CUSTOMER
            },
            PicklistEnumTest.values()
        );
    }

    @IsTest
    static void testEqualTo() {
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toLowerCase()));
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toUpperCase()));
//        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(NEW_CUSTOMER_VALUE));
    }

    @IsTest
    static void testNotEqualTo() {
//        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(NEW_CUSTOMER_VALUE));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toLowerCase()));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toUpperCase()));
    }

    @IsTest
    static void testToString() {
        Assert.equals(EXISTING_CUSTOMER_UPGRADE_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.toString());
        Assert.equals(EXISTING_CUSTOMER_REPLACEMENT_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT.toString());
//        Assert.equals(EXISTING_CUSTOMER_DOWNGRADE_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE.toString());
//        Assert.equals(NEW_CUSTOMER_VALUE, PicklistEnumTest.NEW_CUSTOMER.toString());
    }

    @IsTest
    static void testMatchesAny() {
        Assert.isTrue(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isTrue(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), EXISTING_CUSTOMER_REPLACEMENT_VALUE));
//        Assert.isTrue(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), EXISTING_CUSTOMER_DOWNGRADE_VALUE));
//        Assert.isTrue(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), NEW_CUSTOMER_VALUE));
//        Assert.isTrue(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), NEW_CUSTOMER_VALUE.toLowerCase().capitalize()));

        Assert.isFalse(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), null));
        Assert.isFalse(PicklistEnumTest.matchesAny(PicklistEnumTest.values(), 'Yadda Yadda'));
        Assert.isFalse(PicklistEnumTest.matchesAny(new Entry[]{}, 'Yadda Yadda'));
    }

    @IsTest
    static void testMatchesNone() {
        Assert.isFalse(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isFalse(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), EXISTING_CUSTOMER_REPLACEMENT_VALUE));
//        Assert.isFalse(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), EXISTING_CUSTOMER_DOWNGRADE_VALUE));
//        Assert.isFalse(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), NEW_CUSTOMER_VALUE));
//        Assert.isFalse(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), NEW_CUSTOMER_VALUE.toLowerCase().capitalize()));

        Assert.isTrue(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), null));
        Assert.isTrue(PicklistEnumTest.matchesNone(PicklistEnumTest.values(), 'Yadda Yadda'));
        Assert.isTrue(PicklistEnumTest.matchesNone(new Entry[]{}, 'Yadda Yadda'));
    }

    @IsTest
    static void testToStrings() {
        String[] expectedValues = new String[]{
            EXISTING_CUSTOMER_UPGRADE_VALUE,
            EXISTING_CUSTOMER_REPLACEMENT_VALUE
//            ,
//            EXISTING_CUSTOMER_DOWNGRADE_VALUE,
//            NEW_CUSTOMER_VALUE
        };
        expectedValues.sort();

        String[] allStringValues = PicklistEnumTest.toStrings(PicklistEnumTest.values());
        allStringValues.sort();

        Assert.equals(expectedValues, allStringValues);
    }

    // Sample implementation of PicklistEnum for testing purposes.
    // NOTE: Cannot be an inner class because inner classes can't be static.

    private static final PicklistEnumTest INSTANCE = new PicklistEnumTest();

    private static final String EXISTING_CUSTOMER_UPGRADE_VALUE = 'Existing Business';
    private static final String EXISTING_CUSTOMER_REPLACEMENT_VALUE = 'New Business';
//    private static final String EXISTING_CUSTOMER_DOWNGRADE_VALUE = 'Existing Customer - Downgrade';
//    private static final String NEW_CUSTOMER_VALUE = 'New Customer';

    // TODO: Unfortunately no picklist entry is flagged as default so that logic isn't tested
    private static final Entry EXISTING_CUSTOMER_UPGRADE = valueOf(EXISTING_CUSTOMER_UPGRADE_VALUE);
    private static final Entry EXISTING_CUSTOMER_REPLACEMENT = valueOf(EXISTING_CUSTOMER_REPLACEMENT_VALUE);
//    private static final Entry EXISTING_CUSTOMER_DOWNGRADE = valueOf(EXISTING_CUSTOMER_DOWNGRADE_VALUE);
//    private static final Entry NEW_CUSTOMER = valueOf(NEW_CUSTOMER_VALUE);

    private PicklistEnumTest() {
        super(Opportunity.Type);
    }

    public static Entry valueOf(String value) {
        return INSTANCE.getEntry(value);
    }

    public static Entry[] values() {
        return INSTANCE.getEntries();
    }
}
