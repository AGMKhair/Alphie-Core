class TimetableSlotModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int groupId;
  final String groupName;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String dayOfWeek; // Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
  final String startTime; // 09:00 AM / 09:00
  final String endTime; // 09:45 AM / 09:45
  final String? roomNo; // Room 201, Lab 03
  final String status;

  TimetableSlotModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    required this.groupId,
    required this.groupName,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNo,
    this.status = 'active',
  });

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      groupId: json['group_id'] as int,
      groupName: json['group_name'] as String? ?? '',
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String? ?? '',
      teacherId: json['teacher_id'] as int,
      teacherName: json['teacher_name'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? 'Monday',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      roomNo: json['room_no'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'group_id': groupId,
      'group_name': groupName,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room_no': roomNo,
      'status': status,
    };
  }
}

class CreateTimetableSlotRequest {
  final int organizationId;
  final int? branchId;
  final int groupId;
  final int subjectId;
  final int teacherId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? roomNo;

  CreateTimetableSlotRequest({
    required this.organizationId,
    this.branchId,
    required this.groupId,
    required this.subjectId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'group_id': groupId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room_no': roomNo,
    };
  }
}
