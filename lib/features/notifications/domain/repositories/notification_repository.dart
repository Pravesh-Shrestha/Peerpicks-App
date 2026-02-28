import 'package:dartz/dartz.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, bool>> markAllAsRead();
  Future<Either<Failure, bool>> deleteNotification(String id);
}
