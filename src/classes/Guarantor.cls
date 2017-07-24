/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class Guarantor {

	@AuraEnabled public GuarantorUser grtUser {get; set;}
	@AuraEnabled public GuarantorContact grtContact {get; set;}
	@AuraEnabled public Invoice grtInvoice {get; set;}
	@AuraEnabled public PaymentPlan grtPaymentPlan {get; set;}
	@AuraEnabled public Integer newEstimatesCount {get; set;}

	public Guarantor() {}
	public Guarantor(GuarantorUser grtUser, GuarantorContact grtContact, Invoice grtInvoice, PaymentPlan grtPaymentPlan, Integer newEstimatesCount) {
		this.grtUser = grtUser;
		this.grtContact = grtContact;
		this.grtInvoice = grtInvoice;
		this.grtPaymentPlan = grtPaymentPlan;
		this.newEstimatesCount = newEstimatesCount;
	}

	public class GuarantorUser {
		@AuraEnabled public String userName {get;set;}
		@AuraEnabled public String password {get;set;}
		@AuraEnabled public String contactId {get;set;}

		public GuarantorUser() {}

        public GuarantorUser(String userName, String password, String contactId) {
            this.userName = userName;
            this.password = password;
            this.contactId = contactId;
        }
	}
    
    public class GuarantorContact {

        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Decimal outstandingInvoices {get;set;}
        @AuraEnabled public Decimal overdueInvoices {get;set;}
        @AuraEnabled public Decimal delinquentInvoices {get;set;}
        @AuraEnabled public Boolean addToPaymentPlan {get;set;}
        @AuraEnabled public Decimal invoicedBalance {get;set;}

        public GuarantorContact() {}

        public GuarantorContact(String status, Decimal outstandingInvoices, Decimal overdueInvoices, Decimal delinquentInvoices, Boolean addToPaymentPlan, Decimal invoicedBalance) {
            this.status = status;
            this.overdueInvoices = overdueInvoices;
            this.outstandingInvoices = outstandingInvoices;
            this.delinquentInvoices = delinquentInvoices;
            this.addToPaymentPlan = addToPaymentPlan;
            this.invoicedBalance = invoicedBalance;
        }
    }

    public class Invoice {
    	@AuraEnabled public Date dueDate {get;set;}

    	public Invoice() {}

    	public Invoice(Date dueDate) {
    		this.dueDate = dueDate;
    	}
    }

    public class PaymentPlan {
    	@AuraEnabled public Date nextPaymentDate {get;set;}
    	@AuraEnabled public Boolean isActive {get; set;}
    	@AuraEnabled public String paymentPlanStanding {get; set;}
    	@AuraEnabled public String planType {get; set;}

    	public PaymentPlan() {}

    	public PaymentPlan(Date nextPaymentDate, Boolean isActive, String paymentPlanStanding, String planType) {
    		this.nextPaymentDate = nextPaymentDate;
    		this.isActive = isActive;
    		this.paymentPlanStanding = paymentPlanStanding;
    		this.planType = planType;
    	}
    }
}