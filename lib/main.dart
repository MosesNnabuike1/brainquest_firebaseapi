import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_quizzapp/utils/auth_helper.dart';
import 'package:firebase_quizzapp/student/question_page.dart';
import 'package:firebase_quizzapp/tutor/auth/tutor_login_screen.dart';
import 'package:firebase_quizzapp/student/screens/tutor_id_screen.dart';
import 'package:firebase_quizzapp/tutor/screens/tutor_main_screen.dart';
import 'package:firebase_quizzapp/tutor/screens/tutor_profile_page.dart';
import 'package:firebase_quizzapp/student/screens/daily_quiz_screen.dart';
import 'package:firebase_quizzapp/tutor/editing/add_category_screen.dart';
import 'package:firebase_quizzapp/tutor/editing/add_question_screen.dart';
import 'package:firebase_quizzapp/student/results/quiz_history_page.dart';
import 'package:firebase_quizzapp/student/auth/student_login_screen.dart';
import 'package:firebase_quizzapp/student/screens/achievements_screen.dart';
import 'package:firebase_quizzapp/student/screens/student_main_screen.dart';
import 'package:firebase_quizzapp/tutor/screens/tutor_dashboard_screen.dart';
import 'package:firebase_quizzapp/tutor/auth/tutor_registration_screen.dart';
import 'package:firebase_quizzapp/student/screens/student_welcome_screen.dart';
import 'package:firebase_quizzapp/tutor/auth/tutor_forgot_password_screen.dart';
import 'package:firebase_quizzapp/tutor/screens/tutor_question_list_screen.dart';
import 'package:firebase_quizzapp/student/auth/student_registration_screen.dart';
import 'package:firebase_quizzapp/tutor/screens/tutor_manage_category_screen.dart';
import 'package:firebase_quizzapp/student/auth/student_forgot_password_screen.dart';
import 'package:firebase_quizzapp/student/screens/daily_critical_thinking_screen.dart';
import 'package:firebase_quizzapp/tutor/editing/add_critical_thinking_puzzle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Optionally handle errors here, but no print statements
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const StudentWelcomeScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const StudentRegistrationScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return StudentMainScreen(
              studentName: extra['studentName'] as String? ?? 'Student Name',
              tutorId: extra['tutorId'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/category',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return StudentMainScreen(
              studentName: extra['studentName'] as String? ?? 'Student Name',
              tutorId: extra['tutorId'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/results',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return StudentMainScreen(
              studentName: extra['studentName'] as String? ?? 'Student Name',
              tutorId: extra['tutorId'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/daily-quiz',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return DailyQuizScreen(
              tutorId: extra['tutorId'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/daily-critical',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return DailyCriticalThinkingScreen(
              tutorId: extra['tutorId'] as String?,
            );
          },
        ),
        // Additional routes migrated from imperative navigation
        GoRoute(
          path: '/tutor-id',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return TutorIdScreen(
              studentName: extra['studentName'] as String? ?? 'Student Name',
            );
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/tutor-register',
          builder: (context, state) => const TutorRegistrationScreen(),
        ),
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/question',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return QuestionPage(
              subject: extra['subject'] as String? ?? '',
              topic: extra['topic'] as String? ?? '',
              categoryId: extra['categoryId'] as String? ?? '',
              tutorId: extra['tutorId'] as String? ?? '',
            );
          },
        ),
        GoRoute(
          path: '/quiz-history',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return QuizHistoryPage(resultId: extra['resultId'] as String);
          },
        ),
        GoRoute(
          path: '/tutor/questions',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return TutorQuestionListScreen(
              categoryId: extra['categoryId'] as String,
              categoryTitle: extra['categoryTitle'] as String,
              tutorId: extra['tutorId'] as String,
            );
          },
        ),
        // Tutor routes
        GoRoute(
          path: '/tutor/login',
          builder: (context, state) => const TutorLoginScreen(),
        ),
        GoRoute(
          path: '/tutor/forgot-password',
          builder: (context, state) => const TutorForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/tutor/main',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return TutorMainScreen(
              tutorId: extra['tutorId'] as String? ?? '',
              tutorName: extra['tutorName'] as String? ?? 'Tutor',
            );
          },
        ),
        GoRoute(
          path: '/tutor/dashboard',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return TutorDashboardScreen(
              tutorId: extra['tutorId'] as String? ?? '',
              tutorName: extra['tutorName'] as String? ?? 'Tutor',
              onOpenProfileTab: extra['onOpenProfileTab'] as VoidCallback?,
            );
          },
        ),
        GoRoute(
          path: '/tutor/profile',
          builder: (context, state) => const TutorProfilePage(),
        ),
        GoRoute(
          path: '/tutor/add-category',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return AddCategoryScreen(tutorId: extra['tutorId'] as String);
          },
        ),
        GoRoute(
          path: '/tutor/add-question',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return AddQuestionScreen(tutorId: extra['tutorId'] as String);
          },
        ),
        GoRoute(
          path: '/tutor/add-puzzle',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return AddCriticalThinkingPuzzleScreen(
                tutorId: extra['tutorId'] as String);
          },
        ),
        GoRoute(
          path: '/tutor/manage-category',
          builder: (context, state) {
            final extra = (state.extra is Map) ? state.extra as Map : const {};
            return TutorManageCategoryScreen(
                tutorId: extra['tutorId'] as String);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'BrainQuest',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyLarge:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.black),
              bodyMedium:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.black),
              titleLarge:
                  const TextStyle(fontFamily: 'Poppins', color: Colors.black),
            ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a small delay for splash screen effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final userData = await AuthHelper.getCurrentUserData();

    if (userData != null) {
      final role = userData['role'] as String?;

      if (role == 'tutor') {
        // Navigate to tutor dashboard
        context.go('/tutor/main', extra: {
          'tutorId': userData['tutorId'] as String? ?? '',
          'tutorName': userData['fullName'] as String? ?? 'Tutor',
        });
      } else if (role == 'student') {
        // If student, ensure tutorId is provided; otherwise route to TutorIdScreen
        final maybeTutorId = userData['tutorId'] as String?;
        if (maybeTutorId == null || maybeTutorId.isEmpty) {
          context.go('/tutor-id', extra: {
            'studentName': userData['fullName'] as String? ?? 'Student',
          });
        } else {
          context.go('/home', extra: {
            'studentName': userData['fullName'] as String? ?? 'Student',
            'tutorId': maybeTutorId,
          });
        }
      } else {
        // Unknown role, go to welcome screen
        context.go('/');
      }
    } else {
      // No user logged in, go to welcome screen
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181DB4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SizedBox(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // App name
            const Text(
              'BrainQuest',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
