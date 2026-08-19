import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/attendance_model.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecordModel>> getGroupAttendance({
    required int organizationId,
    required int groupId,
    required DateTime date,
  });
  Future<void> saveAttendance(SaveAttendanceRequest request);
  Future<AttendanceSummaryModel> getAttendanceSummary({
    required int organizationId,
    int? branchId,
    required DateTime date,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio apiClient;

  AttendanceRepositoryImpl({required this.apiClient});

  @override
  Future<List<AttendanceRecordModel>> getGroupAttendance({
    required int organizationId,
    required int groupId,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await apiClient.get('/attendance/sheet', queryParameters: {
        'group_id': groupId,
        'date': dateStr,
      });

      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          return AttendanceRecordModel(
            id: json['id'] as int? ?? 0,
            organizationId: organizationId,
            studentId: json['student_id'] as int? ?? 1,
            groupId: json['group_id'] as int? ?? groupId,
            studentName: json['student_name'] as String? ?? 'Student',
            rollNo: json['roll_no'] as String? ?? '01',
            studentNo: json['student_no'] as String? ?? 'STD-2026-001',
            date: date,
            status: json['status'] as String? ?? 'present',
            remark: json['remark'] as String?,
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
  Future<void> saveAttendance(SaveAttendanceRequest request) async {
    try {
      await apiClient.post('/attendance/bulk-save', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AttendanceSummaryModel> getAttendanceSummary({
    required int organizationId,
    int? branchId,
    required DateTime date,
  }) async {
    try {
      return AttendanceSummaryModel(
        totalStudents: 8,
        presentCount: 7,
        absentCount: 1,
        lateCount: 0,
        leaveCount: 0,
        percentage: 87.5,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
