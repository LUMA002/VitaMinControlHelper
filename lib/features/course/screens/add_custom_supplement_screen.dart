import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:vita_min_control_helper/data/models/supplement.dart';
import 'package:vita_min_control_helper/data/repositories/supplement_repository.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';

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
  final _deficiencySymptomsController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deficiencySymptomsController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomSupplement() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        // Get current user ID from auth provider
        final authState = ref.read(authProvider);
        final userId = authState.userId ?? 'guest-user';

        // Create the supplement
        final newSupplement = Supplement(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          description:
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
          deficiencySymptoms:
              _deficiencySymptomsController.text.trim().isNotEmpty
                  ? _deficiencySymptomsController.text.trim()
                  : null,
          isGlobal: false,
          creatorId: userId,
          createdAt: DateTime.now(),
          types: [], // No types for custom supplements
        );

        // Save the supplement to the repository
        final supplementRepo = ref.read(supplementRepositoryProvider);
        final savedSupplement = await supplementRepo.addSupplement(
          newSupplement,
        );

        log('Додано кастомний препарат: ${savedSupplement.toJson()}');

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.pop(context, savedSupplement);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Додати свій препарат')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Назва препарату',
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

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Опис (необов\'язково)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _deficiencySymptomsController,
              decoration: const InputDecoration(
                labelText: 'Симптоми дефіциту (необов\'язково)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveCustomSupplement,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Зберегти препарат',
                style: TextStyle(fontSize: 16),
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
