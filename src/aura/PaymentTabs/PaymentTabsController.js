({
	activateTab : function (component, event, helper) {
		var tabToActivate = event.target.id;
		var activeTab = component.get("v.activeTab");
		if (activeTab != tabToActivate) {
			if (activeTab) {
				$A.util.addClass(component.find(activeTab), 'display_false');
				$A.util.removeClass(component.find(activeTab+'_tab'), 'active');
			}
			$A.util.removeClass(component.find(tabToActivate), 'display_false');
			$A.util.addClass(component.find(tabToActivate+'_tab'), 'active');
			component.set("v.activeTab",tabToActivate);
		}
	},
	doInit: function(cmp, e, hlpr) {
		var activeTab = cmp.get("v.activeTab");
		
		console.log("activeTab", activeTab);
		if(activeTab === undefined || activeTab == 'MakeAPayment') {
			//set default value
			cmp.set("v.activeTab", "MakeAPayment");
		} else {
			$A.util.removeClass(cmp.find('MakeAPayment' + '_tab'), 'active');
			$A.util.addClass(cmp.find('MakeAPayment'), 'display_false');
			$A.util.addClass(cmp.find(activeTab + '_tab'), 'active');
			$A.util.removeClass(cmp.find(activeTab), 'display_false');
		}

		var checkPPAction = cmp.get("c.getPaymentPlanInfo");
		checkPPAction.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var paymentInfo = response.getReturnValue();
				var PaymentRequestInfo = getInitPaymentRequestInfo(paymentInfo);

				console.info('PaymentInfo', paymentInfo);
				console.info('PaymentRequestInfo', PaymentRequestInfo);

				cmp.set('v.PaymentInfo', paymentInfo);
				cmp.find('paymentPlanCmp').doCmpInit(paymentInfo, PaymentRequestInfo);
			}
		});
		$A.enqueueAction(checkPPAction);
		

		/** @TODO DO PaymentRequestInfo from the values selected from Controller: Active Payment Plan or smth like that ? */
		function getInitPaymentRequestInfo(paymentInfo) {
			var initInfo = {
				creditCard: {},
				totalAmount: 0,
				planValue: 0,
				executeOnDay: 15,
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

			if (paymentInfo.chargeGroups) {
				paymentInfo.chargeGroups.forEach(function (group) {
					initInfo.totalAmount += parseFloat( group.cg.Balance__c ? group.cg.Balance__c : 0 );
				});
			}

			if (paymentInfo.settings) {
				if (paymentInfo.settings.Min_Installment_Amount__c) {
					initInfo.planValue = paymentInfo.settings.Min_Installment_Amount__c;

				}
				if (paymentInfo.settings.Max_Number_Plan_Installments__c) {
					initInfo.totalInstallments = paymentInfo.settings.Max_Number_Plan_Installments__c;

					var calcPlanValue = parseFloat( initInfo.totalAmount / paymentInfo.settings.Max_Number_Plan_Installments__c, 10 );
					console.log('initially calcPlanValue: ' + calcPlanValue );
					if (calcPlanValue < initInfo.planValue) {
						initInfo.totalInstallments = Math.round( initInfo.totalAmount / initInfo.planValue, 10 );
					} else {
						initInfo.planValue = calcPlanValue;
					}
				}
			}
			return initInfo;
		};
	},
})