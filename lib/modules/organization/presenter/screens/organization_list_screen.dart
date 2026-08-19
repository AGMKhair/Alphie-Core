import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../model/organization_model.dart';
import '../../provider/organization_provider.dart';

class OrganizationListScreen extends ConsumerWidget {
  const OrganizationListScreen({super.key});

  void _showCreateOrganizationDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedType = 'school';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Organization'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: nameController,
                        labelText: 'Organization Name',
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: codeController,
                        labelText: 'Unique Code (e.g. ABC-SCH)',
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'school', child: Text('🏫 School')),
                          DropdownMenuItem(value: 'coaching', child: Text('📖 Coaching Center')),
                          DropdownMenuItem(value: 'training_center', child: Text('💻 Training Center')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => selectedType = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: emailController,
                        labelText: 'Official Email (Optional)',
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: phoneController,
                        labelText: 'Phone (Optional)',
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: addressController,
                        labelText: 'Main Address (Optional)',
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
                      final success = await ref.read(organizationListControllerProvider.notifier).createOrganization(
                            OrganizationRequest(
                              name: nameController.text,
                              code: codeController.text,
                              type: selectedType,
                              email: emailController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                            ),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          UiHelpers.showSnackBar(context, 'Organization added successfully');
                        } else {
                          UiHelpers.showSnackBar(context, 'Failed to add organization', isError: true);
                        }
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddBranchDialog(BuildContext context, WidgetRef ref, OrganizationModel org) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final cityController = TextEditingController(text: 'Dhaka');
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Branch / Campus to ${org.name}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameController,
                    labelText: 'Branch Name (e.g. Uttara Campus)',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: codeController,
                    labelText: 'Branch Code (e.g. UTR-01)',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: cityController,
                    labelText: 'City / Area',
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: addressController,
                    labelText: 'Campus Address (Optional)',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneController,
                    labelText: 'Campus Contact Phone (Optional)',
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
                  final success = await ref.read(organizationListControllerProvider.notifier).createBranch(
                        BranchRequest(
                          organizationId: org.id,
                          name: nameController.text,
                          code: codeController.text,
                          city: cityController.text,
                          address: addressController.text,
                          phone: phoneController.text,
                          country: 'Bangladesh',
                          isMain: false,
                        ),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      UiHelpers.showSnackBar(context, 'Branch added successfully to ${org.name}');
                    } else {
                      UiHelpers.showSnackBar(context, 'Failed to add branch', isError: true);
                    }
                  }
                }
              },
              child: const Text('Add Branch'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgsState = ref.watch(organizationListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations & Branches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Add Organization',
            onPressed: () => _showCreateOrganizationDialog(context, ref),
          ),
        ],
      ),
      body: orgsState.when(
        loading: () => const AppLoader(message: 'Loading organizations...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.read(organizationListControllerProvider.notifier).loadOrganizations(),
        ),
        data: (organizations) {
          if (organizations.isEmpty) {
            return const AppEmpty(message: 'No organizations registered yet');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: organizations.length,
            itemBuilder: (context, index) {
              final org = organizations[index];
              final isSelected = org.id == currentOrg?.id;

              IconData icon = Icons.school;
              if (org.type == 'coaching') icon = Icons.menu_book;
              if (org.type == 'training_center') icon = Icons.computer;

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                      : BorderSide.none,
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white12,
                            child: Icon(icon, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Code: ${org.code} • Type: ${org.type.toUpperCase()}',
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Chip(
                              label: Text('ACTIVE TENANT'),
                              backgroundColor: Colors.green,
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                ref.read(currentOrganizationProvider.notifier).selectOrganization(org);
                                UiHelpers.showSnackBar(context, 'Switched to ${org.name}');
                              },
                              child: const Text('Select'),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Branches (${org.branches.length}):',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                            label: const Text('Add Branch'),
                            onPressed: () => _showAddBranchDialog(context, ref, org),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (org.branches.isEmpty)
                        const Text('No branches set up yet', style: TextStyle(color: Colors.white54))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: org.branches.map((b) {
                            return Chip(
                              avatar: Icon(
                                b.isMain ? Icons.home_work : Icons.location_on,
                                size: 16,
                                color: b.isMain ? Colors.amberAccent : null,
                              ),
                              label: Text(
                                '${b.name}${b.city != null && b.city!.isNotEmpty ? " (${b.city})" : ""}${b.isMain ? " [MAIN]" : ""}',
                              ),
                            );
                          }).toList(),
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
