import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/change_password_request.dart';
import '../model/login_request.dart';
import '../model/user_model.dart';
import '../provider/auth_provider.dart';
import '../repository/auth_repository.dart';

class AuthController extends AsyncNotifier<UserModel?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<UserModel?> build() async {
    try {
      return await _repository.getCachedUser();
    } catch (_) {
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(LoginRequest(email: email, password: password));
      state = AsyncValue.data(user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _repository.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _repository.forgotPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
