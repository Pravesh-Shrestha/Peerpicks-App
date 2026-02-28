import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/notifications/data/datasources/notification_datasource.dart';
import 'package:peerpicks/features/social/data/models/notification_model.dart';

final notificationRemoteDataSourceProvider = Provider<INotificationDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationRemoteDataSource(client: apiClient);
});

class NotificationRemoteDataSource implements INotificationDataSource {
  final ApiClient client;

  NotificationRemoteDataSource({required this.client});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await client.get(ApiEndpoints.notifications);
    if (response.statusCode == 200) {
      final List data = response.data['data'] as List? ?? [];
      return data
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await client.get(ApiEndpoints.unreadCount);
    if (response.statusCode == 200) {
      return response.data['data']?['count'] ?? response.data['count'] ?? 0;
    }
    return 0;
  }

  @override
  Future<bool> markAllAsRead() async {
    final response = await client.patch(ApiEndpoints.markRead);
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    final response = await client.delete(ApiEndpoints.deleteNotification(id));
    return response.statusCode == 200;
  }
}
