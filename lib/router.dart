import 'package:go_router/go_router.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_shell.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/create_edit_habit_screen.dart';

GoRouter buildRouter({required bool showOnboarding}) {
  return GoRouter(
    initialLocation: showOnboarding ? '/onboarding' : '/home',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/habit/:id',
        builder: (context, state) =>
            HabitDetailScreen(habitId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/habit-form',
        builder: (context, state) {
          final habitId = state.uri.queryParameters['edit'];
          return CreateEditHabitScreen(editHabitId: habitId);
        },
      ),
    ],
  );
}
