import 'package:uuid/uuid.dart';
import 'supplement_type.dart';

class Supplement {
  final String id;
  final String name;
  final String? description;
  final String? deficiencySymptoms;
  final bool isGlobal;
  final String? creatorId;
  final DateTime createdAt;
  final List<SupplementType> types;

  Supplement({
    String? id,
    required this.name,
    this.description,
    this.deficiencySymptoms,
    this.isGlobal = false,
    this.creatorId,
    DateTime? createdAt,
    this.types = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['supplementID'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      deficiencySymptoms: json['deficiencySymptoms'],
      isGlobal: json['isGlobal'] ?? false,
      creatorId: json['creatorId'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      types:
          (json['types'] as List?)
              ?.map((type) => SupplementType.fromJson(type))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplementID': id,
      'name': name,
      'description': description,
      'deficiencySymptoms': deficiencySymptoms,
      'isGlobal': isGlobal,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'types': types.map((type) => type.toJson()).toList(),
    };
  }

  Supplement copyWith({
    String? name,
    String? description,
    String? deficiencySymptoms,
    bool? isGlobal,
    String? creatorId,
    List<SupplementType>? types,
  }) {
    return Supplement(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      deficiencySymptoms: deficiencySymptoms ?? this.deficiencySymptoms,
      isGlobal: isGlobal ?? this.isGlobal,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt,
      types: types ?? this.types,
    );
  }
}
