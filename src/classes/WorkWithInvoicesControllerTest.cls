/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
private class WorkWithInvoicesControllerTest {
    @isTest static void invoicesTest() {
        Contact guarantorContact;
        Contact patientContact;
        Invoice__c invoice1;
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        System.runAs(adminUser) {
            Account testAcc = TestUtility.getPortalAccount();
            guarantorContact = TestUtility.getPortalGuarantor();

            patientContact = TestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.Medical_Record_Number__c = '1234512345';
            INSERT patientContact;

            Payment_Plan__c pPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
            INSERT pPlan;

            List<Invoice__c> lstInvoice = new List<Invoice__c>();
            invoice1 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice1);

            Invoice__c invoice2 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice2);

            Invoice__c invoice3 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            invoice3.Invoice_Status_Index__c = 2;
            lstInvoice.add(invoice3);

            INSERT lstInvoice;

            List<Charge_Group__c> lstChrgGroup = new List<Charge_Group__c>();
            Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup1.Invoice__c = invoice1.Id;
            lstChrgGroup.add(chargeGroup1);

            Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup2.Invoice__c = invoice2.Id;
            lstChrgGroup.add(chargeGroup2);
            INSERT lstChrgGroup;

            Payor__c payorTest = new Payor__c(
                Name = 'payotTest'
            );
            INSERT payorTest;

            Coverage__c objcoverage = new Coverage__c(
                Name = 'Test',
                Payor__c = payorTest.Id
            );
            INSERT objcoverage;

            Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
            objCGCoverage.Name = 'Test';
            objCGCoverage.Charge_Group__c = chargeGroup1.Id;
            objCGCoverage.Coverage__c = objcoverage.Id;
            INSERT objCGCoverage;

            Service__c serviceTest = new Service__c(
                Name = 'serviceTest',
                Charge_Group__c = chargeGroup2.Id
            );
            INSERT serviceTest;

            Payment_Adjustments__c paymentAdjTest = new Payment_Adjustments__c(
                Name = 'paymentAdjTest',
                Charge_Group__c = chargeGroup2.Id
            );
            INSERT paymentAdjTest;

            Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            List<Payment__c> lstPayment = new List<Payment__c>{
                payment1, payment2
            };
            INSERT lstPayment;

            List<Payment__c> pays = [SELECT Id from Payment__c];

            List<Transaction__c> lstTransaction = new List<Transaction__c>();
            Transaction__c transaction1 = TestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
            lstTransaction.add(transaction1);

            Transaction__c transaction2 = TestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
            lstTransaction.add(transaction2);

            Transaction__c transaction3 = TestUtility.generateServiceTxn(chargeGroup2, 20, serviceTest);
            lstTransaction.add(transaction3);

            Transaction__c transaction4 = TestUtility.generateServiceTxn(chargeGroup2, 200, serviceTest);
            lstTransaction.add(transaction4);

            Transaction__c transaction5 = TestUtility.generateAdjTxn(chargeGroup2, 200, paymentAdjTest);
            lstTransaction.add(transaction5);
            INSERT lstTransaction;

            List<Transaction__c> txns = [Select Id from Transaction__c];

            invoice1.Invoice_Status_Index__c = 9;
            invoice2.Invoice_Status_Index__c = 4;
            List<Invoice__c> lstInvoiceUpdate = new List<Invoice__c>{
                invoice1, invoice2
            };
            UPDATE lstInvoiceUpdate;
        }

        List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
        System.assertEquals(0, patientList.size());

        System.runAs(portalUser) {
            Test.startTest();

            List<WorkWithInvoicesController.InvoicesWrapper> invoiceList = WorkWithInvoicesController.getAllInvoices(Constants.UNPAID, new List<String>{
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Unpaid invoice.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(Constants.PAID, new List<String>{
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Paid Invoice.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(Constants.UNKNOWN, new List<String>{
                patientContact.Id
            });
            System.assertEquals(1, invoiceList.size(), 'Should have found Unknown Invoice for patient.');
            invoiceList = WorkWithInvoicesController.getAllInvoices(Constants.UNKNOWN, new List<String>());
            System.assertEquals(1, invoiceList.size(), 'Should have found Unknown Invoice for any patient.');
            invoiceList = WorkWithInvoicesController.getInvoice(invoice1.Id);
            System.assertEquals(1, invoiceList.size(), 'Should be able to look up Invoice.');

            patientList = WorkWithInvoicesController.getPatientList();
            System.assertEquals(3, patientList.size(), 'Should find the patients.');

            Test.stopTest();
        }
    }

    @isTest static void estimatesTest() {
        Contact guarantorContact;
        Contact patientContact;
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();
        Encounter__c encounter1;

        System.runAs(adminUser) {
            Account testAcc = TestUtility.getPortalAccount();
            guarantorContact = TestUtility.getPortalGuarantor();

            patientContact = TestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.Medical_Record_Number__c = '1234512345';
            INSERT patientContact;

            List<Encounter__c> lstEncounter = new List<Encounter__c>();
            encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
            encounter1.Patient__c = patientContact.Id;
            encounter1.Insurance_Discount__c = 2;
            encounter1.Insurance_Portion__c = 2;
            lstEncounter.add(encounter1);
            Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
            encounter2.Total_Payments__c = 5;
            encounter2.Patient__c = patientContact.Id;
            encounter2.Insurance_Discount__c = 3;
            encounter2.Insurance_Portion__c = 2;
            lstEncounter.add(encounter2);

            INSERT lstEncounter;

            Attachment testAttach = new Attachment(
                Body = Blob.valueOf('Test string'),
                Name = 'test attach',
                ParentId = encounter1.Id
            );
            INSERT testAttach;
        }

        System.runAs(portalUser) {
            Test.startTest();

            List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithInvoicesController.getAllEstimates(Constants.UNPAID, patientContact.Id);
            System.assertEquals(estimateList.size(), 1);
            estimateList = WorkWithInvoicesController.getAllEstimates(Constants.PAID, 'null');
            System.assertEquals(estimateList.size(), 0);
            estimateList = WorkWithInvoicesController.getEstimate(encounter1.Id);
            System.assertEquals(estimateList.size(), 1);

            Test.stopTest();
        }
    }
}