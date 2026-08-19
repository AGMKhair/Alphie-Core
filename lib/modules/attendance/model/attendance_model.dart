class AttendanceRecordModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int studentId;
  final int groupId;
  final String studentName;
  final String rollNo;
  final String studentNo;
  final DateTime date;
  final String status; // present, absent, late, half_day, leave
  final String? remark;

  AttendanceRecordModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    required this.studentId,
    required this.groupId,
    required this.studentName,
    required this.rollNo,
    required this.studentNo,
    required this.date,
    required this.status,
    this.remark,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      studentId: json['student_id'] as int,
      groupId: json['group_id'] as int,
      studentName: json['student_name'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      studentNo: json['student_no'] as String? ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'present',
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'student_id': studentId,
      'group_id': groupId,
      'student_name': studentName,
      'roll_no': rollNo,
      'student_no': studentNo,
      'date': date.toIso8601String(),
      'status': status,
      'remark': remark,
    };
  }

  AttendanceRecordModel copyWith({
    int? id,
    int? organizationId,
    int? branchId,
    int? studentId,
    int? groupId,
    String? studentName,
    String? rollNo,
    String? studentNo,
    DateTime? date,
    String? status,
    String? remark,
  }) {
    return AttendanceRecordModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      studentId: studentId ?? this.studentId,
      groupId: groupId ?? this.groupId,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      studentNo: studentNo ?? this.studentNo,
      date: date ?? this.date,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }
}

class AttendanceSummaryModel {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;
  final double percentage;

  AttendanceSummaryModel({
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.percentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      totalStudents: json['total_students'] as int? ?? 0,
      presentCount: json['present_count'] as int? ?? 0,
      absentCount: json['absent_count'] as int? ?? 0,
      lateCount: json['late_count'] as int? ?? 0,
      leaveCount: json['leave_count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SaveAttendanceRequest {
  final int organizationId;
  final int? branchId;
  final int groupId;
  final DateTime date;
  final List<AttendanceEntry> entries;

  SaveAttendanceRequest({
    required this.organizationId,
    this.branchId,
    required this.groupId,
    required this.date,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'group_id': groupId,
      'date': date.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceEntry {
  final int studentId;
  final String status; // present, absent, late, leave
  final String? remark;

  AttendanceEntry({
    required this.studentId,
    required this.status,
    this.remark,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status,
      'remark': remark,
    };
  }
}
