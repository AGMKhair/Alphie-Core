import 'package:go_router/go_router.dart';
import '../presenter/screens/login_screen.dart';
import '../presenter/screens/profile_screen.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String profile = '/profile';

  static List<GoRoute> get routes => [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ];
}
