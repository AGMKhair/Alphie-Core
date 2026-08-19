import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/notice_controller.dart';
import '../model/notice_model.dart';
import '../repository/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final selectedNoticeAudienceProvider = NotifierProvider<SelectedNoticeAudienceNotifier, String>(() {
  return SelectedNoticeAudienceNotifier();
});

final noticeListControllerProvider = AsyncNotifierProvider<NoticeListController, List<NoticeModel>>(() {
  return NoticeListController();
});
