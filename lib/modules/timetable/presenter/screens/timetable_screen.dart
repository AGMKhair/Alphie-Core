import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../../programs/provider/academic_provider.dart';
import '../../../teachers/provider/teacher_provider.dart';
import '../../model/timetable_model.dart';
import '../../provider/timetable_provider.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void _showAddSlotDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);
    final programsState = ref.read(programsListControllerProvider);
    final teachersState = ref.read(teacherListControllerProvider);
    final selectedDay = ref.read(selectedDayProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final startTimeController = TextEditingController(text: '09:00 AM');
    final endTimeController = TextEditingController(text: '09:45 AM');
    final roomController = TextEditingController(text: 'Room 201');
    final formKey = GlobalKey<FormState>();

    int? selectedGroupId;
    int? selectedSubjectId;
    int? selectedTeacherId;
    String slotDay = selectedDay;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Class Schedule Slot'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: slotDay,
                    decoration: const InputDecoration(labelText: 'Day of the Week'),
                    items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => slotDay = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Group/Batch Dropdown
                  programsState.when(
                    loading: () => const AppLoader(),
                    error: (e, s) => const Text('Error loading batches'),
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
                  // Subject Dropdown
                  programsState.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                    data: (programs) {
                      final allSubjects = programs.expand((p) => p.subjects).toList();
                      return DropdownButtonFormField<int>(
                        initialValue: allSubjects.isNotEmpty ? allSubjects.first.id : null,
                        decoration: const InputDecoration(labelText: 'Subject / Course'),
                        items: allSubjects.map((s) {
                          return DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.code})'));
                        }).toList(),
                        onChanged: (v) => selectedSubjectId = v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Teacher Dropdown
                  teachersState.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                    data: (teachers) {
                      return DropdownButtonFormField<int>(
                        initialValue: teachers.isNotEmpty ? teachers.first.id : null,
                        decoration: const InputDecoration(labelText: 'Assigned Teacher / Faculty'),
                        items: teachers.map((t) {
                          return DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.designation})'));
                        }).toList(),
                        onChanged: (v) => selectedTeacherId = v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: startTimeController,
                          labelText: 'Start Time',
                          validator: Validators.required,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: endTimeController,
                          labelText: 'End Time',
                          validator: Validators.required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: roomController,
                    labelText: 'Room / Lab No.',
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
                  final success = await ref.read(timetableListControllerProvider.notifier).createSlot(
                        CreateTimetableSlotRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          groupId: selectedGroupId ?? 1,
                          subjectId: selectedSubjectId ?? 1,
                          teacherId: selectedTeacherId ?? 1,
                          dayOfWeek: slotDay,
                          startTime: startTimeController.text,
                          endTime: endTimeController.text,
                          roomNo: roomController.text,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Schedule slot added successfully');
                    }
                  }
                }
              },
              child: const Text('Save Slot'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timetableListControllerProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selectedGroupId = ref.watch(selectedTimetableGroupProvider);
    final programsState = ref.watch(programsListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable & Routine (${currentOrg?.name ?? ""})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm),
            tooltip: 'Add Slot',
            onPressed: () => _showAddSlotDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Theme.of(context).cardColor,
            child: programsState.when(
              loading: () => const AppLoader(),
              error: (e, s) => const Text('Error loading classes'),
              data: (programs) {
                final allGroups = programs.expand((p) => p.groups).toList();
                return DropdownButtonFormField<int>(
                  initialValue: selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Select Class / Section / Batch',
                    isDense: true,
                  ),
                  items: allGroups.map((g) {
                    return DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.code})'));
                  }).toList(),
                  onChanged: (v) {
                    ref.read(selectedTimetableGroupProvider.notifier).setGroup(v);
                  },
                );
              },
            ),
          ),
          // Day Tabs (Mon - Sun)
          Container(
            height: 48,
            color: Theme.of(context).cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day == selectedDay;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedDayProvider.notifier).setDay(day);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Timetable Slots List
          Expanded(
            child: state.when(
              loading: () => const AppLoader(message: 'Loading routine...'),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () {
                  if (currentOrg != null) {
                    ref.read(timetableListControllerProvider.notifier).fetchTimetable(
                          organizationId: currentOrg.id,
                          dayOfWeek: selectedDay,
                          groupId: selectedGroupId,
                        );
                  }
                },
              ),
              data: (slots) {
                if (slots.isEmpty) {
                  return AppEmpty(message: 'No classes scheduled for $selectedDay');
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: slots.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (context, index) {
                    final slot = slots[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).primaryColor),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    slot.startTime,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const Text('to', style: TextStyle(fontSize: 10, color: Colors.white60)),
                                  Text(
                                    slot.endTime,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.subjectName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 16, color: Colors.amberAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        slot.teacherName,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if (slot.roomNo != null) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.room_outlined, size: 16, color: Colors.greenAccent),
                                        const SizedBox(width: 4),
                                        Text(
                                          slot.roomNo!,
                                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
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
}
