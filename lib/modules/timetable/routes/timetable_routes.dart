import 'package:go_router/go_router.dart';
import '../presenter/screens/timetable_screen.dart';

class TimetableRoutes {
  static const String timetable = '/timetable';

  static List<GoRoute> get routes => [
        GoRoute(
          path: timetable,
          builder: (context, state) => const TimetableScreen(),
        ),
      ];
}
