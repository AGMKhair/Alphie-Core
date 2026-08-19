import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/reports_controller.dart';
import '../model/reports_model.dart';
import '../repository/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final reportsControllerProvider = AsyncNotifierProvider<ReportsController, DashboardAnalyticsModel>(() {
  return ReportsController();
});
