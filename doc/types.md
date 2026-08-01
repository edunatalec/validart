The primitives a schema validates: one class per Dart type.

`VString`, `VNumber` with its `VInt` and `VDouble` refinements, `VBool` and
`VDate` cover the values that arrive from a form, a JSON payload or a query
string. `VEnum`, `VLiteral` and `VUnion` cover the shapes a plain type cannot
express: one of a fixed set, one exact value, one of several schemas.

Every method returns the concrete subtype, so a chain keeps its type all the
way down and `V.string().trim().email()` is still a `VString`. `VTransformed`
and `VTransformedAsync` are what a chain becomes after `transform`, when the
output type stops matching the input.
