import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vita_min_control_helper/data/models/reminder.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/features/course/screens/add_custom_supplement_screen.dart';

class AddEditMedicationScreen extends ConsumerStatefulWidget {
  final Reminder?
  reminder; // глянути цей ремайндер, звідки прийшов і з чим саме

  const AddEditMedicationScreen({super.key, this.reminder});

  @override
  ConsumerState<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState
    extends ConsumerState<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Supplement> _supplements = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedSupplementId;
  ReminderFrequency? _frequency = ReminderFrequency.daily;
  TimeOfDay _timeToTake = const TimeOfDay(hour: 8, minute: 0);
  final _quantityController = TextEditingController(text: '1');

  final _stockAmountController = TextEditingController();
  final _activeIngredientController = TextEditingController();
  String _measurementUnit = 'мг';
  final bool _showTimePicker = true;

  final List<String> _measurementUnits = ['мг', 'мкг', 'г', 'мл', 'МО', 'КУО'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supplementRepo = ref.read(supplementRepositoryProvider);
      final supplements = await supplementRepo.getSupplements();

      setState(() {
        _supplements = supplements;
        _isLoading = false;
      });

      if (widget.reminder != null) {
        _selectedSupplementId = widget.reminder!.supplementId;
        if (widget.reminder!.frequency != null) {
          _frequency = widget.reminder!.frequency;
        }
        if (widget.reminder!.timeToTake != null) {
          _timeToTake = widget.reminder!.timeToTake!;
        }
        _quantityController.text = widget.reminder!.quantity.toString();
        _measurementUnit = widget.reminder!.unit;
        if (widget.reminder!.stockAmount > 0) {
          _stockAmountController.text = widget.reminder!.stockAmount.toString();
        }
        if (widget.reminder!.activeIngredientAmount != null) {
          _activeIngredientController.text =
              widget.reminder!.activeIngredientAmount.toString();
        }
        if (widget.reminder!.measurementUnit != null) {
          _measurementUnit = widget.reminder!.measurementUnit!;
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Помилка завантаження даних: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _stockAmountController.dispose();
    _activeIngredientController.dispose();
    super.dispose();
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

  Future<void> _saveReminder() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Get current user ID from auth provider
        final authState = ref.read(authProvider);
        final userId = authState.userId ?? 'guest-user';

        // Create a reminder object locally
        final newReminder = Reminder(
          id: widget.reminder?.id ?? const Uuid().v4(),
          userId: userId,
          supplementId: _selectedSupplementId!,
          frequency: _frequency!,
          timeToTake: _showTimePicker ? _timeToTake : null,
          quantity: double.parse(_quantityController.text),
          unit: _measurementUnit,
          stockAmount:
              _stockAmountController.text.isNotEmpty
                  ? int.parse(_stockAmountController.text)
                  : 0,
          isConfirmed: false,
          nextReminder: DateTime.now(),
          activeIngredientAmount:
              _activeIngredientController.text.isNotEmpty
                  ? double.parse(_activeIngredientController.text)
                  : null,
          measurementUnit:
              _activeIngredientController.text.isNotEmpty
                  ? _measurementUnit
                  : null,
        );

        // Для реального додатку, тут має бути збереження у репозиторій
        // Наприклад:
        // final reminderRepo = ref.read(reminderRepositoryProvider);
        // await reminderRepo.saveReminder(newReminder);

        // Для цілей відладки виведемо інформацію
        print('Зберігаємо нагадування: ${newReminder.toJson()}');

        if (mounted) {
          Navigator.pop(context, newReminder);
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

  void _addCustomSupplement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomSupplementScreen(),
      ),
    );

    if (result != null && result is Supplement) {
      // Reload supplements to include the new one
      _loadData();

      setState(() {
        _selectedSupplementId = result.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Редагувати прийом' : 'Додати прийом'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Редагувати прийом' : 'Додати прийом'),
        ),
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
                onPressed: _loadData,
                child: const Text('Спробувати знову'),
              ),
            ],
          ),
        ),
      );
    }

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Вітамін/Препарат',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSupplementId,
                  items:
                      _supplements.map((supplement) {
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
                TextButton.icon(
                  onPressed: _addCustomSupplement,
                  icon: const Icon(Icons.add),
                  label: const Text('Додати свій препарат'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Frequency dropdown
            DropdownButtonFormField<ReminderFrequency>(
              decoration: const InputDecoration(
                labelText: 'Частота нагадувань',
                border: OutlineInputBorder(),
              ),
              value: _frequency,
              items:
                  ReminderFrequency.values.map((frequency) {
                    String text;
                    switch (frequency) {
                      case ReminderFrequency.daily:
                        text = 'Щодня';
                        break;
                      case ReminderFrequency.weekly:
                        text = 'Щотижня';
                        break;
                      case ReminderFrequency.monthly:
                        text = 'Щомісяця';
                        break;
                      case ReminderFrequency.asNeeded:
                        text = 'За потребою';
                        break;
                    }
                    return DropdownMenuItem<ReminderFrequency>(
                      value: frequency,
                      child: Text(text),
                    );
                  }).toList(),
              onChanged: (ReminderFrequency? value) {
                setState(() {
                  _frequency = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Quantity field
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Кількість порцій',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть кількість порцій';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Введіть коректне число';
                }
                return null;
              },
            ),

            /*   const SizedBox(height: 16),

            // Unit field
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Одиниця виміру порції',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть одиницю виміру';
                }
                return null;
              },
            ),
 */
            const SizedBox(height: 16),

            // Active ingredient amount
            TextFormField(
              controller: _activeIngredientController,
              decoration: const InputDecoration(
                labelText: 'Кількість діючої речовини',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Будь ласка, введіть кількість діючої речовини';
                }
                if (value.isNotEmpty) {
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Введіть коректне число';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Measurement unit dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Одиниця виміру',
                border: OutlineInputBorder(),
              ),
              value: _measurementUnit,
              items:
                  _measurementUnits.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _measurementUnit = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Stock amount field
            TextFormField(
              controller: _stockAmountController,
              decoration: const InputDecoration(
                labelText: 'Залишок (кількість порцій)',
                hintText: 'Необов\'язкове поле',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Введіть коректне число';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Time selection
            if (_showTimePicker)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Час прийому:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_timeToTake.hour.toString().padLeft(2, '0')}:${_timeToTake.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Оновити прийом' : 'Додати прийом',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
