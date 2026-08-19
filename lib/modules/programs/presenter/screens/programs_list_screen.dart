import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../model/academic_models.dart';
import '../../provider/academic_provider.dart';

class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key});

  void _showAddProgramDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Academic Program (${currentOrg.type.toUpperCase()})'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  labelText: currentOrg.type == 'school'
                      ? 'Class Name (e.g. Class 7)'
                      : currentOrg.type == 'coaching'
                          ? 'Course Name (e.g. HSC Chemistry)'
                          : 'Course / Program Name (e.g. Flutter Track)',
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: codeController,
                  labelText: 'Program Code (e.g. CLS-07)',
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descController,
                  labelText: 'Description (Optional)',
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
                final success = await ref.read(programsListControllerProvider.notifier).createProgram(
                      ProgramRequest(
                        organizationId: currentOrg.id,
                        branchId: currentBranch?.id,
                        name: nameController.text,
                        code: codeController.text,
                        type: currentOrg.type,
                        description: descController.text,
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    UiHelpers.showSnackBar(context, 'Program added successfully');
                  } else {
                    UiHelpers.showSnackBar(context, 'Failed to add program', isError: true);
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref, ProgramModel program) {
    final currentOrg = ref.read(currentOrganizationProvider);
    if (currentOrg == null) return;

    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final roomController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Section / Batch to ${program.name}'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  labelText: currentOrg.type == 'school'
                      ? 'Section Name (e.g. Section B)'
                      : 'Batch Name (e.g. Morning Batch 01)',
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: codeController,
                  labelText: 'Code (e.g. SEC-B / B-01)',
                  validator: Validators.required,
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
                final success = await ref.read(programsListControllerProvider.notifier).createGroup(
                      GroupRequest(
                        organizationId: currentOrg.id,
                        programId: program.id,
                        name: nameController.text,
                        code: codeController.text,
                        roomName: roomController.text,
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    UiHelpers.showSnackBar(context, 'Section / Batch added');
                  }
                }
              }
            },
            child: const Text('Add Section/Batch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsState = ref.watch(programsListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Structure: ${currentOrg?.name ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Class / Course',
            onPressed: () => _showAddProgramDialog(context, ref),
          ),
        ],
      ),
      body: programsState.when(
        loading: () => const AppLoader(message: 'Loading academic structure...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () {
            if (currentOrg != null) {
              ref.read(programsListControllerProvider.notifier).loadPrograms(organizationId: currentOrg.id);
            }
          },
        ),
        data: (programs) {
          if (programs.isEmpty) {
            return const AppEmpty(message: 'No programs / classes configured yet');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    program.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Code: ${program.code} • ${program.type.toUpperCase()}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sections / Batches (${program.groups.length}):',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddGroupDialog(context, ref, program),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Batch/Section'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (program.groups.isEmpty)
                            const Text('No sections or batches added yet', style: TextStyle(color: Colors.white54))
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: program.groups.map((g) {
                                return Chip(
                                  avatar: const Icon(Icons.group, size: 16),
                                  label: Text('${g.name} (${g.code}) [${g.roomName ?? "No Room"}]'),
                                );
                              }).toList(),
                            ),
                          const Divider(height: 24),
                          Text(
                            'Subjects / Courses (${program.subjects.length}):',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (program.subjects.isEmpty)
                            const Text('No subjects added yet', style: TextStyle(color: Colors.white54))
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: program.subjects.map((s) {
                                return Chip(
                                  avatar: const Icon(Icons.book, size: 16),
                                  label: Text('${s.name} (${s.code})'),
                                );
                              }).toList(),
                            ),
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
