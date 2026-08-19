class ExamModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int? academicYearId;
  final String title; // 1st Term Exam 2026, Model Test 01, Weekly Assessment
  final String code;
  final String type; // term, class_test, model_test, final
  final DateTime startDate;
  final DateTime endDate;
  final String status; // upcoming, ongoing, published, completed
  final List<ExamSubjectScheduleModel> schedules;

  ExamModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    this.academicYearId,
    required this.title,
    required this.code,
    this.type = 'term',
    required this.startDate,
    required this.endDate,
    this.status = 'upcoming',
    this.schedules = const [],
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      academicYearId: json['academic_year_id'] as int?,
      title: json['title'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'term',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      status: json['status'] as String? ?? 'upcoming',
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((e) => ExamSubjectScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'academic_year_id': academicYearId,
      'title': title,
      'code': code,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }
}

class ExamSubjectScheduleModel {
  final int id;
  final int examId;
  final int programId;
  final String programName;
  final int subjectId;
  final String subjectName;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final double fullMarks;
  final double passMarks;

  ExamSubjectScheduleModel({
    required this.id,
    required this.examId,
    required this.programId,
    required this.programName,
    required this.subjectId,
    required this.subjectName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    this.fullMarks = 100.0,
    this.passMarks = 33.0,
  });

  factory ExamSubjectScheduleModel.fromJson(Map<String, dynamic> json) {
    return ExamSubjectScheduleModel(
      id: json['id'] as int,
      examId: json['exam_id'] as int,
      programId: json['program_id'] as int,
      programName: json['program_name'] as String? ?? '',
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String? ?? '',
      examDate: DateTime.tryParse(json['exam_date'] ?? '') ?? DateTime.now(),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      fullMarks: (json['full_marks'] as num?)?.toDouble() ?? 100.0,
      passMarks: (json['pass_marks'] as num?)?.toDouble() ?? 33.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'program_id': programId,
      'program_name': programName,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'exam_date': examDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'full_marks': fullMarks,
      'pass_marks': passMarks,
    };
  }
}

class StudentMarkEntryModel {
  final int studentId;
  final String studentName;
  final String rollNo;
  final String studentNo;
  final double? marksObtained;
  final String? grade;
  final double? gpa;
  final String? remark;

  StudentMarkEntryModel({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.studentNo,
    this.marksObtained,
    this.grade,
    this.gpa,
    this.remark,
  });

  factory StudentMarkEntryModel.fromJson(Map<String, dynamic> json) {
    return StudentMarkEntryModel(
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      studentNo: json['student_no'] as String? ?? '',
      marksObtained: (json['marks_obtained'] as num?)?.toDouble(),
      grade: json['grade'] as String?,
      gpa: (json['gpa'] as num?)?.toDouble(),
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'roll_no': rollNo,
      'student_no': studentNo,
      'marks_obtained': marksObtained,
      'grade': grade,
      'gpa': gpa,
      'remark': remark,
    };
  }

  StudentMarkEntryModel copyWith({
    int? studentId,
    String? studentName,
    String? rollNo,
    String? studentNo,
    double? marksObtained,
    String? grade,
    double? gpa,
    String? remark,
  }) {
    return StudentMarkEntryModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      studentNo: studentNo ?? this.studentNo,
      marksObtained: marksObtained ?? this.marksObtained,
      grade: grade ?? this.grade,
      gpa: gpa ?? this.gpa,
      remark: remark ?? this.remark,
    );
  }
}

class CreateExamRequest {
  final int organizationId;
  final int? branchId;
  final int? academicYearId;
  final String title;
  final String code;
  final String type;
  final DateTime startDate;
  final DateTime endDate;

  CreateExamRequest({
    required this.organizationId,
    this.branchId,
    this.academicYearId,
    required this.title,
    required this.code,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'academic_year_id': academicYearId,
      'title': title,
      'code': code,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

class SaveMarksRequest {
  final int examScheduleId;
  final List<StudentMarkEntryModel> entries;

  SaveMarksRequest({
    required this.examScheduleId,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'exam_schedule_id': examScheduleId,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
