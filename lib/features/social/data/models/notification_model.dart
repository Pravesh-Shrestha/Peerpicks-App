import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.actorId,
    super.actorName,
    super.actorProfilePicture,
    required super.type,
    super.status,
    super.pickId,
    required super.message,
    super.read,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    String? actorId;
    String? actorName;
    String? actorPic;

    if (actor is Map<String, dynamic>) {
      actorId = actor['_id'];
      actorName = actor['fullName'];
      actorPic = actor['profilePicture'];
    } else if (actor is String) {
      actorId = actor;
    }

    return NotificationModel(
      id: json['_id'] ?? '',
      recipientId: json['recipient'] is Map
          ? json['recipient']['_id']
          : json['recipient'] ?? '',
      actorId: actorId,
      actorName: actorName,
      actorProfilePicture: actorPic,
      type: _parseType(json['type']),
      status: json['status'] ?? 'info',
      pickId: json['pickId'] is Map ? json['pickId']['_id'] : json['pickId'],
      message: json['message'] ?? _fallbackMessage(json['type']),
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'VOTE':
        return NotificationType.vote;
      case 'COMMENT':
        return NotificationType.comment;
      case 'SAVE':
        return NotificationType.save;
      case 'FOLLOW':
        return NotificationType.follow;
      case 'WELCOME':
        return NotificationType.welcome;
      case 'SYSTEM':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  static String _fallbackMessage(String? type) {
    switch (type?.toUpperCase()) {
      case 'VOTE':
        return 'Someone upvoted your pick!';
      case 'COMMENT':
        return 'Someone commented on your pick!';
      case 'SAVE':
        return 'Someone saved your pick!';
      case 'FOLLOW':
        return 'Someone started following you!';
      case 'WELCOME':
        return 'Welcome to PeerPicks!';
      default:
        return 'You have a new notification';
    }
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfilePicture: actorProfilePicture,
      type: type,
      status: status,
      pickId: pickId,
      message: message,
      read: read,
      createdAt: createdAt,
    );
  }

  static List<NotificationEntity> toEntityList(List<NotificationModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
