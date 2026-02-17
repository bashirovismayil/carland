import '../../../../core/constants/enums/enums.dart';

class BrandListResponse {
  final int? brandId;
  final String? brandName;
  final BrandStatus? status;

  BrandListResponse({
    this.brandId,
    this.brandName,
    this.status,
  });

  BrandListResponse copyWith({
    int? brandId,
    String? brandName,
    BrandStatus? status,
  }) =>
      BrandListResponse(
        brandId: brandId ?? this.brandId,
        brandName: brandName ?? this.brandName,
        status: status ?? this.status,
      );

  factory BrandListResponse.fromJson(Map<String, dynamic> json) {
    BrandStatus? parsedStatus;
    try {
      final raw = json['status'] as String?;
      if (raw == 'ACTIVE') parsedStatus = BrandStatus.ACTIVE;
    } catch (_) {
      parsedStatus = BrandStatus.UNKNOWN;
    }

    return BrandListResponse(
      brandId: json['brandId'] as int?,
      brandName: json['brandName'] as String?,
      status: parsedStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'brandName': brandName,
    'status': status?.name,
  };
}