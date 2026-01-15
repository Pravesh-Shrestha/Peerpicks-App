import 'package:peerpicks/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String gender;
  final DateTime dob;
  final String phone;
  final String role;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    required this.gender,
    required this.dob,
    required this.phone,
    required this.role,
    this.profilePicture,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      gender: json['gender'] as String,
      dob: DateTime.parse(json['dob'] as String),
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'user',
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'gender': gender,
    'dob': dob.toIso8601String(),
    'phone': phone,
    'role': role,
    'profilePicture': profilePicture,
  };

  AuthEntity toEntity() => AuthEntity(
    authId: id,
    fullName: fullName,
    email: email,
    password: password,
    gender: gender,
    dob: dob,
    phone: phone,
    role: role,
    profilePicture: profilePicture,
  );

  factory AuthApiModel.fromEntity(AuthEntity entity) => AuthApiModel(
    id: entity.authId,
    fullName: entity.fullName,
    email: entity.email,
    password: entity.password,
    gender: entity.gender,
    dob: entity.dob,
    phone: entity.phone,
    role: entity.role,
    profilePicture: entity.profilePicture,
  );
  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
