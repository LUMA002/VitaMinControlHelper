import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/knowledge_item.dart';
import 'package:vita_min_control_helper/data/repositories/knowledge_repository.dart';
import 'package:vita_min_control_helper/features/knowledge/screens/knowledge_detail_screen.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<KnowledgeItem> _items;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Отримуємо дані
    _items = KnowledgeRepository.getMockItems();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedCategory = 'all';
          break;
        case 1:
          _selectedCategory = 'vitamin';
          break;
        case 2:
          _selectedCategory = 'mineral';
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Вкладки для категорій
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Всі'),
            Tab(text: 'Вітаміни'),
            Tab(text: 'Мінерали'),
          ],
          labelColor: theme.colorScheme.primary,
        ),

        // Основний контент з підтримкою свайпів
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGrid(_items), // Всі
              _buildGrid(
                _items.where((item) => item.category == 'vitamin').toList(),
              ), // Вітаміни
              _buildGrid(
                _items.where((item) => item.category == 'mineral').toList(),
              ), // Мінерали
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<KnowledgeItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(context, item);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, KnowledgeItem item) {
    final theme = Theme.of(context);

    // Визначаємо колір для категорії
    Color cardColor =
        item.category == 'vitamin'
            ? Colors.green.withValues(alpha: 0.200)
            : Colors.blue.withValues(alpha: 0.200);

    Color iconColor =
        item.category == 'vitamin'
            ? const Color.fromARGB(255, 10, 135, 17)
            : const Color.fromARGB(255, 19, 136, 231);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: InkWell(
        onTap: () => _openDetailScreen(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Іконка у верхній частині картки
            Expanded(
              flex: 4,
              child: Container(
                color: theme.colorScheme.surfaceContainerLowest,
                child: Center(
                  child: Icon(item.icon, size: 56, color: iconColor),
                ),
              ),
            ),

            // Інформація у нижній частині картки
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, top: 6, right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    //const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Індикатор категорії у нижній частині картки
            Container(
              color: iconColor.withValues(alpha: 0.180),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                item.category == 'vitamin' ? 'Вітамін' : 'Мінерал',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailScreen(BuildContext context, KnowledgeItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KnowledgeDetailScreen(item: item),
      ),
    );
  }
}
