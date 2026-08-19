import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../model/teacher_model.dart';
import '../../provider/teacher_provider.dart';

class TeachersListScreen extends ConsumerStatefulWidget {
  const TeachersListScreen({super.key});

  @override
  ConsumerState<TeachersListScreen> createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends ConsumerState<TeachersListScreen> {
  final _searchController = TextEditingController();

  void _showAddTeacherDialog(BuildContext context) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final nameController = TextEditingController();
    final employeeNoController = TextEditingController();
    final designationController = TextEditingController();
    final qualificationController = TextEditingController();
    final specializationController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final subjectsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Teacher / Instructor'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  labelText: 'Faculty Full Name',
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: employeeNoController,
                        labelText: 'Emp / ID No. (e.g. TCH-101)',
                        validator: Validators.required,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppTextField(
                        controller: designationController,
                        labelText: 'Designation (e.g. Lecturer)',
                        validator: Validators.required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: qualificationController,
                  labelText: 'Qualification (e.g. M.Sc, B.Sc)',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: specializationController,
                  labelText: 'Specialization (e.g. Physics, Flutter, Math)',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: phoneController,
                  labelText: 'Phone Number',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: emailController,
                  labelText: 'Email Address',
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: subjectsController,
                  labelText: 'Assigned Subjects (comma separated)',
                  hintText: 'Physics, Higher Math',
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
                final subjectsList = subjectsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final success = await ref.read(teacherListControllerProvider.notifier).createTeacher(
                      CreateTeacherRequest(
                        organizationId: currentOrg.id,
                        branchId: currentBranch?.id,
                        employeeNo: employeeNoController.text,
                        name: nameController.text,
                        designation: designationController.text,
                        qualification: qualificationController.text,
                        specialization: specializationController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        assignedSubjects: subjectsList,
                      ),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    UiHelpers.showSnackBar(context, 'Teacher profile created successfully');
                  }
                }
              }
            },
            child: const Text('Save Teacher'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Teachers & Faculty: ${currentOrg?.name ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Faculty',
            onPressed: () => _showAddTeacherDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search faculty by Name, Emp No. or Subject...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(teacherListControllerProvider.notifier).fetchTeachers();
                  },
                ),
              ),
              onSubmitted: (q) {
                ref.read(teacherListControllerProvider.notifier).fetchTeachers(search: q);
              },
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const AppLoader(message: 'Loading teachers...'),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () => ref.read(teacherListControllerProvider.notifier).fetchTeachers(),
              ),
              data: (teachers) {
                if (teachers.isEmpty) {
                  return const AppEmpty(message: 'No teachers registered yet');
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: teachers.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                              child: Text(
                                teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        teacher.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Chip(
                                        label: Text(
                                          teacher.employeeNo,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    teacher.designation,
                                    style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600),
                                  ),
                                  if (teacher.qualification != null) ...[
                                    const SizedBox(height: 2),
                                    Text('🎓 ${teacher.qualification!}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                  if (teacher.phone != null || teacher.email != null) ...[
                                    const SizedBox(height: 4),
                                    Text('📞 ${teacher.phone ?? ""} • ✉️ ${teacher.email ?? ""}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                  if (teacher.assignedSubjects.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: teacher.assignedSubjects.map((sub) {
                                        return Chip(
                                          avatar: const Icon(Icons.menu_book, size: 14),
                                          label: Text(sub, style: const TextStyle(fontSize: 11)),
                                        );
                                      }).toList(),
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
