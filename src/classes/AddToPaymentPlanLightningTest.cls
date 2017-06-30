@isTest
private class AddToPaymentPlanLightningTest { 
    @isTest
    static void passAllValidation(){
        // Create Guarantor Contact record.
        Contact g = TestUtility.generateGuarantorContact();
        g.Profile_Pointer_Id__c = 23232323;
        INSERT g;

        // Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        INSERT p;

        // Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
        t.Sirono_ID__c = 2876;
        INSERT t;
        
        // Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
        INSERT i;

        // Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
        cg.Sirono_ID__c = Math.round(cg.Sirono_ID__c * 100);
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT cg;

        // Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        INSERT transactionObj;

        // Create Charge Group record with different Charge Group ID.
        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        INSERT cg;

        // Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        INSERT transactionObj;
        Test.startTest();
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.id);
        for (ChargeGroupWrapper cgw: ppCon.chargeGroupList) {
            cgw.isSelected = true;
        }

        ppCon.doNext();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        ppCon.submit();
        List<Charge_Group__c> checkResults = [SELECT Id, 
                                                    Account_Sub_Status__c 
                                              FROM Charge_Group__c];
        Test.stopTest();

        // Check system asserts.
        System.assertEquals('On Payment Plan', checkResults[0].Account_Sub_Status__c);
        System.assertEquals('On Payment Plan', checkResults[1].Account_Sub_Status__c);
    }

    /**
     * This test checks the logic of submit method.
     * If CG is successfully added into PP than we got success message.
     **/
    @isTest
    static void testSuccess(){
        // Create Guarantor Contact record.
        Contact guarantor = TestUtility.generateGuarantorContact();
        guarantor.Profile_Pointer_Id__c = 23232323;
        INSERT guarantor;

        // Create Payment Plan record.
        Payment_Plan__c pp = TestUtility.generatePaymentPlan(guarantor.Id);
        pp.Active__c = true;
        pp.Sirono_ID__c = 2876;
        INSERT pp;

        // Create Charge Group record.
        Charge_Group__c cg = TestUtility.generateChargeGroup(guarantor.Id, null, 121114);
        cg.Charge_Group_External_ID__c = true;
        cg.Sirono_ID__c = Math.round(cg.Sirono_ID__c * 100);
        INSERT cg;

        // Create Transaction record.
        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        INSERT transactionObj;

        Test.startTest();
        AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(guarantor.id);
        for (ChargeGroupWrapper cgw: ppCon.chargeGroupList) {
            cgw.isSelected = true;
        }

        ppCon.doNext();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        String message = ppCon.submit();
        Test.stopTest();

        // Check system assert.
        System.assertEquals(message, 'Added Successfully!');
    }
}