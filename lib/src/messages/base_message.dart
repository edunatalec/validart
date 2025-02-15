class BaseMessage {
  final String required;
  final String refine;

  BaseMessage({required this.required, required this.refine});

  BaseMessage copyWith({String? required, String? refine}) {
    return BaseMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
    );
  }
}
