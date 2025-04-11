import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _gender;
  DateTime? _dateOfBirth;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Ім'я користувача",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введіть ім'я користувача";
                    }
                    if (value.length < 3) {
                      return "Ім'я користувача має містити щонайменше 3 символи";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Введіть коректний email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль має містити щонайменше 6 символів';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Підтвердіть пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Підтвердіть пароль';
                    }
                    if (value != _passwordController.text) {
                      return 'Паролі не співпадають';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                Text(
                  'Додаткова інформація (необов\'язково)',
                  style: theme.textTheme.titleMedium,
                ),
                
                const SizedBox(height: 16),

                // Date of Birth
                ListTile(
                  title: const Text('Дата народження'),
                  subtitle: _dateOfBirth != null 
                    ? Text('${_dateOfBirth!.day}.${_dateOfBirth!.month}.${_dateOfBirth!.year}')
                    : const Text('Не вказано'),
                  leading: const Icon(Icons.calendar_today),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 16),

                // Gender selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Стать',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Чоловіча')),
                    DropdownMenuItem(value: 'female', child: Text('Жіноча')),
                    DropdownMenuItem(value: 'other', child: Text('Інша')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Height
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Зріст (см)',
                    prefixIcon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final height = double.tryParse(value);
                      if (height == null || height <= 0 || height > 250) {
                        return 'Введіть коректний зріст';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Weight
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Вага (кг)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final weight = double.tryParse(value);
                      if (weight == null || weight <= 0 || weight > 500) {
                        return 'Введіть коректну вагу';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Register button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // For now, just navigate to home
                      // In future, we'll send this data to the backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Реєстрація успішна')),
                      );
                      context.go('/home');
                    }
                  },
                  child: const Text('Зареєструватися'),
                ),

                const SizedBox(height: 16),

                // Back to login
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Вже маєте акаунт? Увійти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 