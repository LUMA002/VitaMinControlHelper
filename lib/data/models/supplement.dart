import 'package:uuid/uuid.dart';
import 'supplement_form.dart';
import 'supplement_type.dart';

class Supplement {
  final String id;
  final String name;
  final String? description;
  final String? recommendedDosage;
  final String? deficiencySymptoms;
  final String? overdoseSymptoms;
  final bool isMedication;
  final List<SupplementType> types;
  final List<SupplementForm> forms;

  Supplement({
    String? id,
    required this.name,
    this.description,
    this.recommendedDosage,
    this.deficiencySymptoms,
    this.overdoseSymptoms,
    this.isMedication = false,
    this.types = const [],
    this.forms = const [],
  }) : id = id ?? const Uuid().v4();

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      recommendedDosage: json['recommendedDosage'],
      deficiencySymptoms: json['deficiencySymptoms'],
      overdoseSymptoms: json['overdoseSymptoms'],
      isMedication: json['isMedication'] ?? false,
      types: (json['types'] as List?)
          ?.map((type) => SupplementType.fromJson(type))
          .toList() ?? [],
      forms: (json['forms'] as List?)
          ?.map((form) => SupplementForm.fromJson(form))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recommendedDosage': recommendedDosage,
      'deficiencySymptoms': deficiencySymptoms,
      'overdoseSymptoms': overdoseSymptoms,
      'isMedication': isMedication,
      'types': types.map((type) => type.toJson()).toList(),
      'forms': forms.map((form) => form.toJson()).toList(),
    };
  }

  Supplement copyWith({
    String? name,
    String? description,
    String? recommendedDosage,
    String? deficiencySymptoms,
    String? overdoseSymptoms,
    bool? isMedication,
    List<SupplementType>? types,
    List<SupplementForm>? forms,
  }) {
    return Supplement(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      recommendedDosage: recommendedDosage ?? this.recommendedDosage,
      deficiencySymptoms: deficiencySymptoms ?? this.deficiencySymptoms,
      overdoseSymptoms: overdoseSymptoms ?? this.overdoseSymptoms,
      isMedication: isMedication ?? this.isMedication,
      types: types ?? this.types,
      forms: forms ?? this.forms,
    );
  }
}

