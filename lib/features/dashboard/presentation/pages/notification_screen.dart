import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/notifications/presentation/state/notification_state.dart';
import 'package:peerpicks/features/notifications/presentation/view_model/notification_viewmodel.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/user_profile_view_screen.dart';

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
    final isOffline = ref
        .watch(connectivityStatusProvider)
        .maybeWhen(data: (isConnected) => !isConnected, orElse: () => false);
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
      body: Column(
        children: [
          if (isOffline) _buildOfflineCacheBanner(context),
          Expanded(child: _buildBody(notifState)),
        ],
      ),
    );
  }

  Widget _buildOfflineCacheBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 18, color: cs.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline. Showing cached notifications.',
              style: TextStyle(
                color: cs.onTertiaryContainer,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
      child: Builder(
        builder: (context) {
          final now = DateTime.now();
          final recent = notifState.notifications
              .where((n) => now.difference(n.createdAt).inHours < 24)
              .toList();
          final old = notifState.notifications
              .where((n) => now.difference(n.createdAt).inHours >= 24)
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (recent.isNotEmpty) ...[
                _buildSectionHeader(context, 'Recent'),
                ...recent.map((notification) {
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
                    onActorTap: () {
                      if (notification.actorId != null &&
                          notification.actorId!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileViewScreen(
                              userId: notification.actorId!,
                              userName: notification.actorName,
                              userAvatar: notification.actorProfilePicture,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
              if (old.isNotEmpty) ...[
                _buildSectionHeader(context, 'Old'),
                ...old.map((notification) {
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
                    onActorTap: () {
                      if (notification.actorId != null &&
                          notification.actorId!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileViewScreen(
                              userId: notification.actorId!,
                              userName: notification.actorName,
                              userAvatar: notification.actorProfilePicture,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;
  final VoidCallback? onActorTap;

  const _NotificationTile({
    required this.notification,
    required this.onDismiss,
    this.onTap,
    this.onActorTap,
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

  String _formatNotificationDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
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
              GestureDetector(
                onTap: onActorTap,
                child: CircleAvatar(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.actorName != null &&
                              notification.actorName!.isNotEmpty
                          ? '${notification.actorName} ${notification.message}'
                          : notification.message,
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
                    if (notification.about != null &&
                        notification.about!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'About: ${notification.about}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _formatNotificationDate(notification.createdAt),
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
