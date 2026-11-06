import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.student;
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final error = validateAluEmail(value);
    if (error != null) return error;
    if (_role == UserRole.staff && roleFromEmail(value!) != UserRole.staff) {
      return 'Staff accounts need an @alueducation.com email';
    }
    return null;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(_name.text, _email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    final strength = passwordStrength(_password.text);
    final strengthColor = strength >= 3
        ? AppColors.strong
        : AppColors.pendingText;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only verified ALU emails can join, so every report comes from a real member of campus.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full name',
                  controller: _name,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'ALU email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  helper: _role == UserRole.staff
                      ? 'Use your @alueducation.com staff email'
                      : 'Use your ALU email ending in @alustudent.com',
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'I am a',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.student,
                        label: Text('Student'),
                      ),
                      ButtonSegment(
                        value: UserRole.staff,
                        label: Text('Staff'),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() => _role = s.first),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  obscureText: true,
                  validator: validatePassword,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: i < strength
                                ? strengthColor
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  passwordStrengthLabel(strength),
                  style: TextStyle(
                    fontSize: 12,
                    color: strength == 0
                        ? AppColors.textSecondary
                        : strengthColor,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm password',
                  controller: _confirm,
                  obscureText: true,
                  validator: (v) => validateConfirmPassword(v, _password.text),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I agree to use CampusCare responsibly. False or abusive reports may lead to account suspension.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create account',
                  loading: busy,
                  onPressed: _agreed ? _createAccount : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
