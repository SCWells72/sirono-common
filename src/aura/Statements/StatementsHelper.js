({
    getAllInfo: function (component) {
        var action = component.get("c.getAllInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var statements = response.getReturnValue();
                var stateLength = Math.ceil(statements.length / 6);
                component.set('v.statements', statements);
                component.set('v.stateLength', stateLength);
                var ArrayFilterItems = [];
                for (var i = 0; i < stateLength; i++) {
                    ArrayFilterItems[i] = [];
                    var start = i * 6;
                    var end = ((start + 6) > statements.length )? +(statements.length) : +(start+6); 
                    for (start; start < end; start++) {
                        ArrayFilterItems[i].push(statements[start])
                    }
                }
                component.set('v.statementsSortItems', ArrayFilterItems);
                console.log('----',ArrayFilterItems);
            }
        });
        $A.enqueueAction(action);
    }
})