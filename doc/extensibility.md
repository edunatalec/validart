The seams where a rule this package does not ship gets plugged in.

`Validator` and `AsyncValidator` are the base of every rule; implement one and
attach it with `.add(...)` to get a check the fluent chain treats as its own.

The pattern interfaces are the narrower seam: `TaxIdPattern`,
`PostalCodePattern`, `PhonePattern`, `LicensePlatePattern` and
`CardBrandPattern` each describe one document or format, and the corresponding
validator takes a list of them. That is why documents from different countries
coexist in a single validation — `V.string().taxId(patterns: [UsSsnPattern(),
CpfPattern()])` accepts both — and why the Brazilian rules ship as a separate
package instead of living here.

The implementations included cover the formats that are unambiguous
internationally; anything national belongs in an extension package.
