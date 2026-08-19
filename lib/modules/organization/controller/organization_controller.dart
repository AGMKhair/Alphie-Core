import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/organization_model.dart';
import '../provider/organization_provider.dart';
import '../repository/organization_repository.dart';

class OrganizationListController extends AsyncNotifier<List<OrganizationModel>> {
  OrganizationRepository get _repository => ref.read(organizationRepositoryProvider);

  @override
  Future<List<OrganizationModel>> build() async {
    return await _repository.getOrganizations();
  }

  Future<void> loadOrganizations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _repository.getOrganizations();
      final current = ref.read(currentOrganizationProvider);
      if (current == null && list.isNotEmpty) {
        ref.read(currentOrganizationProvider.notifier).selectOrganization(list.first);
      }
      return list;
    });
  }

  Future<bool> createOrganization(OrganizationRequest request) async {
    try {
      final newOrg = await _repository.createOrganization(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newOrg]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createBranch(BranchRequest request) async {
    try {
      final newBranch = await _repository.createBranch(request);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((org) {
        if (org.id == request.organizationId) {
          return org.copyWith(branches: [...org.branches, newBranch]);
        }
        return org;
      }).toList();
      state = AsyncValue.data(updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }
}
