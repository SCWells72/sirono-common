@isTest
private class AddToPaymentPlanLightningTest { 
	@isTest
	static void passAllValidation(){
		//Create Guarantor Contact record.
        Contact g = TestUtility.generateGuarantorContact();
		g.Profile_Pointer_Id__c = 23232323;
        insert g;

        //Create Patient Contact record.
        Contact p = TestUtility.generatePatientContact();
        insert p;

        //Create Payment Plan record.
        Payment_Plan__c t = TestUtility.generatePaymentPlan(g.Id);
        t.Active__c = true;
		t.Sirono_ID__c = 2876;
        insert t;
		system.debug('Active Payment Plan:' + t);
        
		//Create Invoice record.
        Invoice__c i = TestUtility.generateInvoice(g.Id,p.Id);
        insert i;

        //Create Charge Group record.
        Charge_Group__c   cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Charge_Group_External_ID__c = true;
		cg.Sirono_ID__c = Math.round(cg.Sirono_ID__c * 100);
        insert cg;
		System.debug('CG:'+cg);

        //Create Transaction record.
        Transaction__c  transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;

        //Create Charge Group record with different Charge Group ID.
        cg = TestUtility.generateChargeGroup(g.Id,null,121114);
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Sirono_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        //Create Transaction record.
        transactionObj = TestUtility.generateTransaction(cg ,100,'Automatic');
        insert transactionObj;
	Test.startTest();
	AddToPaymentPlanLightning ppCon = new AddToPaymentPlanLightning(g.id);
        for (ChargeGroupWrapper cgw: ppCon.chargeGroupList) {
            cgw.isSelected = true;
        }

        ppCon.doNext();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        ppCon.submit();
		List<Charge_Group__c> checkResults = [SELECT id, 
													 Account_Sub_Status__c 
											  FROM Charge_Group__c];
		Test.stopTest();
		System.assertEquals('On Payment Plan', checkResults[0].Account_Sub_Status__c);
		System.assertEquals('On Payment Plan', checkResults[1].Account_Sub_Status__c);
		
	}
}