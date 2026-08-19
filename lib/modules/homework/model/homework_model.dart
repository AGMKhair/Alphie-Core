class HomeworkModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int groupId;
  final String groupName;
  final int subjectId;
  final String subjectName;
  final int? teacherId;
  final String? teacherName;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String? attachmentUrl;
  final int totalSubmissions;
  final int totalStudents;
  final String status; // active, closed

  HomeworkModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    required this.groupId,
    required this.groupName,
    required this.subjectId,
    required this.subjectName,
    this.teacherId,
    this.teacherName,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    this.attachmentUrl,
    this.totalSubmissions = 0,
    this.totalStudents = 0,
    this.status = 'active',
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      groupId: json['group_id'] as int,
      groupName: json['group_name'] as String? ?? '',
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String? ?? '',
      teacherId: json['teacher_id'] as int?,
      teacherName: json['teacher_name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      assignedDate: DateTime.tryParse(json['assigned_date'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      attachmentUrl: json['attachment_url'] as String?,
      totalSubmissions: json['total_submissions'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
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
      'title': title,
      'description': description,
      'assigned_date': assignedDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'attachment_url': attachmentUrl,
      'total_submissions': totalSubmissions,
      'total_students': totalStudents,
      'status': status,
    };
  }
}

class HomeworkSubmissionModel {
  final int id;
  final int homeworkId;
  final int studentId;
  final String studentName;
  final String rollNo;
  final String studentNo;
  final DateTime submittedAt;
  final String? submissionText;
  final String? fileUrl;
  final double? marksObtained;
  final String? feedback;
  final String status; // submitted, evaluated, resubmit

  HomeworkSubmissionModel({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.studentNo,
    required this.submittedAt,
    this.submissionText,
    this.fileUrl,
    this.marksObtained,
    this.feedback,
    this.status = 'submitted',
  });

  factory HomeworkSubmissionModel.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmissionModel(
      id: json['id'] as int,
      homeworkId: json['homework_id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      studentNo: json['student_no'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submitted_at'] ?? '') ?? DateTime.now(),
      submissionText: json['submission_text'] as String?,
      fileUrl: json['file_url'] as String?,
      marksObtained: (json['marks_obtained'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      status: json['status'] as String? ?? 'submitted',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homework_id': homeworkId,
      'student_id': studentId,
      'student_name': studentName,
      'roll_no': rollNo,
      'student_no': studentNo,
      'submitted_at': submittedAt.toIso8601String(),
      'submission_text': submissionText,
      'file_url': fileUrl,
      'marks_obtained': marksObtained,
      'feedback': feedback,
      'status': status,
    };
  }
}

class CreateHomeworkRequest {
  final int organizationId;
  final int? branchId;
  final int groupId;
  final int subjectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? attachmentUrl;

  CreateHomeworkRequest({
    required this.organizationId,
    this.branchId,
    required this.groupId,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachmentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'group_id': groupId,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'attachment_url': attachmentUrl,
    };
  }
}

class GradeSubmissionRequest {
  final int submissionId;
  final double marksObtained;
  final String? feedback;

  GradeSubmissionRequest({
    required this.submissionId,
    required this.marksObtained,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'marks_obtained': marksObtained,
      'feedback': feedback,
    };
  }
}
