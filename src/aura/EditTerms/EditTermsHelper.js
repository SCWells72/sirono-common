({
	showError: function(cmp, message) {
		console.error(message);
		cmp.set('v.hasError', true);
		cmp.set('v.severity', 'error');
		cmp.set('v.message', message);
	}
})