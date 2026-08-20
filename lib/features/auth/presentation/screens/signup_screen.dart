import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_text_field.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          );
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join PashuRakhshak',
                  style: AppTypography.displayMedium.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your role and help protect animals',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Role Selector Cards
                Text('Select Account Type', style: AppTypography.labelLarge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _RoleCard(
                      title: 'Pet Parent',
                      icon: Icons.favorite,
                      isSelected: _selectedRole == UserRole.user,
                      onTap: () => setState(() => _selectedRole = UserRole.user),
                    ),
                    const SizedBox(width: 8),
                    _RoleCard(
                      title: 'Seller/Breeder',
                      icon: Icons.storefront,
                      isSelected: _selectedRole == UserRole.seller,
                      onTap: () => setState(() => _selectedRole = UserRole.seller),
                    ),
                    const SizedBox(width: 8),
                    _RoleCard(
                      title: 'Rescue NGO',
                      icon: Icons.health_and_safety,
                      isSelected: _selectedRole == UserRole.ngo,
                      onTap: () => setState(() => _selectedRole = UserRole.ngo),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                PashuTextField(
                  label: 'Full Name',
                  hint: 'e.g. Rahul Sharma',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Phone Number (for rescue alerts)',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textMuted),
                  validator: (val) => val == null || val.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 16),

                PashuTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 28),

                PashuButton(
                  text: 'Create Account',
                  icon: Icons.check_circle_outline,
                  isLoading: authState.isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.onPrimaryContainer : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
