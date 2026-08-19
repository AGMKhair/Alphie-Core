import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../model/notice_model.dart';
import '../../provider/notice_provider.dart';

class NoticeBoardScreen extends ConsumerWidget {
  const NoticeBoardScreen({super.key});

  void _showAddNoticeDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String audience = 'all';
    String priority = 'normal';
    bool sendSms = false;
    bool sendPush = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Publish Notice / Broadcast'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: titleController,
                    labelText: 'Notice Headline',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: contentController,
                    labelText: 'Announcement Message Body',
                    maxLines: 4,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: audience,
                          decoration: const InputDecoration(labelText: 'Target Audience'),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Users')),
                            DropdownMenuItem(value: 'students', child: Text('Students & Guardians')),
                            DropdownMenuItem(value: 'teachers', child: Text('Faculty & Teachers')),
                            DropdownMenuItem(value: 'staff', child: Text('Office Staff')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => audience = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: priority,
                          decoration: const InputDecoration(labelText: 'Priority'),
                          items: const [
                            DropdownMenuItem(value: 'normal', child: Text('Normal')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'urgent', child: Text('Urgent / Alert')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => priority = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Send Mobile Push Notification', style: TextStyle(fontSize: 13)),
                    value: sendPush,
                    onChanged: (v) => setState(() => sendPush = v ?? true),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Send SMS Gateway Alert (Charges apply)', style: TextStyle(fontSize: 13)),
                    value: sendSms,
                    onChanged: (v) => setState(() => sendSms = v ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
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
                  final success = await ref.read(noticeListControllerProvider.notifier).createNotice(
                        CreateNoticeRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          title: titleController.text,
                          content: contentController.text,
                          targetAudience: audience,
                          priority: priority,
                          sendPush: sendPush,
                          sendSms: sendSms,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Notice broadcasted successfully');
                    }
                  }
                }
              },
              child: const Text('Broadcast Notice'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noticeListControllerProvider);
    final selectedAudience = ref.watch(selectedNoticeAudienceProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notice & Communication (${currentOrg?.name ?? ""})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Publish Notice',
            onPressed: () => _showAddNoticeDialog(context, ref),
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
                _buildAudienceChip(ref, 'All', 'all', selectedAudience),
                const SizedBox(width: 8),
                _buildAudienceChip(ref, 'Students', 'students', selectedAudience),
                const SizedBox(width: 8),
                _buildAudienceChip(ref, 'Teachers', 'teachers', selectedAudience),
              ],
            ),
          ),
          const Divider(height: 1),
          // Notices Feed
          Expanded(
            child: state.when(
              loading: () => const AppLoader(message: 'Loading notice board...'),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () {
                  if (currentOrg != null) {
                    ref.read(noticeListControllerProvider.notifier).fetchNotices(organizationId: currentOrg.id);
                  }
                },
              ),
              data: (notices) {
                if (notices.isEmpty) {
                  return const AppEmpty(message: 'No notices posted in this category');
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notices.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    final isUrgent = notice.priority == 'urgent';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    notice.priority.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: isUrgent
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : notice.priority == 'high'
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : Colors.blue.withValues(alpha: 0.2),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Audience: ${notice.targetAudience.toUpperCase()}',
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateUtilsHelper.formatDate(notice.publishDate),
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              notice.title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notice.content,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.person_pin, size: 16, color: Colors.amberAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'By: ${notice.authorName}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                                const Spacer(),
                                if (notice.sendPush)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.notifications_active, size: 16, color: Colors.greenAccent),
                                  ),
                                if (notice.sendSms)
                                  const Icon(Icons.sms, size: 16, color: Colors.blueAccent),
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

  Widget _buildAudienceChip(WidgetRef ref, String label, String value, String current) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      onSelected: (selected) {
        if (selected) {
          ref.read(selectedNoticeAudienceProvider.notifier).setAudience(value);
        }
      },
    );
  }
}
