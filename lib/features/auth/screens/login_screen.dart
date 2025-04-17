import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vita_min_control_helper/features/auth/providers/auth_provider.dart';
import 'package:vita_min_control_helper/services/api_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // App Logo or Icon
                Icon(
                  Icons.medication_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 24),

                // App Title
                Text(
                  'VitaMin Control',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'example@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть пароль';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    _login();
                  },
                ),

                const SizedBox(height: 8),

                // Показуємо помилку, якщо вона є
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 32),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Увійти'),
                ),

                const SizedBox(height: 16),

                // Register link
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            context.go('/register');
                          },
                  child: const Text('Створити новий акаунт'),
                ),

                const SizedBox(height: 24),

                // Continue as guest
                OutlinedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            ref.read(authProvider.notifier).setGuestMode(); //передавався тру
                            context.go('/knowledge');
                          },
                  child: const Text('Продовжити як гість'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final email = _emailController.text;
      final password = _passwordController.text;

      // Використовуємо API сервіс для авторизації
      final apiService = ref.read(apiServiceProvider);
      final responseData = await apiService.login(email, password);

      if (mounted) {
        if (responseData != null && responseData['success'] == true) {
          // Успішний вхід
          final user = responseData['user'];
          final token = responseData['token'];
          final expiration = DateTime.parse(responseData['expiration']);

          // Зберігаємо дані авторизації
          ref
              .read(authProvider.notifier)
              .setAuthData(
                userId: user['id'],
                userEmail: user['email'],
                username: user['username'],
                token: token,
                tokenExpiration: expiration,
              );

          // Переходимо на головний екран
          context.go('/home');
        } else {
          // Невдалий вхід
          setState(() {
            _isLoading = false;
            _errorMessage =
                responseData?['message'] ?? 'Помилка входу. Спробуйте ще раз.';
          });
        }
      }
    }
  }
}
