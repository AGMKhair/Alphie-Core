import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../model/fee_model.dart';

abstract class FeeRepository {
  Future<List<FeeHeadModel>> getFeeHeads(int organizationId);
  Future<List<InvoiceModel>> getInvoices({
    required int organizationId,
    int? branchId,
    int? studentId,
    String? status,
  });
  Future<InvoiceModel> createInvoice(CreateInvoiceRequest request);
  Future<void> collectPayment(CollectPaymentRequest request);
}

class FeeRepositoryImpl implements FeeRepository {
  final Dio apiClient;

  FeeRepositoryImpl({required this.apiClient});

  @override
  Future<List<FeeHeadModel>> getFeeHeads(int organizationId) async {
    try {
      return [
        FeeHeadModel(id: 1, organizationId: organizationId, title: 'Monthly Tuition Fee', code: 'TFEE', defaultAmount: 2500),
        FeeHeadModel(id: 2, organizationId: organizationId, title: 'Semester Exam Fee', code: 'EXFEE', defaultAmount: 800),
        FeeHeadModel(id: 3, organizationId: organizationId, title: 'Laboratory & IT Charges', code: 'LABFEE', defaultAmount: 1200),
        FeeHeadModel(id: 4, organizationId: organizationId, title: 'Annual Admission Charge', code: 'ADM_SESS', defaultAmount: 5000),
      ];
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<InvoiceModel>> getInvoices({
    required int organizationId,
    int? branchId,
    int? studentId,
    String? status,
  }) async {
    try {
      final response = await apiClient.get(
        '/fees/invoices',
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
        },
      );

      final data = response.data;
      if ((data['status'] == 'success' || data['success'] == true) && data['data'] != null) {
        final List<dynamic> list = data['data'] is List ? data['data'] : [];
        return list.map((json) {
          final itemsList = (json['items'] as List<dynamic>?)?.map((i) {
            return InvoiceItemModel(
              id: i['id'] as int? ?? 1,
              title: i['title'] as String? ?? '',
              amount: (i['amount'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList() ?? [];

          final txList = (json['transactions'] as List<dynamic>?)?.map((t) {
            return PaymentTransactionModel(
              id: t['id'] as int? ?? 1,
              invoiceId: t['invoice_id'] as int? ?? 1,
              transactionNo: t['transaction_no'] as String? ?? '',
              amount: (t['amount'] as num?)?.toDouble() ?? 0.0,
              paymentMethod: t['payment_method'] as String? ?? 'cash',
              paymentDate: DateTime.tryParse(t['payment_date'] ?? '') ?? DateTime.now(),
              note: t['note'] as String?,
            );
          }).toList() ?? [];

          return InvoiceModel(
            id: json['id'] as int? ?? 1,
            organizationId: json['organization_id'] as int? ?? 1,
            branchId: json['branch_id'] as int? ?? 1,
            invoiceNo: json['invoice_no'] as String? ?? '',
            studentId: json['student_id'] as int? ?? 1,
            studentName: 'Sadman Rahman',
            studentNo: 'STD-2026-0001',
            rollNo: '01',
            groupName: 'Class 6 - Section A',
            title: json['title'] as String? ?? 'Tuition Fee',
            totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
            paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
            dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
            dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
            status: json['status'] as String? ?? 'unpaid',
            items: itemsList,
            transactions: txList,
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
  Future<InvoiceModel> createInvoice(CreateInvoiceRequest request) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return InvoiceModel(
        id: DateTime.now().millisecondsSinceEpoch % 1000,
        organizationId: request.organizationId,
        branchId: request.branchId,
        invoiceNo: 'INV-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
        studentId: request.studentId,
        studentName: 'Selected Student',
        studentNo: 'STD-2026',
        rollNo: '01',
        groupName: 'Assigned Batch',
        title: request.title,
        totalAmount: request.totalAmount,
        paidAmount: 0.0,
        dueAmount: request.totalAmount,
        dueDate: request.dueDate,
        status: 'unpaid',
        items: request.items,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> collectPayment(CollectPaymentRequest request) async {
    try {
      await apiClient.post('/fees/collect-payment', data: request.toJson());
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
