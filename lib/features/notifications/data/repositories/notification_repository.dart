import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/error/failures.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/notifications/data/datasources/notification_datasource.dart';
import 'package:peerpicks/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:peerpicks/features/notifications/domain/repositories/notification_repository.dart';
import 'package:peerpicks/features/social/data/models/notification_model.dart';
import 'package:peerpicks/features/social/domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final dataSource = ref.read(notificationRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return NotificationRepository(
    dataSource: dataSource,
    networkInfo: networkInfo,
  );
});

class NotificationRepository implements INotificationRepository {
  final INotificationDataSource _dataSource;
  final INetworkInfo _networkInfo;

  NotificationRepository({
    required INotificationDataSource dataSource,
    required INetworkInfo networkInfo,
  }) : _dataSource = dataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final notifications = await _dataSource.getNotifications();
      return Right(NotificationModel.toEntityList(notifications));
    } on DioException catch (e) {
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
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final count = await _dataSource.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
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
}
