import 'package:flutter/material.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/models/supplement_form.dart';
import 'package:vita_min_control_helper/data/repositories/mock_data.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddEditMedicationScreen({super.key, this.reminder});

  @override
  State<AddEditMedicationScreen> createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Supplement> _supplements;
  late List<SupplementForm> _supplementForms;

  String? _selectedSupplementId;
  String? _selectedFormId;
  ReminderFrequency _frequency = ReminderFrequency.daily;
  TimeOfDay _timeToTake = const TimeOfDay(hour: 8, minute: 0);
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'таблетка');
  final _stockAmountController = TextEditingController(text: '30');
  bool _showTimePicker = true;

  @override
  void initState() {
    super.initState();
    _supplements = MockData.supplements;
    _supplementForms = MockData.supplementForms;

    if (widget.reminder != null) {
      _selectedSupplementId = widget.reminder!.supplementId;
      _selectedFormId = widget.reminder!.formId;
      _frequency = widget.reminder!.frequency;
      if (widget.reminder!.timeToTake != null) {
        _timeToTake = widget.reminder!.timeToTake!;
      }
      _quantityController.text = widget.reminder!.quantity.toString();
      _unitController.text = widget.reminder!.unit;
      _stockAmountController.text = widget.reminder!.stockAmount.toString();
      _showTimePicker = widget.reminder!.frequency != ReminderFrequency.asNeeded;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    _stockAmountController.dispose();
    super.dispose();
  }

  void _onFrequencyChanged(ReminderFrequency? value) {
    if (value != null) {
      setState(() {
        _frequency = value;
        _showTimePicker = value != ReminderFrequency.asNeeded;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeToTake,
    );
    if (picked != null) {
      setState(() {
        _timeToTake = picked;
      });
    }
  }

  void _saveReminder() {
    if (_formKey.currentState?.validate() ?? false) {
      // Here we would save the reminder to storage
      // For now just pop back to course screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редагувати прийом' : 'Додати прийом'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Supplement dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Вітамін/Препарат',
                border: OutlineInputBorder(),
              ),
              value: _selectedSupplementId,
              items: _supplements.map((supplement) {
                return DropdownMenuItem<String>(
                  value: supplement.id,
                  child: Text(supplement.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedSupplementId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, оберіть вітамін/препарат';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Form dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Форма випуску',
                border: OutlineInputBorder(),
              ),
              value: _selectedFormId,
              items: _supplementForms.map((form) {
                return DropdownMenuItem<String>(
                  value: form.id,
                  child: Text(form.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedFormId = value;
                  
                  // Update the unit based on selected form
                  final selectedForm = _supplementForms.firstWhere(
                    (form) => form.id == value,
                    orElse: () => SupplementForm(name: 'таблетка'),
                  );
                  _unitController.text = selectedForm.name.toLowerCase();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, оберіть форму випуску';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Quantity field
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Кількість',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть кількість';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Введіть коректне число';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Unit field
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Одиниця виміру',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть одиницю виміру';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Stock amount field
            TextFormField(
              controller: _stockAmountController,
              decoration: const InputDecoration(
                labelText: 'Залишок (кількість)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть кількість, що залишилась';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Введіть коректне число';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Frequency selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Частота прийому:',
                  style: TextStyle(fontSize: 16),
                ),
                                RadioListTile<ReminderFrequency>(
                  title: const Text('Щодня'),
                  value: ReminderFrequency.daily,
                  groupValue: _frequency,
                  onChanged: _onFrequencyChanged,
                ),
                RadioListTile<ReminderFrequency>(
                  title: const Text('Щотижня'),
                  value: ReminderFrequency.weekly,
                  groupValue: _frequency,
                  onChanged: _onFrequencyChanged,
                ),
                RadioListTile<ReminderFrequency>(
                  title: const Text('За потреби'),
                  value: ReminderFrequency.asNeeded,
                  groupValue: _frequency,
                  onChanged: _onFrequencyChanged,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time picker
            if (_showTimePicker)
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Час прийому',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    controller: TextEditingController(
                      text: '${_timeToTake.hour.toString().padLeft(2, '0')}:${_timeToTake.minute.toString().padLeft(2, '0')}',
                    ),
                    validator: _showTimePicker
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Будь ласка, оберіть час прийому';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Зберегти зміни' : 'Додати прийом',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}