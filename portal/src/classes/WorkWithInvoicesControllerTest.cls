/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class WorkWithInvoicesControllerTest {
    @IsTest static void invoicesTest() {
        Contact guarantorContact;
        Contact patientContact;
        sPRS__Invoice__c invoice1;
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        System.runAs(adminUser) {
            Account testAcc = PortalTestUtility.getPortalAccount();
            guarantorContact = PortalTestUtility.getPortalGuarantor();

            patientContact = PortalTestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.sPRS__Medical_Record_Number__c = '1234512345';
            insert patientContact;

            sPRS__Payment_Plan__c pPlan = PortalTestUtility.generatePaymentPlan(guarantorContact.Id);
            insert pPlan;

            List<sPRS__Invoice__c> lstInvoice = new List<sPRS__Invoice__c>();
            invoice1 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice1);

            sPRS__Invoice__c invoice2 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice2);

            sPRS__Invoice__c invoice3 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            invoice3.sPRS__Status_Index__c = 2;
            lstInvoice.add(invoice3);

            insert lstInvoice;

            List<sPRS__Charge_Group__c> lstChrgGroup = new List<sPRS__Charge_Group__c>();
            sPRS__Charge_Group__c chargeGroup1 = PortalTestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup1.sPRS__Invoice__c = invoice1.Id;
            lstChrgGroup.add(chargeGroup1);

            sPRS__Charge_Group__c chargeGroup2 = PortalTestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup2.sPRS__Invoice__c = invoice2.Id;
            lstChrgGroup.add(chargeGroup2);
            insert lstChrgGroup;

            sPRS__Payor__c payorTest = new sPRS__Payor__c(
                Name = 'payotTest'
            );
            insert payorTest;

            sPRS__Coverage__c objcoverage = new sPRS__Coverage__c(
                Name = 'Test',
                sPRS__Payor__c = payorTest.Id
            );
            insert objcoverage;

            sPRS__Charge_Group_Coverage_Junction__c objCGCoverage = new sPRS__Charge_Group_Coverage_Junction__c();
            objCGCoverage.Name = 'Test';
            objCGCoverage.sPRS__Charge_Group__c = chargeGroup1.Id;
            objCGCoverage.sPRS__Coverage__c = objcoverage.Id;
            insert objCGCoverage;

            sPRS__Service2__c serviceTest = new sPRS__Service2__c(
                sPRS__Guarantor__c = guarantorContact.Id
            );
            insert serviceTest;

            sPRS__Adjustment__c testAdjustment = new sPRS__Adjustment__c(
                sPRS__Description__c = 'BC/BS adjustment', sPRS__Amount__c = 200, sPRS__Guarantor__c = guarantorContact.Id
            );
            insert testAdjustment;

            sPRS__Payment__c payment1 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            sPRS__Payment__c payment2 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            List<sPRS__Payment__c> lstPayment = new List<sPRS__Payment__c> {
                payment1, payment2
            };
            insert lstPayment;

            List<sPRS__Transaction__c> lstTransaction = new List<sPRS__Transaction__c>();
            sPRS__Transaction__c transaction1 = PortalTestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
            lstTransaction.add(transaction1);

            sPRS__Transaction__c transaction2 = PortalTestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
            lstTransaction.add(transaction2);

            sPRS__Transaction__c transaction3 = PortalTestUtility.generateServiceTxn(chargeGroup2, 20, serviceTest);
            lstTransaction.add(transaction3);

            sPRS__Transaction__c transaction4 = PortalTestUtility.generateServiceTxn(chargeGroup2, 200, serviceTest);
            lstTransaction.add(transaction4);

            sPRS__Transaction__c transaction5 = PortalTestUtility.generateAdjTxn(chargeGroup2, 200, testAdjustment);
            lstTransaction.add(transaction5);
            insert lstTransaction;

            invoice1.sPRS__Status_Index__c = 9;
            invoice2.sPRS__Status_Index__c = 4;
            List<sPRS__Invoice__c> lstInvoiceUpdate = new List<sPRS__Invoice__c> {
                invoice1, invoice2
            };
            update lstInvoiceUpdate;
        }

        List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
        System.assertEquals(0, patientList.size());

        System.runAs(portalUser) {
            Test.startTest();

            List<WorkWithInvoicesController.InvoicesWrapper> invoiceList = WorkWithInvoicesController.getAllInvoices(PortalConstants.UNPAID, new List<String> {
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Unpaid invoice.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(PortalConstants.PAID, new List<String> {
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Paid Invoice.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(PortalConstants.UNKNOWN, new List<String> {
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Unknown Invoice for patient.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(PortalConstants.UNKNOWN, new List<String>());
            System.assertEquals(1, invoiceList.size(), 'Should have found Unknown Invoice for any patient.');
            invoiceList = WorkWithInvoicesController.getInvoice(invoice1.Id);
            System.assertEquals(1, invoiceList.size(), 'Should be able to look up Invoice.');

            patientList = WorkWithInvoicesController.getPatientList();
            System.assertEquals(3, patientList.size(), 'Should find the patients.');

            Test.stopTest();
        }
    }

    @IsTest static void estimatesTest() {
        Contact guarantorContact;
        Contact patientContact;
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();
        sPRS__Encounter__c encounter1;

        System.runAs(adminUser) {
            Account testAcc = PortalTestUtility.getPortalAccount();
            guarantorContact = PortalTestUtility.getPortalGuarantor();

            patientContact = PortalTestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.sPRS__Medical_Record_Number__c = '1234512345';
            insert patientContact;

            List<sPRS__Encounter__c> encounters = new List<sPRS__Encounter__c>();
            encounter1 = PortalTestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
            encounter1.sPRS__Patient__c = patientContact.Id;
            encounter1.sPRS__Insurance_Discount__c = 2;
            encounter1.sPRS__Insurance_Portion__c = 2;
            encounters.add(encounter1);
            sPRS__Encounter__c encounter2 = PortalTestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
            encounter2.sPRS__Total_Payments__c = 5;
            encounter2.sPRS__Patient__c = patientContact.Id;
            encounter2.sPRS__Insurance_Discount__c = 3;
            encounter2.sPRS__Insurance_Portion__c = 2;
            encounters.add(encounter2);

            insert encounters;

            Attachment testAttach = new Attachment(
                Body = Blob.valueOf('Test string'),
                Name = 'test attach',
                ParentId = encounter1.Id
            );
            insert testAttach;
        }

        System.runAs(portalUser) {
            Test.startTest();

            List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithInvoicesController.getAllEstimates(PortalConstants.UNPAID, patientContact.Id);
            System.assertEquals(estimateList.size(), 1);
            estimateList = WorkWithInvoicesController.getAllEstimates(PortalConstants.PAID, 'null');
            System.assertEquals(estimateList.size(), 0);
            estimateList = WorkWithInvoicesController.getEstimate(encounter1.Id);
            System.assertEquals(estimateList.size(), 1);

            Test.stopTest();
        }
    }
}