import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_form.dart';
import 'package:vita_min_control_helper/data/models/supplement_type.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';

class AddCustomSupplementScreen extends StatefulWidget {
  const AddCustomSupplementScreen({super.key});

  @override
  State<AddCustomSupplementScreen> createState() => _AddCustomSupplementScreenState();
}

class _AddCustomSupplementScreenState extends State<AddCustomSupplementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _deficiencySymptomsController = TextEditingController();
  final _overdoseSymptomsController = TextEditingController();
  bool _isMedication = false;

  final List<SupplementType> _selectedTypes = [];
  final List<SupplementForm> _selectedForms = [];

  @override
  void initState() {
    super.initState();
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

  void _saveCustomSupplement() {
    if (_formKey.currentState?.validate() ?? false) {
      // Створюємо новий препарат
      final newSupplement = Supplement(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty 
            ? null : _descriptionController.text,
        deficiencySymptoms: _deficiencySymptomsController.text.isEmpty 
            ? null : _deficiencySymptomsController.text,
        types: _selectedTypes,
      );
      
      // Додаємо до списку препаратів (в реальному додатку тут був би код для збереження в БД)

      
      // Повертаємось на попередній екран з новим препаратом
      Navigator.pop(context, newSupplement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Додати свій препарат'),
      ),
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
                  children: MockData.supplementTypes.map((type) {
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
            
            const SizedBox(height: 16),
            
            // Вибір форм випуску
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Форма випуску:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: MockData.supplementForms.map((form) {
                    final isSelected = _selectedForms.contains(form);
                    return FilterChip(
                      label: Text(form.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedForms.add(form);
                          } else {
                            _selectedForms.remove(form);
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
