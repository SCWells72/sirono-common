({
  getAllHeaderInfo: function (component) {
    var action = component.get("c.getAllHeaderInfo");
    var formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var guarantorWrapper = response.getReturnValue();
        console.log({guarantorWrapper: guarantorWrapper}, 'Reponse from getAllHeaderInfo.');
        component.set('v.guarantorWrapper', guarantorWrapper);
        component.set('v.invoiceValue', formatter.format(Math.floor(guarantorWrapper.paymentPlan.Installment_Amount__c)));
        component.set('v.invoiceValuePart', (guarantorWrapper.paymentPlan.Installment_Amount__c % 1).toFixed(2).toString().substring(2));
        var isWarning = guarantorWrapper.contact.Guarantor_Status__c == 'Overdue';
        component.set('v.warningMessage', isWarning);
        var isError = guarantorWrapper.contact.Guarantor_Status__c == 'Delinquent';
        component.set('v.errorMessage', isError);

      }
    });
    $A.enqueueAction(action);
  }
})