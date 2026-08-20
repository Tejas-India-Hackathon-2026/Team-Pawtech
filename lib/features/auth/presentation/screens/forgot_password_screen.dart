import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_emailController.text.contains('@')) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingScreen,
          child: _sent
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mark_email_read_outlined,
                          size: 64, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text('Password Reset Link Sent',
                          style: AppTypography.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Check ${_emailController.text} for instructions to reset your password.',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      PashuButton(
                        text: 'Back to Login',
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: AppTypography.displayMedium.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your registered email address and we will send you a reset link.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    PashuTextField(
                      label: 'Email Address',
                      hint: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 24),
                    PashuButton(
                      text: 'Send Reset Link',
                      icon: Icons.send,
                      onPressed: _sendResetEmail,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
