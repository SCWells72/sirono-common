/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getAdjustedPaymentInfo: function (paymentInfo, params) {
        var invoices = params.invoices || [];
        var addOrRemove = params.add;
        var groupsToRemove = [];
        var groupsToAdd = [];

        invoices.forEach(function (invoice) {
            ;(invoice.allGroups || []).forEach(function (groupWr) {
                var group = groupWr.cGroup;
                if (group.Active__c && group.Balance__c && group.Sirono_ID__c) {
                    if (addOrRemove) {
                        groupsToAdd.push(group);
                    } else {
                        groupsToRemove.push(group);
                    }
                }
            });
        });

        var currentGroups = paymentInfo.chargeGroups || [];
        var newGroups = [].concat(currentGroups);
        // add all new if needed
        var filteredWithNew = groupsToAdd.filter(function (newGroup) {
            var passed = true;
            newGroups.forEach(function (group) {
                if (passed && group.Id === newGroup.Id) {
                    passed = false;
                }
            });
            return passed;
        });
        newGroups = newGroups.concat(filteredWithNew);
        // remove groups for remove
        var filteredAfterRemove = newGroups.filter(function (group) {
            var passed = true;
            groupsToRemove.forEach(function (newGroup) {
                if (passed && group.Id === newGroup.Id) {
                    passed = false;
                }
            });
            return passed;
        });
        paymentInfo.chargeGroups = filteredAfterRemove;
        return paymentInfo;
    },
    getInitPaymentRequestInfo: function (paymentInfo) {
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

        initInfo.sironoId = paymentInfo.guarantorSironoId;
        initInfo.contactId = paymentInfo.guarantor.Id;

        if (paymentInfo.hasPaymentPlan) {
            initInfo.sfId = paymentInfo.paymentPlan.Id;
            initInfo.paymentPlanId = paymentInfo.paymentPlan.Sirono_ID__c;
            initInfo.totalAmount = paymentInfo.paymentPlan.Remaining_Balance__c;
            initInfo.planValue = paymentInfo.paymentPlan.Installment_Amount__c;
            initInfo.executeOnDay = paymentInfo.paymentPlan.Execute_On_Day__c;
            initInfo.totalInstallments = paymentInfo.paymentPlan.Remaining_Installment_Count__c;
            return initInfo;
        }

        if (paymentInfo.chargeGroups) {
            var groupsList = [];
            paymentInfo.chargeGroups.forEach(function (group) {
                if (group.Balance__c && group.Sirono_ID__c) {
                    groupsList.push(group.Sirono_ID__c);
                    initInfo.totalAmount += parseFloat(group.Balance__c ? group.Balance__c : 0);
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

                var calcPlanValue = parseFloat(initInfo.totalAmount / paymentInfo.settings.Max_Number_Plan_Installments__c, 10);
                //console.log('initially calcPlanValue: ' + calcPlanValue );
                if (calcPlanValue < initInfo.planValue) {
                    initInfo.totalInstallments = Math.ceil(initInfo.totalAmount / initInfo.planValue, 10);
                } else {
                    initInfo.planValue = calcPlanValue;
                }
            }
        }
        return initInfo;
    }
})