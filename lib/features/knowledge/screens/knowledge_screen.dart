import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vita_min_control_helper/data/models/knowledge_item.dart';

class KnowledgeScreen extends ConsumerWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Mock data for knowledge items
    final knowledgeItems = [
      KnowledgeItem(
        id: '1',
        title: 'Вітамін D',
        description: 'Вітамін D відіграє важливу роль у засвоєнні кальцію та фосфору, сприяє зміцненню кісток і зубів. Також впливає на імунну систему та перешкоджає розвитку аутоімунних захворювань.',
        recommendedDosage: '600-800 МО на день для дорослих',
        deficiencySymptoms: 'Біль у кістках, м\'язова слабкість, підвищена втомлюваність',
        overdoseSymptoms: 'Нудота, блювота, підвищення рівня кальцію в крові',
        icon: Icons.wb_sunny_outlined,
      ),
      KnowledgeItem(
        id: '2',
        title: 'Вітамін C',
        description: 'Вітамін C є потужним антиоксидантом, сприяє зміцненню імунної системи, покращує всмоктування заліза з їжі, сприяє утворенню колагену, який потрібен для здоров\'я шкіри, сухожиль і кровоносних судин.',
        recommendedDosage: '75-90 мг на день для дорослих',
        deficiencySymptoms: 'Кровоточивість ясен, повільне загоєння ран, сухість шкіри',
        overdoseSymptoms: 'Діарея, нудота, судоми в животі',
        icon: Icons.sanitizer_outlined,
      ),
      KnowledgeItem(
        id: '3',
        title: 'Цинк',
        description: 'Цинк є важливим мінералом, який бере участь у багатьох біохімічних процесах організму. Він необхідний для нормального функціонування імунної системи, загоєння ран, синтезу ДНК та підтримки нормального відчуття смаку та запаху.',
        recommendedDosage: '8-11 мг на день для дорослих',
        deficiencySymptoms: 'Випадіння волосся, діарея, затримка росту у дітей',
        overdoseSymptoms: 'Нудота, біль у животі, головний біль',
        icon: Icons.ac_unit_outlined,
      ),
      KnowledgeItem(
        id: '4',
        title: 'Кальцій',
        description: 'Кальцій - це мінерал, необхідний для формування і зміцнення кісток і зубів. Він також регулює м\'язові скорочення, включаючи серцебиття, і забезпечує правильне функціонування нервової системи.',
        recommendedDosage: '1000-1200 мг на день для дорослих',
        deficiencySymptoms: 'Остеопороз, м\'язові судоми, підвищений ризик переломів',
        overdoseSymptoms: 'Камені в нирках, закрепи, проблеми з серцем',
        icon: Icons.fitness_center_outlined,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: knowledgeItems.length,
      itemBuilder: (context, index) {
        final item = knowledgeItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ExpansionTile(
            leading: Icon(
              item.icon,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            title: Text(
              item.title,
              style: theme.textTheme.titleLarge,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      context,
                      'Рекомендоване дозування:',
                      item.recommendedDosage,
                      Icons.medication_outlined,
                    ),
                    _buildInfoSection(
                      context,
                      'Симптоми дефіциту:',
                      item.deficiencySymptoms,
                      Icons.sick_outlined,
                    ),
                    _buildInfoSection(
                      context,
                      'Симптоми передозування:',
                      item.overdoseSymptoms,
                      Icons.warning_amber_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
} 