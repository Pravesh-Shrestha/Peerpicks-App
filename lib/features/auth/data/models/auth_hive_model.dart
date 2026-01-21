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
  final String? password;
  @HiveField(4)
  final String gender;
  @HiveField(5)
  final DateTime dob;
  @HiveField(6)
  final String phone;
  @HiveField(7)
  final String role;
  @HiveField(8)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.password,
    required this.gender,
    required this.dob,
    required this.phone,
    this.role = 'user',
    this.profilePicture,
  }) : authId = authId ?? const Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity entity) => AuthHiveModel(
    authId: entity.authId,
    fullName: entity.fullName,
    email: entity.email,
    password: entity.password,
    gender: entity.gender,
    dob: entity.dob,
    phone: entity.phone,
    role: entity.role,
    profilePicture: entity.profilePicture,
  );

  AuthEntity toEntity() => AuthEntity(
    authId: authId,
    fullName: fullName,
    email: email,
    password: password,
    gender: gender,
    dob: dob,
    phone: phone,
    role: role,
    profilePicture: profilePicture,
  );
}
