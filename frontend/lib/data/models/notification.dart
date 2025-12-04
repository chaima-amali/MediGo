class NotificationModel {
  final int? notificationId;
  final int userId;
  final int planId;
  final int reservationId;
  final int medicineFindId;
  final int dcId;
  final String datetime;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    this.notificationId,
    required this.userId,
    required this.planId,
    required this.reservationId,
    required this.medicineFindId,
    required this.dcId,
    required this.datetime,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    int? notificationId,
    int? userId,
    int? planId,
    int? reservationId,
    int? medicineFindId,
    int? dcId,
    String? datetime,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      reservationId: reservationId ?? this.reservationId,
      medicineFindId: medicineFindId ?? this.medicineFindId,
      dcId: dcId ?? this.dcId,
      datetime: datetime ?? this.datetime,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notification_id'] as int?,
      userId: map['user_id'] as int,
      planId: map['plan_id'] as int,
      reservationId: map['reservation_id'] as int,
      medicineFindId: map['medicine_find_id'] as int,
      dcId: map['dc_id'] as int,
      datetime: map['datetime'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      isRead: (map['is_read'] == 1),
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'plan_id': planId,
      'reservation_id': reservationId,
      'medicine_find_id': medicineFindId,
      'dc_id': dcId,
      'datetime': datetime,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }
}