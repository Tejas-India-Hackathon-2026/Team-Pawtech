import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../l10n/l10n.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _vaccinationReminders = true;
  bool _medicineReminders = true;
  bool _communityNotifs = true;
  bool _referralNotifs = true;
  bool _voiceAssistant = true;
  bool _voiceResponse = true;
  bool _locationPermission = true;
  bool _profileVisibility = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    return Scaffold(
      appBar: const PashuAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Account Section
            _buildSectionHeader('Account'),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary),
              title: Text(user?.fullName ?? 'User Profile'),
              subtitle: Text('${user?.email ?? "user@pawfinder.in"} • ${user?.phone ?? "+91 98765 43210"}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/forgot-password'),
            ),
            const Divider(),

            // 2. Language Section
            _buildSectionHeader('Language'),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('App Language'),
              subtitle: Text('${AppLanguages.getLanguageName(lang)} (${lang.toUpperCase()})'),
              trailing: DropdownButton<String>(
                value: lang,
                underline: const SizedBox(),
                items: AppLanguages.supportedLanguages.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value['name'] as String)))
                    .toList(),
                onChanged: (code) {
                  if (code != null) {
                    ref.read(localeProvider.notifier).setLanguage(code);
                  }
                },
              ),
            ),
            const Divider(),

            // 3. Notifications Section
            _buildSectionHeader('Notifications'),
            SwitchListTile(
              secondary: const Icon(Icons.vaccines, color: AppColors.primary),
              title: const Text('Vaccination Reminders'),
              value: _vaccinationReminders,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _vaccinationReminders = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.medication, color: AppColors.primary),
              title: const Text('Medicine Reminders'),
              value: _medicineReminders,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _medicineReminders = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.group, color: AppColors.primary),
              title: const Text('Community Notifications'),
              value: _communityNotifs,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _communityNotifs = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.assignment, color: AppColors.primary),
              title: const Text('Referral Updates'),
              value: _referralNotifs,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _referralNotifs = v),
            ),
            const Divider(),

            // 4. AI & Voice Assistant Section
            _buildSectionHeader('AI & Voice'),
            SwitchListTile(
              secondary: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('Voice Assistant (STT)'),
              subtitle: const Text('Speech-To-Text voice input'),
              value: _voiceAssistant,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _voiceAssistant = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up, color: AppColors.primary),
              title: const Text('Voice Responses (TTS)'),
              subtitle: const Text('Text-To-Speech audio output'),
              value: _voiceResponse,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _voiceResponse = v),
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy, color: AppColors.primary),
              title: const Text('PashuMitra AI Assistant'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai-assistant'),
            ),
            const Divider(),

            // 5. Location Section
            _buildSectionHeader('Location'),
            SwitchListTile(
              secondary: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('Location Permission'),
              subtitle: const Text('Required for PostGIS nearby NGO search'),
              value: _locationPermission,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _locationPermission = v),
            ),
            const Divider(),

            // 6. Privacy & Security Section
            _buildSectionHeader('Privacy & Security'),
            SwitchListTile(
              secondary: const Icon(Icons.visibility, color: AppColors.primary),
              title: const Text('Public Profile Visibility'),
              value: _profileVisibility,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _profileVisibility = v),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.emergencyRed),
              title: const Text('Delete Account', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('Are you sure you want to permanently delete your account and pet health records? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).logout();
                          context.go('/login');
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),

            // 7. Premium Subscription Section
            _buildSectionHeader('Premium Membership'),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: Text(user?.isPremium ?? false ? 'Premium Member (Active)' : 'Free Plan (Upgrade to Premium)'),
              subtitle: const Text('Manage plan, payments & billing'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/premium'),
            ),
            const Divider(),

            // 8. Admin Portal (Role Protected)
            _buildSectionHeader('Administration'),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppColors.primaryDark),
              title: const Text('Admin Moderation Dashboard'),
              subtitle: const Text('Verify sellers, manage NGOs, AI moderation queue'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin'),
            ),
            const Divider(),

            // 9. Support & Logout Section
            _buildSectionHeader('Support & Account'),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.primary),
              title: const Text('FAQ & Help Center'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic_outlined, color: AppColors.primary),
              title: const Text('Contact Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.emergencyRed),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
