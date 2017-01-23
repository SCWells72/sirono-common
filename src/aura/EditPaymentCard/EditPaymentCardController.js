({
	cancelAction: function (cmp, e, hlpr) {
		cmp.getEvent('paymentMethodInit').fire();
	},
	validate : function(component, event) {
    var inputCmp = component.find("cardNumber");
    var value = inputCmp.get("v.value");
    console.log('value ', value);
    console.log('rierjejg');
    // is input numeric?
    if (! value || isNaN(value)) {
    	inputCmp.set("v.errors", [{message:"Card number is a required field"}]);
    	
       //component.set("v.warnings", "Credit card number must be 12-19 digits.");
    // } else if (value.length < 12 || value.length > 19) {
    //    // clear error
    //     inputCmp.set("v.errors", [{message:"Credit card number must be 12-19 digits."}]);
    } else {
    	inputCmp.set("v.errors", null);
    }
}
})