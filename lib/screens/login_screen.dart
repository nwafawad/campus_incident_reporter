import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_email.text, _password.text);
    if (!ok && mounted) _showMessage(auth.error!);
  }

  Future<void> _forgotPassword() async {
    if (validateAluEmail(_email.text) != null) {
      _showMessage('Enter your ALU email first');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendPasswordReset(_email.text);
    if (mounted) {
      _showMessage(
        ok ? 'Reset link sent to ${_email.text.trim()}' : auth.error!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CAMPUSCARE · ALU',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with your ALU account to report campus issues and follow their progress.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'ALU email',
                  controller: _email,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  helper:
                      'Use your @alustudent.com or @alueducation.com address',
                  validator: validateAluEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  icon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Enter your password' : null,
                  suffix: IconButton(
                    tooltip: _hidePassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: busy ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Sign in',
                  loading: busy,
                  onPressed: _signIn,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to CampusCare?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Campus staff?',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sign in here with your @alueducation.com email. '
                              'Staff accounts unlock the incident queue.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
