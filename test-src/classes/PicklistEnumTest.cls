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
                PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT_VALUE => PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT,
                PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE_VALUE => PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE,
                PicklistEnumTest.NEW_CUSTOMER_VALUE => PicklistEnumTest.NEW_CUSTOMER
            },
            PicklistEnumTest.values()
        );
    }

    @IsTest
    static void testEqualTo() {
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toLowerCase()));
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toUpperCase()));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.equalTo(NEW_CUSTOMER_VALUE));
    }

    @IsTest
    static void testNotEqualTo() {
        Assert.isTrue(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(NEW_CUSTOMER_VALUE));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toLowerCase()));
        Assert.isFalse(PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.notEqualTo(EXISTING_CUSTOMER_UPGRADE_VALUE.toUpperCase()));
    }

    @IsTest
    static void testToString() {
        Assert.equals(EXISTING_CUSTOMER_UPGRADE_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_UPGRADE.toString());
        Assert.equals(EXISTING_CUSTOMER_REPLACEMENT_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_REPLACEMENT.toString());
        Assert.equals(EXISTING_CUSTOMER_DOWNGRADE_VALUE, PicklistEnumTest.EXISTING_CUSTOMER_DOWNGRADE.toString());
        Assert.equals(NEW_CUSTOMER_VALUE, PicklistEnumTest.NEW_CUSTOMER.toString());
    }

    // Sample implementation of PicklistEnum for testing purposes.
    // NOTE: Cannot be an inner class because inner classes can't be static.

    private static final PicklistEnumTest INSTANCE = new PicklistEnumTest();

    private static final String EXISTING_CUSTOMER_UPGRADE_VALUE = 'Existing Customer - Upgrade';
    private static final String EXISTING_CUSTOMER_REPLACEMENT_VALUE = 'Existing Customer - Replacement';
    private static final String EXISTING_CUSTOMER_DOWNGRADE_VALUE = 'Existing Customer - Downgrade';
    private static final String NEW_CUSTOMER_VALUE = 'New Customer';

    private static final Entry EXISTING_CUSTOMER_UPGRADE = valueOf(EXISTING_CUSTOMER_UPGRADE_VALUE);
    private static final Entry EXISTING_CUSTOMER_REPLACEMENT = valueOf(EXISTING_CUSTOMER_REPLACEMENT_VALUE);
    private static final Entry EXISTING_CUSTOMER_DOWNGRADE = valueOf(EXISTING_CUSTOMER_DOWNGRADE_VALUE);
    private static final Entry NEW_CUSTOMER = valueOf(NEW_CUSTOMER_VALUE);

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
