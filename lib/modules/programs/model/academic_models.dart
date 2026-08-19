class AcademicYearModel {
  final int id;
  final int organizationId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final String status;

  AcademicYearModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.status = 'active',
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now().add(const Duration(days: 365)),
      isCurrent: json['is_current'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_current': isCurrent,
      'status': status,
    };
  }
}

class ProgramModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final int? academicYearId;
  final String name; // Class 6, HSC Physics, Flutter Course
  final String code;
  final String type; // school, coaching, training_center
  final String? description;
  final String? duration;
  final String status;
  final List<GroupModel> groups;
  final List<SubjectModel> subjects;

  ProgramModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    this.academicYearId,
    required this.name,
    required this.code,
    required this.type,
    this.description,
    this.duration,
    this.status = 'active',
    this.groups = const [],
    this.subjects = const [],
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      academicYearId: json['academic_year_id'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'school',
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      status: json['status'] as String? ?? 'active',
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
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
      'name': name,
      'code': code,
      'type': type,
      'description': description,
      'duration': duration,
      'status': status,
      'groups': groups.map((g) => g.toJson()).toList(),
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
  }

  ProgramModel copyWith({
    int? id,
    int? organizationId,
    int? branchId,
    int? academicYearId,
    String? name,
    String? code,
    String? type,
    String? description,
    String? duration,
    String? status,
    List<GroupModel>? groups,
    List<SubjectModel>? subjects,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      groups: groups ?? this.groups,
      subjects: subjects ?? this.subjects,
    );
  }
}

class GroupModel {
  final int id;
  final int organizationId;
  final int programId;
  final String name; // Section A, Morning Batch, Batch 01
  final String code;
  final int capacity;
  final String? roomName;
  final String status;

  GroupModel({
    required this.id,
    required this.organizationId,
    required this.programId,
    required this.name,
    required this.code,
    this.capacity = 40,
    this.roomName,
    this.status = 'active',
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      programId: json['program_id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 40,
      roomName: json['room_name'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'program_id': programId,
      'name': name,
      'code': code,
      'capacity': capacity,
      'room_name': roomName,
      'status': status,
    };
  }
}

class SubjectModel {
  final int id;
  final int organizationId;
  final String name; // Mathematics, Physics, Flutter UI
  final String code;
  final String type; // theory, practical, optional
  final String status;

  SubjectModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.type = 'theory',
    this.status = 'active',
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'theory',
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'code': code,
      'type': type,
      'status': status,
    };
  }
}

class ProgramRequest {
  final int organizationId;
  final int? branchId;
  final int? academicYearId;
  final String name;
  final String code;
  final String type;
  final String? description;

  ProgramRequest({
    required this.organizationId,
    this.branchId,
    this.academicYearId,
    required this.name,
    required this.code,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'academic_year_id': academicYearId,
      'name': name,
      'code': code,
      'type': type,
      'description': description,
    };
  }
}

class GroupRequest {
  final int organizationId;
  final int programId;
  final String name;
  final String code;
  final int capacity;
  final String? roomName;

  GroupRequest({
    required this.organizationId,
    required this.programId,
    required this.name,
    required this.code,
    this.capacity = 40,
    this.roomName,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'program_id': programId,
      'name': name,
      'code': code,
      'capacity': capacity,
      'room_name': roomName,
    };
  }
}
