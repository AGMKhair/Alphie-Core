import 'package:go_router/go_router.dart';
import '../presenter/screens/reports_screen.dart';

class ReportRoutes {
  static const String reports = '/reports';

  static List<GoRoute> get routes => [
        GoRoute(
          path: reports,
          builder: (context, state) => const ReportsScreen(),
        ),
      ];
}
