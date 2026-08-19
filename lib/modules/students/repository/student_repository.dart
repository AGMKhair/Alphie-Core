import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/student_model.dart';

abstract class StudentRepository {
  Future<List<StudentModel>> getStudents({
    required int organizationId,
    int? branchId,
    int? groupId,
    String? search,
    int page = 1,
  });
  Future<StudentModel> getStudentById(int id);
  Future<StudentModel> createStudent(CreateStudentRequest request);
  Future<void> updateStudent(int id, CreateStudentRequest request);
  Future<void> deleteStudent(int id);
}

class StudentRepositoryImpl implements StudentRepository {
  final Dio apiClient;

  StudentRepositoryImpl({required this.apiClient});

  @override
  Future<List<StudentModel>> getStudents({
    required int organizationId,
    int? branchId,
    int? groupId,
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await apiClient.get(
        '/students',
        queryParameters: {
          if (branchId != null) 'branch_id': branchId,
          if (groupId != null) 'group_id': groupId,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
        },
      );

      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((json) {
          final guardiansList = (json['guardians'] as List<dynamic>?)?.map((g) {
            return GuardianModel(
              id: g['id'] as int? ?? 1,
              organizationId: json['organization_id'] as int? ?? organizationId,
              name: g['name'] as String? ?? 'Guardian',
              relationship: g['relationship'] as String? ?? 'Parent',
              phone: g['phone'] as String? ?? '',
            );
          }).toList() ?? [];

          final enrollmentJson = json['current_enrollment'];
          final enrollment = enrollmentJson != null
              ? EnrollmentModel(
                  id: enrollmentJson['id'] as int? ?? 1,
                  organizationId: json['organization_id'] as int? ?? organizationId,
                  studentId: json['id'] as int? ?? 1,
                  groupId: enrollmentJson['group_id'] as int? ?? 1,
                  rollNo: enrollmentJson['roll_no'] as String? ?? '01',
                  enrollmentDate: DateTime.tryParse(enrollmentJson['created_at'] ?? '') ?? DateTime.now(),
                  groupName: 'Class 6 (Section A)',
                )
              : null;

          return StudentModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? 1,
            branchId: json['branch_id'] as int? ?? 1,
            studentNo: json['student_no'] as String? ?? '',
            admissionNo: json['admission_no'] as String? ?? '',
            firstName: json['first_name'] as String? ?? '',
            lastName: json['last_name'] as String? ?? '',
            gender: json['gender'] as String? ?? 'male',
            phone: json['phone'] as String?,
            email: json['email'] as String?,
            bloodGroup: json['blood_group'] as String?,
            status: json['status'] as String? ?? 'active',
            currentEnrollment: enrollment,
            guardians: guardiansList,
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
  Future<StudentModel> getStudentById(int id) async {
    try {
      final response = await apiClient.get('/students/$id');
      return StudentModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<StudentModel> createStudent(CreateStudentRequest request) async {
    try {
      final response = await apiClient.post(
        '/students',
        data: request.toJson(),
      );
      final json = response.data['data'];
      return StudentModel(
        id: json['id'] as int? ?? 1,
        organizationId: json['organization_id'] as int? ?? 1,
        branchId: json['branch_id'] as int? ?? 1,
        studentNo: json['student_no'] as String? ?? '',
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        gender: json['gender'] as String? ?? 'male',
        status: json['status'] as String? ?? 'active',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateStudent(int id, CreateStudentRequest request) async {
    try {
      await apiClient.put('/students/$id', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteStudent(int id) async {
    try {
      await apiClient.delete('/students/$id');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
