import 'package:go_router/go_router.dart';
import '../presenter/screens/attendance_screen.dart';

class AttendanceRoutes {
  static const String attendance = '/attendance';

  static List<GoRoute> get routes => [
        GoRoute(
          path: attendance,
          builder: (context, state) => const AttendanceScreen(),
        ),
      ];
}
