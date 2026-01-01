import 'package:hive/hive.dart';
import 'package:peerpicks/core/constants/hive_table_constant.dart';
import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String username;

  @HiveField(5)
  final String? password;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
  }) : authId = authId ?? const Uuid().v4();

  // Convert Hive Model to Domain Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber?.toString() ?? '',
      username: username,
      password: password,
    );
  }

  // Create Hive Model from Domain Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
    );
  }
}
