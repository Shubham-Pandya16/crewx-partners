import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

class CrewXPartnersApp extends ConsumerWidget {
  const CrewXPartnersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes to refresh FCM token
    ref.listen(authProvider.select((s) => s.user), (previous, next) {
      if (next != null) {
        NotificationService().refreshToken(next.uid);
      }
    });

    return MaterialApp.router(
      title: 'CrewX Partners',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
