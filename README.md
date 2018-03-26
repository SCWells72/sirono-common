# sirono-common
Common Apex utility classes and frameworks used by Sirono products.

## Trigger handler framework

The library includes a simple, lightweight framework for handling DML events in accordance with [documented best
practices](https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices). The primary
interfaces and classes in the framework are:

* `TriggerHandler` - the common interface for all trigger handlers
* `AbstractTriggerHandler` - an abstract base implementation of `TriggerHandler` that provides default on-op
  implementations of all trigger event handler methods and common utility methods for processing trigger data.
* `TriggerHandlerFactory` - the factory interface for the creation of `TriggerHandler` implementations in response
  to DML events.
* `TriggerHandlerDispatcher` - the "glue" between the trigger and the trigger handler that instantiates the trigger
  handler using the specified factory and invokes the appropriate method based on the originating DML event.

### Example

A typical trigger handler implementation would follow the pattern:

**Trigger**
```java
trigger TestContactTrigger on Contact (before insert, before update, ...) {
    TriggerHandlerDispatcher.dispatch(ContactTriggerHandler.Factory.class);
}
```

**Trigger handler**
```java
public with sharing class ContactTriggerHandler extends AbstractTriggerHandler {
    // Trigger handler factory as inner class to avoid top-level namespace pollution
    public class Factory implements TriggerHandlerFactory {
        public TriggerHandler create(List<SObject> objects, Map<Id, SObject> oldObjectsById) {
            return new ContactTriggerHandler(objects, oldObjectsById);
        }
    }

    // Strongly-typed collections of new and old objects initialized by the trigger handler 
    // constructor when invoked by the factory
    private final List<Contact> contacts;
    private final Map<Id, Contact> oldContactsById;

    // Private constructor that is only ever invoked by the factory in response to a DML event
    private ContactTriggerHandler(List<SObject> contacts, Map<Id, SObject> oldContactsById) {
        this.contacts = contacts;
        this.oldContactsById = (Map<Id, Contact>) oldContactsById;
    }

    // Event/timing handler implementations corresponding to the trigger from which the handler was invoked

    public override void beforeInsert() {
        for (Contact newContact : contacts) {
            // Do something interesting
        }
    }

    public override void beforeUpdate() {
        for (Contact newContact : contacts) {
            Contact oldContact = oldContactsById.get(newContact.Id);
            if (fieldValueChanged(oldContact, newContact, Contact.Birthdate)) {
                // Do something interesting
            }
        }
    }

    ...
}
```
