class GetNotificationListResponse {
  final int id;
  final DateTime created;
  final String type;
  final String notificationText;
  final String title;
  final int customerId;
  final String status;
  final bool isRead;

  GetNotificationListResponse({
    required this.id,
    required this.created,
    required this.type,
    required this.notificationText,
    required this.title,
    required this.customerId,
    required this.status,
    required this.isRead,
  });

  GetNotificationListResponse copyWith({
    int? id,
    DateTime? created,
    String? type,
    String? notificationText,
    String? title,
    int? customerId,
    String? status,
    bool? isRead,
  }) =>
      GetNotificationListResponse(
        id: id ?? this.id,
        created: created ?? this.created,
        type: type ?? this.type,
        notificationText: notificationText ?? this.notificationText,
        title: title ?? this.title,
        customerId: customerId ?? this.customerId,
        status: status ?? this.status,
        isRead: isRead ?? this.isRead,
      );

  factory GetNotificationListResponse.fromJson(Map<String, dynamic> json) =>
      GetNotificationListResponse(
        id: json['id'] as int,
        created: DateTime.parse(json['created'] as String),
        type: json['type'] as String,
        notificationText: json['notificationText'] as String,
        title: json['title'] as String,
        customerId: json['customerId'] as int,
        status: json['status'] as String,
        isRead: json['isRead'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created': created.toIso8601String(),
    'type': type,
    'notificationText': notificationText,
    'title': title,
    'customerId': customerId,
    'status': status,
    'isRead': isRead,
  };
}