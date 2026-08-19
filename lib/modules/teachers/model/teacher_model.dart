class TeacherModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int? userId;
  final String employeeNo; // EMP-101
  final String name;
  final String designation; // Senior Lecturer, Headmaster, Lead Instructor
  final String? qualification; // M.Sc in Physics, B.Sc in CSE
  final String? specialization; // Higher Math, Quantum Physics, Mobile Dev
  final String? phone;
  final String? email;
  final DateTime? joinDate;
  final String status; // active, on_leave, resigned
  final List<String> assignedSubjects;

  TeacherModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    this.userId,
    required this.employeeNo,
    required this.name,
    required this.designation,
    this.qualification,
    this.specialization,
    this.phone,
    this.email,
    this.joinDate,
    this.status = 'active',
    this.assignedSubjects = const [],
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      userId: json['user_id'] as int?,
      employeeNo: json['employee_no'] as String? ?? '',
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? 'Teacher',
      qualification: json['qualification'] as String?,
      specialization: json['specialization'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      joinDate: json['join_date'] != null ? DateTime.tryParse(json['join_date']) : null,
      status: json['status'] as String? ?? 'active',
      assignedSubjects: (json['assigned_subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'user_id': userId,
      'employee_no': employeeNo,
      'name': name,
      'designation': designation,
      'qualification': qualification,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'join_date': joinDate?.toIso8601String(),
      'status': status,
      'assigned_subjects': assignedSubjects,
    };
  }
}

class CreateTeacherRequest {
  final int organizationId;
  final int? branchId;
  final String employeeNo;
  final String name;
  final String designation;
  final String? qualification;
  final String? specialization;
  final String? phone;
  final String? email;
  final List<String> assignedSubjects;

  CreateTeacherRequest({
    required this.organizationId,
    this.branchId,
    required this.employeeNo,
    required this.name,
    required this.designation,
    this.qualification,
    this.specialization,
    this.phone,
    this.email,
    this.assignedSubjects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'employee_no': employeeNo,
      'name': name,
      'designation': designation,
      'qualification': qualification,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'assigned_subjects': assignedSubjects,
    };
  }
}
