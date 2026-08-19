class NoticeModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final String title;
  final String content;
  final String targetAudience; // all, students, teachers, guardians, staff
  final String priority; // normal, high, urgent
  final DateTime publishDate;
  final DateTime? expiryDate;
  final String? attachmentUrl;
  final bool sendSms;
  final bool sendPush;
  final String authorName;

  NoticeModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    required this.title,
    required this.content,
    this.targetAudience = 'all',
    this.priority = 'normal',
    required this.publishDate,
    this.expiryDate,
    this.attachmentUrl,
    this.sendSms = false,
    this.sendPush = true,
    required this.authorName,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      targetAudience: json['target_audience'] as String? ?? 'all',
      priority: json['priority'] as String? ?? 'normal',
      publishDate: DateTime.tryParse(json['publish_date'] ?? '') ?? DateTime.now(),
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date']) : null,
      attachmentUrl: json['attachment_url'] as String?,
      sendSms: json['send_sms'] as bool? ?? false,
      sendPush: json['send_push'] as bool? ?? true,
      authorName: json['author_name'] as String? ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'title': title,
      'content': content,
      'target_audience': targetAudience,
      'priority': priority,
      'publish_date': publishDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'attachment_url': attachmentUrl,
      'send_sms': sendSms,
      'send_push': sendPush,
      'author_name': authorName,
    };
  }
}

class CreateNoticeRequest {
  final int organizationId;
  final int? branchId;
  final String title;
  final String content;
  final String targetAudience;
  final String priority;
  final bool sendSms;
  final bool sendPush;

  CreateNoticeRequest({
    required this.organizationId,
    this.branchId,
    required this.title,
    required this.content,
    required this.targetAudience,
    required this.priority,
    this.sendSms = false,
    this.sendPush = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'title': title,
      'content': content,
      'target_audience': targetAudience,
      'priority': priority,
      'send_sms': sendSms,
      'send_push': sendPush,
    };
  }
}
