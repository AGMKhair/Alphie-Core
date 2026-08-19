import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/fee_model.dart';
import '../provider/fee_provider.dart';
import '../repository/fee_repository.dart';

class SelectedFeeFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String filter) => state = filter;
}

class InvoiceListController extends AsyncNotifier<List<InvoiceModel>> {
  FeeRepository get _repository => ref.read(feeRepositoryProvider);

  @override
  Future<List<InvoiceModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);
    final filter = ref.watch(selectedFeeFilterProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getInvoices(
      organizationId: orgId,
      branchId: branchId,
      status: filter == 'all' ? null : filter,
    );
  }

  Future<void> fetchInvoices({
    int? organizationId,
    int? branchId,
    int? studentId,
    String? status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getInvoices(
        organizationId: orgId,
        branchId: branchId,
        studentId: studentId,
        status: status,
      );
    });
  }

  Future<bool> createInvoice(CreateInvoiceRequest request) async {
    try {
      final newInvoice = await _repository.createInvoice(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([newInvoice, ...currentList]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> collectPayment(CollectPaymentRequest request) async {
    try {
      await _repository.collectPayment(request);

      final currentList = state.value ?? [];
      final updatedList = currentList.map((inv) {
        if (inv.id == request.invoiceId) {
          final newPaid = inv.paidAmount + request.amount;
          final newDue = (inv.totalAmount - newPaid).clamp(0.0, inv.totalAmount);
          final newStatus = newDue <= 0 ? 'paid' : 'partial';

          return InvoiceModel(
            id: inv.id,
            organizationId: inv.organizationId,
            branchId: inv.branchId,
            invoiceNo: inv.invoiceNo,
            studentId: inv.studentId,
            studentName: inv.studentName,
            studentNo: inv.studentNo,
            rollNo: inv.rollNo,
            groupName: inv.groupName,
            title: inv.title,
            totalAmount: inv.totalAmount,
            paidAmount: newPaid,
            dueAmount: newDue,
            dueDate: inv.dueDate,
            status: newStatus,
            items: inv.items,
            transactions: [
              ...inv.transactions,
              PaymentTransactionModel(
                id: DateTime.now().millisecondsSinceEpoch % 1000,
                invoiceId: inv.id,
                transactionNo: 'TRX-${DateTime.now().millisecondsSinceEpoch % 100000}',
                amount: request.amount,
                paymentMethod: request.paymentMethod,
                paymentDate: DateTime.now(),
                note: request.note,
              ),
            ],
          );
        }
        return inv;
      }).toList();

      state = AsyncValue.data(updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }
}
