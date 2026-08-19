import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/reports_model.dart';
import '../provider/reports_provider.dart';
import '../repository/reports_repository.dart';

class ReportsController extends AsyncNotifier<DashboardAnalyticsModel> {
  ReportsRepository get _repository => ref.read(reportsRepositoryProvider);

  @override
  Future<DashboardAnalyticsModel> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getAnalytics(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> fetchAnalytics({int? organizationId, int? branchId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getAnalytics(
        organizationId: orgId,
        branchId: branchId,
      );
    });
  }
}
