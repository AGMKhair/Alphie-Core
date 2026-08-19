import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/homework_model.dart';

abstract class HomeworkRepository {
  Future<List<HomeworkModel>> getHomeworkList({
    required int organizationId,
    int? branchId,
    int? groupId,
    int? subjectId,
  });
  Future<HomeworkModel> createHomework(CreateHomeworkRequest request);
  Future<List<HomeworkSubmissionModel>> getSubmissions(int homeworkId);
  Future<void> gradeSubmission(GradeSubmissionRequest request);
}

class HomeworkRepositoryImpl implements HomeworkRepository {
  final Dio apiClient;

  HomeworkRepositoryImpl({required this.apiClient});

  @override
  Future<List<HomeworkModel>> getHomeworkList({
    required int organizationId,
    int? branchId,
    int? groupId,
    int? subjectId,
  }) async {
    try {
      final response = await apiClient.get('/homework', queryParameters: {
        if (groupId != null) 'group_id': groupId,
      });
      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          return HomeworkModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? organizationId,
            branchId: json['branch_id'] as int? ?? (branchId ?? 1),
            groupId: json['group_id'] as int? ?? (groupId ?? 1),
            groupName: json['group']?['name'] as String? ?? 'Section A',
            subjectId: json['subject_id'] as int? ?? (subjectId ?? 1),
            subjectName: json['subject']?['name'] as String? ?? 'General Mathematics',
            teacherName: json['teacher']?['name'] as String? ?? 'Faculty Instructor',
            title: json['title'] as String? ?? '',
            description: json['description'] as String? ?? '',
            assignedDate: DateTime.tryParse(json['assigned_date']?.toString() ?? '') ?? DateTime.now(),
            dueDate: DateTime.tryParse(json['due_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 3)),
            totalSubmissions: (json['submissions_count'] as num?)?.toInt() ?? 0,
            totalStudents: 40,
            attachmentUrl: json['attachment_url'] as String?,
            status: json['status'] as String? ?? 'active',
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
  Future<HomeworkModel> createHomework(CreateHomeworkRequest request) async {
    try {
      final response = await apiClient.post('/homework', data: request.toJson());
      final json = response.data['data'];
      return HomeworkModel(
        id: json['id'] as int? ?? 1,
        organizationId: request.organizationId,
        branchId: request.branchId,
        groupId: request.groupId,
        groupName: 'Assigned Batch',
        subjectId: request.subjectId,
        subjectName: 'Assigned Subject',
        teacherName: 'Faculty Teacher',
        title: json['title'] as String? ?? request.title,
        description: json['description'] as String? ?? request.description,
        assignedDate: DateTime.now(),
        dueDate: request.dueDate,
        totalSubmissions: 0,
        totalStudents: 40,
        status: 'active',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<HomeworkSubmissionModel>> getSubmissions(int homeworkId) async {
    try {
      final response = await apiClient.get('/homework/$homeworkId/submissions');
      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          return HomeworkSubmissionModel(
            id: json['id'] as int? ?? 1,
            homeworkId: json['homework_id'] as int? ?? homeworkId,
            studentId: json['student_id'] as int? ?? 1,
            studentName: json['student']?['first_name'] != null ? '${json['student']['first_name']} ${json['student']['last_name'] ?? ""}' : 'Student',
            rollNo: '01',
            studentNo: 'STD-2026-001',
            submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
            submissionText: json['submission_text'] as String?,
            fileUrl: json['file_url'] as String?,
            marksObtained: (json['marks_obtained'] as num?)?.toDouble(),
            feedback: json['feedback'] as String?,
            status: json['status'] as String? ?? 'submitted',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> gradeSubmission(GradeSubmissionRequest request) async {
    try {
      await apiClient.post('/homework/grade-submission', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
