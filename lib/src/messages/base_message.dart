class BaseMessage {
  final String required;
  final String refine;

  const BaseMessage({String? required, String? refine})
    : required = required ?? 'Required',
      refine = refine ?? 'Invalid value';

  BaseMessage copyWith({String? required, String? refine}) {
    return BaseMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
    );
  }
}
