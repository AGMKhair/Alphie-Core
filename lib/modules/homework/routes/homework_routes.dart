import 'package:go_router/go_router.dart';
import '../presenter/screens/homework_list_screen.dart';

class HomeworkRoutes {
  static const String homework = '/homework';

  static List<GoRoute> get routes => [
        GoRoute(
          path: homework,
          builder: (context, state) => const HomeworkListScreen(),
        ),
      ];
}
