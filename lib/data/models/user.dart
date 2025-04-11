import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String? email;
  final String? username;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final DateTime createdAt;
  final bool isGuest;

  User({
    String? id,
    this.email,
    this.username,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    DateTime? createdAt,
    this.isGuest = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      isGuest: json['isGuest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
      'isGuest': isGuest,
    };
  }

  User copyWith({
    String? email,
    String? username,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    bool? isGuest,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}