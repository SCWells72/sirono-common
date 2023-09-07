The class library includes a framework for modeling enum-like data types as wrappers for picklist field values, at least those for whom the candidate values are known at compile-time.

The class library includes a framework for modeling extensible type-safe enums. These should be considered distinct from Apex enums and also from the picklist enums described above. They are more sophisticated than the former and do not represent the known values for a picklist field like the latter. They are particularly useful to provide Apex symbolic constants for the values of string formula fields.
