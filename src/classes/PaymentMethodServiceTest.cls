@isTest
public with sharing class PaymentMethodServiceTest {

    @isTest
    public static void testGetPaymentMethods() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        List<Payment_Method__c> pms = createPaymentMethods(guarantorContact);
        Payment_Method__c pm1 = pms.get(0);
        Payment_Method__c pm2 = pms.get(1);

        Test.startTest();
        List<Payment_Method__c> results = PaymentMethodService.getPaymentMethods(guarantorContact.Id);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should find the PMs.');
    }

    @isTest
    public static void testGetPaymentMethodsNoResults() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();

        Test.startTest();
        List<Payment_Method__c> pms = PaymentMethodService.getPaymentMethods(guarantorContact.Id);
        Test.stopTest();

        System.assertEquals(0, pms.size(), 'Should not find any PMs.');
    }

    @isTest
    public static void testGetCreditCard() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        List<Payment_Method__c> pms = createPaymentMethods(guarantorContact);
        Payment_Method__c card = pms.get(0);

        Test.startTest();
        Payment_Method__c queryCard = PaymentMethodService.getCreditCard(card.Id);
        Payment_Method__c noCard = PaymentMethodService.getCreditCard('notAnId');
        Test.stopTest();

        System.assertEquals(card.Id, queryCard.Id, 'Should have found an existing card.');
        System.assertEquals(null, noCard, 'Should return null if no card is found.');
    }

    @isTest
    public static void testGeneratePaymentMethod() {
        PaymentPlanInformation ppInfo = new PaymentPlanInformation(new Map<String, Object>{
            PaymentPlanInformation.EXPIRATION_YEAR => '2020',
            PaymentPlanInformation.EXPIRATION_MONTH => '5',
            PaymentPlanInformation.CREDITCARD_NUMBER => '4111111111111234',
            PaymentPlanInformation.CARD_HOLDER_NAME => 'Ihold AllTheCards'
        });
        User guarantor = TestUtility.getGuarantorCommunityUser();

        Test.startTest();
        Payment_Method__c payMethod = PaymentMethodService.generatePaymentMethod(ppInfo, guarantor.Id);
        Test.stopTest();

        System.assertEquals('Visa', payMethod.Card_Type__c, 'Should default to visa.');
        System.assertEquals(Constants.CREDIT_CARD, payMethod.Type__c, 'Should default to credit card type.');
        System.assertEquals('Ihold AllTheCards', payMethod.Card_Holder_Name__c, 'Should populate last four.');
        System.assertEquals(guarantor.Id, payMethod.Guarantor__c, 'Should correctly map Guarantor.');
        System.assertEquals(Date.newInstance(2020, 5, 1), payMethod.Expiration_Date__c, 'Should create expiration date.');
        System.assertEquals('1234', payMethod.Last_4__c, 'Should populate last four.');
    }

    @isTest
    public static void testGetPaymentMethodExpiration() {
        String month = '1';
        String year = '1980';

        Test.startTest();
        Date expDate = PaymentMethodService.getPaymentMethodExpiration(month, year);
        Test.stopTest();

        System.assertNotEquals(null, expDate, 'Should exist.');
        System.assertEquals(Date.newInstance(1980, 1, 1), expDate, 'Should equal expected date.');
    }

    @isTest
    public static void testGetPaymentMethodExpirationBlanks() {
        String month = '2';
        String year = '1992';
        String blank = '';

        Test.startTest();
        Date blankYearDate = PaymentMethodService.getPaymentMethodExpiration(month, blank);
        Date blankMonthDate = PaymentMethodService.getPaymentMethodExpiration(blank, year);
        Date blankBothDate = PaymentMethodService.getPaymentMethodExpiration(blank, blank);

        Test.stopTest();

        System.assertEquals(null, blankYearDate, 'Should be null with blank year.');
        System.assertEquals(null, blankMonthDate, 'Should be null with blank day.');
        System.assertEquals(null, blankBothDate, 'Should be null with both blank.');
    }

    @isTest
    public static void testGetLastFourPopulated() {
        String ccNum = '4111111111111532';

        Test.startTest();
        String result = PaymentMethodService.getLastFour(ccNum);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should exist.');
        System.assertEquals('1532', result, 'Should create last for digits string.');
    }

    @isTest
    public static void testGetLastFourBlank() {
        String ccNumShort = '333';
        String ccNum = '';

        Test.startTest();
        String result = PaymentMethodService.getLastFour(ccNum);
        String shorty = PaymentMethodService.getLastFour(ccNumShort);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should exist.');
        System.assert(String.isBlank(result), 'Should be empty.');
        System.assertNotEquals(null, shorty, 'Should exist.');
        System.assert(String.isBlank(shorty), 'Should be empty.');
    }

    private static List<Payment_Method__c> createPaymentMethods(Contact guarantorContact) {

        List<Payment_Method__c> pms = new List<Payment_Method__c>();

        PaymentPlanInformation ppInfo = new PaymentPlanInformation();
        ppInfo.cardholderName = 'Spending DaMoney';
        ppInfo.expirationMonth = '6';
        ppInfo.expirationYear = '2020';
        ppInfo.creditCardNumber = '4111111111111111';

        pms.add(PaymentMethodService.generatePaymentMethod(ppInfo, guarantorContact.Id));

        ppInfo.cardholderName = 'Spending DaMoney Jr';
        ppInfo.expirationMonth = '12';
        ppInfo.expirationYear = '2025';
        ppInfo.creditCardNumber = '4111111111111234';

        pms.add(PaymentMethodService.generatePaymentMethod(ppInfo, guarantorContact.Id));

        INSERT pms;

        return pms;

    }
}