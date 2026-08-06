import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../app_theme.dart';
import '../widgets/app_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      await ApiClient.instance.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
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
    _nameController.dispose();
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
              constraints: const BoxConstraints(maxWidth: 384),
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
                        child: const Text('FM',
                            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Finance Manager',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.3)),
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
                          const Text('Create an account',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Start tracking your finances today.',
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
                              child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 14)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text('Name',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: AppColors.fg, fontSize: 14),
                            decoration: const InputDecoration(hintText: 'Your name'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Введите имя' : null,
                          ),
                          const SizedBox(height: 16),
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
                            validator: (v) => (v == null || v.length < 6) ? 'Минимум 6 символов' : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: Text(_loading ? 'Creating account...' : 'Sign up'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text('Already have an account? ',
                                    style: TextStyle(fontSize: 14, color: AppColors.muted)),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: const Text('Log in',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
