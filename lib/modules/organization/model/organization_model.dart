class OrganizationModel {
  final int id;
  final String name;
  final String code;
  final String type; // school, coaching, training_center
  final String? logo;
  final String? email;
  final String? phone;
  final String? address;
  final String status; // active, inactive, pending
  final Map<String, dynamic>? settings;
  final List<BranchModel> branches;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.logo,
    this.email,
    this.phone,
    this.address,
    required this.status,
    this.settings,
    this.branches = const [],
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'school',
      logo: json['logo'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'active',
      settings: json['settings'] as Map<String, dynamic>?,
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'logo': logo,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status,
      'settings': settings,
      'branches': branches.map((b) => b.toJson()).toList(),
    };
  }

  OrganizationModel copyWith({
    int? id,
    String? name,
    String? code,
    String? type,
    String? logo,
    String? email,
    String? phone,
    String? address,
    String? status,
    Map<String, dynamic>? settings,
    List<BranchModel>? branches,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      logo: logo ?? this.logo,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      branches: branches ?? this.branches,
    );
  }
}

class BranchModel {
  final int id;
  final int organizationId;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final String? city;
  final String? country;
  final String status;
  final bool isMain;

  BranchModel({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.city,
    this.country,
    this.status = 'active',
    this.isMain = false,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      status: json['status'] as String? ?? 'active',
      isMain: json['is_main'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'city': city,
      'country': country,
      'status': status,
      'is_main': isMain,
    };
  }
}

class OrganizationRequest {
  final String name;
  final String code;
  final String type;
  final String? email;
  final String? phone;
  final String? address;

  OrganizationRequest({
    required this.name,
    required this.code,
    required this.type,
    this.email,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'type': type,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}

class BranchRequest {
  final int organizationId;
  final String name;
  final String code;
  final String? address;
  final String? phone;
  final String? city;
  final String? country;
  final bool isMain;

  BranchRequest({
    required this.organizationId,
    required this.name,
    required this.code,
    this.address,
    this.phone,
    this.city,
    this.country,
    this.isMain = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'city': city,
      'country': country,
      'is_main': isMain,
    };
  }
}
