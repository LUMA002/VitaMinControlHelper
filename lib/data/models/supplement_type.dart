import 'package:uuid/uuid.dart';

class SupplementType {
  final String id;
  final String name;
  final bool isCustom;

  SupplementType({
    String? id,
    required this.name,
    this.isCustom = false,
  }) : id = id ?? const Uuid().v4();

  factory SupplementType.fromJson(Map<String, dynamic> json) {
    return SupplementType(
      id: json['id'],
      name: json['name'],
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCustom': isCustom,
    };
  }
}