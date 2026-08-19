import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../controller/auth_controller.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});

final currentUserRoleProvider = Provider<String?>((ref) {
  final userState = ref.watch(authControllerProvider);
  return userState.value?.role;
});

final userPermissionsProvider = Provider<List<String>>((ref) {
  final userState = ref.watch(authControllerProvider);
  return userState.value?.permissions ?? [];
});

final canManageAttendanceProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return false;

  if (user.permissions.contains('attendance:manage')) return true;

  final role = user.role.toLowerCase();
  return role == 'super_admin' ||
      role == 'organization_admin' ||
      role == 'branch_admin' ||
      role == 'teacher';
});

final isStudentOrParentProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider)?.toLowerCase() ?? '';
  return role == 'student' || role == 'guardian' || role == 'parent';
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final userState = ref.watch(authControllerProvider);
  return userState.value != null;
});
