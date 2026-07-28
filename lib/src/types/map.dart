part of 'type.dart';

class _WhenRule {
  const _WhenRule({
    required this.field,
    required this.equals,
    required this.then,
  });

  final String field;
  final Object? equals;
  final Map<String, VType> then;
}

class _WhenMatchesRule {
  const _WhenMatchesRule({
    required this.condition,
    required this.dependsOn,
    required this.then,
  });

  final bool Function(Map<String, dynamic> input) condition;
  final Set<String> dependsOn;
  final Map<String, VType> then;
}

/// Validates `Map<String, dynamic>` values against a field schema.
///
/// Errors from individual fields include the field name in their path.
///
/// ```dart
/// final schema = V.map({
///   'name': V.string().min(2),
///   'age': V.int().positive(),
/// });
/// schema.parse({'name': 'Jo', 'age': 25});
/// ```
class VMap extends VType<Map<String, dynamic>> {
  /// Creates a map validator with the given field [_schema].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VMap(this._schema, {super.message, super.invalidTypeMessage}) {
    assert(_schema.isNotEmpty, 'Schema must have at least one field.');
  }
  final Map<String, VType> _schema;
  final List<_WhenRule> _whenRules = [];
  final List<_WhenMatchesRule> _whenMatchesRules = [];
  bool _isStrict = false;
  bool _isPassthrough = false;

  @override
  String get typeName => 'map';

  @override
  VMap add(
    Validator<Map<String, dynamic>> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VMap nullable() {
    super.nullable();
    return this;
  }

  @override
  VMap defaultValue(Map<String, dynamic> value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VMap preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  /// Adds a custom entity-level validation that runs after every field has
  /// been validated.
  ///
  /// Pass [dependsOn] to declare which schema field keys this refine reads.
  /// When provided, the refine is skipped only if one of those specific
  /// fields failed validation, so its error is aggregated alongside
  /// unrelated field errors in a single pass. When omitted, the refine
  /// follows the conservative rule: skip if ANY field failed (avoids
  /// cast crashes on partially-parsed inputs).
  ///
  /// Pass `dependsOn: const {}` (empty set) to opt OUT of the
  /// conservative skip entirely — the refine runs even when other
  /// fields failed. The callback must be defensive about
  /// partially-parsed input (fields that failed may be missing from
  /// the map). Useful for audit / logging rules that should fire on
  /// every submission.
  ///
  /// `dependsOn` accepts any key declared in the base schema OR injected
  /// via any `when.then` / `whenMatches.then` block (or referenced in
  /// `whenMatches.dependsOn`). Unknown keys throw an `AssertionError`.
  ///
  /// ```dart
  /// // Conservative default — skip if any field failed.
  /// V.map({...}).refine((m) => ...);
  ///
  /// // Aggregate alongside unrelated failures — skip only if 'a' or
  /// // 'b' failed.
  /// V.map({...}).refine((m) => ..., dependsOn: const {'a', 'b'});
  ///
  /// // Always run, even when fields failed (callback must be safe).
  /// V.map({...}).refine((m) => audit(m), dependsOn: const {});
  ///
  /// V.map({
  ///   'startDate': V.date(),
  ///   'endDate': V.date(),
  /// }).refine(
  ///   (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
  ///   code: 'date_range_invalid',
  ///   message: 'endDate must be after startDate',
  ///   dependsOn: const {'startDate', 'endDate'},
  /// );
  /// ```
  @override
  VMap refine(
    bool Function(Map<String, dynamic> value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    _assertDependsOnKeys(dependsOn);
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VMap preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  /// Async sibling of [refine]. See [refine] for the meaning of
  /// [dependsOn].
  @override
  VMap refineAsync(
    Future<bool> Function(Map<String, dynamic> value) check, {
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
    final keys = <String>{..._schema.keys};

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

  /// Returns an unmodifiable view of the field schema.
  Map<String, VType> get schema => Map.unmodifiable(_schema);

  /// The conditional validation rules added via [when].
  List<({String field, Object? equals, Map<String, VType> then})>
      get whenRules => _whenRules
          .map((r) => (field: r.field, equals: r.equals, then: r.then))
          .toList();

  /// The predicate-based conditional validation rules added via
  /// [whenMatches].
  List<
      ({
        bool Function(Map<String, dynamic> input) condition,
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

  /// Creates a new schema containing only the specified [keys].
  ///
  /// ```dart
  /// final full = V.map({'name': V.string(), 'age': V.int()});
  /// final partial = full.pick(['name']); // only validates 'name'
  /// ```
  VMap pick(List<String> keys) {
    final picked = <String, VType>{};

    for (final key in keys) {
      if (_schema.containsKey(key)) {
        picked[key] = _schema[key]!;
      }
    }

    return VMap(picked);
  }

  /// Creates a new schema excluding the specified [keys].
  ///
  /// ```dart
  /// final full = V.map({'name': V.string(), 'age': V.int()});
  /// final reduced = full.omit(['age']); // only validates 'name'
  /// ```
  VMap omit(List<String> keys) {
    final omitted = Map<String, VType>.from(_schema);

    for (final key in keys) {
      omitted.remove(key);
    }

    return VMap(omitted);
  }

  /// Creates a new schema by adding [extra] fields to the current schema.
  ///
  /// Preserves all pipeline state from the base schema: validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `strict` and
  /// `passthrough` flags, `nullable`, `defaultValue`, and preprocessors.
  ///
  /// ```dart
  /// final base = V.map({'name': V.string()});
  /// final extended = base.extend({'age': V.int()});
  /// ```
  VMap extend(Map<String, VType> extra) {
    final result = VMap({..._schema, ...extra});
    _copyMapStateTo(result);
    return result;
  }

  /// Creates a new schema by merging with [other]'s fields.
  ///
  /// Combines pipeline state from both schemas: `when` rules, validator
  /// steps, and preprocessors are concatenated (base first, then other).
  /// Boolean flags (`strict`, `passthrough`, `nullable`) are OR-ed. If both
  /// sides set `defaultValue`, [other]'s wins.
  ///
  /// ```dart
  /// final a = V.map({'name': V.string()});
  /// final b = V.map({'age': V.int()});
  /// final merged = a.merge(b);
  /// ```
  VMap merge(VMap other) {
    final result = VMap({..._schema, ...other._schema});
    _copyMapStateTo(result);
    other._copyMapStateTo(result);
    return result;
  }

  void _copyMapStateTo(VMap target) {
    target._whenRules.addAll(_whenRules);
    target._whenMatchesRules.addAll(_whenMatchesRules);
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

  /// Creates a new schema where all fields are nullable.
  ///
  /// Pass [except] to keep specific keys with their original validator
  /// (useful for partial-update DTOs that retain a required identifier).
  ///
  /// Does not mutate the original schema — inner validators are wrapped so
  /// that the base schema continues to reject null. Preserves all pipeline
  /// state from the base (validators added via `add`/`equalFields`/
  /// `refineField`/`refine`, `when` rules, `strict`/`passthrough` flags,
  /// `nullable`, `defaultValue`, and preprocessors), matching the
  /// behavior of `extend`/`merge`/`pick`/`omit`.
  ///
  /// ```dart
  /// final schema = V.map({'name': V.string()}).partial();
  /// schema.parse({'name': null}); // {'name': null}
  ///
  /// final update = V.map({
  ///   'id': V.string().uuid(),
  ///   'name': V.string().min(1),
  /// }).partial(except: ['id']);
  /// update.validate({'id': '...'}); // true (name is now nullable)
  /// update.validate({'name': 'Jo'}); // false (id is still required)
  /// ```
  VMap partial({List<String>? except}) {
    assert(
      except == null || except.every(_schema.containsKey),
      'partial(except: ...) received undeclared keys: '
      '${except.where((k) => !_schema.containsKey(k)).toList()}',
    );

    final Set<String> exceptSet =
        (except == null || except.isEmpty) ? const <String>{} : except.toSet();

    final Map<String, VType> partialSchema = <String, VType>{};

    for (final entry in _schema.entries) {
      if (exceptSet.contains(entry.key)) {
        partialSchema[entry.key] = entry.value;
        continue;
      }

      partialSchema[entry.key] = entry.value.mapType<VType>(
        <U>(inner) => _NullableWrapper<U>(inner),
      );
    }

    final VMap result = VMap(partialSchema);
    _copyMapStateTo(result);

    return result;
  }

  /// Rejects keys not present in the schema.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).strict()
  ///   .validate({'name': 'Jo', 'extra': true}); // false
  /// ```
  VMap strict() {
    _isStrict = true;
    return this;
  }

  /// Allows extra keys not in the schema to pass through to the result.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).passthrough()
  ///   .parse({'name': 'Jo', 'extra': true}); // {'name': 'Jo', 'extra': true}
  /// ```
  VMap passthrough() {
    _isPassthrough = true;
    return this;
  }

  /// Applies conditional validation rules based on a field's value.
  ///
  /// When [field] equals [equals], the [then] validators are applied.
  ///
  /// ```dart
  /// V.map({
  ///   'type': V.string(),
  ///   'value': V.string(),
  /// }).when('type', equals: 'email', then: {
  ///   'value': V.string().email(),
  /// });
  /// ```
  VMap when(
    String field, {
    required Object? equals,
    required Map<String, VType> then,
  }) {
    assert(
      _schema.containsKey(field),
      "The provided field '$field' does not exist in the schema.",
    );
    _whenRules.add(_WhenRule(field: field, equals: equals, then: then));
    return this;
  }

  /// Applies conditional validation rules based on an arbitrary predicate
  /// that reads the raw input map.
  ///
  /// Use this when [when] is not expressive enough — when the trigger
  /// depends on a comparison other than `==` (`>`, `oneOf`, etc.) or on
  /// the combined value of multiple fields. The [condition] receives the
  /// raw `Map<String, dynamic>` (post-preprocess, post type-check, but
  /// before per-field parsing). When it returns `true`, every validator
  /// in [then] is applied to the corresponding field in addition to its
  /// baseline validator.
  ///
  /// [dependsOn] is required and must be **non-empty**: every key in
  /// [dependsOn] must already be declared in the base schema OR in a
  /// previously registered `when.then` / `whenMatches.then`. The rule
  /// uses [dependsOn] for two purposes:
  ///
  /// 1. **Skip gating** (defensive). If any declared dependency failed
  ///    its own per-field validation, the entire rule is skipped — the
  ///    predicate is not called and [then] is not applied. Mirrors
  ///    `refine(dependsOn:)`: a [condition] that casts `m['x'] as int`
  ///    would crash on a partially-parsed payload, so skipping is the
  ///    safe default.
  /// 2. **Visibility for downstream `refine(dependsOn:)`**. Keys
  ///    declared here enter `_knownKeys()`, letting later refines
  ///    reference them without tripping the assertion.
  ///
  /// The predicate is always synchronous; validators inside [then] may be
  /// sync or async. A [whenMatches] rule whose [then] contains an async
  /// validator opts the schema into async mode (`hasAsync == true`).
  ///
  /// ```dart
  /// V.map({
  ///   'role': V.string(),
  ///   'level': V.int(),
  ///   'audit_token': V.string().nullable(),
  /// }).whenMatches(
  ///   (m) => m['role'] == 'admin' && (m['level'] as int) > 5,
  ///   dependsOn: const {'role', 'level'},
  ///   then: {'audit_token': V.string().min(1)},
  /// );
  /// ```
  VMap whenMatches(
    bool Function(Map<String, dynamic> input) condition, {
    required Set<String> dependsOn,
    required Map<String, VType> then,
  }) {
    assert(
      dependsOn.isNotEmpty,
      'whenMatches dependsOn must declare at least one schema key — '
      'the rule is skipped when a declared dependency failed per-field '
      'validation. Use refine() or add() for rules that should always run.',
    );

    final known = _knownKeys();

    for (final key in dependsOn) {
      assert(
        known.contains(key),
        "whenMatches dependsOn key '$key' is not declared in the schema "
        '(base, when.then, or whenMatches.then).',
      );
    }

    _whenMatchesRules.add(
      _WhenMatchesRule(
        condition: condition,
        dependsOn: dependsOn,
        then: then,
      ),
    );

    return this;
  }

  /// Creates a [VArray] schema that validates a `List<Map<String, dynamic>>`.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).array().parse([{'name': 'Jo'}]);
  /// ```
  VArray<Map<String, dynamic>> array() => VArray<Map<String, dynamic>>(this);

  /// Validates that two fields have equal values.
  ///
  /// Runs in the validation phase. Declares `dependsOn: {field, other}`
  /// internally — when [field] or [other] fails its own validation, this
  /// check is skipped (the field error already covers the issue);
  /// otherwise the result is aggregated alongside any unrelated field
  /// errors in a single `VFailure`.
  ///
  /// ```dart
  /// V.map({
  ///   'password': V.string(),
  ///   'confirm': V.string(),
  /// }).equalFields('password', 'confirm');
  /// ```
  VMap equalFields(String field, String other, {String? message}) {
    // Reuse the same key-existence check as `refine(dependsOn:)` — accepts
    // both base-schema keys and when.then keys, and emits a uniform
    // assertion message across all entity-level rules.
    _assertDependsOnKeys({field, other});

    return add(
      EqualFieldsValidator(field: field, other: other),
      message: message,
      dependsOn: {field, other},
    );
  }

  /// Adds a custom validation that targets a specific field path.
  ///
  /// The [stage] controls when the check runs in the container pipeline:
  ///
  /// - [RefineStage.post] (default): runs **after** every field has been
  ///   parsed and transformed. Callback sees the post-pipeline values.
  ///   Skipped when any declared dependency failed — this protects the
  ///   callback from casting a value that never satisfied its own
  ///   validator (`data['x'] as int` on a non-int input).
  /// - [RefineStage.pre]: runs **before** any per-field iteration.
  ///   Callback sees the raw input as the user typed it (no preprocess /
  ///   transforms applied). Always runs once the type check passed;
  ///   [dependsOn] is not accepted (no field has been validated yet).
  ///
  /// In [RefineStage.post]: **`path` is always part of the dependency set**,
  /// even when [dependsOn] is omitted. When [dependsOn] is provided it is
  /// **unioned with `{path}`**, not replaced — you only declare the *extra*
  /// fields the callback reads. Passing an empty set triggers an
  /// `AssertionError`: a refineField on a path that only depends on itself
  /// is already the default; for "always run regardless", use a plain
  /// `refine(dependsOn: const {})`.
  ///
  /// ```dart
  /// // Default (post) — implicit dependsOn = {age}.
  /// V.map({'age': V.int()}).refineField(
  ///   (data) => (data['age'] as int) >= 18,
  ///   path: 'age',
  ///   message: 'Must be at least 18',
  /// );
  ///
  /// // Cross-field (post) — declares the extra dep; path is implicit.
  /// V.map({
  ///   'email': V.string().email(),
  ///   'domain': V.string().min(1),
  /// }).refineField(
  ///   (data) => (data['email'] as String).endsWith(data['domain'] as String),
  ///   path: 'email',
  ///   dependsOn: const {'domain'}, // effective: {email, domain}
  ///   message: 'email must match the configured domain',
  /// );
  ///
  /// // Pre-pipeline — see raw input before .toLowerCase() applies.
  /// V.map({
  ///   'email': V.string().toLowerCase().email(),
  ///   'expected': V.string(),
  /// }).refineField(
  ///   (data) => data['email'] == data['expected'],
  ///   path: 'email',
  ///   stage: RefineStage.pre,
  ///   message: 'email must match expected (raw, case-sensitive)',
  /// );
  /// ```
  VMap refineField(
    bool Function(Map<String, dynamic> data) check, {
    required String path,
    String? message,
    Set<String>? dependsOn,
    RefineStage stage = RefineStage.post,
  }) {
    assert(
      _schema.containsKey(path),
      "The provided path '$path' does not exist in the schema.",
    );
    assert(
      stage == RefineStage.post || dependsOn == null,
      'refineField with stage: RefineStage.pre cannot declare dependsOn — '
      'pre-pipeline runs unconditionally (no field has been validated yet).',
    );
    assert(
      dependsOn == null || dependsOn.isNotEmpty,
      'refineField dependsOn must declare at least one extra schema key when '
      'provided — the path is implicitly included. To run a check that '
      'should fire regardless of field failures, use stage: RefineStage.pre '
      '(raw input) or refine(dependsOn: const {}) (entity-level, post).',
    );
    _assertDependsOnKeys(dependsOn);

    switch (stage) {
      case RefineStage.pre:
        addRaw(
          _RefineValidator<Map<String, dynamic>>(
            check: check,
            validatorCode: VCode.custom,
          ),
          message: message,
          path: [path],
        );
        return this;
      case RefineStage.post:
        final Set<String> effectiveDeps =
            dependsOn == null ? {path} : {...dependsOn, path};

        return add(
          _RefineValidator<Map<String, dynamic>>(
            check: check,
            validatorCode: VCode.custom,
          ),
          message: message,
          path: [path],
          dependsOn: effectiveDeps,
        );
    }
  }

  @override
  bool get hasAsync {
    if (super.hasAsync) return true;

    for (final field in _schema.values) {
      if (field.hasAsync) return true;
    }

    for (final rule in _whenRules) {
      for (final field in rule.then.values) {
        if (field.hasAsync) return true;
      }
    }

    for (final rule in _whenMatchesRules) {
      for (final field in rule.then.values) {
        if (field.hasAsync) return true;
      }
    }

    return false;
  }

  @override
  VResult<Map<String, dynamic>?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final Object? preprocessed = runPreprocessors(value);

    final resolution = _resolveNull<Map<String, dynamic>>(
      _defaultValue,
      _hasDefault,
      preprocessed,
    );
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        input!,
      );
    }

    // Raw entity-level validators (refineFieldRaw) run BEFORE any
    // per-field iteration so their callback sees the input as it
    // arrived, not the parsed/transformed values.
    final errors = <VError>[..._runRawValidators(input)];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in input.keys) {
        if (!_schema.containsKey(key)) {
          errors.add(
            VError(
              code: VMapCode.unrecognizedKey,
              message: V.t(VMapCode.unrecognizedKey, {'key': key}),
              path: [key],
            ),
          );
        }
      }
    }

    for (final entry in _schema.entries) {
      final fieldValue = input[entry.key];
      final result = entry.value.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[entry.key] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(
              error.copyWith(
                path: [entry.key, ...error.path],
              ),
            );
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] == rule.equals) {
        for (final entry in rule.then.entries) {
          final fieldValue = input[entry.key];
          final result = entry.value.safeParse(fieldValue);

          switch (result) {
            case VSuccess():
              parsed[entry.key] = result.value;
            case VFailure():
              for (final error in result.errors) {
                errors.add(
                  error.copyWith(
                    path: [entry.key, ...error.path],
                  ),
                );
              }
          }
        }
      }
    }

    final Set<String> whenMatchesFailedFieldPaths =
        _whenMatchesRules.isEmpty ? const {} : _firstSegments(errors);

    for (final rule in _whenMatchesRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        whenMatchesFailedFieldPaths,
      )) {
        continue;
      }

      if (rule.condition(input)) {
        for (final entry in rule.then.entries) {
          final fieldValue = input[entry.key];
          final result = entry.value.safeParse(fieldValue);

          switch (result) {
            case VSuccess():
              parsed[entry.key] = result.value;
            case VFailure():
              for (final error in result.errors) {
                errors.add(
                  error.copyWith(
                    path: [entry.key, ...error.path],
                  ),
                );
              }
          }
        }
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!_schema.containsKey(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    return _runPipeline(
      parsed,
      carriedErrors: errors,
      failedFieldPaths: _firstSegments(errors),
    );
  }

  @override
  Future<VResult<Map<String, dynamic>?>> safeParseAsync(Object? value) async {
    final Object? preprocessed = await runPreprocessorsAsync(value);

    final resolution = _resolveNull<Map<String, dynamic>>(
      _defaultValue,
      _hasDefault,
      preprocessed,
    );
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        input!,
      );
    }

    // Raw entity-level validators (refineFieldRaw) run BEFORE any
    // per-field iteration so their callback sees the input as it
    // arrived, not the parsed/transformed values.
    final errors = <VError>[..._runRawValidators(input)];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in input.keys) {
        if (!_schema.containsKey(key)) {
          errors.add(
            VError(
              code: VMapCode.unrecognizedKey,
              message: V.t(VMapCode.unrecognizedKey, {'key': key}),
              path: [key],
            ),
          );
        }
      }
    }

    for (final entry in _schema.entries) {
      final fieldValue = input[entry.key];
      final result = entry.value.hasAsync
          ? await entry.value.safeParseAsync(fieldValue)
          : entry.value.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[entry.key] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(
              error.copyWith(
                path: [entry.key, ...error.path],
              ),
            );
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] == rule.equals) {
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
                errors.add(
                  error.copyWith(
                    path: [entry.key, ...error.path],
                  ),
                );
              }
          }
        }
      }
    }

    final Set<String> whenMatchesFailedFieldPaths =
        _whenMatchesRules.isEmpty ? const {} : _firstSegments(errors);

    for (final rule in _whenMatchesRules) {
      if (VType._shouldSkipForFailedFields(
        rule.dependsOn,
        whenMatchesFailedFieldPaths,
      )) {
        continue;
      }

      if (rule.condition(input)) {
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
                errors.add(
                  error.copyWith(
                    path: [entry.key, ...error.path],
                  ),
                );
              }
          }
        }
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!_schema.containsKey(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    return _runPipelineAsync(
      parsed,
      carriedErrors: errors,
      failedFieldPaths: _firstSegments(errors),
    );
  }
}
