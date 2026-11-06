import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 60 second wait before resend works again.
  void _startCountdown() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _continue() async {
    final ok = await context.read<AuthProvider>().checkVerified();
    if (!ok && mounted) {
      _showMessage(
        'Not verified yet. Open the link in your email, then try again.',
      );
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.resendVerification();
    if (!mounted) return;
    _showMessage(ok ? 'Verification email sent' : auth.error!);
    if (ok) setState(_startCountdown);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final waiting = _seconds > 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to sign in',
          icon: const Icon(Icons.arrow_back),
          onPressed: auth.signOut,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check your inbox',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'We sent a verification link to',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.email,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Open the link to activate your account. You can\'t submit reports until your ALU email is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'I\'ve verified, continue',
                icon: Icons.check,
                loading: auth.busy,
                onPressed: _continue,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: waiting || auth.busy ? null : _resend,
                icon: const Icon(Icons.refresh),
                label: Text(
                  waiting
                      ? 'Resend email in 0:${_seconds.toString().padLeft(2, '0')}'
                      : 'Resend email',
                ),
              ),
              TextButton(
                onPressed: auth.signOut,
                child: const Text('Use a different email'),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Didn\'t get it? Check your Spam or Other folder in Outlook. Links expire after 24 hours.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
