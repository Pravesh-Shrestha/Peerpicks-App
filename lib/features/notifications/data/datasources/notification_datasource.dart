import 'package:peerpicks/features/social/data/models/notification_model.dart';

abstract interface class INotificationDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<bool> markAllAsRead();
  Future<bool> deleteNotification(String id);
}
