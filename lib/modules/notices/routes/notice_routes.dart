import 'package:go_router/go_router.dart';
import '../presenter/screens/notice_board_screen.dart';

class NoticeRoutes {
  static const String notices = '/notices';

  static List<GoRoute> get routes => [
        GoRoute(
          path: notices,
          builder: (context, state) => const NoticeBoardScreen(),
        ),
      ];
}
