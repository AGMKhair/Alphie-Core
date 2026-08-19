import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../modules/attendance/presenter/screens/attendance_screen.dart';
import '../../modules/auth/presenter/screens/login_screen.dart';
import '../../modules/auth/presenter/screens/profile_screen.dart';
import '../../modules/auth/provider/auth_provider.dart';
import '../../modules/dashboard/presenter/screens/dashboard_screen.dart';
import '../../modules/exams/presenter/screens/exams_list_screen.dart';
import '../../modules/fees/presenter/screens/fees_invoices_screen.dart';
import '../../modules/homework/presenter/screens/homework_list_screen.dart';
import '../../modules/notices/presenter/screens/notice_board_screen.dart';
import '../../modules/organization/presenter/screens/organization_list_screen.dart';
import '../../modules/programs/presenter/screens/programs_list_screen.dart';
import '../../modules/reports/presenter/screens/reports_screen.dart';
import '../../modules/students/presenter/screens/student_list_screen.dart';
import '../../modules/teachers/presenter/screens/teachers_list_screen.dart';
import '../../modules/timetable/presenter/screens/timetable_screen.dart';
import '../../modules/users/presenter/screens/users_list_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.initial,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RouteNames.login || state.matchedLocation == RouteNames.initial;

      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          if (isLoggedIn && isLoggingIn) {
            return RouteNames.dashboard;
          }
          if (!isLoggedIn && !isLoggingIn) {
            return RouteNames.login;
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => isLoggingIn ? null : RouteNames.login,
      );
    },
    routes: [
      GoRoute(
        path: RouteNames.initial,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.organizations,
        builder: (context, state) => const OrganizationListScreen(),
      ),
      GoRoute(
        path: RouteNames.users,
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: RouteNames.programs,
        builder: (context, state) => const ProgramsListScreen(),
      ),
      GoRoute(
        path: RouteNames.teachers,
        builder: (context, state) => const TeachersListScreen(),
      ),
      GoRoute(
        path: RouteNames.students,
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: RouteNames.attendance,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: RouteNames.timetable,
        builder: (context, state) => const TimetableScreen(),
      ),
      GoRoute(
        path: RouteNames.exams,
        builder: (context, state) => const ExamsListScreen(),
      ),
      GoRoute(
        path: RouteNames.homework,
        builder: (context, state) => const HomeworkListScreen(),
      ),
      GoRoute(
        path: RouteNames.fees,
        builder: (context, state) => const FeesInvoicesScreen(),
      ),
      GoRoute(
        path: RouteNames.notices,
        builder: (context, state) => const NoticeBoardScreen(),
      ),
      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
