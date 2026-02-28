import 'package:equatable/equatable.dart';

enum NotificationType { vote, comment, save, follow, welcome, system }

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId;
  final String? actorId;
  final String? actorName;
  final String? actorProfilePicture;
  final NotificationType type;
  final String status; // success, error, info, warning
  final String? pickId;
  final String message;
  final bool read;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.actorId,
    this.actorName,
    this.actorProfilePicture,
    required this.type,
    this.status = 'info',
    this.pickId,
    required this.message,
    this.read = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, recipientId, type, read, createdAt];
}
