import 'package:go_router/go_router.dart';
import '../presenter/screens/student_list_screen.dart';

class StudentRoutes {
  static const String students = '/students';

  static List<GoRoute> get routes => [
        GoRoute(
          path: students,
          builder: (context, state) => const StudentListScreen(),
        ),
      ];
}
