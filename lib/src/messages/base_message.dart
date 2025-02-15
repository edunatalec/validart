class BaseMessage {
  final String required;
  final String refine;
  final String any;
  final String every;

  const BaseMessage({
    String? required,
    String? refine,
    String? any,
    String? every,
  }) : required = required ?? 'Required',
       refine = refine ?? 'Invalid value',
       any = any ?? 'Invalid value',
       every = every ?? 'Invalid value';

  BaseMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
  }) {
    return BaseMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
    );
  }
}
