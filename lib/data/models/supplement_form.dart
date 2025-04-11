import 'package:uuid/uuid.dart';

class SupplementForm {
  final String id;
  final String name;

  SupplementForm({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  factory SupplementForm.fromJson(Map<String, dynamic> json) {
    return SupplementForm(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}