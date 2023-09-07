# sirono-common
Common Apex utility classes and frameworks used by Sirono products including:

* [Trigger handler framework](#trigger-handler-framework)
* [MultiMap collection and collection utilities](#multimap-collection-and-collection-utilities)
* [Configurable `Comparator` factory](#configurable-comparator-factory)
* [Authorization utilities](#authorization-utilities)
* [Additional test assertions](#test-assertions)
* [Apex picklist enum wrapper to provide symbolic constants for picklist field values](#apex-picklist-enums)
* [Apex type-safe enums](#apex-type-safe-enums)
* [Logging-style wrapper for `System.debug()`](#logging-wrapper)

## Trigger handler framework

The class library includes a simple, lightweight framework for handling DML events in accordance with [documented best practices](https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices). The primary interfaces and classes in the framework are:

* `TriggerHandler` - the common interface for all trigger handlers
* `AbstractTriggerHandler` - an abstract base implementation of `TriggerHandler` that provides default no-op implementations of all trigger event handler methods and common utility methods for processing trigger data.
* `TriggerHandlerFactory` - the factory interface for the creation of `TriggerHandler` implementations in response to DML events.
* `TriggerHandlerDispatcher` - the "glue" between the trigger and the trigger handler that instantiates the trigger handler using the specified factory and invokes the appropriate method based on the originating DML event.

### Example

A typical trigger handler implementation would follow the pattern:

**Trigger**
```apex
trigger ContactTrigger on Contact (before insert, before update/*, ...*/) {
    TriggerHandlerDispatcher.dispatch(ContactTriggerHandler.Factory.class);
}
```

**Trigger handler**
```apex
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

    //...
}
```

## MultiMap Collection and Collection Utilities

### MultiMap

The three standard Apex collection types--`List`, `Set`, and `Map`--are exceptionally useful. However, sometimes more complex in-memory data storage mechanisms are required. One of the most useful non-standard collections is a map with multiple values per-key. This can be easily modeled using a standard map with a `List` or `Set` of some other type as its value type, e.g.:

```apex
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

However, this is quite a bit of boilerplate code that's required every time this pattern is needed. The `MultiMap` collection type exists for exactly this reason. It is [by definition](https://en.wikipedia.org/wiki/Multimap) a multi-valued map data structure.

The class library includes an Apex implementation of `MultiMap`. Unlike the standard collection types, it does not support type parameterization. However, it is still quite simple to extract both keys and values from the map and work with them in a strongly-typed manner. Here is the same example displayed above but using a `MultiMap`:

```apex
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

As you can see, a small amount of explicit casting is required, but overall the code is more compact, especially during population. It's always safe to iterate the results of `MultiMap` key and value extractors (`keySet()`, `getValues()`, etc.) because they will always return a non-null collection.

Apex `MultiMap` collections can be created with either `List`- or `Set`-based backing storage, and values in the `MultiMap` share behavioral characteristics with the underlying collection type. Use `List`-based storage via `MultiMap.newListInstance()` when you need duplicate values for the same key and/or preservation of value insertion order is important. Use `Set`-based storage via `MultiMap.newSetInstance()` when you need distinct values and/or value order is unimportant.

### Collection Utilities

We often find ourselves doing the same repeated actions when working with collections of data. This includes checking whether a provided collection is non-null and actually has contents, extracting first or last elements from lists (which may be null or empty, so best to check first!), converting a list of SObjects to a list of Ids for use in a SOQL query IN clause, and many other common idioms and patterns.

The class library includes `CollectionUtil` a set of common utility methods for many of these frequently required collection operations, for example:

* `isEmpty(list)` - Checks whether a collection is non-null and contains any elements.
* `isNotEmpty(list)` Checks whether a collection is null or empty (technically a negation of `isEmpty()`, but makes for much more readable code).
* `getFirstItem(list)` - Returns the first item from a list if the list is non-null and contains at least one item; otherwise safely returns null.
* `getLastItem(list)` - Returns the last item from a list if the list is non-null and contains at least one item; otherwise safely returns null.
* `addIfNotNull(toList, value)` - Adds a value to the list only if it's non-null.
* `addAllNotNull(toList, fromList)` - Adds all non-null values from one (potentially null) list to another list.
* `toIds(rawIds)` - Converts an untyped collection of IDs to a typed collection of IDs. This is particularly useful when used with `MultiMap` because of the untyped nature of its keys and values, e.g. `SELECT Id FROM Account WHERE Id IN :CollectionUtil.toIds(contactsByAccountId.keySet())`.
* `toStrings(values)` - Converts a collection of arbitrarily typed data into string values. This is particularly useful when used with `String.format()`.
* `toTypedList(sourceValues, targetValues)` - Converts an untyped list of values into a typed list of values. This is particularly useful when used with `MultiMap` because of the untyped nature of its keys and values, e.g. `List<Contact> contacts = CollectionUtil.toTypedList(contactsByAccountId.values(), new List<Contact>());`
* `getIds(sobjects)` - Extracts IDs from a list of SObjects.
* `getIdSet(sobjects)` - Extracts distinct IDs from a list of SObjects.
* `mapByIdField(sobjects, field)` - Slices the provided list of SObjects by the specified Id field.
* `mapByField(sobjects, field)` - Slices the provided list of SObjects by the specified field of any type.
* `multiMapByField(sobjects, field)` - Slices the provided list of SObjects by the specified field of any type allowing for duplicate values.
* `sort(objects, comparator)` - Uses the specified comparator to sort the provided list of objects. Note that this method is now **deprecated** (though still functional with the same behavior), and `List.sort(Comparator)` should be used instead.
  
Refer to the ApexDoc for more comprehensive and up-to-date documentation. 

**NOTE:** Due to current Apex bugs, many of these utility methods are only available for `List` collections and, to a lesser extent, `Set` collections via the `Iterable` interface. This is because Apex currently does not properly support polymorphic assignment of `Set` or `Map` collections based on type parameters. We have reported this to Salesforce and hope that it will be addressed in a relatively near-term release. Once it has been addressed, the class library will be updated to support all three collection types more completely.

## Configurable `Comparator` factory

With the introduction of a standard Apex [`System.Comparator`](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_System_Comparator.htm) interface in Winter '24 / API v59.0, `sirono-common`'s custom interface with the same name has been removed. However, the `Comparators` factory class remains, as does the `CollectionUtil.sort()` utility method, though it is now simply a deprecated pass-through for `List.sort(Comparator)` on the provided list, and migration to the latter is encouraged.

To update existing `sirono-common` deployments:
1. Deploy the latest source which includes explicit references to `System.Comparator` to remove references to the class library's now-obsolete custom `Comparator` interface.
2. Update all references to the class library's custom `Comparator` interface in non-class library source to use the qualified name `System.Comparator<Object>`, at least temporarily, and deploy those changes as well.
3. Safely remove the class library's custom `Comparator` interface from the org (and from the local project source if not already so).
4. If desired, revert qualified `System.Comparator<Object>` references to `Comparator<Object>` or, preferably, update those comparators to be strongly-typed, e.g.:
   ```apex
   public class MyComparator implements Comparator<String> {
       public Integer compare(String s1, String s2) {
           // Simplify your comparator now that params are strongly-typed
       }
   }
   ```

As stated previously, the class library includes a set of standard comparators via the `Comparators` factory class for ordering lists of primitive types and lists of SObjects by a particular field value. These standard comparators can be configured for the direction of sorting (ascending vs. descending), how null values are handled (nulls first vs. nulls last), and as appropriate, case-sensitivity of string comparisons. The standard comparators can also be used as building blocks for more complex comparators via composition and delegation.

Comparator-based sorting of SObjects is particularly useful when required ordering of a result set cannot be accomplished as part of a SOQL query's `ORDER BY` clause, for example, because the ordering logic is more complex than `ORDER BY` allows or because the data cannot be ordered as part of the query due to features such as Salesforce Shield Platform Encryption. 

### Example

**Standard SObject field value comparator**
```apex
// Query contacts from an org where birth date is encrypted and cannot be used in an ORDER BY clause
List<Contact> contacts = [SELECT Id, Birthdate FROM Contact];
// Sort the contacts by birth date descending with null birth dates at the end
contacts.sort(Comparators.sobjectFieldValueComparator(Contact.Birthdate).ascending(false).nullsFirst(false));
```

**Standard string comparator**
```apex
List<Contact> contacts = [SELECT Name FROM Contact];
List<String> contactNames = new List<String>();
for (Contact c : contacts) {
    CollectionUtil.addIfNotNull(contactNames, c.Name);
}
// Sort the contact names ascending case-insensitive
contactNames.sort(Comparators.stringComparator().caseSensitive(false));
```

**Custom composite comparator**
```apex
public with sharing class OpportunityDateComparator implements Comparator<Opportunity> {
    // Initialize a delegate that can be used to sort by the respective date values in descending order
    private static final Comparator DATE_COMPARATOR = Comparators.dateComparator().ascending(false);

    public Integer compare(Opportunity opportunity1, Opportunity opportunity2) {
        // NOTE: Null checks omitted here for brevity, but generally you'd want to check any values that are not
        // guaranteed to be non-null for null values. You could also extend Comparators.ConfigurableComparator
        // and use its native ability to perform null checks.
        
        // Primarily order by close date if one or both opportunities have been closed
        Date closeDate1 = opportunity1.CloseDate;
        Date closeDate2 = opportunity2.CloseDate;
        if ((closeDate1 != null) && (closeDate2 == null)) {
            return -1;
        } else if ((closeDate1 == null) && (closeDate2 != null)) {
            return 1;
        } else if ((closeDate1 != null) && (closeDate2 != null)) {
            // Both opportunities have been closed, so sort by close date descending
            return DATE_COMPARATOR.compare(closeDate1, closeDate2);
        }
        
        // Neither is closed, so compare by last activity date if possible
        Date lastActivityDate1 = opportunity1.LastActivityDate;
        Date lastActivityDate2 = opportunity2.LastActivityDate;
        if ((lastActivityDate1 != null) && (lastActivityDate2 == null)) {
            return -1;
        } else if ((lastActivityDate1 == null) && (lastActivityDate2 != null)) {
            return 1;
        } else if ((lastActivityDate1 != null) && (lastActivityDate2 != null)) {
            return DATE_COMPARATOR.compare(lastActivityDate1, lastActivityDate2);
        }
        
        // Worst-case scenario sort by created date
        return DATE_COMPARATOR.compare(opportunity1.CreatedDate, opportunity2.CreatedDate);
    }
}

// Using the custom comparator
List<Opportunity> opportunities = [SELECT Id, CloseDate, LastActivityDate, CreatedDate FROM Opportunity];
opportunities.sort(new OpportunityDateComparator());
```

## Authorization utilities

Apex does not automatically enforce authorization. The onus is placed upon the developer to ensure that access to data is properly authorized for the current user. There are three general types of authorization checks which may be performed:

* **CRUD** - Whether the user has Create/Read/Update/Delete access to an entire object type.
* **FLS** - Whether the user has Field-Level access(/Security) for the distinct fields on an object type.
* **Sharing** - Whether the user has access to specific rows for an object type.

Failure to verify authorization properly can lead to security gaps and is a major consideration during the security review process. Salesforce provides [documentation](https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS) on how to address these types of issues, but again, doing so is the responsibility of the developer.

The class library includes a simple authorization utility class, `AuthorizationUtil`, that currently helps to address the CRUD aspects. It provides both check and assertion methods of verifying the various types of object-level operations that are allowed for the current user. The check methods should be used when an alternative execution path is available if the user is not authorized; the assertion methods should be used when a lack of sufficient authorization should terminate the operation immediately, though recovery is possible through exception handling.

### Example

**Check methods**
```apex
// Use an empty list by default
List<Contact> contacts = new List<Contact>();

// If the user is authorized to read contacts and accounts, query the appropriate contacts and their accounts
if (AuthorizationUtil.isAccessible(Contact.SObjectType) && AuthorizationUtil.isAccessible(Account.SObjectType)) {
    contacts = [SELECT Id, Account.Id FROM Contact];

    // If the user is authorized to update contacts, update them
    if (AuthorizationUtil.isUpdateable(Contact.SObjectType)) {
        for (Contact contact : contacts) {
            // Do something interesting to each contact
        }
        update contacts;
    } else {
        // Report the lack of access
    }
} else {
    // Report the lack of access
}
```

**Assert methods**
```apex
// Exception handling would generally occur in the service or presentation tier and queries/DML in the data access tier,
// but showing both together here to demonstrate how assertion handling might work
try {
    // If the user is authorized to read contacts and accounts, query the appropriate contacts and their accounts
    AuthorizationUtil.assertAccessible(Contact.SObjectType);
    AuthorizationUtil.assertAccessible(Account.SObjectType);
    List<Contact> contacts = [SELECT Id, Account.Id FROM Contact];

    // If the user is authorized to update contacts, update them
    AuthorizationUtil.assertUpdateable(Contact.SObjectType);
    for (Contact contact : contacts) {
        // Do something interesting to each contact
    }
    update contacts;
} catch (AuthorizationException e) {
    // Report the failure
}
```

## Test Assertions

With the introduction of the standard Apex [`System.Assert`](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Assert.htm) class, this library's original `Assert` utility class has been rendered largely obsolete. As a result, it has been removed and only the assertion methods that are not present in the system analog have been preserved. To avoid any ambiguity around the type named `Assert`, the library's type with that name has been removed and the remaining methods have been moved into a utility class called `Asserts`. Also, the library's `equals` and `notEquals` methods are not present with those exact same names in `System.Assert` which instead uses `areEqual` and `areNotEqual` respectively.

This does result in a backward-incompatible change, but hopefully one that is trivial to resolve for existing library consumers. A simple (mostly) pass-through implementation of the library's original `Assert` class is available under `migration/classes` that can help with the migration as follows:

1. Deploy the migration `Assert` class using:
    ```text
     sfdx force:mdapi:deploy -d migration -u <alias> -w 10
    ```
1. Deploy/push all other updated library types from `force-app` as appropriate for your project.
1. Remove the migration `Assert` class using:
    ```text
    sfdx force:source:delete -m ApexClass:Assert -u <alias> -r -w 10
    ```

The remaining assertions are for verifying expected messages (up to the first embedded formatting specifier) from raised exceptions including special handling for object- and field-level errors as a result of failed validation rules or errors added in trigger logic:

* `hasExceptionMessage(expectedMessage, actualException)`
* `hasDmlExceptionMessage(expectedField, expectedMessage, actualDmlException)` - field-level errors
* `hasDmlExceptionMessage(expectedMessage, actualDmlException)` - object-level errors
* `hasPageMessage(expectedField, expectedMessage)` - field-level errors added to page messages; required when multiple levels of triggers have fired even if not using Visualforce

In practice this looks like:

```apex
try {
    update contact;
    Assert.fail('Expected DmlException here');
} catch (DmlException e) {
    Asserts.hasDmlExceptionMessage(Contact.FirstName, Label.Invalid_First_Name, e);
}
```

## Apex Picklist Enums

We often need to refer to known values of picklist fields from Apex. These values are not modeled as symbolic constants, though, so this can lead to a proliferation of hard-coded strings or, at least a bit better, one-off string constants. The class library includes a framework for modeling enum-like data types as wrappers for picklist field values, at least those for whom the candidate values are known at compile-time.

### Implementation

In order to create a new picklist enum for a picklist field's known values, create a new subclass of `PicklistEnum` with the following pattern (using `Opportunity.Type` as an example):

```apex
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

```apex
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

* **Picklist field value naming** - Picklist field values should be named the same as the symbolic constant that will be used in Apex. Traditionally it was difficult to provide distinct values and labels for picklist field values, but now it's quite easy. As a result, we would have recommended that the entries for `Opportunity.Type` above have values like `EXISTING_CUSTOMER_UPGRADE`, `EXISTING_CUSTOMER_REPLACEMENT`, `EXISTING_CUSTOMER_DOWNGRADE`, and `NEW_CUSTOMER` and labels as shown above. Ultimately what you see as the value in the database should be the exact same as the name of the enum constant used to reference that value from Apex. This won't be possible for existing picklist fields which have already been deployed into production, but it's a good practice for new picklist fields going forward.
* **Picklist enum type naming** - The picklist enum type should reflect the SObject type and field as closely as possible within the constraints of Apex type naming (maximum 40 characters). In the example above, the two names are concatenated into a type name with an `Enum` suffix. Sometimes the type and field names will have overlap, for example, `Account.AccountSource`. Picklist enum types for such fields should merge overlapping name portions, e.g., `AccountSourceEnum`.

## Apex Type-Safe Enums

Apex supports first-class enum types. However, unlike in other languages, Apex enums are very simple and cannot include information other than the enum constants themselves. There are times when it's desirable to have additional information stored with each enum constant, or to have enum constant values be distinct from enum constant names.

The class library includes a framework for modeling extensible type-safe enums. These should be considered distinct from Apex enums and also from the picklist enums described above. They are more sophisticated than the former and do not represent the known values for a picklist field like the latter. They are particularly useful to provide Apex symbolic constants for the values of string formula fields.

Ordinals are computed automatically for each enum constant based on the order of declaration within the containing type. Additional information can be captured in the concrete type-safe enum implementation as appropriate, e.g., the name of an image to represent the process status, a severity index, etc., and behavior can be extended because the enum is just an Apex class.

### Implementation

In order to create a new type-safe enum, create a new subclass of `TypeSafeEnum` with the following pattern:

```apex
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

Again, the inclusion of `imagePath` is to demonstrate the extensible nature of these enums. If no additional state is required, all references to that property would be removed and the concrete `TypeSafeEnum` subclass would simply include its enum constants, the private constructor, and the strongly-typed class methods.

### Example

Type-safe enum values can then be referenced from Apex as:

```apex
List<ComputedScoreEnum> computedScores = ComputedScoreEnum.values();
for (ComputedScoreEnum computedScore : computedScores) {
    System.debug('Value = ' + computedScore.value() + ', ordinal = ' + computedScore.ordinal() + ', image path = ' + computedScore.imagePath);
}

// You can also perform direct comparisons with string values
String computedScore = getComputedScore();
if (ProcessStatusEnum.LOW.equalTo(computedScore)) {
    // Handle low scores
}
```

## Logging Wrapper

The primary Apex logging facility is `System.debug()`. While this is a useful diagnostic tool, the calling interface certainly has its limitations. If you'd like to log at different level than the default (`DEBUG`), you must include a value for the `LoggingLevel` enum as the first argument which can lead to unnecessarily verbose logging statements. Additionally, if you'd like to log messages of any complexity, you must either use string concatenation or `String.format()` to build a more sophisticated message, again muddying the actual message that is being constructed.

For these reasons the class library includes a simple logging wrapper that more closely mimics loggers in other environments. The logging wrapper supports level-specific logging and direct construction of more complex logged messages via `String.format()` embedded formatting specifiers as call arguments.

### Example

```apex
public with sharing class ExternalServiceInvoker {

    // Create the logger as a class constant, providing the type name of the containing class
    private static final Logger LOG = Logger.getInstance(ExternalServiceInvoker.class);
    
    public void invokeExternalService(String host, Integer port, String path, String externalId) {
        LOG.info('Invoking service at https://{0}:{1}/{2}?id={3}.', host, port, path, externalId);
        
        try {
            HttpResponse response = invokeExternalService();
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

There are some gotchas when using loggers from inner classes. Consult the ApexDoc for `Logger` for more details and how to work around those issues.

### Future Thoughts

The logging wrapper was also designed to have a pluggable back end with `System.debug()` as the default implementation. In the future we'd like to investigate the use of alternative back ends, in particular some type of remote/federated logging facility. Unfortunately this is complicated by various limitations of the Salesforce platform. It's possible that platform events may provide a good option for remote logging and, if so, once implemented no client should need to change if written against the logging wrapper instead of directly against `System.debug()`.
