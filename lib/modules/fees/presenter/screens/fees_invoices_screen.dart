import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../../students/provider/student_provider.dart';
import '../../model/fee_model.dart';
import '../../provider/fee_provider.dart';

class FeesInvoicesScreen extends ConsumerWidget {
  const FeesInvoicesScreen({super.key});

  void _showCreateInvoiceDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);
    final studentsState = ref.read(studentListControllerProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final titleController = TextEditingController(text: 'Monthly Tuition & Session Fee');
    final amountController = TextEditingController(text: '2500');
    final formKey = GlobalKey<FormState>();
    int? selectedStudentId;
    DateTime dueDate = DateTime.now().add(const Duration(days: 10));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generate Student Invoice'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  studentsState.when(
                    loading: () => const AppLoader(),
                    error: (e, s) => const Text('Error loading students'),
                    data: (students) {
                      return DropdownButtonFormField<int>(
                        initialValue: students.isNotEmpty ? students.first.id : null,
                        decoration: const InputDecoration(labelText: 'Select Student'),
                        items: students.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.fullName} (Roll: ${s.studentNo})'),
                          );
                        }).toList(),
                        onChanged: (v) => selectedStudentId = v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: titleController,
                    labelText: 'Invoice Description / Fee Head',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: amountController,
                    labelText: 'Total Fee Amount (৳)',
                    keyboardType: TextInputType.number,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Payment Due Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.event, size: 16),
                        label: Text(DateUtilsHelper.formatDate(dueDate)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => dueDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amount = double.tryParse(amountController.text) ?? 2500.0;
                  final success = await ref.read(invoiceListControllerProvider.notifier).createInvoice(
                        CreateInvoiceRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          studentId: selectedStudentId ?? 1,
                          title: titleController.text,
                          totalAmount: amount,
                          dueDate: dueDate,
                          items: [
                            InvoiceItemModel(id: 1, title: titleController.text, amount: amount),
                          ],
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Invoice created successfully');
                    }
                  }
                }
              },
              child: const Text('Generate Invoice'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollectPaymentDialog(BuildContext context, WidgetRef ref, InvoiceModel invoice) {
    final amountController = TextEditingController(text: invoice.dueAmount.toStringAsFixed(0));
    final noteController = TextEditingController();
    String paymentMethod = 'bKash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Collect Fee: ${invoice.invoiceNo}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Student: ${invoice.studentName} (${invoice.rollNo})', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Total: ৳${invoice.totalAmount} • Paid: ৳${invoice.paidAmount} • Due: ৳${invoice.dueAmount}', style: const TextStyle(color: Colors.amberAccent)),
                const SizedBox(height: 16),
                AppTextField(
                  controller: amountController,
                  labelText: 'Received Amount (৳)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'bKash', child: Text('bKash Merchant')),
                    DropdownMenuItem(value: 'nagad', child: Text('Nagad')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash at Counter')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer / Deposit')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => paymentMethod = v);
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: noteController,
                  labelText: 'Transaction Note / TrxID (Optional)',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? invoice.dueAmount;
                final success = await ref.read(invoiceListControllerProvider.notifier).collectPayment(
                      CollectPaymentRequest(
                        invoiceId: invoice.id,
                        amount: amount,
                        paymentMethod: paymentMethod,
                        note: noteController.text,
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    UiHelpers.showSnackBar(context, 'Payment collected successfully');
                  }
                }
              },
              child: const Text('Confirm Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoiceListControllerProvider);
    final selectedFilter = ref.watch(selectedFeeFilterProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fees & Invoices (${currentOrg?.name ?? ""})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add),
            tooltip: 'Generate Invoice',
            onPressed: () => _showCreateInvoiceDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                _buildFilterChip(ref, 'All', 'all', selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Unpaid', 'unpaid', selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Partial', 'partial', selectedFilter),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Paid', 'paid', selectedFilter),
              ],
            ),
          ),
          const Divider(height: 1),
          // Invoice List
          Expanded(
            child: state.when(
              loading: () => const AppLoader(message: 'Loading student invoices...'),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () {
                  if (currentOrg != null) {
                    ref.read(invoiceListControllerProvider.notifier).fetchInvoices(organizationId: currentOrg.id);
                  }
                },
              ),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return const AppEmpty(message: 'No invoices found matching filter');
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: invoices.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    final isPaid = inv.status == 'paid';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  inv.invoiceNo,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                                ),
                                Chip(
                                  label: Text(inv.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  backgroundColor: isPaid
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : inv.status == 'partial'
                                          ? Colors.amber.withValues(alpha: 0.2)
                                          : Colors.red.withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '👤 ${inv.studentName} (${inv.groupName} • Roll: ${inv.rollNo})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              inv.title,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total: ${CurrencyUtils.format(inv.totalAmount)}'),
                                  Text('Paid: ${CurrencyUtils.format(inv.paidAmount)}', style: const TextStyle(color: Colors.greenAccent)),
                                  Text('Due: ${CurrencyUtils.format(inv.dueAmount)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Due Date: ${DateUtilsHelper.formatDate(inv.dueDate)}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                const Spacer(),
                                if (!isPaid)
                                  AppButton(
                                    text: 'COLLECT FEE',
                                    icon: Icons.payments_outlined,
                                    onPressed: () => _showCollectPaymentDialog(context, ref, inv),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String value, String current) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      onSelected: (selected) {
        if (selected) {
          ref.read(selectedFeeFilterProvider.notifier).setFilter(value);
        }
      },
    );
  }
}
