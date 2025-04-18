/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_form.dart';
import 'package:vita_min_control_helper/data/models/supplement_type.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';

class AddCustomSupplementScreen extends ConsumerStatefulWidget {
  const AddCustomSupplementScreen({super.key});

  @override
  ConsumerState<AddCustomSupplementScreen> createState() =>
      _AddCustomSupplementScreenState();
}

class _AddCustomSupplementScreenState
    extends ConsumerState<AddCustomSupplementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _deficiencySymptomsController = TextEditingController();
  final _overdoseSymptomsController = TextEditingController();
  bool _isMedication = false;
  bool _isLoading = true;
  String? _error;

  final List<SupplementType> _selectedTypes = [];
  final List<SupplementForm> _selectedForms = [];
  List<SupplementType> _availableTypes = [];

  @override
  void initState() {
    super.initState();
    _loadSupplementTypes();
  }

  Future<void> _loadSupplementTypes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supplementRepo = ref.read(supplementRepositoryProvider);
      final types = await supplementRepo.getSupplementTypes();

      setState(() {
        _availableTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Помилка завантаження типів: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _deficiencySymptomsController.dispose();
    _overdoseSymptomsController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomSupplement() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the repository
        final supplementRepo = ref.read(supplementRepositoryProvider);

        // Create the supplement
        final newSupplement = await supplementRepo.createSupplement(
          _nameController.text,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          deficiencySymptoms:
              _deficiencySymptomsController.text.isEmpty
                  ? null
                  : _deficiencySymptomsController.text,
          typeIds: _selectedTypes.map((type) => type.id).toList(),
          isGlobal: false,
        );

        // Return to previous screen with the new supplement
        if (mounted) {
          Navigator.pop(context, newSupplement);
        }
      } catch (e) {
        setState(() {
          _error = 'Помилка збереження: ${e.toString()}';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Додати свій препарат')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Додати свій препарат')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSupplementTypes,
                child: const Text('Спробувати знову'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Додати свій препарат')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Поле для назви препарату
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Назва препарату *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть назву препарату';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Поле для опису препарату
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Опис препарату',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Поле для рекомендованого дозування
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Рекомендоване дозування',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Поле для симптомів дефіциту
            TextFormField(
              controller: _deficiencySymptomsController,
              decoration: const InputDecoration(
                labelText: 'Симптоми дефіциту',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Поле для симптомів передозування
            TextFormField(
              controller: _overdoseSymptomsController,
              decoration: const InputDecoration(
                labelText: 'Симптоми передозування',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Перемикач для типу препарату (медикамент або добавка)
            SwitchListTile(
              title: const Text('Це медикамент'),
              subtitle: const Text('Вимкніть, якщо це харчова добавка'),
              value: _isMedication,
              onChanged: (value) {
                setState(() {
                  _isMedication = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Вибір типів препарату
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Тип препарату:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children:
                      _availableTypes.map((type) {
                        final isSelected = _selectedTypes.contains(type);
                        return FilterChip(
                          label: Text(type.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Кнопка збереження
            ElevatedButton(
              onPressed: _saveCustomSupplement,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Додати препарат',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */