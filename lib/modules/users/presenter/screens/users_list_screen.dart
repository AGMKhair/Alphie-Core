import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../model/user_rbac_model.dart';
import '../../provider/users_provider.dart';

class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  void _showInviteUserDialog(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.read(currentOrganizationProvider);
    final currentBranch = ref.read(currentBranchProvider);
    final rolesState = ref.read(rolesListProvider);

    if (currentOrg == null) {
      UiHelpers.showSnackBar(context, 'Please select an organization first', isError: true);
      return;
    }

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int selectedRoleId = 4; // Default to Teacher

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add / Invite Member'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: nameController,
                        labelText: 'Full Name',
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: emailController,
                        labelText: 'Email Address',
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: phoneController,
                        labelText: 'Phone Number (Optional)',
                      ),
                      const SizedBox(height: 12),
                      rolesState.when(
                        loading: () => const AppLoader(),
                        error: (err, stack) => const Text('Could not load roles'),
                        data: (roles) {
                          return DropdownButtonFormField<int>(
                            initialValue: selectedRoleId,
                            decoration: const InputDecoration(labelText: 'Assign Role'),
                            items: roles.map((r) {
                              return DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => selectedRoleId = v);
                            },
                          );
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
                      final success = await ref.read(usersListControllerProvider.notifier).inviteUser(
                            InviteUserRequest(
                              organizationId: currentOrg.id,
                              branchId: currentBranch?.id,
                              name: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              roleId: selectedRoleId,
                            ),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          UiHelpers.showSnackBar(context, 'User added to organization');
                        } else {
                          UiHelpers.showSnackBar(context, 'Failed to add user', isError: true);
                        }
                      }
                    }
                  },
                  child: const Text('Save User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Members: ${currentOrg?.name ?? "Alphie Core"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite / Add User',
            onPressed: () => _showInviteUserDialog(context, ref),
          ),
        ],
      ),
      body: usersState.when(
        loading: () => const AppLoader(message: 'Loading members & permissions...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.read(usersListControllerProvider.notifier).fetchUsers(
                organizationId: currentOrg?.id,
              ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const AppEmpty(message: 'No members in this organization');
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.isNotEmpty ? user.name[0] : 'U'),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.email} • ${user.phone ?? ""}'),
                    const SizedBox(height: 2),
                    Text(
                      'Branch: ${user.branchName ?? "All Branches"}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(user.roleName),
                  backgroundColor: _getRoleColor(user.roleSlug),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String slug) {
    switch (slug) {
      case 'super_admin':
      case 'organization_admin':
        return Colors.redAccent.withValues(alpha: 0.3);
      case 'branch_admin':
        return Colors.orangeAccent.withValues(alpha: 0.3);
      case 'teacher':
        return Colors.blueAccent.withValues(alpha: 0.3);
      case 'accountant':
        return Colors.greenAccent.withValues(alpha: 0.3);
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }
}
