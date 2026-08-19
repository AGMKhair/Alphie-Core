import 'package:go_router/go_router.dart';
import '../presenter/screens/exams_list_screen.dart';

class ExamRoutes {
  static const String exams = '/exams';

  static List<GoRoute> get routes => [
        GoRoute(
          path: exams,
          builder: (context, state) => const ExamsListScreen(),
        ),
      ];
}
