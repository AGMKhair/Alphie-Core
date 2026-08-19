class RoleModel {
  final int id;
  final String name;
  final String slug;
  final String scope; // system, organization, branch
  final String? description;
  final List<PermissionModel> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    this.scope = 'organization',
    this.description,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      scope: json['scope'] as String? ?? 'organization',
      description: json['description'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'scope': scope,
      'description': description,
      'permissions': permissions.map((p) => p.toJson()).toList(),
    };
  }
}

class PermissionModel {
  final int id;
  final String name;
  final String slug;
  final String module; // student, teacher, attendance, exam, fee, setting

  PermissionModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.module,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      module: json['module'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'module': module,
    };
  }
}

class OrganizationUserModel {
  final int id;
  final int organizationId;
  final int userId;
  final int roleId;
  final int? branchId;
  final String name;
  final String email;
  final String? phone;
  final String roleName;
  final String roleSlug;
  final String? branchName;
  final String status; // active, inactive, invited
  final DateTime? joinedAt;

  OrganizationUserModel({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.roleId,
    this.branchId,
    required this.name,
    required this.email,
    this.phone,
    required this.roleName,
    required this.roleSlug,
    this.branchName,
    this.status = 'active',
    this.joinedAt,
  });

  factory OrganizationUserModel.fromJson(Map<String, dynamic> json) {
    return OrganizationUserModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      userId: json['user_id'] as int,
      roleId: json['role_id'] as int,
      branchId: json['branch_id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      roleName: json['role_name'] as String? ?? 'Member',
      roleSlug: json['role_slug'] as String? ?? 'member',
      branchName: json['branch_name'] as String?,
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joined_at'] != null ? DateTime.tryParse(json['joined_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'role_id': roleId,
      'branch_id': branchId,
      'name': name,
      'email': email,
      'phone': phone,
      'role_name': roleName,
      'role_slug': roleSlug,
      'branch_name': branchName,
      'status': status,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }
}

class InviteUserRequest {
  final int organizationId;
  final int? branchId;
  final String name;
  final String email;
  final String? phone;
  final int roleId;

  InviteUserRequest({
    required this.organizationId,
    this.branchId,
    required this.name,
    required this.email,
    this.phone,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'name': name,
      'email': email,
      'phone': phone,
      'role_id': roleId,
    };
  }
}
