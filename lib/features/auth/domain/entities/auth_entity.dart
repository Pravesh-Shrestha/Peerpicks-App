import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? password;
  final String gender;
  final DateTime dob;
  final String phone;
  final String role;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    required this.gender,
    required this.dob,
    required this.phone,
    this.role = 'user',
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    email,
    fullName,
    gender,
    dob,
    phone,
    role,
    profilePicture,
  ];
}
