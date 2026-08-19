class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String token;
  final String role; // super_admin, organization_admin, branch_admin, teacher, student, guardian, accountant
  final int? organizationId;
  final int? branchId;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.token,
    required this.role,
    this.organizationId,
    this.branchId,
    this.permissions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      organizationId: json['organization_id'] as int?,
      branchId: json['branch_id'] as int?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'token': token,
      'role': role,
      'organization_id': organizationId,
      'branch_id': branchId,
      'permissions': permissions,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? token,
    String? role,
    int? organizationId,
    int? branchId,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      permissions: permissions ?? this.permissions,
    );
  }
}
