import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? role; // 'adoptante' o 'refugio'
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, name, phone, role, avatarUrl];
}
