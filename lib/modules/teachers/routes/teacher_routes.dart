import 'package:go_router/go_router.dart';
import '../presenter/screens/teachers_list_screen.dart';

class TeacherRoutes {
  static const String teachers = '/teachers';

  static List<GoRoute> get routes => [
        GoRoute(
          path: teachers,
          builder: (context, state) => const TeachersListScreen(),
        ),
      ];
}
