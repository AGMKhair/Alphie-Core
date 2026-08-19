class FeeHeadModel {
  final int id;
  final int organizationId;
  final String title; // Tuition Fee, Admission Fee, Exam Fee, Lab Fee
  final String code; // TFEE, AFEE, EXFEE
  final String type; // recurring, one_time
  final double defaultAmount;

  FeeHeadModel({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.code,
    this.type = 'recurring',
    this.defaultAmount = 0.0,
  });

  factory FeeHeadModel.fromJson(Map<String, dynamic> json) {
    return FeeHeadModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      title: json['title'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'recurring',
      defaultAmount: (json['default_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'code': code,
      'type': type,
      'default_amount': defaultAmount,
    };
  }
}

class InvoiceModel {
  final int id;
  final int organizationId;
  final int? branchId;
  final String invoiceNo; // INV-2026-0001
  final int studentId;
  final String studentName;
  final String studentNo;
  final String rollNo;
  final String groupName;
  final String title; // April 2026 Tuition Fee, 1st Term Exam Fee
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final DateTime dueDate;
  final String status; // paid, partial, unpaid, overdue
  final List<InvoiceItemModel> items;
  final List<PaymentTransactionModel> transactions;

  InvoiceModel({
    required this.id,
    required this.organizationId,
    this.branchId,
    required this.invoiceNo,
    required this.studentId,
    required this.studentName,
    required this.studentNo,
    required this.rollNo,
    required this.groupName,
    required this.title,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.dueDate,
    this.status = 'unpaid',
    this.items = const [],
    this.transactions = const [],
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      branchId: json['branch_id'] as int?,
      invoiceNo: json['invoice_no'] as String? ?? '',
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String? ?? '',
      studentNo: json['student_no'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      groupName: json['group_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'unpaid',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => PaymentTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'branch_id': branchId,
      'invoice_no': invoiceNo,
      'student_id': studentId,
      'student_name': studentName,
      'student_no': studentNo,
      'roll_no': rollNo,
      'group_name': groupName,
      'title': title,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'due_amount': dueAmount,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

class InvoiceItemModel {
  final int id;
  final String title;
  final double amount;

  InvoiceItemModel({
    required this.id,
    required this.title,
    required this.amount,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
    };
  }
}

class PaymentTransactionModel {
  final int id;
  final int invoiceId;
  final String transactionNo;
  final double amount;
  final String paymentMethod; // cash, bKash, nagad, bank_transfer, card
  final DateTime paymentDate;
  final String? note;

  PaymentTransactionModel({
    required this.id,
    required this.invoiceId,
    required this.transactionNo,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.note,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as int,
      invoiceId: json['invoice_id'] as int,
      transactionNo: json['transaction_no'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentDate: DateTime.tryParse(json['payment_date'] ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'transaction_no': transactionNo,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
    };
  }
}

class CreateInvoiceRequest {
  final int organizationId;
  final int? branchId;
  final int studentId;
  final String title;
  final double totalAmount;
  final DateTime dueDate;
  final List<InvoiceItemModel> items;

  CreateInvoiceRequest({
    required this.organizationId,
    this.branchId,
    required this.studentId,
    required this.title,
    required this.totalAmount,
    required this.dueDate,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'branch_id': branchId,
      'student_id': studentId,
      'title': title,
      'total_amount': totalAmount,
      'due_date': dueDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CollectPaymentRequest {
  final int invoiceId;
  final double amount;
  final String paymentMethod;
  final String? note;

  CollectPaymentRequest({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod,
      'note': note,
    };
  }
}
