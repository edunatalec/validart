class MapMessage {
  final String required;
  final String refine;

  MapMessage({required this.required, required this.refine});

  MapMessage copyWith({String? required, String? refine}) {
    return MapMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
    );
  }
}
