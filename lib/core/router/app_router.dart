import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';

import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/identify/presentation/screens/identify_animal_screen.dart';
import '../../features/identify/presentation/screens/identification_result_screen.dart';
import '../../features/help/presentation/screens/find_help_screen.dart';
import '../../features/help/presentation/screens/report_emergency_screen.dart';

import '../../features/adopt/presentation/screens/adopt_marketplace_screen.dart';
import '../../features/adopt/presentation/screens/pet_detail_screen.dart';
import '../../features/adopt/presentation/screens/create_listing_screen.dart';
import '../../features/adopt/presentation/screens/seller_verification_screen.dart';

import '../../features/community/presentation/screens/community_feed_screen.dart';
import '../../features/community/presentation/screens/create_post_screen.dart';

import '../../features/pet_health/presentation/screens/pet_health_dashboard_screen.dart';
import '../../features/pet_health/presentation/screens/add_pet_screen.dart';
import '../../features/pet_health/presentation/screens/pet_health_records_screen.dart';
import '../../features/pet_health/presentation/screens/health_trends_screen.dart';
import '../../features/pet_health/presentation/screens/add_reminder_screen.dart';
import '../../features/pet_health/presentation/screens/symptom_checker_screen.dart';

import '../../features/referrals/presentation/screens/partnerships_referrals_screen.dart';
import '../../features/referrals/presentation/screens/submit_referral_screen.dart';
import '../../features/referrals/presentation/screens/referral_status_screen.dart';

import '../../features/ai_assistant/presentation/screens/pashu_mitra_chat_screen.dart';
import '../../features/premium/presentation/screens/premium_membership_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/identify',
        builder: (context, state) => const IdentifyAnimalScreen(),
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) => const IdentificationResultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const FindHelpScreen(),
      ),
      GoRoute(
        path: '/report-emergency',
        builder: (context, state) => const ReportEmergencyScreen(),
      ),
      GoRoute(
        path: '/adopt',
        builder: (context, state) => const AdoptMarketplaceScreen(),
        routes: [
          GoRoute(
            path: 'detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'pet_1';
              return PetDetailScreen(petId: id);
            },
          ),
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateListingScreen(),
          ),
          GoRoute(
            path: 'seller-verification',
            builder: (context, state) => const SellerVerificationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityFeedScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePostScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/pet-health',
        builder: (context, state) => const PetHealthDashboardScreen(),
        routes: [
          GoRoute(
            path: 'add-pet',
            builder: (context, state) => const AddPetScreen(),
          ),
          GoRoute(
            path: 'records/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'pet_1';
              return PetHealthRecordsScreen(petId: id);
            },
          ),
          GoRoute(
            path: 'trends/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'pet_1';
              return HealthTrendsScreen(petId: id);
            },
          ),
          GoRoute(
            path: 'add-reminder',
            builder: (context, state) => const AddReminderScreen(),
          ),
          GoRoute(
            path: 'symptom-checker',
            builder: (context, state) => const SymptomCheckerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/referrals',
        builder: (context, state) => const PartnershipsReferralsScreen(),
        routes: [
          GoRoute(
            path: 'submit',
            builder: (context, state) => const SubmitReferralScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/referral-status/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'ref_101';
          return ReferralStatusScreen(referralId: id);
        },
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const PashuMitraChatScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumMembershipScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
