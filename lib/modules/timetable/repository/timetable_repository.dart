import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/timetable_model.dart';

abstract class TimetableRepository {
  Future<List<TimetableSlotModel>> getTimetable({
    required int organizationId,
    int? branchId,
    int? groupId,
    String? dayOfWeek,
    int? teacherId,
  });
  Future<TimetableSlotModel> createSlot(CreateTimetableSlotRequest request);
  Future<void> deleteSlot(int id);
}

class TimetableRepositoryImpl implements TimetableRepository {
  final Dio apiClient;

  TimetableRepositoryImpl({required this.apiClient});

  @override
  Future<List<TimetableSlotModel>> getTimetable({
    required int organizationId,
    int? branchId,
    int? groupId,
    String? dayOfWeek,
    int? teacherId,
  }) async {
    try {
      final response = await apiClient.get('/timetable', queryParameters: {
        if (groupId != null) 'group_id': groupId,
        if (dayOfWeek != null) 'day_of_week': dayOfWeek,
        if (teacherId != null) 'teacher_id': teacherId,
      });
      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((json) {
          return TimetableSlotModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? organizationId,
            branchId: json['branch_id'] as int? ?? (branchId ?? 1),
            groupId: json['group_id'] as int? ?? (groupId ?? 1),
            groupName: json['group']?['name'] as String? ?? 'Section A',
            subjectId: json['subject_id'] as int? ?? 1,
            subjectName: json['subject']?['name'] as String? ?? 'Subject',
            teacherId: json['teacher_id'] as int? ?? 1,
            teacherName: json['teacher']?['name'] as String? ?? 'Teacher',
            dayOfWeek: json['day_of_week'] as String? ?? 'Monday',
            startTime: json['start_time'] as String? ?? '09:00 AM',
            endTime: json['end_time'] as String? ?? '09:45 AM',
            roomNo: json['room_no'] as String? ?? 'Room 101',
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
  Future<TimetableSlotModel> createSlot(CreateTimetableSlotRequest request) async {
    try {
      final response = await apiClient.post('/timetable', data: request.toJson());
      final json = response.data['data'];
      return TimetableSlotModel(
        id: json['id'] as int? ?? 1,
        organizationId: request.organizationId,
        branchId: request.branchId,
        groupId: request.groupId,
        groupName: 'Batch',
        subjectId: request.subjectId,
        subjectName: 'Subject',
        teacherId: request.teacherId,
        teacherName: 'Teacher',
        dayOfWeek: request.dayOfWeek,
        startTime: request.startTime,
        endTime: request.endTime,
        roomNo: request.roomNo,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteSlot(int id) async {
    try {
      await apiClient.delete('/timetable/$id');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
