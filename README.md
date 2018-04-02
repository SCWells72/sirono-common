# sirono-common
Common Apex utility classes and frameworks used by Sirono products including:

* [Trigger handler framework](#trigger-handler-framework)
* [MultiMap collection and collection utilities](#multimap-collection-and-collection-utilities)
* [Additional test assertions](#test-assertions)
* [Apex picklist enum wrapper to provide symbolic constants for picklist field values](#apex-picklist-enums)
* [Apex type-safe enums](#apex-type-safe-enums)
* [Logging-style wrapper for `System.debug()`](#logging-wrapper)

## Trigger handler framework

The class library includes a simple, lightweight framework for handling DML events in accordance with 
[documented best practices](https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices). 
The primary interfaces and classes in the framework are:

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

The class library includes an Apex implementation of `MultiMap`. Unlike the standard collection types, it does not 
support type parameterization. However, it is still quite simple to extract both keys and values from the map and
work with them in a strongly-typed manner. Here is the same example displayed above but using a `MultiMap`:

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
population. It's always safe to iterate the results of `MultiMap` key and value extractors (`keySet()`, `getValues()`, etc.)
because they will always return a non-null collection.

Apex `MultiMap` collections can be created with either `List`- or `Set`-based backing storage, and values in the `MultiMap`
share behavioral characteristics with the underlying collection type. Use `List`-based storage via `MultiMap.newListInstance()` 
when you need duplicate values for the same key and/or preservation of value insertion order is important. Use 
`Set`-based storage via `MultiMap.newSetInstance()` when you need distinct values and/or value order is unimportant.

### Collection Utilities

We often find ourselves doing the same repeated actions when working with collections of data. This includes checking
whether a provided collection is non-null and actually has contents, extracting first or last elements from lists
(which may be null or empty, so best to check first!), converting a list of SObjects to a list of Ids for use in a
SOQL query IN clause, and many other common idioms and patterns.

The class library includes `CollectionUtil` a set of common utility methods for many of these frequently required 
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
Once it has been addressed the class library will be updated to support all three collection types.

## Test Assertions

Apex includes three methods for verification of test expectations:
`System.assert(condition)`, `System.assertEquals(expected, actual)`, and `System.assertNotEquals(expected, actual)`.
You can express pretty much any test expectation using these three methods (in fact, you **really** only need the first one).
For example, if you want to verify that a value is non-null, you can use either `assert(value != null)` or
`assertNotEquals(null, value)`. Similarly, if you want to force a test failure when an expected exception has not been
raised, you can use `assert(false, 'Expected some exception')`. These work, but they're not as expressive as they
could be. Many other test frameworks include more extensive sets of assertions. The previous two examples could be
expressed as `assertNotNull(value)` and `fail('Expected some exception')` respectively. While these are functionally
identical, the latter are more explicit in their intent.

The class library includes a test assertion facade, `Assert`, with methods for the most common types of test
assertions (all of the methods also accept an optional message):

* `isTrue(condition)` / `isFalse(condition)`
* `equals(expected, actual)` / `notEquals(expected, actual)`
* `isNull(actual)` / `isNotNull(actual)`
* `fail(message)`

### Example

In practice test code looks like:

```java
Contact contact = [SELECT Id, FirstName FROM Contact WHERE Name = :expectedName];
Assert.isNotNull(contact.FirstName);
Assert.equals('Me', contact.FirstName);
Assert.isTrue(contact.Name.startsWith('Me'));
```

`Assert` also includes higher-level assertions for verifying expected messages (up to the first embedded formatting
specifier) from raised exceptions including special handling for object- and field-level errors as a result of failed
validation rules or errors added in trigger logic:

* `hasExceptionMessage(expectedMessage, actualException)`
* `hasDmlExceptionMessage(expectedField, expectedMessage, actualDmlException)` - field-level errors
* `hasDmlExceptionMessage(expectedMessage, actualDmlException)` - object-level errors
* `hasPageMessage(expectedField, expectedMessage)` - field-level errors added to page messages; required when
  multiple levels of triggers have fired even if not using Visualforce

Again, in practice this looks like:

```java
try {
    update contact;
    Assert.fail('Expected DmlException here');
} catch (DmlException e) {
    Assert.hasDmlExceptionMessage(Contact.FirstName, Label.Invalid_First_Name, e);
}
```

## Apex Picklist Enums

We often need to refer to known values of picklist fields from Apex. These values are not modeled as symbolic constants,
though, so this can lead to a proliferation of hard-coded strings or, at least a bit better, one-off string constants.
The class library includes a framework for modeling enum-like data types as wrappers for picklist field values, at
least those for whom the candidate values are known at compile-time.

### Implementation

In order to create a new picklist enum for a picklist field's known values, create a new subclass of `PicklistEnum`
with the following pattern (using `Opportunity.Type` as an example):

```java
public with sharing class OpportunityTypeEnum extends PicklistEnum {
    // Model the enum as a private singleton for convenient access from class methods below
    private static final OpportunityTypeEnum INSTANCE = new OpportunityTypeEnum();

    // Initialize the enum values by using valueOf() on each picklist field value (values, not labels)
    public static final Entry EXISTING_CUSTOMER_UPGRADE = valueOf('Existing Customer - Upgrade');
    public static final Entry EXISTING_CUSTOMER_REPLACEMENT = valueOf('Existing Customer - Replacement');
    public static final Entry EXISTING_CUSTOMER_DOWNGRADE = valueOf('Existing Customer - Downgrade');
    public static final Entry NEW_CUSTOMER = valueOf('New Customer');

    // Private constructor for singleton initialized off of the picklist field's SObjectField
    private OpportunityTypeEnum() {
        super(Opportunity.Type);
    }
    
    // The following must be provided in each implementation to provide class-level access to entries based on
    // the type-specific singleton

    public static Entry valueOf(String value) {
        return INSTANCE.getEntry(value);
    }

    public static Entry[] values() {
        return INSTANCE.getEntries();
    }
}
```

### Example

Picklist enum values can then be referenced from Apex as:

```java
Entry[] opportunityTypes = OpportunityTypeEnum.values();
for (Entry opportunityType : opportunityTypes) {
    System.debug('Value = ' + opportunityType.value() + 
                 ', label = ' + opportunityType.label() + 
                 ', active = ' + opportunityType.isActive() +
                 ', defaultValue = ' + opportunityType.isDefaultValue());
}

// You can also perform direct comparisons with string values from SObject instances
Opportunity opp = [SELECT Type FROM Opportunity LIMIT 1];
if (OpportunityTypeEnum.NEW_CUSTOMER.equalTo(opp.Type)) {
    // Do something new customer-ish
}
```

### Best Practices for Picklist Enums

In order to get the best results from picklist enums and the underlying picklist fields, we recommend the following guidelines:

* **Picklist field value naming** - Picklist field values should be named the same as the symbolic constant that will be used 
  in Apex. Traditionally it was difficult to provide distinct values and labels for picklist field values, but now it's quite
  easy. As a result, we would have recommended that the entries for `Opportunity.Type` above have values like `EXISTING_CUSTOMER_UPGRADE`,
  `EXISTING_CUSTOMER_REPLACEMENT`, `EXISTING_CUSTOMER_DOWNGRADE`, and `NEW_CUSTOMER` and labels as shown above. Ultimately what
  you see as the value in the database should be the exact same as the name of the enum constant used to reference that value
  from Apex. This won't be possible for existing picklist fields which have already been deployed into production, but it's a
  good practice for new picklist fields going forward.
* **Picklist enum type naming** - The picklist enum type should reflect the SObject type and field as closely as possible within
  the constraints of Apex type naming (maximum 40 characters). In the example above, the two names are concatenated into a type
  name with an `Enum` suffix. Sometimes the type and field names will have overlap, for example, `Account.AccountSource`. Picklist
  enum types for such fields should merge overlapping name portions, e.g., `AccountSourceEnum`.

## Apex Type-Safe Enums

Apex supports first-class enum types. However, unlike in other languages, Apex enums are very simple and cannot include
information other than the enum constants themselves. There are times when it's desirable to have additional information stored
with each enum constant, or to have enum constant values be distinct from enum constant names.

The class library includes a framework for modeling extensible type-safe enums. These should be considered distinct from Apex
enums and also from the picklist enums described above. They are more sophisticated than the former and do not represent the
known values for a picklist field like the latter. They are particularly useful to provide Apex symbolic constants for the
values of string formula fields.

Ordinals are computed automatically for each enum constant based on the order of declaration within the containing type.
Additional information can be captured in the concrete type-safe enum implementation as appropriate, e.g., the name of
an image to represent the process status, a severity index, etc., and behavior can be extended because the enum is just
an Apex class.

### Implementation

In order to create a new type-safe enum, create a new subclass of `TypeSafeEnum` with the following pattern:

```java
public with sharing class ComputedScoreEnum extends TypeSafeEnum {
    // Initialize the enum constants with the distinct string value for each
    public static final ComputedScoreEnum HIGH = new ComputedScoreEnum('HIGH', '/images/stoplight-green.png');
    public static final ComputedScoreEnum MEDIUM = new ComputedScoreEnum('MEDIUM', '/images/stoplight-yellow.png');
    public static final ComputedScoreEnum LOW = new ComputedScoreEnum('LOW', '/images/stoplight-red.png');
    
    // Optionally extend the enum interface with custom properties and behavior
    public final String imagePath { get; private set; }
    
    // Private constructor for singleton initialized using the concrete sub-type and distinct value for that type.
    // Note that the signature minimally needs the value to delegate to the base constructor, but additional state
    // can be gathered for each enum constant as required.
    private ComputedScoreEnum(String value, String imagePath) {
        super(ComputedScoreEnum.class, value);
        this.imagePath = imagePath;
    }

    // The following must be provided in each implementation to provide strongly-typed versions
    // of class method class-level for the enum

    public static ComputedScoreEnum valueOf(String value) {
        return (ComputedScoreEnum) TypeSafeEnum.valueOf(ComputedScoreEnum.class, value);
    }

    public static List<ComputedScoreEnum> values() {
        return (List<ComputedScoreEnum>) TypeSafeEnum.values(ComputedScoreEnum.class, new List<ComputedScoreEnum>());
    }

    public static Boolean matchesAny(ComputedScoreEnum[] values, String testValues) {
        return TypeSafeEnum.matchesAny(values, testValues);
    }

    public static Boolean matchesNone(ComputedScoreEnum[] values, String testValue) {
        return TypeSafeEnum.matchesNone(values, testValue);
    }
}
```

Again, the inclusion of `imagePath` is to demonstrate the extensible nature of these enums. If no additional state is required, 
all references to that property would be removed and the concrete `TypeSafeEnum` subclass would simply include its enum constants, 
the private constructor, and the strongly-typed class methods.

### Example

Type-safe enum values can then be referenced from Apex as:

```java
List<ComputedScoreEnum> computedScores = ComputedScoreEnum.values();
for (ComputedScoreEnum computedScore : computedScores) {
    System.debug('Value = ' + computedScore.value() + ', ordinal = ' + computedScore.ordinal() + ', image path = ' computedScore.imagePath);
}

// You can also perform direct comparisons with string values
String computedScore = getComputedScore();
if (ProcessStatusEnum.LOW.equalTo(computedScore)) {
    // Handle low scores
}
```

## Logging Wrapper

The primary Apex logging facility is `System.debug()`. While this is a useful diagnostic tool, the calling interface
certainly has its limitations. If you'd like to log at different level than the default (`DEBUG`), you must include a
value for the `LoggingLevel` enum as the first argument which can lead to unnecessarily verbose logging statements.
Additionally, if you'd like to log messages of any complexity, you must either use string concatenation or 
`String.format()` to build a more sophisticated message, again muddying the actual message that is being constructed.

For these reasons the class library includes a simple logging wrapper that more closely mimics loggers in other
environments. The logging wrapper supports level-specific logging and direct construction of more complex logged 
messages via `String.format()` embedded formatting specifiers as call arguments (up to 6 after which you must provide
your own list of parameters).

### Example

```java
public with sharing class ExternalServiceInvoker {

    // Create the logger as a class constant, providing the type name of the containing class
    private static final Logger LOG = Logger.getInstance(ExternalServiceInvoker.class);
    
    public void invokeExternalService(String host, Integer port, String path, String externalId) {
        LOG.info('Invoking service at https://{0}:{1}/{2}?id={3}.', host, port, path, externalId);
        
        try {
            HttpResponse response = // actually invoke the service
            if (response.getStatusCode() != 200) {
                LOG.warn('Failed to invoke the service: status code = {0}, status = {1}', 
                    response.getStatusCode(), response.getStatus());
            }
        } catch (Exception e) {
            LOG.error('Exception while invoking the service: {0}', e);
        }
    }
}
```

There are some gotchas when using loggers from inner classes. Consult the ApexDoc for `Logger` for more details and how
to work around those issues.

### Future Thoughts

The logging wrapper was also designed to have a pluggable back end with `System.debug()` as the default implementation.
In the future we'd like to investigate the use of alternative back ends, in particular some type of remote/federated
logging facility. Unfortunately this is complicated by various limitations of the Salesforce platform. It's possible
that platform events may provide a good option for remote logging and, if so, once implemented no client should need
to change if written against the logging wrapper instead of directly against `System.debug()`.