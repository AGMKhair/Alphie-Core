import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/academic_models.dart';

abstract class AcademicRepository {
  Future<List<AcademicYearModel>> getAcademicYears(int organizationId);
  Future<List<ProgramModel>> getPrograms({required int organizationId, int? branchId, int? academicYearId});
  Future<ProgramModel> createProgram(ProgramRequest request);
  Future<GroupModel> createGroup(GroupRequest request);
  Future<List<SubjectModel>> getSubjects(int organizationId);
}

class AcademicRepositoryImpl implements AcademicRepository {
  final Dio apiClient;

  AcademicRepositoryImpl({required this.apiClient});

  @override
  Future<List<AcademicYearModel>> getAcademicYears(int organizationId) async {
    try {
      return [
        AcademicYearModel(
          id: 1,
          organizationId: organizationId,
          name: 'Academic Year 2026',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
          isCurrent: true,
        ),
      ];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<ProgramModel>> getPrograms({required int organizationId, int? branchId, int? academicYearId}) async {
    try {
      final response = await apiClient.get('/academic/programs');
      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          final groups = (json['groups'] as List<dynamic>?)?.map((g) {
            return GroupModel(
              id: g['id'] as int? ?? 1,
              organizationId: g['organization_id'] as int? ?? organizationId,
              programId: g['program_id'] as int? ?? (json['id'] as int? ?? 1),
              name: g['name'] as String? ?? 'Section A',
              code: g['code'] as String? ?? 'SEC-A',
              capacity: g['capacity'] as int? ?? 40,
              status: g['status'] as String? ?? 'active',
            );
          }).toList() ?? [];

          final subjects = (json['subjects'] as List<dynamic>?)?.map((s) {
            return SubjectModel(
              id: s['id'] as int? ?? 1,
              organizationId: s['organization_id'] as int? ?? organizationId,
              name: s['name'] as String? ?? 'General Mathematics',
              code: s['code'] as String? ?? 'MATH-01',
              type: s['type'] as String? ?? 'theory',
            );
          }).toList() ?? [];

          return ProgramModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? organizationId,
            branchId: json['branch_id'] as int? ?? branchId,
            academicYearId: academicYearId ?? 1,
            name: json['name'] as String? ?? '',
            code: json['code'] as String? ?? '',
            type: 'school',
            description: json['description'] as String?,
            status: json['status'] as String? ?? 'active',
            groups: groups,
            subjects: subjects,
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
  Future<ProgramModel> createProgram(ProgramRequest request) async {
    try {
      final response = await apiClient.post('/academic/programs', data: request.toJson());
      final json = response.data['data'];
      return ProgramModel(
        id: json['id'] as int? ?? 1,
        organizationId: request.organizationId,
        branchId: request.branchId,
        academicYearId: request.academicYearId,
        name: json['name'] as String? ?? request.name,
        code: json['code'] as String? ?? request.code,
        type: request.type,
        description: request.description,
        status: 'active',
        groups: [],
        subjects: [],
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<GroupModel> createGroup(GroupRequest request) async {
    try {
      final response = await apiClient.post('/academic/groups', data: request.toJson());
      final json = response.data['data'];
      return GroupModel(
        id: json['id'] as int? ?? 1,
        organizationId: request.organizationId,
        programId: request.programId,
        name: json['name'] as String? ?? request.name,
        code: json['code'] as String? ?? request.code,
        capacity: request.capacity,
        status: 'active',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects(int organizationId) async {
    try {
      final programs = await getPrograms(organizationId: organizationId);
      return programs.expand((p) => p.subjects).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
