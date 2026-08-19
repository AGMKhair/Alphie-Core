import 'package:dio/dio.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/error/failure.dart';
import '../model/user_rbac_model.dart';

abstract class UsersRepository {
  Future<List<OrganizationUserModel>> getUsers({int? organizationId, int? branchId, String? search});
  Future<List<RoleModel>> getRoles({int? organizationId});
  Future<List<PermissionModel>> getPermissions();
  Future<OrganizationUserModel> inviteUser(InviteUserRequest request);
  Future<void> updateUserRole({required int organizationUserId, required int roleId});
  Future<void> removeUser(int organizationUserId);
}

class UsersRepositoryImpl implements UsersRepository {
  final Dio apiClient;

  UsersRepositoryImpl({required this.apiClient});

  @override
  Future<List<OrganizationUserModel>> getUsers({int? organizationId, int? branchId, String? search}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        OrganizationUserModel(
          id: 1,
          organizationId: organizationId ?? 1,
          userId: 1,
          roleId: 1,
          branchId: branchId ?? 1,
          name: 'Kamal Hossain',
          email: 'admin@alphiecore.com',
          phone: '+8801711111111',
          roleName: 'Organization Admin',
          roleSlug: 'organization_admin',
          branchName: 'Dhaka Main Campus',
          status: 'active',
          joinedAt: DateTime(2025, 1, 1),
        ),
        OrganizationUserModel(
          id: 2,
          organizationId: organizationId ?? 1,
          userId: 2,
          roleId: 2,
          branchId: branchId ?? 1,
          name: 'Nasreen Akhtar',
          email: 'nasreen@school.edu',
          phone: '+8801722222222',
          roleName: 'Teacher / Instructor',
          roleSlug: 'teacher',
          branchName: 'Dhaka Main Campus',
          status: 'active',
          joinedAt: DateTime(2025, 2, 15),
        ),
        OrganizationUserModel(
          id: 3,
          organizationId: organizationId ?? 1,
          userId: 3,
          roleId: 3,
          branchId: branchId ?? 2,
          name: 'Tariqul Islam',
          email: 'tariq@school.edu',
          phone: '+8801733333333',
          roleName: 'Branch Admin',
          roleSlug: 'branch_admin',
          branchName: 'Chittagong Campus',
          status: 'active',
          joinedAt: DateTime(2025, 3, 10),
        ),
        OrganizationUserModel(
          id: 4,
          organizationId: organizationId ?? 1,
          userId: 4,
          roleId: 4,
          branchId: branchId ?? 1,
          name: 'Mahbubur Rahman',
          email: 'accountant@school.edu',
          phone: '+8801744444444',
          roleName: 'Accountant',
          roleSlug: 'accountant',
          branchName: 'Dhaka Main Campus',
          status: 'active',
          joinedAt: DateTime(2025, 4, 1),
        ),
      ];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<RoleModel>> getRoles({int? organizationId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        RoleModel(
          id: 1,
          name: 'Super Admin',
          slug: 'super_admin',
          scope: 'system',
          description: 'Full system wide unrestricted access',
        ),
        RoleModel(
          id: 2,
          name: 'Organization Admin',
          slug: 'organization_admin',
          scope: 'organization',
          description: 'Owner / Principal / Managing Director of the institute',
        ),
        RoleModel(
          id: 3,
          name: 'Branch Admin',
          slug: 'branch_admin',
          scope: 'branch',
          description: 'Campus manager or branch coordinator',
        ),
        RoleModel(
          id: 4,
          name: 'Teacher / Instructor',
          slug: 'teacher',
          scope: 'branch',
          description: 'Manages classes, attendance, grading & exams',
        ),
        RoleModel(
          id: 5,
          name: 'Accountant',
          slug: 'accountant',
          scope: 'branch',
          description: 'Manages student invoices, fees, and payments',
        ),
        RoleModel(
          id: 6,
          name: 'Student',
          slug: 'student',
          scope: 'branch',
          description: 'View schedule, results, notices and fees',
        ),
        RoleModel(
          id: 7,
          name: 'Guardian / Parent',
          slug: 'guardian',
          scope: 'branch',
          description: 'Monitor student progress, attendance, and pay dues',
        ),
      ];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<PermissionModel>> getPermissions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return [
        PermissionModel(id: 1, name: 'View Students', slug: 'students.view', module: 'students'),
        PermissionModel(id: 2, name: 'Create Student', slug: 'students.create', module: 'students'),
        PermissionModel(id: 3, name: 'Edit Student', slug: 'students.edit', module: 'students'),
        PermissionModel(id: 4, name: 'Take Attendance', slug: 'attendance.take', module: 'attendance'),
        PermissionModel(id: 5, name: 'View Attendance', slug: 'attendance.view', module: 'attendance'),
        PermissionModel(id: 6, name: 'Manage Fees', slug: 'fees.manage', module: 'fees'),
        PermissionModel(id: 7, name: 'Collect Payment', slug: 'payments.collect', module: 'fees'),
        PermissionModel(id: 8, name: 'Publish Notice', slug: 'notices.publish', module: 'communication'),
      ];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<OrganizationUserModel> inviteUser(InviteUserRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return OrganizationUserModel(
        id: DateTime.now().millisecondsSinceEpoch % 1000,
        organizationId: request.organizationId,
        userId: DateTime.now().millisecondsSinceEpoch % 2000,
        roleId: request.roleId,
        branchId: request.branchId,
        name: request.name,
        email: request.email,
        phone: request.phone,
        roleName: 'Assigned Role',
        roleSlug: 'assigned_role',
        status: 'active',
        joinedAt: DateTime.now(),
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateUserRole({required int organizationUserId, required int roleId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> removeUser(int organizationUserId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
