({
	bodyStatus: function (component, event, helper) {
        var status = event.getParam("collapse");
        var alert = event.getParam("alert");
        var scroll = component.find('payment_scroll');
        if(status == "true"){
            $A.util.removeClass(scroll,"small");
        }
        if(status == "false"){
            $A.util.addClass(scroll,"small");
        }
        if(alert == "true"){
            $A.util.removeClass(scroll,"alert");
        }
	}
})