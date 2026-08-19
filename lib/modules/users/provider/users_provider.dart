import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/users_controller.dart';
import '../model/user_rbac_model.dart';
import '../repository/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final rolesListProvider = FutureProvider<List<RoleModel>>((ref) async {
  return ref.watch(usersRepositoryProvider).getRoles();
});

final permissionsListProvider = FutureProvider<List<PermissionModel>>((ref) async {
  return ref.watch(usersRepositoryProvider).getPermissions();
});

final usersListControllerProvider = AsyncNotifierProvider<UsersListController, List<OrganizationUserModel>>(() {
  return UsersListController();
});
