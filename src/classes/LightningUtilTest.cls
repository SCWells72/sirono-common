/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class LightningUtilTest {

    @IsTest
    static void testNewAuraHandledException() {
        AuraHandledException ex = LightningUtil.newAuraHandledException('Test message');
        System.assertNotEquals(null, ex);
        System.assertEquals('Test message', ex.getMessage());
    }
}