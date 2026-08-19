import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../provider/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@alphiecore.edu');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authControllerProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        final error = ref.read(authControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error?.toString() ?? 'Login failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(themeColorsProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeColors.primaryGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: themeColors.card,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Alphie Core',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: themeColors.glow,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'System Access Terminal',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email, color: themeColors.accent),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: themeColors.accent),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColors.primary,
                              elevation: isLoading ? 0 : 4,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'INITIALIZE SESSION',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Quick Switch Demo Credentials:',
                          style: TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildQuickChip('👑 Super Admin', 'admin@alphiecore.edu', 'password123'),
                            _buildQuickChip('🏫 Principal', 'admin@alphiecore.com', 'password'),
                            _buildQuickChip('👨‍🏫 Teacher', 'teacher@alphiecore.com', 'password'),
                            _buildQuickChip('👨‍🎓 Student', 'student@alphiecore.com', 'password'),
                            _buildQuickChip('👨‍👩‍👧 Parent', 'parent@alphiecore.com', 'password'),
                            _buildQuickChip('💼 Accountant', 'staff@alphiecore.com', 'password'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ThemeDot(
                              color: const Color(0xFFE53935),
                              onTap: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeType.cyberpunk),
                            ),
                            const SizedBox(width: 16),
                            _ThemeDot(
                              color: const Color(0xFF00897B),
                              onTap: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeType.matrixGreen),
                            ),
                            const SizedBox(width: 16),
                            _ThemeDot(
                              color: const Color(0xFF2979FF),
                              onTap: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeType.deepOcean),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, String email, String pass) {
    return InkWell(
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = pass;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ThemeDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
      ),
    );
  }
}
