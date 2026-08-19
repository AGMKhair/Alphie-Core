import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../model/change_password_request.dart';
import '../model/login_request.dart';
import '../model/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Future<UserModel> getProfile();
  Future<void> updateProfile({required String name, String? phone});
  Future<void> changePassword(ChangePasswordRequest request);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<UserModel?> getCachedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio apiClient;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Future<UserModel> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final data = response.data;
      if ((data['success'] == true || data['status'] == 'success') && data['data'] != null) {
        final userData = data['data'];
        final userObj = userData['user'] ?? userData;
        final token = userData['token'] ?? '';

        final user = UserModel(
          id: userObj['id'] as int? ?? 1,
          name: userObj['name'] as String? ?? '',
          email: userObj['email'] as String? ?? '',
          phone: userObj['phone'] as String?,
          token: token,
          role: userObj['role'] as String? ?? 'admin',
          organizationId: userObj['organization_id'] as int? ?? 1,
          branchId: userObj['branch_id'] as int? ?? 1,
          permissions: (userObj['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['*'],
        );

        await secureStorage.write(StorageConstants.authToken, token);
        if (user.organizationId != null) {
          await secureStorage.write(StorageConstants.selectedOrgId, user.organizationId.toString());
        }
        if (user.branchId != null) {
          await secureStorage.write(StorageConstants.selectedBranchId, user.branchId.toString());
        }
        return user;
      } else {
        throw ServerFailure(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final token = await secureStorage.read(StorageConstants.authToken);
      if (token == null) throw const AuthFailure('Unauthenticated session');

      final response = await apiClient.get(ApiConstants.me);
      final data = response.data;
      if (data['success'] == true || data['status'] == 'success') {
        final userObj = data['data'] ?? data;
        return UserModel(
          id: userObj['id'] as int? ?? 1,
          name: userObj['name'] as String? ?? '',
          email: userObj['email'] as String? ?? '',
          phone: userObj['phone'] as String?,
          token: token,
          role: userObj['role'] as String? ?? 'admin',
          organizationId: userObj['organization_id'] as int? ?? 1,
          branchId: userObj['branch_id'] as int? ?? 1,
          permissions: const ['*'],
        );
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateProfile({required String name, String? phone}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await secureStorage.read(StorageConstants.authToken);
      if (token != null) {
        await apiClient.post(ApiConstants.logout);
      }
    } catch (_) {
      // Ignore API logout failure to allow local clean-up
    } finally {
      await secureStorage.clearAll();
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final token = await secureStorage.read(StorageConstants.authToken);
    if (token == null) return null;
    return getProfile();
  }
}
