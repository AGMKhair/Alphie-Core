import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

class EducationApp extends ConsumerWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Alphie Core',
      theme: AppTheme.getTheme(themeColors),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
