import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/notice_model.dart';

abstract class NoticeRepository {
  Future<List<NoticeModel>> getNotices({
    required int organizationId,
    int? branchId,
    String? audience,
  });
  Future<NoticeModel> createNotice(CreateNoticeRequest request);
  Future<void> deleteNotice(int id);
}

class NoticeRepositoryImpl implements NoticeRepository {
  final Dio apiClient;

  NoticeRepositoryImpl({required this.apiClient});

  @override
  Future<List<NoticeModel>> getNotices({
    required int organizationId,
    int? branchId,
    String? audience,
  }) async {
    try {
      final response = await apiClient.get(
        '/notices',
        queryParameters: {
          if (audience != null && audience != 'all') 'audience': audience,
        },
      );

      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((json) {
          return NoticeModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? 1,
            branchId: json['branch_id'] as int? ?? 1,
            title: json['title'] as String? ?? '',
            content: json['content'] as String? ?? '',
            targetAudience: json['target_audience'] as String? ?? 'all',
            priority: json['priority'] as String? ?? 'normal',
            publishDate: DateTime.tryParse(json['publish_date'] ?? '') ?? DateTime.now(),
            sendSms: json['send_sms'] == true || json['send_sms'] == 1,
            sendPush: json['send_push'] == true || json['send_push'] == 1,
            authorName: json['author_name'] as String? ?? 'Admin',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<NoticeModel> createNotice(CreateNoticeRequest request) async {
    try {
      final response = await apiClient.post(
        '/notices',
        data: request.toJson(),
      );
      final json = response.data['data'];
      return NoticeModel(
        id: json['id'] as int? ?? 1,
        organizationId: json['organization_id'] as int? ?? 1,
        branchId: json['branch_id'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        targetAudience: json['target_audience'] as String? ?? 'all',
        priority: json['priority'] as String? ?? 'normal',
        publishDate: DateTime.tryParse(json['publish_date'] ?? '') ?? DateTime.now(),
        sendSms: json['send_sms'] == true || json['send_sms'] == 1,
        sendPush: json['send_push'] == true || json['send_push'] == 1,
        authorName: json['author_name'] as String? ?? 'Admin',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteNotice(int id) async {
    try {
      await apiClient.delete('/notices/$id');
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
