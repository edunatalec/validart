Error codes, and the messages they resolve to.

Every failure emits a code before it emits a sentence: `VCode` and its
per-type siblings — `VStringCode`, `VNumberCode`, `VDateCode`, `VMapCode`,
`VObjectCode`, and the rest — are the stable identifiers a client can branch
on. They do not change when the wording does.

`VLocale` maps those codes to text. Set one globally with `V.setLocale(...)`
and every schema in the process follows; override a single message with the
`message:` parameter on the validator itself. Lookup accepts both the flat
form (`'string.required'`) and the nested one, falling back to the trailing
segment when a prefixed key has no match — so a partial translation degrades
to the generic message instead of showing a raw code.

Country-specific messages live in extension packages, such as
[validart_br](https://pub.dev/packages/validart_br).
