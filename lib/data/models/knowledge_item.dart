import 'package:flutter/material.dart';

class KnowledgeItem {
  final String id;
  final String title;
  final String description;
  final String recommendedDosage;
  final String deficiencySymptoms;
  final String overdoseSymptoms;
  final IconData icon;
  final String category; // 'vitamin' або 'mineral'
  final List<String> foodSources;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.recommendedDosage,
    required this.deficiencySymptoms,
    required this.overdoseSymptoms,
    required this.icon,
    required this.category,
    this.foodSources = const [],
  });
}
