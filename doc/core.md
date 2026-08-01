The entry point, the base type, and what running a schema gives back.

`V` is where every schema starts — `V.string()`, `V.int()`, `V.map()`,
`V.object<T>()` — and `VType` is the base each one extends, carrying the
methods they all share: `nullable`, `defaultValue`, `refine`, `preprocess`,
`transform`, `add`.

Running a schema returns a `VResult`: a `VSuccess` with the normalized value,
or a `VFailure` with a list of `VError`. Each error carries a `code`, a
`message` resolved through the active locale, and a `path` locating it inside
nested maps, objects and arrays — which is what makes a single result enough to
drive a form, an API response and a log line.

`ValidationMode` decides how a mask is treated, and `VTypeApplyIf` conditionally
applies a fragment of the chain without breaking it.
