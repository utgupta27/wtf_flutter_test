import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role; // 'trainer' | 'member'

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final String? assignedTrainerId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.assignedTrainerId,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? assignedTrainerId,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatarUrl': avatarUrl,
        'assignedTrainerId': assignedTrainerId,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        role: map['role'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        assignedTrainerId: map['assignedTrainerId'] as String?,
      );

  @override
  List<Object?> get props => [id, name, email, role, avatarUrl, assignedTrainerId];
}

abstract class SeedUsers {
  static const member = User(
    id: 'member-dk-001',
    name: 'DK',
    email: 'dk@wtf.com',
    role: 'member',
    assignedTrainerId: 'trainer-aarav-001',
  );

  static const trainer = User(
    id: 'trainer-aarav-001',
    name: 'Aarav',
    email: 'aarav@wtf.com',
    role: 'trainer',
  );
}
