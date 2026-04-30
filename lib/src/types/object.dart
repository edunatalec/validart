part of 'type.dart';

class _FieldEntry<T> {
  final String name;
  final Object? Function(T instance) extractor;
  final VType validator;

  const _FieldEntry({
    required this.name,
    required this.extractor,
    required this.validator,
  });
}

class _ObjectWhenRule<T> {
  final String field;
  final Object? equals;
  final Map<String, VType> then;

  const _ObjectWhenRule({
    required this.field,
    required this.equals,
    required this.then,
  });
}

class _ObjectWhenMatchesRule<T> {
  final bool Function(T entity) condition;
  final Set<String> dependsOn;
  final Map<String, VType> then;

  const _ObjectWhenMatchesRule({
    required this.condition,
    required this.dependsOn,
    required this.then,
  });
}

/// Validates class/entity instances of type [T] via type-safe field
/// extraction callbacks.
///
/// ```dart
/// final schema = V.object<User>()
///     .field('name', (u) => u.name, V.string().min(2))
///     .field('age', (u) => u.age, V.int().positive());
/// schema.validate(User(name: 'Jo', age: 25)); // true
/// ```
class VObject<T> extends VType<T> {
  final List<_FieldEntry<T>> _fields = [];
  final List<_ObjectWhenRule<T>> _whenRules = [];
  final List<_ObjectWhenMatchesRule<T>> _whenMatchesRules = [];

  VObject._({super.message, super.invalidTypeMessage});

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
      _fields.map((f) => MapEntry(f.name, f.extractor(instance))));

  /// Creates a [VObject] — chain [field] to add type-safe field extractors.
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  ///
  /// ```dart
  /// final schema = VObject<User>()
  ///     .field('name', (u) => u.name, V.string());
  /// ```
  factory VObject({String? message, String? invalidTypeMessage}) = VObject<T>._;

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
    _fields.add(_FieldEntry<T>(
      name: name,
      extractor: (instance) => extractor(instance),
      validator: validator,
    ));

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
  /// errors in a single `VFailure`.
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
  /// [whenMatches].
  List<
      ({
        bool Function(T entity) condition,
        Set<String> dependsOn,
        Map<String, VType> then,
      })> get whenMatchesRules => _whenMatchesRules
      .map((r) => (
            condition: r.condition,
            dependsOn: r.dependsOn,
            then: r.then,
          ))
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
  /// ```
  VObject<T> partial() {
    final result = VObject<T>._();

    for (final entry in _fields) {
      result._fields.add(_FieldEntry<T>(
        name: entry.name,
        extractor: entry.extractor,
        validator: entry.validator.mapType<VType>(
          <U>(inner) => _NullableWrapper<U>(inner),
        ),
      ));
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
    target._steps.addAll(_steps);
    target._preprocessors.addAll(_preprocessors);

    if (_isNullable) target._isNullable = true;

    if (_hasDefault) {
      target._defaultValue = _defaultValue;
      target._hasDefault = true;
    }
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
  /// that reads the typed entity.
  ///
  /// Use this when [when] is not expressive enough — when the trigger
  /// depends on a comparison other than `==` (`>`, `oneOf`, etc.) or on
  /// the combined value of multiple fields. The [condition] receives the
  /// entity `T` (after the container preprocess and type cast). When it
  /// returns `true`, every validator in [then] is applied to the
  /// corresponding field in addition to its baseline validator.
  ///
  /// [dependsOn] is required: it declares the field names the predicate
  /// reads, so subsequent `refine(dependsOn:)` / `refineField(dependsOn:)`
  /// rules can reference those fields without tripping the
  /// `_knownKeys()` assertion. Every key in [dependsOn] and in [then]
  /// must already be declared via [field] before calling this method.
  ///
  /// The predicate is always synchronous; validators inside [then] may be
  /// sync or async. A [whenMatches] rule whose [then] contains an async
  /// validator opts the schema into async mode (`hasAsync == true`).
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

    _whenMatchesRules.add(_ObjectWhenMatchesRule<T>(
      condition: condition,
      dependsOn: dependsOn,
      then: then,
    ));

    return this;
  }

  /// Adds a custom validation targeting a specific field [path]. The [check]
  /// receives the whole instance and the emitted error is scoped to [path].
  ///
  /// Runs in the validation phase. By default declares
  /// `dependsOn: {path}` — when the field at [path] fails its own
  /// validation, this check is skipped; otherwise the result is
  /// aggregated alongside any unrelated field errors in a single
  /// `VFailure`. Pass [dependsOn] to override the default — useful when
  /// the check on [path] also depends on OTHER fields (or to opt out
  /// of the skip entirely with `dependsOn: const {}`, which makes the
  /// check always run regardless of field failures; the callback must
  /// be defensive about partially-parsed input).
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('age', (u) => u.age, V.int())
  ///     .refineField(
  ///       (u) => u.age >= 18,
  ///       path: 'age',
  ///       message: 'Must be at least 18',
  ///     );
  /// ```
  VObject<T> refineField(
    bool Function(T instance) check, {
    required String path,
    String? message,
    Set<String>? dependsOn,
  }) {
    assert(
      _fields.any((f) => f.name == path),
      "The provided path '$path' does not exist in the schema.",
    );
    _assertDependsOnKeys(dependsOn);

    return add(
      _RefineValidator<T>(check: check, validatorCode: VCode.custom),
      message: message,
      path: [path],
      dependsOn: dependsOn ?? {path},
    );
  }

  /// Adds an entity-level rule scoped to a specific field path that
  /// runs **before** any per-field iteration. The [check] callback
  /// receives the `T` instance after the container preprocess and
  /// type cast — no per-field pipeline has run yet.
  ///
  /// Compare with [refineField], whose callback runs after every
  /// declared field has been individually validated and transformed.
  /// In practice, since `VObject` does not mutate `T` between the cast
  /// and the per-field iteration, the two callbacks observe the same
  /// instance most of the time — the meaningful difference is
  /// **timing**: [refineFieldRaw] always runs once the input is a
  /// valid `T`, while [refineField] is gated on the field at [path]
  /// passing per-field validation. Use [refineFieldRaw] when the rule
  /// must run regardless of per-field results, or to mirror the same
  /// semantics across `VMap` and `VObject<T>`.
  ///
  /// The error is emitted with `path: [path]` so consumers like
  /// `valiform`'s `VForm` surface it inline under that field.
  ///
  /// ```dart
  /// V.object<TaxPayer>()
  ///   .field('country', (t) => t.country, V.string())
  ///   .field('taxId', (t) => t.taxId, V.string())
  ///   .refineFieldRaw(
  ///     (t) => t.country == 'US' ? t.taxId.length == 9 : true,
  ///     path: 'taxId',
  ///     message: 'US taxId must be 9 chars',
  ///   );
  /// ```
  VObject<T> refineFieldRaw(
    bool Function(T instance) check, {
    required String path,
    String? message,
  }) {
    assert(
      _fields.any((f) => f.name == path),
      "The provided path '$path' does not exist in the schema.",
    );

    addRaw(
      _RefineValidator<T>(check: check, validatorCode: VCode.custom),
      message: message,
      path: [path],
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

    // Raw entity-level validators (refineFieldRaw) run BEFORE any
    // per-field iteration. They see `typed` as it was after container
    // preprocess + cast, with no per-field pipeline yet executed.
    final errors = <VError>[..._runRawValidators(typed)];

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

    for (final rule in _whenMatchesRules) {
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

    // Raw entity-level validators (refineFieldRaw) run BEFORE any
    // per-field iteration. They see `typed` as it was after container
    // preprocess + cast, with no per-field pipeline yet executed.
    final errors = <VError>[..._runRawValidators(typed)];

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

    for (final rule in _whenMatchesRules) {
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

    return _runPipelineAsync(
      typed,
      carriedErrors: errors,
      failedFieldPaths: _firstSegments(errors),
    );
  }
}
