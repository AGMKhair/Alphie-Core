import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/teacher_model.dart';

abstract class TeacherRepository {
  Future<List<TeacherModel>> getTeachers({
    required int organizationId,
    int? branchId,
    String? search,
  });
  Future<TeacherModel> getTeacherById(int id);
  Future<TeacherModel> createTeacher(CreateTeacherRequest request);
  Future<void> updateTeacher(int id, CreateTeacherRequest request);
  Future<void> deleteTeacher(int id);
}

class TeacherRepositoryImpl implements TeacherRepository {
  final Dio apiClient;

  TeacherRepositoryImpl({required this.apiClient});

  @override
  Future<List<TeacherModel>> getTeachers({
    required int organizationId,
    int? branchId,
    String? search,
  }) async {
    try {
      final response = await apiClient.get(
        '/teachers',
        queryParameters: {
          if (branchId != null) 'branch_id': branchId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((json) {
          final subjects = (json['assigned_subjects'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          return TeacherModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? 1,
            branchId: json['branch_id'] as int? ?? 1,
            employeeNo: json['employee_no'] as String? ?? '',
            name: json['name'] as String? ?? '',
            designation: json['designation'] as String? ?? '',
            qualification: json['qualification'] as String?,
            specialization: json['specialization'] as String?,
            phone: json['phone'] as String?,
            email: json['email'] as String?,
            status: json['status'] as String? ?? 'active',
            joinDate: DateTime.tryParse(json['join_date'] ?? '') ?? DateTime.now(),
            assignedSubjects: subjects,
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
  Future<TeacherModel> getTeacherById(int id) async {
    try {
      final response = await apiClient.get('/teachers/$id');
      return TeacherModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<TeacherModel> createTeacher(CreateTeacherRequest request) async {
    try {
      final response = await apiClient.post(
        '/teachers',
        data: request.toJson(),
      );
      final json = response.data['data'];
      return TeacherModel(
        id: json['id'] as int? ?? 1,
        organizationId: json['organization_id'] as int? ?? 1,
        branchId: json['branch_id'] as int? ?? 1,
        employeeNo: json['employee_no'] as String? ?? '',
        name: json['name'] as String? ?? '',
        designation: json['designation'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        joinDate: DateTime.now(),
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateTeacher(int id, CreateTeacherRequest request) async {
    try {
      await apiClient.put('/teachers/$id', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteTeacher(int id) async {
    try {
      await apiClient.delete('/teachers/$id');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
