Apex does not automatically enforce authorization. The onus is placed upon the developer to ensure that access to data is properly authorized for the current user. There are three general types of authorization checks which may be performed:

* **CRUD** - Whether the user has Create/Read/Update/Delete access to an entire object type.
* **FLS** - Whether the user has Field-Level access(/Security) for the distinct fields on an object type.
* **Sharing** - Whether the user has access to specific rows for an object type.

Failure to verify authorization properly can lead to security gaps and is a major consideration during the security review process. Salesforce provides [documentation](https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS) on how to address these types of issues, but again, doing so is the responsibility of the developer.

The class library includes a simple authorization utility class, [`AuthorizationUtil`](AuthorizationUtil), that currently helps to address the CRUD aspects. It provides both check and assertion methods of verifying the various types of object-level operations that are allowed for the current user. The check methods should be used when an alternative execution path is available if the user is not authorized; the assertion methods should be used when a lack of sufficient authorization should terminate the operation immediately, though recovery is possible through exception handling.
