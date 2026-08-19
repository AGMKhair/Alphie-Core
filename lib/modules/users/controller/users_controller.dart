import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/user_rbac_model.dart';
import '../provider/users_provider.dart';
import '../repository/users_repository.dart';

class UsersListController extends AsyncNotifier<List<OrganizationUserModel>> {
  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  @override
  Future<List<OrganizationUserModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getUsers(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> fetchUsers({int? organizationId, int? branchId, String? search}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getUsers(
        organizationId: orgId,
        branchId: branchId,
        search: search,
      );
    });
  }

  Future<bool> inviteUser(InviteUserRequest request) async {
    try {
      final newUser = await _repository.inviteUser(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newUser]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserRole(int organizationUserId, int roleId) async {
    try {
      await _repository.updateUserRole(organizationUserId: organizationUserId, roleId: roleId);
      final currentOrg = ref.read(currentOrganizationProvider);
      final currentBranch = ref.read(currentBranchProvider);
      await fetchUsers(organizationId: currentOrg?.id, branchId: currentBranch?.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeUser(int organizationUserId) async {
    try {
      await _repository.removeUser(organizationUserId);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((u) => u.id != organizationUserId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
