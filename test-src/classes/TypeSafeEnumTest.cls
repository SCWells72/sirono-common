/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class TypeSafeEnumTest extends TypeSafeEnum {

    // Test generic functionality for the base class

    @IsTest
    static void testValue() {
        System.assertEquals('First Name', TypeSafeEnumTest.FIRST_NAME.value());
        System.assertEquals('Middle Name', TypeSafeEnumTest.MIDDLE_NAME.value());
        System.assertEquals('Last Name', TypeSafeEnumTest.LAST_NAME.value());
    }

    @IsTest
    static void testOrdinal() {
        System.assertEquals(0, TypeSafeEnumTest.FIRST_NAME.ordinal());
        System.assertEquals(1, TypeSafeEnumTest.MIDDLE_NAME.ordinal());
        System.assertEquals(2, TypeSafeEnumTest.LAST_NAME.ordinal());
    }

    @IsTest
    static void testEqualTo() {
        System.assert(TypeSafeEnumTest.FIRST_NAME.equalTo('First Name'));
        System.assert(TypeSafeEnumTest.FIRST_NAME.equalTo('first name'));
        System.assert(TypeSafeEnumTest.FIRST_NAME.equalTo('FIRST NAME'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.equalTo('Last Name'));
    }

    @IsTest
    static void testNotEqualTo() {
        System.assert(TypeSafeEnumTest.FIRST_NAME.notEqualTo('Last Name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('First Name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('first name'));
        Assert.isFalse(TypeSafeEnumTest.FIRST_NAME.notEqualTo('FIRST NAME'));
    }

    @IsTest
    static void testToString() {
        System.assertEquals('First Name', TypeSafeEnumTest.FIRST_NAME.toString());
        System.assertEquals('Middle Name', TypeSafeEnumTest.MIDDLE_NAME.toString());
        System.assertEquals('Last Name', TypeSafeEnumTest.LAST_NAME.toString());
    }

    @IsTest
    static void testValueOf() {
        System.assertEquals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('First Name'));
        System.assertEquals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('first name'));
        System.assertEquals(TypeSafeEnumTest.FIRST_NAME, TypeSafeEnumTest.valueOf('FIRST NAME'));
        Assert.isNull(TypeSafeEnumTest.valueOf(null));
        Assert.isNull(TypeSafeEnumTest.valueOf('No Name'));
    }

    @IsTest
    static void testValues() {
        List<TypeSafeEnumTest> values = TypeSafeEnumTest.values();
        Assert.notNull(values);

        Set<TypeSafeEnumTest> expectedValues = new Set<TypeSafeEnumTest> {
            TypeSafeEnumTest.FIRST_NAME,
            TypeSafeEnumTest.MIDDLE_NAME,
            TypeSafeEnumTest.LAST_NAME
        };

        System.assertEquals(expectedValues.size(), values.size());
        System.assert(expectedValues.containsAll(values));

        Integer lastOrdinal = null;
        for (TypeSafeEnumTest value : values) {
            Assert.notNull(value);

            // Make sure the values are ordered properly by ordinal
            Integer currentOrdinal = value.ordinal();
            if (lastOrdinal != null) {
                System.assert(currentOrdinal > lastOrdinal);
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
        System.assert(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        System.assert(TypeSafeEnumTest.matchesAny(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME, TypeSafeEnumTest.MIDDLE_NAME, TypeSafeEnumTest.FIRST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
    }

    @IsTest
    private static void testMatchesNone() {
        System.assert(TypeSafeEnumTest.matchesNone(null, TypeSafeEnumTest.FIRST_NAME.value()));
        System.assert(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] {}, TypeSafeEnumTest.FIRST_NAME.value()));
        System.assert(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, 'foo'));
        System.assert(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, ''));
        System.assert(TypeSafeEnumTest.matchesNone(new TypeSafeEnumTest[] { TypeSafeEnumTest.FIRST_NAME }, null));
        System.assert(TypeSafeEnumTest.matchesNone(
            new TypeSafeEnumTest[] { TypeSafeEnumTest.LAST_NAME },
            TypeSafeEnumTest.FIRST_NAME.value()
        ));
        System.assert(TypeSafeEnumTest.matchesNone(
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
