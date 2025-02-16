/// Enum representing different versions of UUID (Universally Unique Identifier).
/// Each version follows a specific structure and is validated using a regex pattern.
enum UUIDVersion {
  /// UUID v1: Based on timestamp and node (MAC address).
  /// Example: `550e8400-e29b-11d4-a716-446655440000`
  v1(r'^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'),

  /// UUID v3: Deterministic hash-based (MD5) UUID.
  /// Example: `6fa459ea-ee8a-3ca4-894e-db77e160355e`
  v3(r'^[0-9a-f]{8}-[0-9a-f]{4}-3[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'),

  /// UUID v4: Randomly generated UUID.
  /// Example: `7d3a94f5-b1c1-4e2b-8e6f-f1d3f2430b9f`
  v4(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'),

  /// UUID v5: Deterministic hash-based (SHA-1) UUID.
  /// Example: `2ed6657d-e927-568b-95e1-2665a8aea6a2`
  v5(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

  /// Regular expression pattern for validating the UUID structure.
  final String pattern;

  /// Constructor assigning a validation regex to each UUID version.
  const UUIDVersion(this.pattern);
}
