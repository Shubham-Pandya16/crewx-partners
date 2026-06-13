import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/applications/applications_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/events/event_create_screen.dart';
import '../../features/events/event_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../services/firebase_service.dart';

final appRouter = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggingIn =
        state.matchedLocation == '/auth' || state.matchedLocation == '/otp';

    if (user == null) {
      return isLoggingIn ? null : '/auth';
    }

    final onboarded = await FirebaseService().onboardingComplete(user.uid);
    if (!onboarded) {
      return state.matchedLocation == '/onboarding' ? null : '/onboarding';
    }

    if (isLoggingIn || state.matchedLocation == '/onboarding') {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OtpScreen(
          verificationId: extra['verificationId'] as String,
          phone: extra['phone'] as String,
        );
      },
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/events/create',
      name: 'event_create',
      builder: (context, state) => const EventCreateScreen(),
    ),
    GoRoute(
      path: '/events/:id',
      name: 'event_detail',
      builder: (context, state) =>
          EventDetailScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/applications',
      name: 'applications',
      builder: (context, state) => const ApplicationsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
