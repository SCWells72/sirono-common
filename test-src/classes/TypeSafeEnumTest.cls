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
private class TypeSafeEnumTest extends TypeSafeEnum {

    // Test generic functionality for the base class

    @IsTest
    static void testValue() {
        Assert.equals('First Name', TypeSafeEnumTest.FIRST_NAME.value());
        Assert.equals('Middle Name', TypeSafeEnumTest.MIDDLE_NAME.value());
        Assert.equals('Last Name', TypeSafeEnumTest.LAST_NAME.value());
    }

    @IsTest
    static void testOrdinal() {
        Assert.equals(0, TypeSafeEnumTest.FIRST_NAME.ordinal());
        Assert.equals(1, TypeSafeEnumTest.MIDDLE_NAME.ordinal());
        Assert.equals(2, TypeSafeEnumTest.LAST_NAME.ordinal());
    }

    @IsTest
    static void testEqualTo() {
        Assert.isTrue(TypeSafeEnumTest.FIRST_NAME.equalTo('First Name'));
        Assert.isTrue(TypeSafeEnumTest.FIRST_NAME.equalTo('first name'));
        Assert.isTrue(TypeSafeEnumTest.FIRST_NAME.equalTo('FIRST NAME'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.equalTo('Last Name'));
    }

    @IsTest
    static void testNotEqualTo() {
        Assert.isTrue(TypeSafeEnumTest.FIRST_NAME.notEqualTo('Last Name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('First Name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('first name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('FIRST NAME'));
    }

    @IsTest
    static void testToString() {
        Assert.equals('First Name', TypeSafeEnumTest.FIRST_NAME.toString());
        Assert.equals('Middle Name', TypeSafeEnumTest.MIDDLE_NAME.toString());
        Assert.equals('Last Name', TypeSafeEnumTest.LAST_NAME.toString());
    }

    @IsTest
    static void testValueOf() {
        Assert.equals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('First Name'));
        Assert.equals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('first name'));
        Assert.equals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('FIRST NAME'));
        Assert.isNull(TypeSafeEnumTest.valueOf(null));
        Assert.isNull(TypeSafeEnumTest.valueOf('No Name'));
    }

    @IsTest
    static void testValues() {
        List<TypeSafeEnumTest> values = TypeSafeEnumTest.values();
        Assert.isNotNull(values);

        Set<TypeSafeEnumTest> expectedValues = new Set<TypeSafeEnumTest> {
            TypeSafeEnumTest.FIRST_NAME,
            TypeSafeEnumTest.MIDDLE_NAME,
            TypeSafeEnumTest.LAST_NAME
        };

        Assert.equals(expectedValues.size(), values.size());
        Assert.isTrue(expectedValues.containsAll(values));

        Integer lastOrdinal = null;
        for (TypeSafeEnumTest value : values) {
            Assert.isNotNull(value);

            // Make sure the values are ordered properly by ordinal
            Integer currentOrdinal = value.ordinal();
            if (lastOrdinal != null) {
                Assert.isTrue(currentOrdinal > lastOrdinal);
            }
            lastOrdinal = currentOrdinal;
        }
    }

    @IsTest
    private static void testMatchesAny() {
        Assert.isFalse(TypeSafeEnumTest.matchesAny(null, TypeSafeEnumTest.FIRST_NAME.value()));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(new TypeSafeEnumTest[] {}, TypeSafeEnumTest.FIRST_NAME.value()));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, 'foo'));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, ''));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, null));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isFalse(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME, TypeSafeEnumTest.MIDDLE_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isTrue(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isTrue(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME, TypeSafeEnumTest.MIDDLE_NAME, TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
    }

    @IsTest
    private static void testMatchesNone() {
        Assert.isTrue(TypeSafeEnumTest.matchesNone(null, TypeSafeEnumTest.FIRST_NAME.value()));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] {}, TypeSafeEnumTest.FIRST_NAME.value()));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, 'foo'));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, ''));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, null));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isTrue(TypeSafeEnumTest.matchesNone(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME, TypeSafeEnumTest.MIDDLE_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isFalse(TypeSafeEnumTest.matchesNone(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        Assert.isFalse(TypeSafeEnumTest.matchesNone(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME, TypeSafeEnumTest.MIDDLE_NAME, TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
    }

    // Sample implementation of TypeSafeEnum for testing purposes.
    // NOTE: Cannot be an inner class because inner classes can't be static.

    public static final TypeSafeEnumTest FIRST_NAME = new TypeSafeEnumTest('First Name');
    public static final TypeSafeEnumTest MIDDLE_NAME = new TypeSafeEnumTest('Middle Name');
    public static final TypeSafeEnumTest LAST_NAME = new TypeSafeEnumTest('Last Name');

    private TypeSafeEnumTest(String value) {
        super(TypeSafeEnumTest.class, value);
    }

    // Strongly-typed class methods

    public static TypeSafeEnumTest valueOf(String value) {
        return (TypeSafeEnumTest) TypeSafeEnum.valueOf(TypeSafeEnumTest.class, value);
    }

    public static List<TypeSafeEnumTest> values() {
        return (List<TypeSafeEnumTest>) TypeSafeEnum.values(TypeSafeEnumTest.class, new List<TypeSafeEnumTest>());
    }

    public static Boolean matchesAny(TypeSafeEnumTest[] values, String testValues) {
        return TypeSafeEnum.matchesAny(values, testValues);
    }

    public static Boolean matchesNone(TypeSafeEnumTest[] values, String testValue) {
        return TypeSafeEnum.matchesNone(values, testValue);
    }
}
