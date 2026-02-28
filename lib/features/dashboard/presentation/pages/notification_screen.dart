import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/notifications/presentation/state/notification_state.dart';
import 'package:peerpicks/features/notifications/presentation/view_model/notification_viewmodel.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationViewModelProvider.notifier).getNotifications();
      ref.read(notificationViewModelProvider.notifier).getUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref
                    .read(notificationViewModelProvider.notifier)
                    .markAllAsRead();
              },
              child: Text('Mark all read', style: TextStyle(color: cs.primary)),
            ),
        ],
      ),
      body: _buildBody(notifState),
    );
  }

  Widget _buildBody(NotificationState notifState) {
    if (notifState.status == NotificationStatus.loading ||
        notifState.status == NotificationStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifState.status == NotificationStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              notifState.errorMessage ?? 'Failed to load notifications',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationViewModelProvider.notifier)
                    .getNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifState.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone interacts with your picks,\nyou\'ll see it here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(notificationViewModelProvider.notifier)
            .getNotifications();
      },
      color: const Color(0xFF75A638),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: notifState.notifications.length,
        itemBuilder: (context, index) {
          final notification = notifState.notifications[index];
          return _NotificationTile(
            notification: notification,
            onDismiss: () {
              ref
                  .read(notificationViewModelProvider.notifier)
                  .deleteNotification(notification.id);
            },
            onTap: () {
              if (notification.pickId != null &&
                  notification.pickId!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PickDetailScreen(pickId: notification.pickId!),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.notification,
    required this.onDismiss,
    this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.vote:
        return Icons.thumb_up_rounded;
      case NotificationType.comment:
        return Icons.chat_bubble_rounded;
      case NotificationType.save:
        return Icons.bookmark_rounded;
      case NotificationType.follow:
        return Icons.person_add_rounded;
      case NotificationType.welcome:
        return Icons.celebration_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.vote:
        return const Color(0xFF4CAF50);
      case NotificationType.comment:
        return const Color(0xFF2196F3);
      case NotificationType.save:
        return const Color(0xFFFF9800);
      case NotificationType.follow:
        return const Color(0xFF9C27B0);
      case NotificationType.welcome:
        return const Color(0xFFB4D333);
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.read
                ? cs.surfaceContainerHighest
                : cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.read
                  ? cs.outlineVariant
                  : cs.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Actor avatar or icon
              CircleAvatar(
                radius: 22,
                backgroundColor: _getIconColor().withOpacity(0.1),
                backgroundImage: notification.actorProfilePicture != null
                    ? NetworkImage(
                        ApiEndpoints.resolveServerUrl(
                          notification.actorProfilePicture!,
                        ),
                      )
                    : null,
                child: notification.actorProfilePicture == null
                    ? Icon(_getIcon(), color: _getIconColor(), size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.read
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
