import 'package:uuid/uuid.dart';

class SupplementType {
  final String id;
  final String name;

  SupplementType({String? id, required this.name})
    : id = id ?? const Uuid().v4();

  factory SupplementType.fromJson(Map<String, dynamic> json) {
    return SupplementType(id: json['typeID'] ?? json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'typeID': id, 'name': name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplementType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
