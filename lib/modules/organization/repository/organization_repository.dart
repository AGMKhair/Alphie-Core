import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/storage_constants.dart';
import '../model/organization_model.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationModel>> getOrganizations();
  Future<OrganizationModel> getOrganizationById(int id);
  Future<OrganizationModel> createOrganization(OrganizationRequest request);
  Future<OrganizationModel> updateOrganization(int id, OrganizationRequest request);
  Future<void> deleteOrganization(int id);
  Future<List<BranchModel>> getBranches(int organizationId);
  Future<BranchModel> createBranch(BranchRequest request);
  Future<void> switchTenantContext({required int organizationId, int? branchId});
}

class OrganizationRepositoryImpl implements OrganizationRepository {
  final Dio apiClient;
  final SecureStorage secureStorage;

  OrganizationRepositoryImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Future<List<OrganizationModel>> getOrganizations() async {
    try {
      final response = await apiClient.get('/organizations');
      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((json) {
          final branchesList = (json['branches'] as List<dynamic>?)?.map((b) {
            return BranchModel(
              id: b['id'] as int? ?? 1,
              organizationId: b['organization_id'] as int? ?? (json['id'] as int? ?? 1),
              name: b['name'] as String? ?? 'Campus',
              code: b['code'] as String? ?? 'BRANCH',
              city: b['city'] as String? ?? 'Dhaka',
              country: 'Bangladesh',
              isMain: b['is_main_branch'] == true || b['is_main_branch'] == 1,
            );
          }).toList() ?? [];

          return OrganizationModel(
            id: json['id'] as int? ?? 1,
            name: json['name'] as String? ?? '',
            code: json['code'] as String? ?? '',
            type: json['type'] as String? ?? 'school',
            email: json['email'] as String? ?? '',
            phone: json['phone'] as String? ?? '',
            address: json['address'] as String? ?? '',
            status: 'active',
            branches: branchesList,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<OrganizationModel> getOrganizationById(int id) async {
    try {
      final list = await getOrganizations();
      return list.firstWhere(
        (o) => o.id == id,
        orElse: () => throw const ServerFailure('Organization not found'),
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<OrganizationModel> createOrganization(OrganizationRequest request) async {
    try {
      final response = await apiClient.post('/organizations', data: request.toJson());
      final json = response.data['data'];
      return OrganizationModel(
        id: json['id'] as int? ?? 1,
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
        type: json['type'] as String? ?? 'school',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        status: 'active',
        branches: [],
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<OrganizationModel> updateOrganization(int id, OrganizationRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return OrganizationModel(
        id: id,
        name: request.name,
        code: request.code,
        type: request.type,
        email: request.email,
        phone: request.phone,
        address: request.address,
        status: 'active',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteOrganization(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<BranchModel>> getBranches(int organizationId) async {
    try {
      final response = await apiClient.get('/organizations/$organizationId/branches');
      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((b) {
          return BranchModel(
            id: b['id'] as int? ?? 1,
            organizationId: b['organization_id'] as int? ?? organizationId,
            name: b['name'] as String? ?? 'Branch',
            code: b['code'] as String? ?? 'BRANCH',
            city: b['city'] as String? ?? 'Dhaka',
            country: 'Bangladesh',
            isMain: b['is_main_branch'] == true || b['is_main_branch'] == 1,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<BranchModel> createBranch(BranchRequest request) async {
    try {
      final response = await apiClient.post(
        '/organizations/${request.organizationId}/branches',
        data: request.toJson(),
      );
      final json = response.data['data'];
      return BranchModel(
        id: json['id'] as int? ?? 1,
        organizationId: json['organization_id'] as int? ?? request.organizationId,
        name: json['name'] as String? ?? request.name,
        code: json['code'] as String? ?? request.code,
        address: json['address'] as String? ?? request.address,
        phone: json['phone'] as String? ?? request.phone,
        city: json['city'] as String? ?? request.city,
        country: json['country'] as String? ?? request.country,
        isMain: json['is_main_branch'] == true || json['is_main_branch'] == 1,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> switchTenantContext({required int organizationId, int? branchId}) async {
    await secureStorage.write(StorageConstants.selectedOrgId, organizationId.toString());
    if (branchId != null) {
      await secureStorage.write(StorageConstants.selectedBranchId, branchId.toString());
    } else {
      await secureStorage.delete(StorageConstants.selectedBranchId);
    }
  }
}
