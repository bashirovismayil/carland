class GetColorListResponse {
  final int colorId;
  final String color;

  GetColorListResponse({
    required this.colorId,
    required this.color,
  });

  GetColorListResponse copyWith({
    int? colorId,
    String? color,
  }) =>
      GetColorListResponse(
        colorId: colorId ?? this.colorId,
        color: color ?? this.color,
      );

  factory GetColorListResponse.fromJson(Map<String, dynamic> json) =>
      GetColorListResponse(
        colorId: json['colorId'] as int,
        color: json['color'] as String,
      );

  Map<String, dynamic> toJson() => {
    'colorId': colorId,
    'color': color,
  };
}