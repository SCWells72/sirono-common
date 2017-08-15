/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

({
    getDefaultCard: function (cmp) {
        var date = new Date(),
            monthStr;

        monthStr = (date.getMonth() + 1) + '';
        if (monthStr.length === 1) {
            monthStr = '0' + monthStr;
        }
        return {
            isSaved: false,
            expirationMonth: monthStr,
            expirationYear: date.getFullYear(),
            cardHolderName: '',
            creditCardNumber: '',
            cvv: '',
            address: '',
            city: '',
            zip: '',
            state: ''
        };
    },

    getCardInformation: function (component, event, helper) {
        console.log('PaymentCard getCardInformation');
        window.setTimeout(
            $A.getCallback(function () {
                if (component.isValid()) {
                    var action = component.get('c.getCardInformation');
                    action.setCallback(this, function (response) {
                        console.log('getCardInformation');
                        if (component.isValid() && response.getState() == 'SUCCESS') {
                            var info = response.getReturnValue();
                            console.log({info: info}, 'CC info callback.');
                            component.set('v.CreditCard', info);
                        } else {
                            console.error(response.getError()[0].message);
                        }

                    });
                    $A.enqueueAction(action);
                }
            }), 10
        );
    },
    checkValidation: function (component, event, helper) {

        var cardName = component.find("cardName").get("v.validity");
        var cardNumber = component.find("cardNumber").get("v.validity");
        var cvv = component.find("cvv").get("v.validity");
        var month = component.find("month").get("v.validity");
        var year = component.find("year").get("v.validity");
        var address = component.find("address").get("v.validity");
        var zipcode = component.find("zipcode").get("v.validity");

        if ((cardName != null && cardName.valid) &&
            (cardNumber != null && cardNumber.valid) &&
            (cvv != null && cvv.valid) &&
            (month != null && month.valid) &&
            (year != null && year.valid) &&
            (address != null && address.valid) &&
            (zipcode != null && zipcode.valid)
        ) {
            console.log('checkValidation true');
            return true;
        } else {
            console.log('checkValidation false');
            return false;
        }
    },

    checkErrorMessages: function (component, event, helper) {
        console.log('checkErrorMessages');
        var cardNameErrors = component.find("cardNameError").get("v.value");
        console.log('cardNameError', cardNameErrors);
        var cardNumberErrors = component.find("cardNumberError").get("v.value");
        console.log('cardNumberError', cardNumberErrors);
        var cvvErrors = component.find("cvvError").get("v.value");
        console.log('cvvError', cvvErrors);
        var expirationErrors = component.find("expirationError").get("v.value");
        console.log('expirationError', expirationErrors);
        var addressErrors = component.find("addressError").get("v.value");
        console.log('addressError', addressErrors);
        var zipcodeErrors = component.find("zipcodeError").get("v.value");
        console.log('zipcodeError', zipcodeErrors);
        if (cardNameErrors != '' ||
            cardNumberErrors != '' ||
            cvvErrors != '' ||
            expirationErrors != '' ||
            addressErrors != '' ||
            zipcodeErrors != ''
        ) {
            console.log('checkValidationE false');
            return false;
        } else {
            console.log('checkValidationE true');
            return true;
        }
    },

    isValidateExpDate: function (cmp) {
        cmp.find('expirationError').set('v.value', '');
        var monthcmp = cmp.find("month");
        var monthValue = monthcmp.get("v.value");
        var yearcmpValue = cmp.find("year").get("v.value");
        var expDate = new Date(yearcmpValue, monthValue);
        var isValid = expDate > Date.now();

        if (!isValid) {
            cmp.find('expirationError').set('v.value', 'Expiration date must be in the future.');
        }
        return isValid;
    },

    isValidateCVV: function (cmp, e) {
        var cvvError = cmp.find("cvvError").set('v.value', '');
        var cncmp = cmp.find("cardNumber");
        var cnValue = cncmp.get("v.value") || '';
        var cvvcmp = cmp.find("cvv");
        var cvvValue = cvvcmp.get("v.value") || '';
        var cvvError = cmp.find("cvvError").set('v.value', '');

        var isValid = false;
        if (!cvvValue) {
            return isValid;
        }
        if ((cncmp.get('v.validity') == null || cncmp.get('v.validity').valid) && cnValue) {
            var cardno = /^(?:3[47][0-9]{13})$/;
            if (cnValue.match(cardno)) {
                if (cvvValue.toString().length != 4 && cvvcmp.get('v.validity').valid) {
                    cmp.find('cvvError').set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
                } else {
                    isValid = true;
                }
            } else {
                if (cvvValue.toString().length != 3 && cvvcmp.get('v.validity').valid) {
                    cmp.find('cvvError').set("v.value", "CVV must be 4 digits for American Express and 3 digits for other card types.");
                } else {
                    isValid = true;
                }
            }

        } else {
            cmp.find('cvvError').set("v.value", '');
        }

        return isValid;
    },
    isValidCutNOTNumber: function (cmp, idToVerify) {
        cmp.find('zipcodeError').set("v.value", "");
        var numberCmp = cmp.find(idToVerify);
        var value = numberCmp.get("v.value");
        if (value && (isNaN(value) || value.includes(' '))) {
            value = value.toString().substring(0, value.toString().length - 1);
            numberCmp.set("v.value", value);
        }
        if (idToVerify == 'zipcode' && value.toString().length != 5 && numberCmp.get('v.validity').valid) {
            cmp.find('zipcodeError').set("v.value", "Zip Code must be 5 digits.");
        }
        return numberCmp.get('v.validity') !== null && numberCmp.get('v.validity').valid;
    },

    initMonthOptions: function (component) {
        var months = component.get('v.months');
        var monthSelection = component.find('month');
        monthSelection.set('v.body', []);
        var body = monthSelection.get('v.body');
        months.forEach(function (month) {
            $A.createComponent(
                'aura:html',
                {
                    tag: 'option',
                    HTMLAttributes: {
                        value: month.value,
                        text: month.label
                    }
                },
                function (newOption) {
                    if (component.isValid()) {
                        body.push(newOption);
                        monthSelection.set('v.body', body);
                    }
                })
        });

    },

    initOptions: function (component, attr, selectionById) {
        selectionById.set('v.body', []);
        var body = selectionById.get('v.body');
        attr.forEach(function (option) {
            $A.createComponent(
                'aura:html',
                {
                    tag: 'option',
                    HTMLAttributes: {
                        value: option,
                        text: option
                    }
                },
                function (newOption) {
                    if (component.isValid()) {
                        body.push(newOption);
                        selectionById.set('v.body', body);
                    }
                })
        });
    }
})