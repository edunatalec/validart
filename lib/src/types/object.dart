part of 'type.dart';

class _FieldEntry<T> {
  const _FieldEntry({
    required this.name,
    required this.extractor,
    required this.validator,
  });

  final String name;
  final Object? Function(T instance) extractor;
  final VType validator;
}

class _ObjectWhenRule<T> {
  const _ObjectWhenRule({
    required this.field,
    required this.equals,
    required this.then,
  });

  final String field;
  final Object? equals;
  final Map<String, VType> then;
}

class _ObjectWhenMatchesRule<T> {
  const _ObjectWhenMatchesRule({
    required this.condition,
    required this.dependsOn,
    required this.then,
  });

  final bool Function(T entity) condition;
  final Set<String> dependsOn;
  final Map<String, VType> then;
}

class _ObjectWhenMatchesRawRule {
  const _ObjectWhenMatchesRawRule({
    required this.condition,
    required this.dependsOn,
    required this.then,
  });

  final bool Function(Map<String, dynamic> input) condition;
  final Set<String> dependsOn;
  final Map<String, VType> then;
}

class _ObjectRawFieldRule {
  const _ObjectRawFieldRule({
    required this.check,
    required this.path,
    required this.message,
    required this.dependsOn,
    required this.stage,
  });

  final bool Function(Map<String, dynamic> data) check;
  final String path;
  final String? message;
  final Set<String> dependsOn;
  final RefineStage stage;
}

/// Validates class/entity instances of type [T] via type-safe field
/// extraction callbacks.
///
/// {@category Containers}
///
/// ```dart
/// final schema = V.object<T>()
///     .field('name', (u) => u.name, V.string().min(2))
///     .field('age', (u) => u.age, V.int().positive());
/// schema.validate(User(name: 'Jo', age: 25)); // true
/// ```
///
/// See also:
///
///  * [V.object], the factory that creates this schema.
///  * [VMap], which validates the raw map the entity is built from.
///  * [VObjectCode], the error codes it emits.
class VObject<T> extends VType<T> {
  VObject._({super.message, super.invalidTypeMessage});

  /// Creates a [VObject] — chain [field] to add type-safe field extractors.
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  ///
  /// Unlike [VMap] (which asserts at least one declared field at factory
  /// time), `VObject<T>` accepts an empty schema. This supports partial
  /// construction patterns like [fieldIf] returning the receiver
  /// unchanged when a flag is off, or building a base schema that gets
  /// fields added later via [merge]. A schema with zero fields
  /// validates any `T` instance trivially.
  ///
  /// ```dart
  /// final schema = VObject<User>()
  ///     .field('name', (u) => u.name, V.string());
  /// ```
  factory VObject({String? message, String? invalidTypeMessage}) = VObject<T>._;
  final List<_FieldEntry<T>> _fields = [];
  final List<_ObjectWhenRule<T>> _whenRules = [];
  final List<_ObjectWhenMatchesRule<T>> _whenMatchesRules = [];
  final List<_ObjectWhenMatchesRawRule> _whenMatchesRawRules = [];
  final List<_ObjectRawFieldRule> _rawFieldRules = [];
  bool _isStrict = false;
  bool _isPassthrough = false;

  @override
  String get typeName => 'object';

  @override
  VObject<T> add(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VObject<T> nullable() {
    super.nullable();
    return this;
  }

  @override
  VObject<T> defaultValue(T value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VObject<T> preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  /// Adds a custom entity-level validation that runs after every field has
  /// been validated.
  ///
  /// Pass [dependsOn] to declare which schema field names this refine reads.
  /// When provided, the refine is skipped only if one of those specific
  /// fields failed validation, so its error is aggregated alongside
  /// unrelated field errors in a single pass. When omitted, the refine
  /// follows the conservative rule: skip if ANY field failed (avoids
  /// dereferencing fields that didn't make it into the parsed instance).
  ///
  /// Pass `dependsOn: const {}` (empty set) to opt OUT of the
  /// conservative skip entirely — the refine runs even when other
  /// fields failed. The callback must be defensive about
  /// partially-parsed input (fields that failed are still extracted from
  /// the original `T`, so accessing them is safe, but their values may
  /// not satisfy the per-field invariants you'd normally rely on).
  /// Useful for audit / logging rules that should fire on every
  /// submission.
  ///
  /// `dependsOn` accepts any field declared on this schema OR injected via
  /// any `when.then` / `whenMatches.then` block (or referenced in
  /// `whenMatches.dependsOn`). Unknown names throw an `AssertionError`.
  ///
  /// ```dart
  /// // Conservative default — skip if any field failed.
  /// V.object<Booking>().refine((b) => ...);
  ///
  /// // Aggregate alongside unrelated failures — skip only if 'startsAt'
  /// // or 'endsAt' failed.
  /// V.object<Booking>()
  ///   .field('startsAt', (b) => b.startsAt, V.date())
  ///   .field('endsAt', (b) => b.endsAt, V.date())
  ///   .refine(
  ///     (b) => b.endsAt.isAfter(b.startsAt),
  ///     code: 'date_range_invalid',
  ///     dependsOn: const {'startsAt', 'endsAt'},
  ///   );
  ///
  /// // Always run, even when fields failed (callback must be safe).
  /// V.object<Booking>().refine((b) => audit(b), dependsOn: const {});
  /// ```
  @override
  VObject<T> refine(
    bool Function(T value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    _assertDependsOnKeys(dependsOn);
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VObject<T> preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  /// Async sibling of [refine]. See [refine] for the meaning of
  /// [dependsOn].
  @override
  VObject<T> refineAsync(
    Future<bool> Function(T value) check, {
    String? message,
    String? code,
    Duration? timeout,
    Set<String>? dependsOn,
  }) {
    _assertDependsOnKeys(dependsOn);
    super.refineAsync(
      check,
      message: message,
      code: code,
      timeout: timeout,
      dependsOn: dependsOn,
    );
    return this;
  }

  Set<String> _knownKeys() {
    final keys = <String>{for (final field in _fields) field.name};

    for (final rule in _whenRules) {
      keys.addAll(rule.then.keys);
    }

    for (final rule in _whenMatchesRules) {
      keys.addAll(rule.then.keys);
      keys.addAll(rule.dependsOn);
    }

    for (final rule in _whenMatchesRawRules) {
      keys.addAll(rule.then.keys);
      keys.addAll(rule.dependsOn);
    }

    return keys;
  }

  void _assertDependsOnKeys(Set<String>? dependsOn) {
    if (dependsOn == null) return;

    final known = _knownKeys();

    for (final key in dependsOn) {
      assert(
        known.contains(key),
        "dependsOn key '$key' is not declared in the schema "
        '(base, when.then, or whenMatches.then).',
      );
    }
  }

  /// Returns an unmodifiable map of field names to their validators.
  Map<String, VType> get schema =>
      Map.fromEntries(_fields.map((f) => MapEntry(f.name, f.validator)));

  /// Extracts field values from [instance] into a `Map<String, dynamic>`.
  ///
  /// ```dart
  /// final data = schema.extract(User(name: 'Jo', age: 25));
  /// // {'name': 'Jo', 'age': 25}
  /// ```
  Map<String, dynamic> extract(T instance) => Map.fromEntries(
        _fields.map((f) => MapEntry(f.name, f.extractor(instance))),
      );

  /// Adds a field to the schema with a [name], an [extractor] to read its
  /// value from an instance of [T], and a [validator] schema.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('email', (u) => u.email, V.string().email())
  ///     .field('age', (u) => u.age, V.int().positive());
  /// ```
  VObject<T> field<F>(
    String name,
    F? Function(T instance) extractor,
    VType<F> validator,
  ) {
    _fields.add(
      _FieldEntry<T>(
        name: name,
        extractor: (instance) => extractor(instance),
        validator: validator,
      ),
    );

    return this;
  }

  /// Conditionally adds a field. When [condition] is `true`, behaves
  /// exactly like [field]; otherwise leaves the schema unchanged. Lets
  /// the fluent chain stay unbroken when a field is only relevant under
  /// some flag (a feature toggle, a request context, an admin-only
  /// projection).
  ///
  /// ```dart
  /// VObject<UpdateCredentialDto> schemaFor({required bool allowName}) =>
  ///     V.object<UpdateCredentialDto>()
  ///         .fieldIf(allowName, 'name', (d) => d.name,
  ///             V.string().min(2).nullable())
  ///         .field('email', (d) => d.email, V.string().email());
  /// ```
  VObject<T> fieldIf<F>(
    bool condition,
    String name,
    F? Function(T instance) extractor,
    VType<F> validator,
  ) {
    if (!condition) return this;

    return field(name, extractor, validator);
  }

  /// Creates a [VArray] schema that validates a `List<T>` using this
  /// schema as the element validator.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .array()
  ///     .validate([User(name: 'Jo'), User(name: 'Ana')]);
  /// ```
  VArray<T> array() => VArray<T>(this);

  /// Requires the fields named [fieldA] and [fieldB] to compare equal
  /// via `==`. Both names must already be declared via [field] before
  /// calling this method.
  ///
  /// Runs in the validation phase. Declares `dependsOn: {fieldA, fieldB}`
  /// internally — when [fieldA] or [fieldB] fails its own validation,
  /// this check is skipped (the field error already covers the issue);
  /// otherwise the result is aggregated alongside any unrelated field
  /// errors in a single [VFailure].
  ///
  /// ```dart
  /// V.object<SignUpDto>()
  ///     .field('password', (d) => d.password, V.string().password())
  ///     .field('confirm', (d) => d.confirm, V.string())
  ///     .equalFields('password', 'confirm');
  /// ```
  VObject<T> equalFields(String fieldA, String fieldB, {String? message}) {
    assert(
      _fields.any((f) => f.name == fieldA),
      "The provided field '$fieldA' does not exist in the schema.",
    );
    assert(
      _fields.any((f) => f.name == fieldB),
      "The provided field '$fieldB' does not exist in the schema.",
    );

    final entryA = _fields.firstWhere((f) => f.name == fieldA);
    final entryB = _fields.firstWhere((f) => f.name == fieldB);

    return add(
      ObjectEqualFieldsValidator<T>(
        fieldA: fieldA,
        fieldB: fieldB,
        extractorA: entryA.extractor,
        extractorB: entryB.extractor,
      ),
      message: message,
      dependsOn: {fieldA, fieldB},
    );
  }

  /// The conditional validation rules added via [when].
  List<({String field, Object? equals, Map<String, VType> then})>
      get whenRules => _whenRules
          .map((r) => (field: r.field, equals: r.equals, then: r.then))
          .toList();

  /// The predicate-based conditional validation rules added via
  /// [whenMatches] — entity-mode only (callback receives `T`).
  List<
      ({
        bool Function(T entity) condition,
        Set<String> dependsOn,
        Map<String, VType> then,
      })> get whenMatchesRules => _whenMatchesRules
      .map(
        (r) => (
          condition: r.condition,
          dependsOn: r.dependsOn,
          then: r.then,
        ),
      )
      .toList();

  /// The predicate-based conditional validation rules added via
  /// [whenMatchesRaw] — universal (callback receives the raw
  /// `Map<String, dynamic>` view of the input).
  List<
      ({
        bool Function(Map<String, dynamic> input) condition,
        Set<String> dependsOn,
        Map<String, VType> then,
      })> get whenMatchesRawRules => _whenMatchesRawRules
      .map(
        (r) => (
          condition: r.condition,
          dependsOn: r.dependsOn,
          then: r.then,
        ),
      )
      .toList();

  /// Creates a new schema containing only the fields named in [keys].
  ///
  /// Preserves all pipeline state from the base schema (validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `nullable`,
  /// `defaultValue`, and preprocessors).
  ///
  /// ```dart
  /// final full = V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .field('age', (u) => u.age, V.int());
  /// final partial = full.pick(['name']); // only validates 'name'
  /// ```
  VObject<T> pick(List<String> keys) {
    final result = VObject<T>._();

    for (final entry in _fields) {
      if (keys.contains(entry.name)) result._fields.add(entry);
    }

    _copyObjectStateTo(result);

    return result;
  }

  /// Creates a new schema excluding the fields named in [keys].
  ///
  /// Preserves all pipeline state from the base schema (validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `nullable`,
  /// `defaultValue`, and preprocessors).
  ///
  /// ```dart
  /// final full = V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .field('age', (u) => u.age, V.int());
  /// final reduced = full.omit(['age']); // only validates 'name'
  /// ```
  VObject<T> omit(List<String> keys) {
    final result = VObject<T>._();

    for (final entry in _fields) {
      if (!keys.contains(entry.name)) result._fields.add(entry);
    }

    _copyObjectStateTo(result);

    return result;
  }

  /// Creates a new schema where every field is nullable.
  ///
  /// Pass [except] to keep specific fields with their original validator
  /// (useful for partial-update DTOs that retain a required identifier).
  ///
  /// Each declared field's validator is wrapped so that `null` is
  /// accepted in addition to the original shape; non-null inputs still
  /// run the original validator. Does not mutate the source schema —
  /// the original keeps rejecting nulls.
  ///
  /// Preserves all pipeline state from the base (validators added via
  /// `add` / `equalFields` / `refineField` / `refine`, `when` /
  /// `whenMatches` rules, `nullable`, `defaultValue`, and
  /// preprocessors), matching the behavior of `pick` / `omit` / `merge`
  /// — and mirroring `VMap.partial()`.
  ///
  /// ```dart
  /// final schema = V.object<UpdateDto>()
  ///     .field('name', (d) => d.name, V.string().min(2))
  ///     .field('email', (d) => d.email, V.string().email())
  ///     .partial();
  ///
  /// final update = V.object<User>()
  ///     .field('id', (u) => u.id, V.string().uuid())
  ///     .field('name', (u) => u.name, V.string().min(1))
  ///     .partial(except: ['id']);
  /// ```
  VObject<T> partial({List<String>? except}) {
    assert(
      except == null || except.every((k) => _fields.any((f) => f.name == k)),
      'partial(except: ...) received undeclared fields: '
      '${except.where((k) => !_fields.any((f) => f.name == k)).toList()}',
    );

    final Set<String> exceptSet =
        (except == null || except.isEmpty) ? const <String>{} : except.toSet();

    final VObject<T> result = VObject<T>._();

    for (final entry in _fields) {
      if (exceptSet.contains(entry.name)) {
        result._fields.add(entry);
        continue;
      }

      result._fields.add(
        _FieldEntry<T>(
          name: entry.name,
          extractor: entry.extractor,
          validator: entry.validator.mapType<VType>(
            <U>(inner) => _NullableWrapper<U>(inner),
          ),
        ),
      );
    }

    _copyObjectStateTo(result);

    return result;
  }

  /// Creates a new schema by merging with [other]'s fields.
  ///
  /// Combines pipeline state from both schemas: `when` rules, validator
  /// steps, and preprocessors are concatenated (base first, then [other]).
  /// Boolean flags (`nullable`) are OR-ed. If both sides set `defaultValue`,
  /// [other]'s wins. If both sides declare a field with the same name,
  /// [other]'s entry appears twice in `_fields` — callers are expected to
  /// merge schemas that do not overlap.
  ///
  /// ```dart
  /// final base = V.object<User>().field('id', (u) => u.id, V.string().uuid());
  /// final audit = V.object<User>().field('createdAt', (u) => u.createdAt, V.date());
  /// final full = base.merge(audit);
  /// ```
  VObject<T> merge(VObject<T> other) {
    final result = VObject<T>._();
    result._fields.addAll(_fields);
    result._fields.addAll(other._fields);
    _copyObjectStateTo(result);
    other._copyObjectStateTo(result);

    return result;
  }

  void _copyObjectStateTo(VObject<T> target) {
    target._whenRules.addAll(_whenRules);
    target._whenMatchesRules.addAll(_whenMatchesRules);
    target._whenMatchesRawRules.addAll(_whenMatchesRawRules);
    target._rawFieldRules.addAll(_rawFieldRules);
    target._steps.addAll(_steps);
    target._preprocessors.addAll(_preprocessors);

    if (_isStrict) target._isStrict = true;
    if (_isPassthrough) target._isPassthrough = true;
    if (_isNullable) target._isNullable = true;

    if (_hasDefault) {
      target._defaultValue = _defaultValue;
      target._hasDefault = true;
    }
  }

  /// Rejects raw map inputs that contain keys not declared on this schema.
  ///
  /// No-op in entity mode (`safeParse(T)`) — declared fields are read
  /// through their extractors, so the `T` instance never exposes unknown
  /// keys. Active in raw mode (`safeParseRaw`): each unrecognized key
  /// emits an `object.unrecognized_key` error scoped to that key's path.
  /// Mirrors `VMap.strict()`.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .strict()
  ///     .errorsRaw({'name': 'Jo', 'extra': true}); // VFailure
  /// ```
  VObject<T> strict() {
    _isStrict = true;
    return this;
  }

  /// Allows raw map inputs to carry keys not declared on this schema and
  /// preserves them in the validated map.
  ///
  /// No-op in entity mode (`safeParse(T)`) — declared fields are read
  /// through their extractors, so unknown keys cannot arrive. Active in
  /// raw mode (`safeParseRaw`): non-declared keys flow through to the
  /// returned map unchanged. Mirrors `VMap.passthrough()`.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .passthrough()
  ///     .parseRaw({'name': 'Jo', 'extra': true}); // {'name': 'Jo', 'extra': true}
  /// ```
  VObject<T> passthrough() {
    _isPassthrough = true;
    return this;
  }

  /// Applies conditional validation rules based on a field's value. When the
  /// value read from [field] equals [equals], every validator in [then] is
  /// applied to the corresponding field in addition to its baseline
  /// validator. Both [field] and every key in [then] must already be
  /// declared on the schema.
  ///
  /// ```dart
  /// V.object<TaxPayer>()
  ///     .field('country', (t) => t.country, V.string())
  ///     .field('taxId', (t) => t.taxId, V.string())
  ///     .when('country', equals: 'US', then: {
  ///       'taxId': V.string().taxId(patterns: [const UsSsnPattern()]),
  ///     });
  /// ```
  VObject<T> when(
    String field, {
    required Object? equals,
    required Map<String, VType> then,
  }) {
    assert(
      _fields.any((f) => f.name == field),
      "The provided field '$field' does not exist in the schema.",
    );

    for (final key in then.keys) {
      assert(
        _fields.any((f) => f.name == key),
        "The provided 'then' field '$key' does not exist in the schema.",
      );
    }

    _whenRules.add(
      _ObjectWhenRule<T>(field: field, equals: equals, then: then),
    );

    return this;
  }

  /// Applies conditional validation rules based on an arbitrary predicate
  /// that reads the typed entity `T`.
  ///
  /// **Entity-only.** This method is intended for schemas that are
  /// validated via [safeParse] / [parse] / [validate] / [errors] — the
  /// callback receives a fully-constructed `T` instance. Schemas with
  /// `whenMatches` rules **cannot** be validated via [safeParseRaw] and
  /// friends — those throw [VException] at the entry point because `T`
  /// does not exist in raw mode. If you need a rule that works in both
  /// entity and raw modes, use [whenMatchesRaw] (callback receives the
  /// raw `Map<String, dynamic>` view).
  ///
  /// Use this when [when] is not expressive enough — multi-field
  /// triggers, range comparisons, `oneOf` membership. When [condition]
  /// returns `true`, every validator in [then] is applied to the
  /// corresponding field in addition to its baseline validator.
  ///
  /// [dependsOn] is required and must be **non-empty**: every key must
  /// already be declared via [field] before calling this method. The
  /// rule uses [dependsOn] for two purposes:
  ///
  /// 1. **Skip gating** (defensive). If any declared dependency failed
  ///    its own per-field validation, the entire rule is skipped —
  ///    avoids running the predicate on data that did not pass its own
  ///    validator (logical correctness; in entity mode the cast is
  ///    safe because `T` is typed, but the value may be reprovado).
  /// 2. **Visibility for downstream `refine(dependsOn:)`**. Keys
  ///    declared here enter `_knownKeys()`, letting later refines
  ///    reference them without tripping the assertion.
  ///
  /// The predicate is always synchronous; validators inside [then] may
  /// be sync or async. A [whenMatches] rule whose [then] contains an
  /// async validator opts the schema into async mode
  /// (`hasAsync == true`).
  ///
  /// ```dart
  /// V.object<TaxPayer>()
  ///     .field('country', (t) => t.country, V.string())
  ///     .field('age', (t) => t.age, V.int())
  ///     .field('taxId', (t) => t.taxId, V.string())
  ///     .whenMatches(
  ///       (t) => t.country == 'US' && t.age >= 21,
  ///       dependsOn: const {'country', 'age'},
  ///       then: {'taxId': V.string().min(9)},
  ///     );
  /// ```
  VObject<T> whenMatches(
    bool Function(T entity) condition, {
    required Set<String> dependsOn,
    required Map<String, VType> then,
  }) {
    assert(
      dependsOn.isNotEmpty,
      'whenMatches dependsOn must declare at least one schema field — '
      'the rule is skipped when a declared dependency failed per-field '
      'validation. Use refine() or add() for rules that should always run.',
    );

    for (final key in dependsOn) {
      assert(
        _fields.any((f) => f.name == key),
        "The whenMatches dependsOn key '$key' does not exist in the schema.",
      );
    }

    for (final key in then.keys) {
      assert(
        _fields.any((f) => f.name == key),
        "The whenMatches 'then' field '$key' does not exist in the schema.",
      );
    }

    _whenMatchesRules.add(
      _ObjectWhenMatchesRule<T>(
        condition: condition,
        dependsOn: dependsOn,
        then: then,
      ),
    );

    return this;
  }

  /// Predicate-based conditional rule whose callback receives the raw
  /// `Map<String, dynamic>` view of the input — the universal sibling
  /// of [whenMatches].
  ///
  /// **Works in both modes.** In `safeParse(T)`, the map is rebuilt
  /// lazily via each declared field's extractor before the predicate
  /// is invoked. In `safeParseRaw(Map)`, the input flows through
  /// untouched. Use this when the schema needs to support raw map
  /// validation (e.g. `valiform` consuming a partial payload, or a
  /// backend handler accepting JSON without constructing `T` first).
  /// For entity-only schemas where the predicate naturally reads
  /// typed fields off `T`, prefer [whenMatches] for ergonomic reasons.
  ///
  /// Same [dependsOn] contract as [whenMatches]: required, non-empty,
  /// keys must be declared via [field]. The rule is skipped when any
  /// declared dependency failed per-field validation — protects the
  /// callback from a `m['x'] as int` cast crash on a partial / wrong-
  /// typed payload.
  ///
  /// ```dart
  /// V.object<TaxPayer>()
  ///     .field('country', (t) => t.country, V.string())
  ///     .field('age', (t) => t.age, V.int())
  ///     .field('taxId', (t) => t.taxId, V.string())
  ///     .whenMatchesRaw(
  ///       (m) => m['country'] == 'US' && (m['age'] as int) >= 21,
  ///       dependsOn: const {'country', 'age'},
  ///       then: {'taxId': V.string().min(9)},
  ///     );
  /// ```
  VObject<T> whenMatchesRaw(
    bool Function(Map<String, dynamic> input) condition, {
    required Set<String> dependsOn,
    required Map<String, VType> then,
  }) {
    assert(
      dependsOn.isNotEmpty,
      'whenMatchesRaw dependsOn must declare at least one schema field — '
      'the rule is skipped when a declared dependency failed per-field '
      'validation. Use refine() or add() for rules that should always run.',
    );

    for (final key in dependsOn) {
      assert(
        _fields.any((f) => f.name == key),
        "The whenMatchesRaw dependsOn key '$key' does not exist in the schema.",
      );
    }

    for (final key in then.keys) {
      assert(
        _fields.any((f) => f.name == key),
        "The whenMatchesRaw 'then' field '$key' does not exist in the schema.",
      );
    }

    _whenMatchesRawRules.add(
      _ObjectWhenMatchesRawRule(
        condition: condition,
        dependsOn: dependsOn,
        then: then,
      ),
    );

    return this;
  }

  /// Adds an **entity-only** custom validation targeting a specific
  /// field [path]. The [check] receives the whole `T` instance and the
  /// emitted error is scoped to [path].
  ///
  /// The [stage] controls when the check runs in the container pipeline:
  ///
  /// - [RefineStage.post] (default): runs **after** every field has
  ///   been parsed and transformed. Skipped when any declared
  ///   dependency failed per-field validation.
  /// - [RefineStage.pre]: runs **before** any per-field iteration.
  ///   Callback sees the `T` instance straight from the caller —
  ///   useful when the rule depends on the raw user input before any
  ///   per-field preprocess / transform applies. Always runs once the
  ///   type cast succeeded; [dependsOn] is not accepted.
  ///
  /// **`refineField` is entity-only**: in raw mode (`safeParseRaw`)
  /// the callback would have no `T` to receive, so it is silently
  /// skipped. Use [refineFieldRaw] for rules that must work in both
  /// modes.
  ///
  /// In [RefineStage.post]: **`path` is always part of the dependency
  /// set**, even when [dependsOn] is omitted. When [dependsOn] is
  /// provided it is **unioned with `{path}`**, not replaced — you only
  /// declare the *extra* fields the callback reads. Passing an empty
  /// set triggers an `AssertionError`: for "always run regardless",
  /// use a plain `refine(dependsOn: const {})`.
  ///
  /// ```dart
  /// // Default (post) — implicit dependsOn = {age}.
  /// V.object<User>()
  ///     .field('age', (u) => u.age, V.int())
  ///     .refineField(
  ///       (u) => u.age >= 18,
  ///       path: 'age',
  ///       message: 'Must be at least 18',
  ///     );
  ///
  /// // Cross-field (post) — declares the extra dep; path is implicit.
  /// V.object<Booking>()
  ///     .field('startsAt', (b) => b.startsAt, V.date())
  ///     .field('endsAt', (b) => b.endsAt, V.date())
  ///     .refineField(
  ///       (b) => b.endsAt.isAfter(b.startsAt),
  ///       path: 'endsAt',
  ///       dependsOn: const {'startsAt'},
  ///       message: 'endsAt must be after startsAt',
  ///     );
  ///
  /// // Pre-pipeline — see raw T before per-field transforms apply.
  /// V.object<TaxPayer>()
  ///     .field('country', (t) => t.country, V.string())
  ///     .field('taxId', (t) => t.taxId, V.string())
  ///     .refineField(
  ///       (t) => t.country == 'US' ? t.taxId.length == 9 : true,
  ///       path: 'taxId',
  ///       stage: RefineStage.pre,
  ///       message: 'US taxId must be 9 chars',
  ///     );
  /// ```
  VObject<T> refineField(
    bool Function(T instance) check, {
    required String path,
    String? message,
    Set<String>? dependsOn,
    RefineStage stage = RefineStage.post,
  }) {
    assert(
      _fields.any((f) => f.name == path),
      "The provided path '$path' does not exist in the schema.",
    );
    assert(
      stage == RefineStage.post || dependsOn == null,
      'refineField with stage: RefineStage.pre cannot declare dependsOn — '
      'pre-pipeline runs unconditionally (no field has been validated yet).',
    );
    assert(
      dependsOn == null || dependsOn.isNotEmpty,
      'refineField dependsOn must declare at least one extra schema field '
      'when provided — the path is implicitly included. To run a check '
      'that should fire regardless of field failures, use stage: '
      'RefineStage.pre (raw input) or refine(dependsOn: const {}) '
      '(entity-level, post).',
    );
    _assertDependsOnKeys(dependsOn);

    switch (stage) {
      case RefineStage.pre:
        addRaw(
          _RefineValidator<T>(check: check, validatorCode: VCode.custom),
          message: message,
          path: [path],
        );
        return this;
      case RefineStage.post:
        final Set<String> effectiveDeps =
            dependsOn == null ? {path} : {...dependsOn, path};

        return add(
          _RefineValidator<T>(check: check, validatorCode: VCode.custom),
          message: message,
          path: [path],
          dependsOn: effectiveDeps,
        );
    }
  }

  /// Adds a **universal** custom validation targeting a specific field
  /// [path]. The [check] receives a `Map<String, dynamic>` view of the
  /// input and the emitted error is scoped to [path].
  ///
  /// Mirror of [refineField] for use cases that need the callback to
  /// also work in raw mode (`safeParseRaw`). In `safeParse(T)` the map
  /// is rebuilt lazily from each declared field's extractor before the
  /// callback is invoked; in `safeParseRaw(Map)` the input flows
  /// through untouched. Reach for this when the schema is consumed by
  /// `valiform` or any other pipeline that validates partial payloads.
  ///
  /// Same [stage] / [dependsOn] semantics as [refineField] — see its
  /// docstring for the full contract. The only difference is the
  /// callback signature (`Map<String, dynamic>` vs `T`).
  ///
  /// ```dart
  /// V.object<Booking>()
  ///     .field('startsAt', (b) => b.startsAt, V.date())
  ///     .field('endsAt', (b) => b.endsAt, V.date())
  ///     .refineFieldRaw(
  ///       (m) => (m['endsAt'] as DateTime)
  ///           .isAfter(m['startsAt'] as DateTime),
  ///       path: 'endsAt',
  ///       dependsOn: const {'startsAt'},
  ///     );
  /// ```
  VObject<T> refineFieldRaw(
    bool Function(Map<String, dynamic> data) check, {
    required String path,
    String? message,
    Set<String>? dependsOn,
    RefineStage stage = RefineStage.post,
  }) {
    assert(
      _fields.any((f) => f.name == path),
      "The provided path '$path' does not exist in the schema.",
    );
    assert(
      stage == RefineStage.post || dependsOn == null,
      'refineFieldRaw with stage: RefineStage.pre cannot declare dependsOn — '
      'pre-pipeline runs unconditionally (no field has been validated yet).',
    );
    assert(
      dependsOn == null || dependsOn.isNotEmpty,
      'refineFieldRaw dependsOn must declare at least one extra schema '
      'field when provided — the path is implicitly included.',
    );
    _assertDependsOnKeys(dependsOn);

    final Set<String> effectiveDeps =
        dependsOn == null ? {path} : {...dependsOn, path};

    _rawFieldRules.add(
      _ObjectRawFieldRule(
        check: check,
        path: path,
        message: message,
        dependsOn: effectiveDeps,
        stage: stage,
      ),
    );

    return this;
  }

  @override
  bool get hasAsync {
    if (super.hasAsync) return true;

    for (final field in _fields) {
      if (field.validator.hasAsync) return true;
    }

    for (final rule in _whenRules) {
      for (final validator in rule.then.values) {
        if (validator.hasAsync) return true;
      }
    }

    for (final rule in _whenMatchesRules) {
      for (final validator in rule.then.values) {
        if (validator.hasAsync) return true;
      }
    }

    for (final rule in _whenMatchesRawRules) {
      for (final validator in rule.then.values) {
        if (validator.hasAsync) return true;
      }
    }

    return false;
  }

  @override
  VResult<T?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final Object? preprocessed = runPreprocessors(value);

    final resolution =
        _resolveNull<T>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final T typed;

    try {
      typed = input as T;
    } catch (_) {
      return _typeError<T>(T.toString(), input!);
    }

    // Raw entity-level validators (`refineField(stage: pre)` →
    // `_RefineValidator<T>` via `addRaw`) run BEFORE any per-field
    // iteration. They see `typed` as it was after container
    // preprocess + cast, with no per-field pipeline yet executed.
    final errors = <VError>[..._runRawValidators(typed)];

    // Map view used by Map-typed rules (whenMatchesRaw + rawFieldRules)
    // in entity mode. Lazy-built only when at least one such rule exists.
    final bool needsMapView =
        _whenMatchesRawRules.isNotEmpty || _rawFieldRules.isNotEmpty;
    final Map<String, dynamic>? mapView = needsMapView ? extract(typed) : null;

    // Map-typed pre-pipeline rules (refineFieldRaw stage: pre) — run
    // alongside the entity-typed raw step above. Always fire.
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.pre) continue;

      if (!rule.check(mapView!)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    for (final field in _fields) {
      final fieldValue = field.extractor(typed);
      final result = field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          break;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    for (final rule in _whenRules) {
      final ruleField = _fields.firstWhere((f) => f.name == rule.field);
      final conditionValue = ruleField.extractor(typed);

      if (conditionValue != rule.equals) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedAfterPerField = _firstSegments(errors);

    for (final rule in _whenMatchesRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterPerField,
      )) {
        continue;
      }

      if (!rule.condition(typed)) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    // Recompute after whenMatches.then may have added field errors —
    // whenMatchesRaw must gate against the latest failed-field set, not
    // the snapshot taken before whenMatches ran.
    final Set<String> failedAfterWhenMatches = _firstSegments(errors);

    for (final rule in _whenMatchesRawRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterWhenMatches,
      )) {
        continue;
      }

      if (!rule.condition(mapView!)) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    // Map-typed post-pipeline rules (refineFieldRaw stage: post).
    final Set<String> failedBeforePostRawField = _firstSegments(errors);
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.post) continue;
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedBeforePostRawField,
      )) {
        continue;
      }

      if (!rule.check(mapView!)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    return _runPipeline(
      typed,
      carriedErrors: errors,
      failedFieldPaths: _firstSegments(errors),
    );
  }

  @override
  Future<VResult<T?>> safeParseAsync(Object? value) async {
    final Object? preprocessed = await runPreprocessorsAsync(value);

    final resolution =
        _resolveNull<T>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final T typed;

    try {
      typed = input as T;
    } catch (_) {
      return _typeError<T>(T.toString(), input!);
    }

    // Raw entity-level validators (`refineField(stage: pre)` →
    // `_RefineValidator<T>` via `addRaw`) run BEFORE any per-field
    // iteration.
    final errors = <VError>[..._runRawValidators(typed)];

    final bool needsMapView =
        _whenMatchesRawRules.isNotEmpty || _rawFieldRules.isNotEmpty;
    final Map<String, dynamic>? mapView = needsMapView ? extract(typed) : null;

    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.pre) continue;

      if (!rule.check(mapView!)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    for (final field in _fields) {
      final fieldValue = field.extractor(typed);
      final result = field.validator.hasAsync
          ? await field.validator.safeParseAsync(fieldValue)
          : field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          break;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    for (final rule in _whenRules) {
      final ruleField = _fields.firstWhere((f) => f.name == rule.field);
      final conditionValue = ruleField.extractor(typed);

      if (conditionValue != rule.equals) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.hasAsync
            ? await thenEntry.value.safeParseAsync(fieldValue)
            : thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedAfterPerField = _firstSegments(errors);

    for (final rule in _whenMatchesRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterPerField,
      )) {
        continue;
      }

      if (!rule.condition(typed)) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.hasAsync
            ? await thenEntry.value.safeParseAsync(fieldValue)
            : thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    // Recompute after whenMatches.then may have added field errors —
    // whenMatchesRaw must gate against the latest failed-field set.
    final Set<String> failedAfterWhenMatches = _firstSegments(errors);

    for (final rule in _whenMatchesRawRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterWhenMatches,
      )) {
        continue;
      }

      if (!rule.condition(mapView!)) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.hasAsync
            ? await thenEntry.value.safeParseAsync(fieldValue)
            : thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedBeforePostRawField = _firstSegments(errors);
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.post) continue;
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedBeforePostRawField,
      )) {
        continue;
      }

      if (!rule.check(mapView!)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    return _runPipelineAsync(
      typed,
      carriedErrors: errors,
      failedFieldPaths: _firstSegments(errors),
    );
  }

  /// Validates [value] as a raw `Map<String, dynamic>` instead of a `T`
  /// instance and returns the validated map.
  ///
  /// Use this when the caller cannot construct `T` ahead of time —
  /// typically because the source data is partial or the `T` constructor
  /// rejects null on required fields. Each declared field is read from
  /// the input using its name as the key (the [field] extractor is not
  /// consulted); per-field validators, transforms, `when` rules,
  /// `whenMatches` rules, `strict`, and `passthrough` apply exactly as
  /// they do for `safeParse(T)`.
  ///
  /// Differences from [safeParse]:
  /// - Returns a `VResult<Map<String, dynamic>?>`, not `VResult<T?>`.
  /// - Entity-level rules registered with [refine], [refineField],
  ///   [refineFieldRaw], and [equalFields] are silently skipped — they
  ///   are typed against `T` and have no place to run when `T` does not
  ///   exist. Construct `T` from the returned map and revalidate with
  ///   [safeParse] when those rules matter.
  /// - Entity-level transforms registered via [transform] do not run.
  /// - `defaultValue` is a no-op — its type is `T?`, not
  ///   `Map<String, dynamic>?`. `nullable()` is honored as usual.
  ///
  /// Throws [VAsyncRequiredException] when the schema has any async
  /// piece — use [safeParseRawAsync] instead.
  ///
  /// ```dart
  /// final schema = V.object<StrictDto>()
  ///     .field('title', (d) => d.title, V.string())
  ///     .field('scheduledDate', (d) => d.scheduledDate, V.date());
  /// schema.safeParseRaw({'title': 'meeting'});
  /// // VFailure with `scheduledDate.required` — no need to build StrictDto.
  /// ```
  VResult<Map<String, dynamic>?> safeParseRaw(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParseRaw',
        suggestion: 'safeParseRawAsync',
      );
    }
    if (_whenMatchesRules.isNotEmpty) {
      throw const VException([
        VError(
          code: VCode.custom,
          message:
              'safeParseRaw cannot validate a schema that declares whenMatches '
              '(entity-only). Use whenMatchesRaw instead, or validate via '
              'safeParse(T) after constructing T.',
        ),
      ]);
    }

    final Object? preprocessed = runPreprocessors(value);

    if (preprocessed == null) {
      if (_isNullable) return const VSuccess<Map<String, dynamic>?>(null);

      return VFailure<Map<String, dynamic>?>([
        VError(
          code: _requiredCode,
          message: _message ?? V.t(_requiredCode),
        ),
      ]);
    }

    if (preprocessed is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        preprocessed,
      );
    }

    final Map<String, dynamic> input = preprocessed;
    final List<VError> errors = <VError>[];
    final Map<String, dynamic> parsed = <String, dynamic>{};

    final Set<String> declaredKeys = <String>{
      for (final field in _fields) field.name,
    };

    if (_isStrict) {
      for (final key in input.keys) {
        if (!declaredKeys.contains(key)) {
          errors.add(
            VError(
              code: VObjectCode.unrecognizedKey,
              message: V.t(VObjectCode.unrecognizedKey, {'key': key}),
              path: [key],
            ),
          );
        }
      }
    }

    // Map-typed pre-pipeline rules (refineFieldRaw stage: pre).
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.pre) continue;

      if (!rule.check(input)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    for (final field in _fields) {
      final fieldValue = input[field.name];
      final result = field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[field.name] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] != rule.equals) continue;

      for (final entry in rule.then.entries) {
        final fieldValue = input[entry.key];
        final result = entry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            parsed[entry.key] = result.value;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [entry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedAfterPerField = _firstSegments(errors);

    for (final rule in _whenMatchesRawRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterPerField,
      )) {
        continue;
      }

      if (!rule.condition(input)) continue;

      for (final entry in rule.then.entries) {
        final fieldValue = input[entry.key];
        final result = entry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            parsed[entry.key] = result.value;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [entry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedBeforePostRawField = _firstSegments(errors);
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.post) continue;
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedBeforePostRawField,
      )) {
        continue;
      }

      if (!rule.check(input)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!declaredKeys.contains(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<Map<String, dynamic>?>(errors);

    return VSuccess<Map<String, dynamic>?>(parsed);
  }

  /// Parses [value] as a raw map and returns the validated map, or
  /// throws a [VException] on failure. See [safeParseRaw] for the full
  /// semantics — what runs, what is skipped, and when to prefer this
  /// over [parse].
  ///
  /// ```dart
  /// final map = schema.parseRaw({'title': 'meeting', 'date': dt});
  /// // throws VException if any field is missing / invalid.
  /// ```
  Map<String, dynamic>? parseRaw(Object? value) {
    final result = safeParseRaw(value);

    if (result case VFailure(:final errors)) {
      throw VException(errors);
    }

    return (result as VSuccess<Map<String, dynamic>?>).value;
  }

  /// Validates [value] as a raw map and returns whether it passes. See
  /// [safeParseRaw] for the full semantics.
  ///
  /// ```dart
  /// schema.validateRaw({'title': 'meeting'}); // false — date missing
  /// ```
  bool validateRaw(Object? value) => safeParseRaw(value).isValid;

  /// Validates [value] as a raw map and returns the list of errors, or
  /// `null` when the input passed. See [safeParseRaw] for the full
  /// semantics.
  ///
  /// ```dart
  /// final errs = schema.errorsRaw({'title': 'meeting'});
  /// // [VError(code: 'date.required', path: ['scheduledDate'], ...)]
  /// ```
  List<VError>? errorsRaw(Object? value) {
    final result = safeParseRaw(value);

    if (result case VFailure(:final errors)) return errors;

    return null;
  }

  /// Async sibling of [safeParseRaw]. See [safeParseRaw] for the full
  /// semantics. The same entity-level rules are skipped (refine,
  /// refineField, equalFields, entity-level transforms); per-field,
  /// `when`, `whenMatchesRaw`, and `refineFieldRaw` validators run —
  /// awaited when async. Throws [VException] when the schema declares
  /// `whenMatches` (entity-only) — those rules cannot run without `T`.
  Future<VResult<Map<String, dynamic>?>> safeParseRawAsync(
    Object? value,
  ) async {
    if (_whenMatchesRules.isNotEmpty) {
      throw const VException([
        VError(
          code: VCode.custom,
          message: 'safeParseRawAsync cannot validate a schema that declares '
              'whenMatches (entity-only). Use whenMatchesRaw instead, or '
              'validate via safeParseAsync(T) after constructing T.',
        ),
      ]);
    }

    final Object? preprocessed = await runPreprocessorsAsync(value);

    if (preprocessed == null) {
      if (_isNullable) return const VSuccess<Map<String, dynamic>?>(null);

      return VFailure<Map<String, dynamic>?>([
        VError(
          code: _requiredCode,
          message: _message ?? V.t(_requiredCode),
        ),
      ]);
    }

    if (preprocessed is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        preprocessed,
      );
    }

    final Map<String, dynamic> input = preprocessed;
    final List<VError> errors = <VError>[];
    final Map<String, dynamic> parsed = <String, dynamic>{};

    final Set<String> declaredKeys = <String>{
      for (final field in _fields) field.name,
    };

    if (_isStrict) {
      for (final key in input.keys) {
        if (!declaredKeys.contains(key)) {
          errors.add(
            VError(
              code: VObjectCode.unrecognizedKey,
              message: V.t(VObjectCode.unrecognizedKey, {'key': key}),
              path: [key],
            ),
          );
        }
      }
    }

    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.pre) continue;

      if (!rule.check(input)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    for (final field in _fields) {
      final fieldValue = input[field.name];
      final result = field.validator.hasAsync
          ? await field.validator.safeParseAsync(fieldValue)
          : field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[field.name] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] != rule.equals) continue;

      for (final entry in rule.then.entries) {
        final fieldValue = input[entry.key];
        final result = entry.value.hasAsync
            ? await entry.value.safeParseAsync(fieldValue)
            : entry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            parsed[entry.key] = result.value;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [entry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedAfterPerField = _firstSegments(errors);

    for (final rule in _whenMatchesRawRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedAfterPerField,
      )) {
        continue;
      }

      if (!rule.condition(input)) continue;

      for (final entry in rule.then.entries) {
        final fieldValue = input[entry.key];
        final result = entry.value.hasAsync
            ? await entry.value.safeParseAsync(fieldValue)
            : entry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            parsed[entry.key] = result.value;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [entry.key, ...error.path]));
            }
        }
      }
    }

    final Set<String> failedBeforePostRawField = _firstSegments(errors);
    for (final rule in _rawFieldRules) {
      if (rule.stage != RefineStage.post) continue;
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        failedBeforePostRawField,
      )) {
        continue;
      }

      if (!rule.check(input)) {
        errors.add(
          VError(
            code: VCode.custom,
            message: rule.message ?? V.t(VCode.custom),
            path: [rule.path],
          ),
        );
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!declaredKeys.contains(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<Map<String, dynamic>?>(errors);

    return VSuccess<Map<String, dynamic>?>(parsed);
  }

  /// Async sibling of [parseRaw]. Returns the validated map or throws
  /// [VException] on failure.
  Future<Map<String, dynamic>?> parseRawAsync(Object? value) async {
    final result = await safeParseRawAsync(value);

    if (result case VFailure(:final errors)) {
      throw VException(errors);
    }

    return (result as VSuccess<Map<String, dynamic>?>).value;
  }

  /// Async sibling of [validateRaw].
  Future<bool> validateRawAsync(Object? value) async =>
      (await safeParseRawAsync(value)).isValid;

  /// Async sibling of [errorsRaw]. Returns the list of errors or `null`.
  Future<List<VError>?> errorsRawAsync(Object? value) async {
    final result = await safeParseRawAsync(value);

    if (result case VFailure(:final errors)) return errors;

    return null;
  }
}
