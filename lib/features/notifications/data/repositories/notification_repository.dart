import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/core/services/storage/storage_service.dart';
import 'package:peerpicks/features/notifications/data/datasources/notification_datasource.dart';
import 'package:peerpicks/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:peerpicks/features/notifications/domain/repositories/notification_repository.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final dataSource = ref.read(notificationRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final storageService = ref.read(storageServiceProvider);
  return NotificationRepository(
    dataSource: dataSource,
    networkInfo: networkInfo,
    storageService: storageService,
  );
});

class NotificationRepository implements INotificationRepository {
  static const String _notificationsCacheKey = 'cache.notifications.list.v1';
  static const String _unreadCountCacheKey = 'cache.notifications.unread.v1';

  final INotificationDataSource _dataSource;
  final INetworkInfo _networkInfo;
  final StorageService _storageService;

  NotificationRepository({
    required INotificationDataSource dataSource,
    required INetworkInfo networkInfo,
    required StorageService storageService,
  }) : _dataSource = dataSource,
       _networkInfo = networkInfo,
       _storageService = storageService;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    if (!await _networkInfo.isConnected) {
      final cached = _getCachedNotifications();
      if (cached != null) {
        return Right(cached);
      }
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final notifications = await _dataSource.getNotifications();
      final entities = notifications.map((n) => n.toEntity()).toList();
      await _saveNotificationsToCache(entities);
      await _storageService.setData(
        _unreadCountCacheKey,
        entities.where((n) => !n.read).length,
      );
      return Right(entities);
    } on DioException catch (e) {
      final cached = _getCachedNotifications();
      if (cached != null) {
        return Right(cached);
      }
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to load notifications',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (!await _networkInfo.isConnected) {
      final cached = _storageService.getInt(_unreadCountCacheKey);
      if (cached != null) {
        return Right(cached);
      }
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final count = await _dataSource.getUnreadCount();
      await _storageService.setData(_unreadCountCacheKey, count);
      return Right(count);
    } on DioException catch (e) {
      final cached = _storageService.getInt(_unreadCountCacheKey);
      if (cached != null) {
        return Right(cached);
      }
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to get unread count',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final result = await _dataSource.markAllAsRead();
      if (result) {
        await _storageService.setData(_unreadCountCacheKey, 0);
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to mark as read',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final result = await _dataSource.deleteNotification(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to delete notification',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<void> _saveNotificationsToCache(List<NotificationEntity> items) async {
    final encoded = jsonEncode(items.map(_notificationToMap).toList());
    await _storageService.setData(_notificationsCacheKey, encoded);
  }

  List<NotificationEntity>? _getCachedNotifications() {
    final raw = _storageService.getString(_notificationsCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_notificationFromMap)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _notificationToMap(NotificationEntity n) {
    return {
      'id': n.id,
      'recipientId': n.recipientId,
      'actorId': n.actorId,
      'actorName': n.actorName,
      'actorProfilePicture': n.actorProfilePicture,
      'type': n.type.name,
      'status': n.status,
      'pickId': n.pickId,
      'about': n.about,
      'message': n.message,
      'read': n.read,
      'createdAt': n.createdAt.toIso8601String(),
    };
  }

  NotificationEntity _notificationFromMap(Map<String, dynamic> map) {
    final typeRaw = map['type']?.toString() ?? 'system';
    final type = NotificationType.values.firstWhere(
      (value) => value.name == typeRaw,
      orElse: () => NotificationType.system,
    );

    return NotificationEntity(
      id: map['id']?.toString() ?? '',
      recipientId: map['recipientId']?.toString() ?? '',
      actorId: map['actorId']?.toString(),
      actorName: map['actorName']?.toString(),
      actorProfilePicture: map['actorProfilePicture']?.toString(),
      type: type,
      status: map['status']?.toString() ?? 'info',
      pickId: map['pickId']?.toString(),
      about: map['about']?.toString(),
      message: map['message']?.toString() ?? 'You have a new notification',
      read: map['read'] == true,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
