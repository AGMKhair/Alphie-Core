import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/exam_model.dart';

abstract class ExamRepository {
  Future<List<ExamModel>> getExams({required int organizationId, int? branchId});
  Future<ExamModel> createExam(CreateExamRequest request);
  Future<List<ExamSubjectScheduleModel>> getExamSchedules(int examId);
  Future<List<StudentMarkEntryModel>> getMarksForSchedule({required int examScheduleId, required int groupId});
  Future<void> saveMarks(SaveMarksRequest request);
}

class ExamRepositoryImpl implements ExamRepository {
  final Dio apiClient;

  ExamRepositoryImpl({required this.apiClient});

  @override
  Future<List<ExamModel>> getExams({required int organizationId, int? branchId}) async {
    try {
      final response = await apiClient.get('/exams', queryParameters: {
        if (branchId != null) 'branch_id': branchId,
      });
      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          final schedules = (json['schedules'] as List<dynamic>?)?.map((s) {
            return ExamSubjectScheduleModel(
              id: s['id'] as int? ?? 1,
              examId: s['exam_id'] as int? ?? (json['id'] as int? ?? 1),
              programId: s['program_id'] as int? ?? 1,
              programName: s['program']?['name'] as String? ?? 'Program',
              subjectId: s['subject_id'] as int? ?? 1,
              subjectName: s['subject']?['name'] as String? ?? 'Subject',
              examDate: DateTime.tryParse(s['exam_date']?.toString() ?? '') ?? DateTime.now(),
              startTime: s['start_time'] as String? ?? '10:00 AM',
              endTime: s['end_time'] as String? ?? '01:00 PM',
              fullMarks: (s['full_marks'] as num?)?.toDouble() ?? 100.0,
              passMarks: (s['pass_marks'] as num?)?.toDouble() ?? 33.0,
            );
          }).toList() ?? [];

          return ExamModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? organizationId,
            branchId: json['branch_id'] as int? ?? (branchId ?? 1),
            title: json['title'] as String? ?? '',
            code: json['code'] as String? ?? '',
            type: json['type'] as String? ?? 'term',
            startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
            endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
            status: json['status'] as String? ?? 'upcoming',
            schedules: schedules,
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
  Future<ExamModel> createExam(CreateExamRequest request) async {
    try {
      final response = await apiClient.post('/exams', data: request.toJson());
      final json = response.data['data'];
      return ExamModel(
        id: json['id'] as int? ?? 1,
        organizationId: json['organization_id'] as int? ?? request.organizationId,
        branchId: json['branch_id'] as int? ?? request.branchId,
        title: json['title'] as String? ?? request.title,
        code: json['code'] as String? ?? request.code,
        type: json['type'] as String? ?? request.type,
        startDate: request.startDate,
        endDate: request.endDate,
        status: json['status'] as String? ?? 'upcoming',
        schedules: [],
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<ExamSubjectScheduleModel>> getExamSchedules(int examId) async {
    try {
      final exams = await getExams(organizationId: 1);
      final exam = exams.firstWhere(
        (e) => e.id == examId,
        orElse: () => throw const ServerFailure('Exam not found'),
      );
      return exam.schedules;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<StudentMarkEntryModel>> getMarksForSchedule({
    required int examScheduleId,
    required int groupId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        StudentMarkEntryModel(
          studentId: 1,
          studentName: 'Ayman Sadik',
          rollNo: '01',
          studentNo: 'STD-2026-001',
          marksObtained: 92.0,
          grade: 'A+',
          gpa: 5.0,
          remark: 'Outstanding',
        ),
        StudentMarkEntryModel(
          studentId: 2,
          studentName: 'Sumaiya Khan',
          rollNo: '02',
          studentNo: 'STD-2026-002',
          marksObtained: 88.0,
          grade: 'A+',
          gpa: 5.0,
          remark: 'Excellent',
        ),
      ];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> saveMarks(SaveMarksRequest request) async {
    try {
      await apiClient.post('/exams/save-marks', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
