class StudentModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int? userId;
  final String studentNo; // Unique ID (e.g. STD-2026-001)
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String gender; // male, female, other
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final String? address;
  final String? bloodGroup;
  final String? photo;
  final DateTime? admissionDate;
  final String status; // active, inactive, graduated, suspended
  final EnrollmentModel? currentEnrollment;
  final List<GuardianModel> guardians;

  StudentModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    this.userId,
    required this.studentNo,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.address,
    this.bloodGroup,
    this.photo,
    this.admissionDate,
    this.status = 'active',
    this.currentEnrollment,
    this.guardians = const [],
  });

  String get fullName => '$firstName $lastName';

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      userId: json['user_id'] as int?,
      studentNo: json['student_no'] as String? ?? '',
      admissionNo: json['admission_no'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      gender: json['gender'] as String? ?? 'male',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth']) : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      bloodGroup: json['blood_group'] as String?,
      photo: json['photo'] as String?,
      admissionDate: json['admission_date'] != null ? DateTime.tryParse(json['admission_date']) : null,
      status: json['status'] as String? ?? 'active',
      currentEnrollment: json['current_enrollment'] != null
          ? EnrollmentModel.fromJson(json['current_enrollment'] as Map<String, dynamic>)
          : null,
      guardians: (json['guardians'] as List<dynamic>?)
              ?.map((e) => GuardianModel.fromJson(e as Map<String, dynamic>))
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
      'student_no': studentNo,
      'admission_no': admissionNo,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone': phone,
      'email': email,
      'address': address,
      'blood_group': bloodGroup,
      'photo': photo,
      'admission_date': admissionDate?.toIso8601String(),
      'status': status,
      'current_enrollment': currentEnrollment?.toJson(),
      'guardians': guardians.map((g) => g.toJson()).toList(),
    };
  }
}

class GuardianModel {
  final int id;
  final int organizationId;
  final String name;
  final String phone;
  final String? email;
  final String? occupation;
  final String? relationship; // Father, Mother, Legal Guardian
  final bool isPrimary;

  GuardianModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.phone,
    this.email,
    this.occupation,
    this.relationship = 'Father',
    this.isPrimary = true,
  });

  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      occupation: json['occupation'] as String?,
      relationship: json['relationship'] as String? ?? 'Father',
      isPrimary: json['is_primary'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'phone': phone,
      'email': email,
      'occupation': occupation,
      'relationship': relationship,
      'is_primary': isPrimary,
    };
  }
}

class EnrollmentModel {
  final int id;
  final int organizationId;
  final int studentId;
  final int groupId;
  final String? programName;
  final String? groupName;
  final String? rollNo;
  final DateTime enrollmentDate;
  final String status;

  EnrollmentModel({
    required this.id,
    required this.organizationId,
    required this.studentId,
    required this.groupId,
    this.programName,
    this.groupName,
    this.rollNo,
    required this.enrollmentDate,
    this.status = 'active',
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      studentId: json['student_id'] as int,
      groupId: json['group_id'] as int,
      programName: json['program_name'] as String?,
      groupName: json['group_name'] as String?,
      rollNo: json['roll_no'] as String?,
      enrollmentDate: DateTime.tryParse(json['enrollment_date'] ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'student_id': studentId,
      'group_id': groupId,
      'program_name': programName,
      'group_name': groupName,
      'roll_no': rollNo,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'status': status,
    };
  }
}

class CreateStudentRequest {
  final int organizationId;
  final int? branchId;
  final String firstName;
  final String lastName;
  final String gender;
  final String? phone;
  final String? email;
  final String? bloodGroup;
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianRelationship;
  final int? groupId;
  final String? rollNo;

  CreateStudentRequest({
    required this.organizationId,
    this.branchId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.phone,
    this.email,
    this.bloodGroup,
    this.guardianName,
    this.guardianPhone,
    this.guardianRelationship,
    this.groupId,
    this.rollNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'phone': phone,
      'email': email,
      'blood_group': bloodGroup,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'guardian_relationship': guardianRelationship,
      'group_id': groupId,
      'roll_no': rollNo,
    };
  }
}
