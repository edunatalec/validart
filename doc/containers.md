The schemas that hold other schemas.

`VMap` validates a `Map<String, dynamic>` — JSON straight off the wire, a
Firestore document, a form's raw values. `VObject<T>` validates an instance of
your own class through field extractor callbacks the compiler checks, with no
code generation. The two accept the same rules, so one schema can serve both
paths: `safeParse` for the typed instance, `safeParseRaw` for the map it was
built from.

`VArray` validates a list, applying its element schema to every entry and
carrying the index in each error's `path`.

Cross-field rules live here too — `refineField`, `refineFieldRaw`,
`equalFields` and `when` see the whole container, which is why a "password
matches confirmation" rule belongs on the container and never on the field.
