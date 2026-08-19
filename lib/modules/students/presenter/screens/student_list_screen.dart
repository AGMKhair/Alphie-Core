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
import '../../model/student_model.dart';
import '../../provider/student_provider.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  final _searchController = TextEditingController();

  void _showAddStudentDialog(BuildContext context) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);
    final programsState = ref.read(programsListControllerProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final guardianNameController = TextEditingController();
    final guardianPhoneController = TextEditingController();
    final rollNoController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedGender = 'male';
    String selectedBloodGroup = 'B+';
    int? selectedGroupId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Student Admission'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: firstNameController,
                          labelText: 'First Name',
                          validator: Validators.required,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          controller: lastNameController,
                          labelText: 'Last Name',
                          validator: Validators.required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedGender,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => selectedGender = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedBloodGroup,
                          decoration: const InputDecoration(labelText: 'Blood Group'),
                          items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                              .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => selectedBloodGroup = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneController,
                    labelText: 'Student Phone (Optional)',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: emailController,
                    labelText: 'Student Email (Optional)',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Class & Batch Enrollment', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  programsState.when(
                    loading: () => const AppLoader(),
                    error: (err, stack) => const Text('Could not load batches'),
                    data: (programs) {
                      final allGroups = programs.expand((p) => p.groups).toList();
                      return DropdownButtonFormField<int>(
                        initialValue: allGroups.isNotEmpty ? allGroups.first.id : null,
                        decoration: const InputDecoration(labelText: 'Select Class / Batch'),
                        items: allGroups.map((g) {
                          return DropdownMenuItem(
                            value: g.id,
                            child: Text('${g.name} (${g.code})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          selectedGroupId = v;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: rollNoController,
                    labelText: 'Roll No. / Student ID',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Guardian Information', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: guardianNameController,
                    labelText: "Guardian's Name",
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: guardianPhoneController,
                    labelText: "Guardian's Phone",
                    validator: Validators.required,
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
                  final success = await ref.read(studentListControllerProvider.notifier).createStudent(
                        CreateStudentRequest(
                          organizationId: currentOrg.id,
                          branchId: currentBranch?.id,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          gender: selectedGender,
                          phone: phoneController.text,
                          email: emailController.text,
                          bloodGroup: selectedBloodGroup,
                          groupId: selectedGroupId,
                          rollNo: rollNoController.text,
                          guardianName: guardianNameController.text,
                          guardianPhone: guardianPhoneController.text,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Student enrolled successfully');
                    }
                  }
                }
              },
              child: const Text('Admit Student'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Directory (${currentOrg?.name ?? ""})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Admit Student',
            onPressed: () => _showAddStudentDialog(context),
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
                hintText: 'Search by Name, Roll No. or Student ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(studentListControllerProvider.notifier).fetchStudents();
                  },
                ),
              ),
              onSubmitted: (query) {
                ref.read(studentListControllerProvider.notifier).fetchStudents(search: query);
              },
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const AppLoader(message: 'Loading students...'),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () => ref.read(studentListControllerProvider.notifier).fetchStudents(),
              ),
              data: (students) {
                if (students.isEmpty) {
                  return const AppEmpty(message: 'No students enrolled yet');
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: students.length,
                  separatorBuilder: (ctx, idx) => const Divider(),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final enrollment = student.currentEnrollment;
                    final guardian = student.guardians.isNotEmpty ? student.guardians.first : null;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                            child: Text(
                              student.firstName.isNotEmpty ? student.firstName[0] : 'S',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: student.status == 'active' ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        student.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: student.status == 'active' ? Colors.greenAccent : Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${student.studentNo} • Roll: ${enrollment?.rollNo ?? "N/A"} • ${enrollment?.groupName ?? "Class 6"}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                                if (guardian != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '👤 ${guardian.name} (${guardian.phone})',
                                    style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
