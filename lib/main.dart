import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase BaaS
  await SupabaseService.initialize();

  // Initialize Local Notifications
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: PashuRakhshakApp(),
    ),
  );
}

class PashuRakhshakApp extends ConsumerWidget {
  const PashuRakhshakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'PashuRakhshak - Animal Welfare & AI Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: currentLocale,
      supportedLocales: AppLanguages.supportedLocales
          .map((item) => Locale(item.code))
          .toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
