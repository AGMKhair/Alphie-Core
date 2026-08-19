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
import '../../../programs/provider/academic_provider.dart';
import '../../model/homework_model.dart';
import '../../provider/homework_provider.dart';

class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key});

  void _showAddHomeworkDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);
    final programsState = ref.read(programsListControllerProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedGroupId;
    int? selectedSubjectId;
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign New Homework'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  programsState.when(
                    loading: () => const AppLoader(),
                    error: (e, s) => const Text('Error loading classes'),
                    data: (programs) {
                      final allGroups = programs.expand((p) => p.groups).toList();
                      return DropdownButtonFormField<int>(
                        initialValue: allGroups.isNotEmpty ? allGroups.first.id : null,
                        decoration: const InputDecoration(labelText: 'Class / Section / Batch'),
                        items: allGroups.map((g) {
                          return DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.code})'));
                        }).toList(),
                        onChanged: (v) => selectedGroupId = v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  programsState.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                    data: (programs) {
                      final allSubjects = programs.expand((p) => p.subjects).toList();
                      return DropdownButtonFormField<int>(
                        initialValue: allSubjects.isNotEmpty ? allSubjects.first.id : null,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: allSubjects.map((s) {
                          return DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.code})'));
                        }).toList(),
                        onChanged: (v) => selectedSubjectId = v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: titleController,
                    labelText: 'Homework Topic / Title',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descController,
                    labelText: 'Assignment Instructions & Problem Sets',
                    maxLines: 3,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Submission Deadline:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await ref.read(homeworkListControllerProvider.notifier).createHomework(
                        CreateHomeworkRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          groupId: selectedGroupId ?? 1,
                          subjectId: selectedSubjectId ?? 1,
                          title: titleController.text,
                          description: descController.text,
                          dueDate: dueDate,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Homework assigned successfully');
                    }
                  }
                }
              },
              child: const Text('Publish Homework'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmissionsBottomSheet(BuildContext context, WidgetRef ref, HomeworkModel homework) {
    ref.read(homeworkSubmissionsControllerProvider.notifier).fetchSubmissions(homework.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final submissionsState = ref.watch(homeworkSubmissionsControllerProvider);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submissions: ${homework.title}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${homework.subjectName} • ${homework.groupName}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: submissionsState.when(
                      loading: () => const AppLoader(message: 'Loading student submissions...'),
                      error: (err, _) => AppErrorWidget(message: err.toString()),
                      data: (submissions) {
                        if (submissions.isEmpty) {
                          return const AppEmpty(message: 'No submissions yet for this homework');
                        }

                        return ListView.separated(
                          itemCount: submissions.length,
                          separatorBuilder: (ctx, idx) => const Divider(),
                          itemBuilder: (context, index) {
                            final sub = submissions[index];

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(child: Text(sub.rollNo)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(sub.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('Roll: ${sub.rollNo} • ID: ${sub.studentNo}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Chip(
                                          label: Text(sub.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                                          backgroundColor: sub.status == 'evaluated'
                                              ? Colors.green.withValues(alpha: 0.2)
                                              : Colors.amber.withValues(alpha: 0.2),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (sub.submissionText != null)
                                      Text('📝 ${sub.submissionText!}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (sub.marksObtained != null)
                                          Text(
                                            'Score: ${sub.marksObtained}/10',
                                            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                          ),
                                        const Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _showGradeDialog(context, ref, sub);
                                          },
                                          icon: const Icon(Icons.grading, size: 16),
                                          label: const Text('Grade & Feedback'),
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
            ),
          );
        },
      ),
    );
  }

  void _showGradeDialog(BuildContext context, WidgetRef ref, HomeworkSubmissionModel sub) {
    final marksController = TextEditingController(text: sub.marksObtained?.toString() ?? '10');
    final feedbackController = TextEditingController(text: sub.feedback ?? 'Well done');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade ${sub.studentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: marksController,
              labelText: 'Marks (out of 10)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: feedbackController,
              labelText: 'Teacher Feedback',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final marks = double.tryParse(marksController.text) ?? 10.0;
              await ref.read(homeworkSubmissionsControllerProvider.notifier).gradeSubmission(
                    sub.id,
                    marks,
                    feedbackController.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                UiHelpers.showSnackBar(context, 'Grade and feedback recorded');
              }
            },
            child: const Text('Save Score'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeworkListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Homework & Tasks (${currentOrg?.name ?? ""})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Assign Homework',
            onPressed: () => _showAddHomeworkDialog(context, ref),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoader(message: 'Loading homework tasks...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () {
            if (currentOrg != null) {
              ref.read(homeworkListControllerProvider.notifier).fetchHomework(organizationId: currentOrg.id);
            }
          },
        ),
        data: (homeworkList) {
          if (homeworkList.isEmpty) {
            return const AppEmpty(message: 'No active homework assigned yet');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: homeworkList.length,
            itemBuilder: (context, index) {
              final hw = homeworkList[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${hw.subjectName} • ${hw.groupName}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Due: ${DateUtilsHelper.formatDate(hw.dueDate)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hw.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hw.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      Row(
                        children: [
                          Icon(Icons.people_alt_outlined, size: 16, color: Colors.blue.shade300),
                          const SizedBox(width: 6),
                          Text(
                            'Submissions: ${hw.totalSubmissions} / ${hw.totalStudents}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showSubmissionsBottomSheet(context, ref, hw),
                            icon: const Icon(Icons.rate_review, size: 16),
                            label: const Text('Review Submissions'),
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
    );
  }
}
