# sirono-common
Common Apex utility classes and frameworks used by Sirono products including:

* [Trigger handler framework](#trigger-handler-framework)
* [MultiMap collection and collection utilities](#multimap-collection-and-collection-utilities)
* [Additional test assertions](#test-assertions)
* [Apex picklist enum wrapper to provide symbolic constants for picklist field values](#picklist-enums)
* [Apex type-safe enums](#type-safe-enums)
* [Logging-style wrapper for `System.debug()`](#logging-wrapper)

## Trigger handler framework

The library includes a simple, lightweight framework for handling DML events in accordance with [documented best
practices](https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices). The primary
interfaces and classes in the framework are:

* `TriggerHandler` - the common interface for all trigger handlers
* `AbstractTriggerHandler` - an abstract base implementation of `TriggerHandler` that provides default no-op
  implementations of all trigger event handler methods and common utility methods for processing trigger data.
* `TriggerHandlerFactory` - the factory interface for the creation of `TriggerHandler` implementations in response
  to DML events.
* `TriggerHandlerDispatcher` - the "glue" between the trigger and the trigger handler that instantiates the trigger
  handler using the specified factory and invokes the appropriate method based on the originating DML event.

### Example

A typical trigger handler implementation would follow the pattern:

**Trigger**
```java
trigger ContactTrigger on Contact (before insert, before update, ...) {
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

## MultiMap Collection and Collection Utilities

### MultiMap

The three standard Apex collection types--`List`, `Set`, and `Map`--are exceptionally useful. However, sometimes
more complex in-memory data storage mechanisms are required. One of the most useful non-standard collections is a
map with multiple values per-key. This can be easily modeled using a standard map with a `List` or `Set` of some
other type as its value type, e.g.:

```java
// Populate the multi-valued map
Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
    Id accountId = contact.AccountId;
    
    // See if there's already a list of contacts for this account ID
    List<Contact> contacts = contactsByAccountId.get(accountId);

    // If not, create one and add it to the map
    if (contacts == null) {
        contacts = new List<Contact>();
        contactsByAccountId.put(accountId, contacts);
    }

    // And finally add the contact to the correct bucket
    contacts.add(contact);
}

// And now work with the map's contents
for (Id accountId : contactsByAccountId.keySet()) {
    for (Contact contact : contactsByAccountId.get(accountId)) {
        // Do something
    }
}
```

However, this is quite a bit of boilerplate code that's required every time this pattern is needed. The `MultiMap`
collection type exists for exactly this reason. It is [by definition](https://en.wikipedia.org/wiki/Multimap) a 
multi-valued map data structure.

This class library includes an Apex implementation of `MultiMap`. Unlike the standard collection types, it does not 
support type parameterization. However, it is still quite simple to extract both keys and values from the map and
work with them in a type-safe manner. Here is the same example displayed above but using a `MultiMap`:

```java
// Populate the multi-valued map
MultiMap contactsByAccountId = MultiMap.newSetInstance();
for (Contact contact : [SELECT Id, AccountId FROM Contact]) {
    contactsByAccountId.putValue(contact.AccountId, contact);
}

// And now work with the map's contents
for (Object key : contactsByAccountId.keySet()) {
    Id accountId = (Id) key;
    for (Object value : contactsByAccountId.getValues(accountId)) {
        Contact contact = (Contact) value;
        // Do something
    }
}
```

As you can see, a small amount of explicit casting is required, but overall the code is more compact, especially during
population.

Apex `MultiMap` collections can be created with either `List`- or `Set`-based backing storage, and the resulting
characteristics are the same. Use `List`-based storage via `MultiMap.newListInstance()` when you need duplicate
values for the same key and/or preservation of value insertion order is important. Use `Set`-based storage via
`MultiMap.newSetInstance()` when you need distinct values and/or value order is unimportant.

### Collection Utilities

We often find ourselves doing the same repeated actions when working with collections of data. This includes checking
whether a provided collection is non-null and actually has contents, extracting first or last elements from lists
(which may be null or empty, so best to check first!), converting a list of SObjects to a list of Ids for use in a
SOQL query IN clause, and many other common idioms and patterns.

This class library includes `CollectionUtil` a set of common utility methods for many of these frequently required 
collection operations, for example:

* `isEmpty(list)` - Checks whether a collection is non-null and contains any elements.
* `isNotEmpty(list)` Checks whether a collection is null or empty (technically a negation of `isEmpty()`, but makes for
  much more readable code).
* `getFirstItem(list)` - Returns the first item from a list if the list is non-null and contains at least one item;
  otherwise safely returns null.
* `getLastItem(list)` - Returns the last item from a list if the list is non-null and contains at least one item;
  otherwise safely returns null.
* `addIfNotNull(toList, value)` - Adds a value to the list only if it's non-null.
* `addAllNotNull(toList, fromList)` - Adds all non-null values from one (potentially null) list to another list.
* `toIds(rawIds)` - Converts an untyped collection of IDs to a typed collection of IDs. This is particularly useful
  when used with `MultiMap` because of the untyped nature of its keys and values, e.g. 
  `SELECT Id FROM Account WHERE Id IN :CollectionUtil.toIds(contactsByAccountId.keySet())`.
* `toStrings(values)` - Converts a collection of arbtrarily typed data into string values. This is particularly useful
  when used with `String.format()`.
* `getIds(sobjects)` - Extracts IDs from a list of SObjects.
* `getIdSet(sobjects)` - Extracts distinct IDs from a list of SObjects.
* `mapByIdField(sobjects, field)` - Slices the provided list of SObjects by the specified Id field.
* `mapByField(sobjects, field)` - Slices the provided list of SObjects by the specified field of any type.
* `multiMapByField(sobjects, field)` - Slices the provided list of SObjects by the specified field of any type allowing
  for duplicate values.
  
Refer to the ApexDoc for more comprehensive and up-to-date documentation. 

**NOTE:** Due to current Apex bugs, many of these utility methods are only available for `List` collections. This is
because Apex currently does not properly support polymorphic assignment of `Set` or `Map` collections based on type
parameters. We have reported this to Salesforce and hope that it will be addressed in a relatively near-term release.
Once it has been addressed this library will be updated to support all three collection types.

## Test Assertions

Apex includes three methods for use during unit testing to verify test expectations:
`System.assert(condition)`, `System.assertEquals(expected, actual)`, and `System.assertNotEquals(expected, actual)`.
You can express pretty much any test expectation using these three methods (in fact, you **really** only need the first one).
For example, if you want to verify that a value is non-null, you can use either `assert(value != null)` or
`assertNotEquals(null, value)`. Similarly, if you want to force a test failure when an expected exception has not been
raised, you can use `assert(false, 'Expected some exception')`. These work, but they're not as expressive as they
could be. Many other test frameworks include more extensive sets of assertions. The previous two examples could be
expressed as `assertNotNull(value)` and `fail('Expected some exception')` respectively. While these are functionally
identical, the latter is arguably more clear in its intent.

This class library includes a test assertion facade, `Assert`, with methods for the most common types of test
assertions (all of the methods also accept an optional message):

* `isTrue(condition)` / `isFalse(condition)`
* `equals(expected, actual)` / `notEquals(expected, actual)`
* `isNull(actual)` / `isNotNull(actual)`
* `fail(message)`

In practice test code looks like:

```java
Contact contact = [SELECT Id, FirstName FROM Contact WHERE Name = :expectedName];
Assert.isNotNull(contact.FirstName);
Assert.equals('Me', contact.FirstName);
Assert.isTrue(contact.Name.startsWith('Me'));
```

`Assert` also includes higher-level assertions for verifying expected messages from raised exceptions including special
handling for object- and field-level errors as a result of failed validation rules or errors added in trigger logic:

* `exceptionMessage(expectedMessage, actualException)`
* `dmlExceptionMessage(expectedField, expectedMessage, actualDmlException)` - field-level errors
* `dmlExceptionMessage(expectedMessage, actualDmlException)` - object-level errors
* `pageMessage(expectedField, expectedMessage)` - field-level errors added to page messages; required when
  multiple levels of triggers have fired even if not using Visualforce

Messages are matched up to the first embedded formatting specifier. Again, in practice this looks like:

```java
try {
    update contact;
    Assert.fail('Expected DmlException here');
} catch (DMLException e) {
    Assert.dmlExceptionMessage(Contact.FirstName, Label.Invalid_First_Name, e);
}
```

