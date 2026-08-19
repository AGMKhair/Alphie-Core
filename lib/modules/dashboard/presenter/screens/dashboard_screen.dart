import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../organization/presenter/widgets/branch_switcher.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../../reports/provider/reports_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);
    final currentUser = ref.watch(authControllerProvider).value;
    final analyticsState = ref.watch(reportsControllerProvider);
    final role = currentUser?.role ?? 'organization_admin';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 14,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Alphie Core',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildRoleBadge(role),
              ],
            ),
            if (role != 'super_admin' && currentOrg != null)
              Text(
                '${currentOrg.name} (${currentOrg.type.toUpperCase()})',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else if (role == 'super_admin')
              const Text(
                'Global SaaS Control Center',
                style: TextStyle(fontSize: 11, color: Colors.amberAccent),
              ),
          ],
        ),
        actions: [
          if (role == 'super_admin' || role == 'organization_admin' || role == 'branch_admin')
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch Branch & Organization',
              onPressed: () => _showSwitchScopeDialog(context, ref, role),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'scope') _showSwitchScopeDialog(context, ref, role);
              if (value == 'orgs') context.push('/organizations');
              if (value == 'users') context.push('/users');
              if (value == 'profile') context.push('/profile');
              if (value == 'logout') {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            itemBuilder: (context) => [
              if (role == 'super_admin' || role == 'organization_admin' || role == 'branch_admin')
                const PopupMenuItem(
                  value: 'scope',
                  child: Row(
                    children: [
                      Icon(Icons.domain_outlined, size: 18, color: Colors.amberAccent),
                      SizedBox(width: 8),
                      Text('Switch Campus Scope'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 8),
                    Text('My Profile'),
                  ],
                ),
              ),
              if (role == 'super_admin')
                const PopupMenuItem(
                  value: 'orgs',
                  child: Row(
                    children: [
                      Icon(Icons.business_outlined, size: 18, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Manage Organizations'),
                    ],
                  ),
                ),
              if (role == 'super_admin' || role == 'organization_admin')
                const PopupMenuItem(
                  value: 'users',
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Staff & Role Allocation'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileContent(context, ref, currentOrg, currentBranch, currentUser, analyticsState, role),
        desktop: _buildDesktopContent(context, ref, currentOrg, currentBranch, currentUser, analyticsState, role),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    String label = 'Staff';
    Color color = Colors.grey;

    switch (role) {
      case 'super_admin':
        label = 'Super Admin';
        color = Colors.amber;
        break;
      case 'organization_admin':
        label = 'Org Admin';
        color = Colors.blueAccent;
        break;
      case 'branch_admin':
        label = 'Campus Head';
        color = Colors.tealAccent;
        break;
      case 'teacher':
        label = 'Faculty Teacher';
        color = Colors.purpleAccent;
        break;
      case 'student':
        label = 'Student';
        color = Colors.greenAccent;
        break;
      case 'guardian':
        label = 'Parent / Guardian';
        color = Colors.orangeAccent;
        break;
      case 'accountant':
        label = 'Accounts Staff';
        color = Colors.cyanAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showSwitchScopeDialog(BuildContext context, WidgetRef ref, String role) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Campus & Organization Scope',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (role == 'super_admin') ...[
                const Text('Active Institution / Tenant:', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 6),
                const SizedBox(width: double.infinity, child: OrganizationSwitcher()),
                const SizedBox(height: 16),
              ],
              const Text('Active Branch / Campus:', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              const SizedBox(width: double.infinity, child: BranchSwitcher()),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    WidgetRef ref,
    dynamic currentOrg,
    dynamic currentBranch,
    dynamic currentUser,
    AsyncValue<dynamic> analyticsState,
    String role,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      children: [
        _buildRoleBasedBanner(context, currentOrg, currentBranch, role, currentUser),
        const SizedBox(height: 14),

        // Live API Metrics
        analyticsState.when(
          loading: () => Container(
            height: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: AppLoader(message: 'Loading live metrics...')),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Could not load live analytics', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                TextButton(
                  onPressed: () {
                    if (currentOrg != null) {
                      ref.read(reportsControllerProvider.notifier).fetchAnalytics(
                            organizationId: currentOrg.id,
                            branchId: currentBranch?.id,
                          );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (analytics) => _buildStatCardsForRole(context, role, analytics, ref),
        ),

        const SizedBox(height: 18),
        Text(
          _getSectionHeaderForRole(role),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 10),

        // Role-Specific Action Grid
        _buildRoleSpecificActions(context, role),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getSectionHeaderForRole(String role) {
    switch (role) {
      case 'super_admin':
        return 'Platform Administration & Global Hub';
      case 'organization_admin':
      case 'branch_admin':
        return 'Campus Operations & Staff Management';
      case 'teacher':
        return 'Teacher Classroom & Academic Hub';
      case 'student':
        return 'Student Portal & Learning Desk';
      case 'guardian':
        return 'Parent Portal & Student Monitoring';
      case 'accountant':
        return 'Finance Desk & Fee Collection';
      default:
        return 'Operations Dashboard';
    }
  }

  Widget _buildStatCardsForRole(BuildContext context, String role, dynamic analytics, WidgetRef ref) {
    if (role == 'super_admin') {
      final orgsList = ref.watch(organizationListControllerProvider).value ?? [];
      final orgCountText = '${orgsList.length} Active';

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _buildCompactStatCard(context, 'Institutions', orgCountText, Icons.apartment, Colors.amberAccent, onTap: () => context.push('/organizations')),
          _buildCompactStatCard(context, 'Total Enrolled', '${analytics.totalStudents}', Icons.school, Colors.blueAccent, onTap: () => context.push('/students')),
          _buildCompactStatCard(context, 'Total Faculty', '${analytics.totalTeachers}', Icons.person_pin, Colors.orangeAccent, onTap: () => context.push('/teachers')),
          _buildCompactStatCard(context, 'SaaS Revenue', CurrencyUtils.format(analytics.collectedFees), Icons.account_balance_wallet_outlined, Colors.purpleAccent, onTap: () => context.push('/reports')),
        ],
      );
    }

    if (role == 'organization_admin' || role == 'branch_admin') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _buildCompactStatCard(context, 'Campus Students', '${analytics.totalStudents}', Icons.school, Colors.blueAccent, onTap: () => context.push('/students')),
          _buildCompactStatCard(context, 'Faculty Staff', '${analytics.totalTeachers}', Icons.person_pin, Colors.orangeAccent, onTap: () => context.push('/teachers')),
          _buildCompactStatCard(context, 'Attendance', '${analytics.todayAttendancePercentage}%', Icons.check_circle_outline, Colors.greenAccent, onTap: () => context.push('/attendance')),
          _buildCompactStatCard(context, 'Fee Collection', CurrencyUtils.format(analytics.collectedFees), Icons.account_balance_wallet_outlined, Colors.purpleAccent, onTap: () => context.push('/fees')),
        ],
      );
    }

    if (role == 'teacher') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _buildCompactStatCard(context, 'My Students', '${analytics.totalStudents}', Icons.school, Colors.blueAccent, onTap: () => context.push('/students')),
          _buildCompactStatCard(context, 'Classes/Batches', '${analytics.totalClasses}', Icons.class_outlined, Colors.orangeAccent, onTap: () => context.push('/programs')),
          _buildCompactStatCard(context, 'Class Attendance', '${analytics.todayAttendancePercentage}%', Icons.check_circle_outline, Colors.greenAccent, onTap: () => context.push('/attendance')),
          _buildCompactStatCard(context, 'Homework Assigned', '1 Active', Icons.menu_book_outlined, Colors.cyanAccent, onTap: () => context.push('/homework')),
        ],
      );
    }

    if (role == 'student') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _buildCompactStatCard(context, 'My Attendance', '95.5%', Icons.check_circle_outline, Colors.greenAccent, onTap: () => context.push('/attendance')),
          _buildCompactStatCard(context, 'Pending Homework', '1 Due', Icons.menu_book_outlined, Colors.amberAccent, onTap: () => context.push('/homework')),
          _buildCompactStatCard(context, 'Upcoming Exam', 'Midterm', Icons.assignment_outlined, Colors.deepOrangeAccent, onTap: () => context.push('/exams')),
          _buildCompactStatCard(context, 'Fee Invoices', 'Paid', Icons.receipt_long_outlined, Colors.cyanAccent, onTap: () => context.push('/fees')),
        ],
      );
    }

    if (role == 'guardian') {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          _buildCompactStatCard(context, "Child's Attendance", '95.5%', Icons.check_circle_outline, Colors.greenAccent, onTap: () => context.push('/attendance')),
          _buildCompactStatCard(context, 'Unpaid Tuition', '৳0 Due', Icons.payments_outlined, Colors.cyanAccent, onTap: () => context.push('/fees')),
          _buildCompactStatCard(context, 'Exam Results', 'GPA 5.0 (A+)', Icons.emoji_events_outlined, Colors.amberAccent, onTap: () => context.push('/exams')),
          _buildCompactStatCard(context, 'Daily Homework', '1 Done', Icons.assignment_turned_in_outlined, Colors.purpleAccent, onTap: () => context.push('/homework')),
        ],
      );
    }

    // Accountant / Staff
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildCompactStatCard(context, 'Total Invoiced', CurrencyUtils.format(analytics.totalRevenue), Icons.receipt_long_outlined, Colors.blueAccent, onTap: () => context.push('/fees')),
        _buildCompactStatCard(context, 'Total Collected', CurrencyUtils.format(analytics.collectedFees), Icons.account_balance_wallet_outlined, Colors.greenAccent, onTap: () => context.push('/fees')),
        _buildCompactStatCard(context, 'Pending Due', CurrencyUtils.format(analytics.dueFees), Icons.pending_actions_outlined, Colors.redAccent, onTap: () => context.push('/fees')),
        _buildCompactStatCard(context, 'Total Students', '${analytics.totalStudents}', Icons.people_outline, Colors.orangeAccent, onTap: () => context.push('/students')),
      ],
    );
  }

  Widget _buildRoleSpecificActions(BuildContext context, String role) {
    if (role == 'super_admin') {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
        children: [
          _buildQuickActionTile(context, 'Institutions', Icons.domain, Colors.amberAccent, () => context.push('/organizations')),
          _buildQuickActionTile(context, 'Global Reports', Icons.insights, Colors.indigoAccent, () => context.push('/reports')),
          _buildQuickActionTile(context, 'All Staff', Icons.admin_panel_settings_outlined, Colors.pinkAccent, () => context.push('/users')),
          _buildQuickActionTile(context, 'Students', Icons.people_outline, Colors.blueAccent, () => context.push('/students')),
          _buildQuickActionTile(context, 'Teachers', Icons.cast_for_education, Colors.orangeAccent, () => context.push('/teachers')),
          _buildQuickActionTile(context, 'All Notices', Icons.campaign_outlined, Colors.tealAccent, () => context.push('/notices')),
        ],
      );
    }

    if (role == 'organization_admin' || role == 'branch_admin') {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
        children: [
          _buildQuickActionTile(context, 'Staff & RBAC', Icons.badge_outlined, Colors.pinkAccent, () => context.push('/users')),
          _buildQuickActionTile(context, 'Branch Reports', Icons.insights, Colors.indigoAccent, () => context.push('/reports')),
          _buildQuickActionTile(context, 'Fees & Collect', Icons.payments_outlined, Colors.greenAccent, () => context.push('/fees')),
          _buildQuickActionTile(context, 'Students', Icons.people_outline, Colors.blueAccent, () => context.push('/students')),
          _buildQuickActionTile(context, 'Faculty', Icons.cast_for_education, Colors.orangeAccent, () => context.push('/teachers')),
          _buildQuickActionTile(context, 'Classes/Batches', Icons.class_outlined, Colors.purpleAccent, () => context.push('/programs')),
          _buildQuickActionTile(context, 'Attendance', Icons.co_present, Colors.lightGreenAccent, () => context.push('/attendance')),
          _buildQuickActionTile(context, 'Exams', Icons.assignment_turned_in_outlined, Colors.deepOrangeAccent, () => context.push('/exams')),
          _buildQuickActionTile(context, 'Broadcasts', Icons.campaign_outlined, Colors.amberAccent, () => context.push('/notices')),
        ],
      );
    }

    if (role == 'teacher') {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
        children: [
          _buildQuickActionTile(context, 'Take Attendance', Icons.co_present, Colors.lightGreenAccent, () => context.push('/attendance')),
          _buildQuickActionTile(context, 'Give Homework', Icons.menu_book_outlined, Colors.cyanAccent, () => context.push('/homework')),
          _buildQuickActionTile(context, 'Class Timetable', Icons.calendar_view_week, Colors.tealAccent, () => context.push('/timetable')),
          _buildQuickActionTile(context, 'Exams & Marks', Icons.assignment_turned_in_outlined, Colors.deepOrangeAccent, () => context.push('/exams')),
          _buildQuickActionTile(context, 'My Students', Icons.people_outline, Colors.blueAccent, () => context.push('/students')),
          _buildQuickActionTile(context, 'Notice Board', Icons.campaign_outlined, Colors.amberAccent, () => context.push('/notices')),
        ],
      );
    }

    if (role == 'student') {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
        children: [
          _buildQuickActionTile(context, 'My Timetable', Icons.calendar_view_week, Colors.tealAccent, () => context.push('/timetable')),
          _buildQuickActionTile(context, 'Homework Desk', Icons.menu_book_outlined, Colors.cyanAccent, () => context.push('/homework')),
          _buildQuickActionTile(context, 'Exam Routine', Icons.assignment_turned_in_outlined, Colors.deepOrangeAccent, () => context.push('/exams')),
          _buildQuickActionTile(context, 'My Attendance', Icons.co_present, Colors.lightGreenAccent, () => context.push('/attendance')),
          _buildQuickActionTile(context, 'Pay Fees', Icons.payments_outlined, Colors.greenAccent, () => context.push('/fees')),
          _buildQuickActionTile(context, 'Notice Board', Icons.campaign_outlined, Colors.amberAccent, () => context.push('/notices')),
        ],
      );
    }

    if (role == 'guardian') {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
        children: [
          _buildQuickActionTile(context, 'Attendance Record', Icons.co_present, Colors.lightGreenAccent, () => context.push('/attendance')),
          _buildQuickActionTile(context, 'Pay Tuition Fee', Icons.payments_outlined, Colors.greenAccent, () => context.push('/fees')),
          _buildQuickActionTile(context, 'Exam Results', Icons.emoji_events_outlined, Colors.amberAccent, () => context.push('/exams')),
          _buildQuickActionTile(context, 'Homework Check', Icons.menu_book_outlined, Colors.cyanAccent, () => context.push('/homework')),
          _buildQuickActionTile(context, 'Class Routine', Icons.calendar_view_week, Colors.tealAccent, () => context.push('/timetable')),
          _buildQuickActionTile(context, 'School Notices', Icons.campaign_outlined, Colors.orangeAccent, () => context.push('/notices')),
        ],
      );
    }

    // Accountant / Finance Staff
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: [
        _buildQuickActionTile(context, 'Fee Collection', Icons.payments_outlined, Colors.greenAccent, () => context.push('/fees')),
        _buildQuickActionTile(context, 'Student Invoices', Icons.receipt_long_outlined, Colors.blueAccent, () => context.push('/fees')),
        _buildQuickActionTile(context, 'Financial Reports', Icons.insights, Colors.indigoAccent, () => context.push('/reports')),
        _buildQuickActionTile(context, 'Student Records', Icons.people_outline, Colors.orangeAccent, () => context.push('/students')),
        _buildQuickActionTile(context, 'Classes & Batches', Icons.class_outlined, Colors.purpleAccent, () => context.push('/programs')),
        _buildQuickActionTile(context, 'Announcements', Icons.campaign_outlined, Colors.tealAccent, () => context.push('/notices')),
      ],
    );
  }

  Widget _buildDesktopContent(
    BuildContext context,
    WidgetRef ref,
    dynamic currentOrg,
    dynamic currentBranch,
    dynamic currentUser,
    AsyncValue<dynamic> analyticsState,
    String role,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoleBasedBanner(context, currentOrg, currentBranch, role, currentUser),
          const SizedBox(height: 20),
          Row(
            children: [
              if (role == 'super_admin') ...[
                ElevatedButton.icon(onPressed: () => context.push('/organizations'), icon: const Icon(Icons.apartment), label: const Text('Manage Organizations')),
                const SizedBox(width: 10),
              ],
              ElevatedButton.icon(onPressed: () => context.push('/reports'), icon: const Icon(Icons.insights), label: const Text('Reports')),
              const SizedBox(width: 10),
              ElevatedButton.icon(onPressed: () => context.push('/notices'), icon: const Icon(Icons.campaign_outlined), label: const Text('Notices')),
              const SizedBox(width: 10),
              ElevatedButton.icon(onPressed: () => context.push('/fees'), icon: const Icon(Icons.payments_outlined), label: const Text('Fees')),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: analyticsState.when(
              loading: () => const Center(child: AppLoader(message: 'Loading live analytics...')),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (analytics) => _buildStatCardsForRole(context, role, analytics, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBasedBanner(BuildContext context, dynamic currentOrg, dynamic currentBranch, String role, dynamic currentUser) {
    final branchName = currentBranch != null ? currentBranch.name : 'All Branches';

    String title = currentOrg?.name ?? 'Alphie Core Platform';
    String subtitle = '$branchName • Multi-Tenant Isolated DB';

    switch (role) {
      case 'super_admin':
        title = 'SaaS Multi-Tenant Global Controller';
        subtitle = 'Super Admin Oversight • All Institutions & Campuses';
        break;
      case 'organization_admin':
        title = '${currentOrg?.name ?? "Institution"} Control Center';
        subtitle = 'Principal / Institution Head • Campus: $branchName';
        break;
      case 'branch_admin':
        title = '$branchName Administration';
        subtitle = 'Campus Manager Portal';
        break;
      case 'teacher':
        title = '${currentUser?.name ?? "Faculty Teacher"}';
        subtitle = 'Instructor Portal • Assigned Campus: $branchName';
        break;
      case 'student':
        title = '${currentUser?.name ?? "Student Portal"}';
        subtitle = 'Student Learner Terminal • Class 6 (Section A)';
        break;
      case 'guardian':
        title = '${currentUser?.name ?? "Parent Portal"}';
        subtitle = 'Parent & Guardian Monitoring Hub';
        break;
      case 'accountant':
        title = 'Finance & Accounts Terminal';
        subtitle = 'Campus: $branchName • Tuition & Ledger';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: role == 'super_admin'
              ? Colors.amberAccent.withValues(alpha: 0.4)
              : (role == 'student'
                  ? Colors.greenAccent.withValues(alpha: 0.4)
                  : (role == 'guardian' ? Colors.orangeAccent.withValues(alpha: 0.4) : Colors.white12)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            role == 'super_admin'
                ? Icons.security
                : (role == 'teacher'
                    ? Icons.cast_for_education
                    : (role == 'student'
                        ? Icons.school
                        : (role == 'guardian' ? Icons.family_restroom : Icons.domain))),
            size: 24,
            color: role == 'super_admin'
                ? Colors.amberAccent
                : (role == 'student'
                    ? Colors.greenAccent
                    : (role == 'guardian'
                        ? Colors.orangeAccent
                        : (role == 'teacher' ? Colors.purpleAccent : Colors.blueAccent))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
