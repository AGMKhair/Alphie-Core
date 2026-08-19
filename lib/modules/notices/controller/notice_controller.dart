import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/notice_model.dart';
import '../provider/notice_provider.dart';
import '../repository/notice_repository.dart';

class SelectedNoticeAudienceNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setAudience(String aud) => state = aud;
}

class NoticeListController extends AsyncNotifier<List<NoticeModel>> {
  NoticeRepository get _repository => ref.read(noticeRepositoryProvider);

  @override
  Future<List<NoticeModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);
    final audience = ref.watch(selectedNoticeAudienceProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getNotices(
      organizationId: orgId,
      branchId: branchId,
      audience: audience == 'all' ? null : audience,
    );
  }

  Future<void> fetchNotices({
    int? organizationId,
    int? branchId,
    String? audience,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getNotices(
        organizationId: orgId,
        branchId: branchId,
        audience: audience,
      );
    });
  }

  Future<bool> createNotice(CreateNoticeRequest request) async {
    try {
      final newNotice = await _repository.createNotice(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([newNotice, ...currentList]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotice(int id) async {
    try {
      await _repository.deleteNotice(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((n) => n.id != id).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
