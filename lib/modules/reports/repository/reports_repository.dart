import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/reports_model.dart';

abstract class ReportsRepository {
  Future<DashboardAnalyticsModel> getAnalytics({
    required int organizationId,
    int? branchId,
  });
}

class ReportsRepositoryImpl implements ReportsRepository {
  final Dio apiClient;

  ReportsRepositoryImpl({required this.apiClient});

  @override
  Future<DashboardAnalyticsModel> getAnalytics({
    required int organizationId,
    int? branchId,
  }) async {
    try {
      final response = await apiClient.get(
        '/reports/analytics',
        queryParameters: {
          if (branchId != null) 'branch_id': branchId,
        }..removeWhere((k, v) => v == null),
      );

      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        return DashboardAnalyticsModel.fromJson(data['data']);
      }

      throw const ServerFailure('Failed to load analytics');
    } catch (e) {
      if (e is Failure) rethrow;
      throw ErrorHandler.handle(e);
    }
  }
}
