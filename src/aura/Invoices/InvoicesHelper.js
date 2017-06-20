({
  getAllInvoices: function (component) {
    var action = component.get("c.getAllInvoices");
    var patientsFilter = [];

    var selectedPatients = component.get('v.patientSet');
    if (selectedPatients != null && selectedPatients.length > 0) {
      for (var i = 0; i < selectedPatients.length; i++) {
        if (selectedPatients[i].isSelected == true) {
          patientsFilter.push(selectedPatients[i].id);
        }
      }
    }

    // If no patients are selected bypass the call to the server
    // and just populate the empty list.
    if (patientsFilter.length === 0) {
      component.set("v.listOfInvoices", []);
      this.createTiles(component, []);
    }
    action.setParams({
      'groupFilter': component.get("v.groupFilter"),
      'patientsFilter': patientsFilter
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var listOfInvoices = response.getReturnValue();
        component.set("v.listOfInvoices", listOfInvoices);
        this.createTiles(component, listOfInvoices);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " +
              errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  init: function (component) {
    var action = component.get("c.getPatientList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var patientList = response.getReturnValue();
        this.buildPatientList(component, patientList);
        this.getAllInvoices(component);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  buildPatientList: function (component, patientListDB) {
    //init patient list
    var patientList = [];
    var patientSet = new Set();
    for (var i = 0; i < patientListDB.length; i++) {
      if (!patientSet.has(patientListDB[i].id)) {
        patientList.push({
          id: patientListDB[i].id,
          name: patientListDB[i].name,
          isSelected: patientListDB[i].isSelected,
          MRN: patientListDB[i].MRN
        });
        patientSet.add(patientListDB[i].id);
      }
    }
    component.set('v.patientSet', patientList);
    component.set('v.patientLabel', 'All Patients');
  },

  createTiles: function (component, listOfInvoices) {

    component.set('v.invoices', []);

    for (var i = 0; i < listOfInvoices.length; i++) {
      $A.createComponent(
        "c:Invoice",
        {
          "invoice": listOfInvoices[i],
          "tileId": i
        },
        function (invoice, status, errorMessage) {
          if (status === "SUCCESS") {
            var invoices = component.get('v.invoices');
            invoices.push(invoice);
            component.set('v.invoices', invoices);
          }
          else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.");
          }
          else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
          }
        }
      );
    }

    $A.createComponent(
      "c:InvoiceDetails",
      {
        "listOfInvoices": listOfInvoices
      },
      function (newComponent, status, errorMessage) {
        if (status === "SUCCESS") {
          var invoiceDetails = component.find('invoice_details');
          invoiceDetails.set("v.body", newComponent);
        }
        else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        }
        else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  }
})