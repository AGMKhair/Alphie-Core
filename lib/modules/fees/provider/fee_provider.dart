import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/fee_controller.dart';
import '../model/fee_model.dart';
import '../repository/fee_repository.dart';

final feeRepositoryProvider = Provider<FeeRepository>((ref) {
  return FeeRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final selectedFeeFilterProvider = NotifierProvider<SelectedFeeFilterNotifier, String>(() {
  return SelectedFeeFilterNotifier();
});

final invoiceListControllerProvider = AsyncNotifierProvider<InvoiceListController, List<InvoiceModel>>(() {
  return InvoiceListController();
});
