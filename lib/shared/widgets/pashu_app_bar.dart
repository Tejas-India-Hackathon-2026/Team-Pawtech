import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../l10n/l10n.dart';

class PashuAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showLanguageSelector;
  final bool showSosButton;
  final List<Widget>? actions;

  const PashuAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showLanguageSelector = true,
    this.showSosButton = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Language (भाषा चुनें)', style: AppTypography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: AppLanguages.supportedLocales.length,
                  itemBuilder: (context, index) {
                    final item = AppLanguages.supportedLocales[index];
                    final currentLocale = ref.watch(localeProvider);
                    final isSelected = currentLocale.languageCode == item.code;

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected ? AppColors.primaryContainer : null,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        child: Text(
                          item.code.toUpperCase().substring(0, 2),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      title: Text(
                        item.nativeName,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(item.englishName, style: AppTypography.bodySmall),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(item.code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            )
          : null,
      title: title != null
          ? Text(title!, style: AppTypography.titleLarge)
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLanguages.get('appName', currentLocale.languageCode),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'AI Animal Care & Rescue',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        if (showLanguageSelector)
          IconButton(
            tooltip: 'Language',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.translate, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    currentLocale.languageCode.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () => _showLanguageDialog(context, ref),
          ),
        if (showSosButton)
          IconButton(
            tooltip: 'Emergency SOS',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.emergencyRedContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_outlined,
                color: AppColors.emergencyRed,
                size: 20,
              ),
            ),
            onPressed: () => context.push('/report-emergency'),
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }
}
