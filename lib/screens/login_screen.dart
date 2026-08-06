import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

/// Mirrors src/app/login/page.tsx: same logo badge, same "Welcome back"
/// copy, same demo credentials hint, same field order and button states.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiClient.instance.login(_emailController.text.trim(), _passwordController.text);
      if (mounted) context.go('/dashboard');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Что-то пошло не так. Попробуйте ещё раз.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FM',
                          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Finance Manager',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Welcome back',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Log in to manage your finances.',
                              style: TextStyle(fontSize: 14, color: AppColors.muted)),
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(AppRadius.field),
                              ),
                              child: Text(_error!,
                                  style: const TextStyle(color: AppColors.danger, fontSize: 14)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text('Email',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.fg, fontSize: 14),
                            decoration: const InputDecoration(hintText: 'you@example.com'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Введите email' : null,
                          ),
                          const SizedBox(height: 16),
                          const Text('Password',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: AppColors.fg, fontSize: 14),
                            decoration: const InputDecoration(hintText: '••••••••'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: Text(_loading ? 'Logging in...' : 'Log in'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text("Don't have an account? ",
                                    style: TextStyle(fontSize: 14, color: AppColors.muted)),
                                GestureDetector(
                                  onTap: () => context.go('/register'),
                                  child: const Text('Sign up',
                                      style: TextStyle(
                                          fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo login: demo@example.com / password123',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
