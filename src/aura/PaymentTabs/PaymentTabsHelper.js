({
	getInitPaymentRequestInfo: function(paymentInfo) {
		var initInfo = {
			creditCard: {},
			totalAmount: 0,
			planValue: 0,
			executeOnDay: 1,
			chargeGroupId: '',
			sironoId: '',
			contactId: '',
			totalInstallments: 24
		};

		if (!paymentInfo) {
			return initInfo;
		}

		initInfo.sironoId = paymentInfo.sironoId;
		initInfo.contactId = paymentInfo.guarantor.Id;

		if (paymentInfo.hasPaymentPlans) {
			initInfo.sfId = paymentInfo.paymentPlan.Id;
			initInfo.paymentPlanId = paymentInfo.paymentPlan.Sirono_ID__c;
			initInfo.totalAmount = paymentInfo.paymentPlan.Remaining_Balance__c;
			initInfo.planValue = paymentInfo.paymentPlan.Installment_Amount__c;
			initInfo.executeOnDay = paymentInfo.paymentPlan.Execute_on_Day__c;
			initInfo.totalInstallments = paymentInfo.paymentPlan.Remaining_Installment_Count__c;
			return initInfo;
		}

		if (paymentInfo.chargeGroups) {
			var groupsList = [];
			paymentInfo.chargeGroups.forEach(function (group) {
				if (group.cg.Balance__c && group.cg.Sirono_ID__c) {
					groupsList.push(group.cg.Sirono_ID__c);
					initInfo.totalAmount += parseFloat( group.cg.Balance__c ? group.cg.Balance__c : 0 );
				}
			});
			initInfo.chargeGroupId = groupsList.join(',');
		}

		if (paymentInfo.settings) {
			if (paymentInfo.settings.Min_Installment_Amount__c) {
				initInfo.planValue = paymentInfo.settings.Min_Installment_Amount__c;

			}
			if (paymentInfo.settings.Max_Number_Plan_Installments__c) {
				initInfo.totalInstallments = paymentInfo.settings.Max_Number_Plan_Installments__c;

				var calcPlanValue = parseFloat( initInfo.totalAmount / paymentInfo.settings.Max_Number_Plan_Installments__c, 10 );
				//console.log('initially calcPlanValue: ' + calcPlanValue );
				if (calcPlanValue < initInfo.planValue) {
					initInfo.totalInstallments = Math.round( initInfo.totalAmount / initInfo.planValue, 10 );
				} else {
					initInfo.planValue = calcPlanValue;
				}
			}
		}
		return initInfo;
	}
})