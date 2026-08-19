import 'package:go_router/go_router.dart';
import '../presenter/screens/programs_list_screen.dart';

class AcademicRoutes {
  static const String programs = '/programs';

  static List<GoRoute> get routes => [
        GoRoute(
          path: programs,
          builder: (context, state) => const ProgramsListScreen(),
        ),
      ];
}
