import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../model/exam_model.dart';
import '../../provider/exam_provider.dart';

class ExamsListScreen extends ConsumerWidget {
  const ExamsListScreen({super.key});

  void _showAddExamDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final titleController = TextEditingController();
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String examType = 'term';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Examination'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: titleController,
                    labelText: 'Exam Title (e.g. 1st Term 2026)',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: codeController,
                    labelText: 'Exam Code (e.g. EX-2026-T1)',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: examType,
                    decoration: const InputDecoration(labelText: 'Exam Type'),
                    items: const [
                      DropdownMenuItem(value: 'term', child: Text('Term / Semester Exam')),
                      DropdownMenuItem(value: 'class_test', child: Text('Class Test / Assessment')),
                      DropdownMenuItem(value: 'model_test', child: Text('Model Test')),
                      DropdownMenuItem(value: 'final', child: Text('Annual / Final Exam')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => examType = v);
                    },
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
                  final success = await ref.read(examListControllerProvider.notifier).createExam(
                        CreateExamRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          title: titleController.text,
                          code: codeController.text,
                          type: examType,
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(const Duration(days: 14)),
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Exam created successfully');
                    }
                  }
                }
              },
              child: const Text('Create Exam'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarksEntryBottomSheet(BuildContext context, WidgetRef ref, ExamSubjectScheduleModel schedule) {
    ref.read(marksEntryControllerProvider.notifier).loadMarksForSchedule(
          scheduleId: schedule.id,
          groupId: schedule.programId,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final marksState = ref.watch(marksEntryControllerProvider);

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marks Entry: ${schedule.subjectName}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${schedule.programName} • Full Marks: ${schedule.fullMarks.toInt()} (Pass: ${schedule.passMarks.toInt()})',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: marksState.when(
                      loading: () => const AppLoader(message: 'Loading student marks sheet...'),
                      error: (err, _) => AppErrorWidget(message: err.toString()),
                      data: (students) {
                        if (students.isEmpty) {
                          return const AppEmpty(message: 'No students enrolled for this exam');
                        }

                        return ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (ctx, idx) => const Divider(),
                          itemBuilder: (context, index) {
                            final s = students[index];
                            final markController = TextEditingController(
                              text: s.marksObtained != null ? s.marksObtained!.toStringAsFixed(1) : '',
                            );

                            return Row(
                              children: [
                                CircleAvatar(child: Text(s.rollNo)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('ID: ${s.studentNo} • Roll: ${s.rollNo}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    controller: markController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: 'Marks',
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null) {
                                        ref.read(marksEntryControllerProvider.notifier).updateMark(s.studentId, parsed);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    s.grade ?? '--',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'SAVE & PUBLISH MARKS',
                      icon: Icons.check_circle_outline,
                      onPressed: () async {
                        final success = await ref.read(marksEntryControllerProvider.notifier).saveMarks(schedule.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            UiHelpers.showSnackBar(context, 'Marks saved & GPA calculated');
                          }
                        }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Examinations: ${currentOrg?.name ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Create Exam',
            onPressed: () => _showAddExamDialog(context, ref),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoader(message: 'Loading examinations...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () {
            if (currentOrg != null) {
              ref.read(examListControllerProvider.notifier).fetchExams(organizationId: currentOrg.id);
            }
          },
        ),
        data: (exams) {
          if (exams.isEmpty) {
            return const AppEmpty(message: 'No examinations created yet');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.assignment, color: Colors.purpleAccent),
                  ),
                  title: Text(
                    exam.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Text(
                    'Code: ${exam.code} • ${DateUtilsHelper.formatDate(exam.startDate)} to ${DateUtilsHelper.formatDate(exam.endDate)}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: Chip(
                    label: Text(exam.status.toUpperCase()),
                    backgroundColor: exam.status == 'ongoing'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.2),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exam Routine & Subject Schedules:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (exam.schedules.isEmpty)
                            const Text('No subject schedules set up yet', style: TextStyle(color: Colors.white54))
                          else
                            ...exam.schedules.map((schedule) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${schedule.subjectName} (${schedule.programName})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '📅 ${DateUtilsHelper.formatDate(schedule.examDate)} (${schedule.startTime} - ${schedule.endTime})',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showMarksEntryBottomSheet(context, ref, schedule),
                                      icon: const Icon(Icons.edit_note, size: 18),
                                      label: const Text('Marks & Grades'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber.shade800,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
