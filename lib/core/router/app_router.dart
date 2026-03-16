import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Auth ──────────────────────────────────────────────────────────────────
import '../../auth/screens/onboarding_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';

// ── Main features ─────────────────────────────────────────────────────────
import '../../dashboard/screens/dashboard_screen.dart';
import '../../mood_tracking/screens/moodtracking_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../planner/screens/planner_screen.dart';
import '../../self_assessment/screens/assessment_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../crisis/screens/crisis_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../breathing/screens/breathing_screen.dart';
import '../../settings/screens/settings_screen.dart';

// ── Shell ─────────────────────────────────────────────────────────────────
import '../../shared/widgets/main_shell.dart';

// ── Route Name Constants ──────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String signup         = '/signup';
  static const String dashboard      = '/dashboard';
  static const String moodTracking   = '/mood';
  static const String chatbot        = '/chat';
  static const String journal        = '/journal';
  static const String planner        = '/planner';
  static const String selfAssessment = '/assessment';
  static const String progress       = '/progress';
  static const String crisis         = '/crisis';
  static const String referral       = '/referral';
  static const String breathing      = '/breathing';
  static const String settings       = '/settings';
}

// ── Router Provider ───────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      // Auth guard goes here in Phase 2
      // final isAuth = ref.read(authStateProvider).isAuthenticated;
      // final onAuthRoute = [
      //   AppRoutes.login,
      //   AppRoutes.signup,
      //   AppRoutes.onboarding,
      // ].contains(state.matchedLocation);
      // if (!isAuth && !onAuthRoute) return AppRoutes.login;
      // if (isAuth && onAuthRoute)   return AppRoutes.dashboard;
      return null;
    },
    routes: [
      // ── Auth screens (no bottom nav) ───────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ── Main app (wrapped with bottom nav shell) ───────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.moodTracking,
            name: 'moodTracking',
            builder: (context, state) => const MoodTrackingScreen(),
          ),
          GoRoute(
            path: AppRoutes.chatbot,
            name: 'chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: AppRoutes.journal,
            name: 'journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: AppRoutes.planner,
            name: 'planner',
            builder: (context, state) => const PlannerScreen(),
          ),
          GoRoute(
            path: AppRoutes.selfAssessment,
            name: 'selfAssessment',
            builder: (context, state) => const SelfAssessmentScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.referral,
            name: 'referral',
            builder: (context, state) => const ReferralScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Standalone screens (no bottom nav) ────────────────────────────
      GoRoute(
        path: AppRoutes.crisis,
        name: 'crisis',
        builder: (context, state) => const CrisisScreen(),
      ),
      GoRoute(
        path: AppRoutes.breathing,
        name: 'breathing',
        builder: (context, state) => const BreathingScreen(),
      ),
    ],
  );
});