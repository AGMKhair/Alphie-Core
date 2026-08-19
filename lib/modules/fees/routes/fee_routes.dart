import 'package:go_router/go_router.dart';
import '../presenter/screens/fees_invoices_screen.dart';

class FeeRoutes {
  static const String fees = '/fees';

  static List<GoRoute> get routes => [
        GoRoute(
          path: fees,
          builder: (context, state) => const FeesInvoicesScreen(),
        ),
      ];
}
