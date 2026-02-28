import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/notifications/data/repositories/notification_repository.dart';
import 'package:peerpicks/features/notifications/domain/repositories/notification_repository.dart';
import 'package:peerpicks/features/notifications/presentation/state/notification_state.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final INotificationRepository _notificationRepository;

  @override
  NotificationState build() {
    _notificationRepository = ref.read(notificationRepositoryProvider);
    return const NotificationState();
  }

  Future<void> getNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);

    final result = await _notificationRepository.getNotifications();
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.message,
      ),
      (notifications) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: notifications,
      ),
    );
  }

  Future<void> getUnreadCount() async {
    final result = await _notificationRepository.getUnreadCount();
    result.fold((_) {}, (count) => state = state.copyWith(unreadCount: count));
  }

  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllAsRead();
    result.fold((_) {}, (_) {
      final updated = state.notifications.map((n) {
        // Return new entity with read = true
        return NotificationEntity(
          id: n.id,
          recipientId: n.recipientId,
          actorId: n.actorId,
          actorName: n.actorName,
          actorProfilePicture: n.actorProfilePicture,
          type: n.type,
          status: n.status,
          pickId: n.pickId,
          about: n.about,
          message: n.message,
          read: true,
          createdAt: n.createdAt,
        );
      }).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    });
  }

  Future<void> deleteNotification(String id) async {
    final result = await _notificationRepository.deleteNotification(id);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updated = state.notifications.where((n) => n.id != id).toList();
        final unread = updated.where((n) => !n.read).length;
        state = state.copyWith(notifications: updated, unreadCount: unread);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
