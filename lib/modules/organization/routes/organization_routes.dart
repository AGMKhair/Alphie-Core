import 'package:go_router/go_router.dart';
import '../presenter/screens/organization_list_screen.dart';

class OrganizationRoutes {
  static const String organizations = '/organizations';

  static List<GoRoute> get routes => [
        GoRoute(
          path: organizations,
          builder: (context, state) => const OrganizationListScreen(),
        ),
      ];
}
