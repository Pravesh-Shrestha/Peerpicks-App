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
  final String? token; // ADDED THIS
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
    this.token, // ADDED THIS
    this.profilePicture,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    // Check if the response is nested (like the login response in your logs)
    // or flat (like a single user update response)
    final bool isNested = json.containsKey('user');
    final Map<String, dynamic> userData = isNested
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthApiModel(
      // Token is at the root level of the login response
      token: json['token'] as String?,

      // All other fields are inside the 'user' object in the login response
      id: (userData['_id'] ?? userData['id']) as String?,
      fullName: userData['fullName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      password: userData['password'] as String?,
      gender: userData['gender'] as String? ?? '',
      dob: userData['dob'] != null
          ? DateTime.parse(userData['dob'] as String)
          : DateTime.now(),
      phone: userData['phone'] as String? ?? '',
      role: userData['role'] as String? ?? 'user',
      profilePicture: userData['profilePicture'] as String?,
    );
  }

  AuthEntity toEntity() => AuthEntity(
    authId: id,
    fullName: fullName,
    email: email,
    password: password,
    gender: gender,
    dob: dob,
    phone: phone,
    role: role,
    token: token, // CRITICAL: Pass the token to the entity!
    profilePicture: profilePicture,
  );

  // Keep your other methods (toJson, fromEntity, toEntityList) below...
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

  factory AuthApiModel.fromEntity(AuthEntity entity) => AuthApiModel(
    id: entity.authId,
    fullName: entity.fullName,
    email: entity.email,
    password: entity.password,
    gender: entity.gender ?? '',
    dob: entity.dob ?? DateTime.now(),
    phone: entity.phone ?? '',
    role: entity.role ?? 'user',
    token: entity.token,
    profilePicture: entity.profilePicture,
  );

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
