import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/knowledge_item.dart';

class KnowledgeDetailScreen extends StatelessWidget {
  final KnowledgeItem item;
  
  const KnowledgeDetailScreen({super.key, required this.item});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок з іконкою
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: item.category == 'vitamin' 
                    ? Colors.green.withValues(alpha: 0.200)
                    : Colors.blue.withValues(alpha: 0.200),
                  radius: 40,
                  child: Icon(
                    item.icon,
                    size: 40,
                    color: item.category == 'vitamin' ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text(
                        item.category == 'vitamin' ? 'Вітамін' : 'Мінерал',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: item.category == 'vitamin' ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Опис
            _buildSection(context, 'Опис', item.description),
            
            // Рекомендоване дозування
            _buildSection(context, 'Рекомендоване дозування', item.recommendedDosage),
            
            // Продукти
            if (item.foodSources.isNotEmpty)
              _buildListSection(context, 'Джерела в продуктах', item.foodSources),
            
            // Симптоми дефіциту
            _buildSection(context, 'Симптоми дефіциту', item.deficiencySymptoms),
            
            // Симптоми передозування
            _buildSection(context, 'Симптоми передозування', item.overdoseSymptoms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Text(content),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListSection(BuildContext context, String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 12),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}