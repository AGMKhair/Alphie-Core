import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../provider/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isChangingPassword = true);
      final success = await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      setState(() => _isChangingPassword = false);

      if (mounted) {
        if (success) {
          UiHelpers.showSnackBar(context, 'Password changed successfully');
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          UiHelpers.showSnackBar(context, 'Failed to change password', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: user == null
          ? const Center(child: Text('No active user session'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0] : 'U',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            user.role.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Account Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone ?? 'Not set'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Security / Change Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _currentPasswordController,
                          labelText: 'Current Password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _newPasswordController,
                          labelText: 'New Password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_reset),
                          validator: (v) => Validators.minLength(v, 6),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_reset),
                          validator: (v) {
                            if (v != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'Update Password',
                            isLoading: _isChangingPassword,
                            onPressed: _handleChangePassword,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
