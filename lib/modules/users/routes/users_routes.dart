import 'package:go_router/go_router.dart';
import '../presenter/screens/users_list_screen.dart';

class UsersRoutes {
  static const String users = '/users';

  static List<GoRoute> get routes => [
        GoRoute(
          path: users,
          builder: (context, state) => const UsersListScreen(),
        ),
      ];
}
