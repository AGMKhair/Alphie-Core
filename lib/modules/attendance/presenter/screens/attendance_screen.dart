import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../shared/helpers/ui_helpers.dart';
import '../../../auth/provider/auth_provider.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../../programs/provider/academic_provider.dart';
import '../../model/attendance_model.dart';
import '../../provider/attendance_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(themeColorsProvider);
    final currentUser = ref.watch(authControllerProvider).value;
    final role = currentUser?.role.toLowerCase() ?? 'student';
    final canManage = ref.watch(canManageAttendanceProvider);
    final isStudentOrParent = ref.watch(isStudentOrParentProvider);

    final state = ref.watch(attendanceListControllerProvider);
    final selectedDate = ref.watch(attendanceDateProvider);
    final selectedGroupId = ref.watch(selectedAttendanceGroupProvider);
    final programsState = ref.watch(programsListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeColors.card,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  canManage ? 'Attendance Terminal' : 'Attendance Portal',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildRolePill(role, themeColors),
              ],
            ),
            if (currentOrg != null)
              Text(
                currentOrg.name,
                style: TextStyle(fontSize: 11, color: themeColors.glow.withValues(alpha: 0.8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_outlined, color: themeColors.accent),
            tooltip: 'Pick Date',
            onPressed: () => _pickDate(context, selectedDate),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Panel (Class Selector & Date Badge)
          _buildTopControlBar(context, ref, themeColors, programsState, selectedGroupId, selectedDate, canManage),

          // Main Body
          Expanded(
            child: state.when(
              loading: () => const Center(child: AppLoader(message: 'Fetching attendance sheet...')),
              error: (err, _) => AppErrorWidget(
                message: err.toString(),
                onRetry: () {
                  if (currentOrg != null && selectedGroupId != null) {
                    ref.read(attendanceListControllerProvider.notifier).fetchAttendance(
                          organizationId: currentOrg.id,
                          groupId: selectedGroupId,
                          date: selectedDate,
                        );
                  }
                },
              ),
              data: (records) {
                if (records.isEmpty) {
                  return const AppEmpty(message: 'No enrolled students found for this batch');
                }

                // Filtered records by search query
                final filteredRecords = records.where((r) {
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return r.studentName.toLowerCase().contains(q) ||
                      r.rollNo.toLowerCase().contains(q) ||
                      r.studentNo.toLowerCase().contains(q);
                }).toList();

                // Compute Stats
                final total = records.length;
                final present = records.where((r) => r.status == 'present').length;
                final absent = records.where((r) => r.status == 'absent').length;
                final lateCount = records.where((r) => r.status == 'late').length;
                final rate = total > 0 ? ((present + (lateCount * 0.5)) / total * 100).toStringAsFixed(1) : '0';

                return isStudentOrParent
                    ? _buildStudentParentView(
                        context,
                        themeColors,
                        records,
                        filteredRecords,
                        selectedDate,
                        currentUser,
                        role,
                        total,
                        present,
                        absent,
                        lateCount,
                        rate,
                      )
                    : _buildFacultyManagementView(
                        context,
                        themeColors,
                        records,
                        filteredRecords,
                        selectedDate,
                        total,
                        present,
                        absent,
                        lateCount,
                        rate,
                      );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: canManage ? _buildFacultyBottomBar(context, ref, themeColors) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Top Control Bar (Batch Dropdown + Quick Date Pills)
  // ---------------------------------------------------------------------------
  Widget _buildTopControlBar(
    BuildContext context,
    WidgetRef ref,
    ThemeColors themeColors,
    AsyncValue<List<dynamic>> programsState,
    int? selectedGroupId,
    DateTime selectedDate,
    bool canManage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: themeColors.card,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Class / Section Dropdown
              Expanded(
                child: programsState.when(
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (e, s) => const Text('Error loading batches', style: TextStyle(color: Colors.redAccent)),
                  data: (programs) {
                    final allGroups = programs.expand((p) => p.groups).toList();
                    final validGroupId = allGroups.any((g) => g.id == selectedGroupId)
                        ? selectedGroupId
                        : (allGroups.isNotEmpty ? allGroups.first.id : null);

                    if (validGroupId != selectedGroupId && validGroupId != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(selectedAttendanceGroupProvider.notifier).setGroup(validGroupId);
                      });
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: themeColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: validGroupId,
                          isExpanded: true,
                          dropdownColor: themeColors.card,
                          hint: const Text('Select Batch / Section', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.keyboard_arrow_down, color: themeColors.accent),
                          items: allGroups.map((g) {
                            return DropdownMenuItem<int>(
                              value: g.id as int,
                              child: Text(
                                '${g.name} (${g.code})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              ref.read(selectedAttendanceGroupProvider.notifier).setGroup(v);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Date Pill Button
              InkWell(
                onTap: () => _pickDate(context, selectedDate),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: themeColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 16, color: themeColors.glow),
                      const SizedBox(width: 6),
                      Text(
                        DateUtilsHelper.formatDate(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search input bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search student by name or roll...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Faculty Management View (Interactive Terminal for Teachers / Admins)
  // ---------------------------------------------------------------------------
  Widget _buildFacultyManagementView(
    BuildContext context,
    ThemeColors themeColors,
    List<AttendanceRecordModel> allRecords,
    List<AttendanceRecordModel> records,
    DateTime selectedDate,
    int total,
    int present,
    int absent,
    int lateCount,
    String rate,
  ) {
    return Column(
      children: [
        // Live Attendance Stats Bar
        _buildStatsBar(themeColors, total, present, absent, lateCount, rate),

        // Quick Action Bar (Mark All Present / All Absent)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          color: themeColors.card.withValues(alpha: 0.5),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(attendanceListControllerProvider.notifier).markAll('present'),
                  icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.greenAccent),
                  label: const Text('Mark All Present', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.greenAccent, width: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(attendanceListControllerProvider.notifier).markAll('absent'),
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                  label: const Text('Mark All Absent', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Student Attendance List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final item = records[idx];
              return _buildInteractiveStudentCard(context, themeColors, item);
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Student & Parent View (Read-Only Portal with Analytics)
  // ---------------------------------------------------------------------------
  Widget _buildStudentParentView(
    BuildContext context,
    ThemeColors themeColors,
    List<AttendanceRecordModel> allRecords,
    List<AttendanceRecordModel> records,
    DateTime selectedDate,
    dynamic currentUser,
    String role,
    int total,
    int present,
    int absent,
    int lateCount,
    String rate,
  ) {
    // Find matching student record for current student or guardian child
    final myRecord = allRecords.firstWhere(
      (r) => r.studentName.toLowerCase().contains(currentUser?.name.toLowerCase() ?? '') ||
          r.studentNo.toLowerCase().contains(currentUser?.email.split('@').first.toLowerCase() ?? ''),
      orElse: () => allRecords.first,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      children: [
        // Role Information Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  role == 'student'
                      ? 'Welcome, ${currentUser?.name ?? "Student"}. Here is your verified institutional attendance overview.'
                      : 'Parent Portal: Viewing attendance records for student (${myRecord.studentName}).',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Hero Today Status Card for Student/Child
        _buildStudentHeroStatusCard(themeColors, myRecord, selectedDate),
        const SizedBox(height: 14),

        // Class Attendance Statistics Overview
        _buildStatsBar(themeColors, total, present, absent, lateCount, rate),
        const SizedBox(height: 14),

        // Section Title: Class Daily Roster (Read-Only)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Batch Daily Roster (${records.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 12, color: Colors.white54),
                  SizedBox(width: 4),
                  Text('Read-Only View', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Read-Only Student Roster Cards
        ...records.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildReadOnlyStudentCard(themeColors, r, isSelf: r.studentId == myRecord.studentId),
            )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Interactive Student Card (For Faculty Marking Attendance)
  // ---------------------------------------------------------------------------
  Widget _buildInteractiveStudentCard(BuildContext context, ThemeColors themeColors, AttendanceRecordModel item) {
    Color statusColor = Colors.greenAccent;
    if (item.status == 'absent') statusColor = Colors.redAccent;
    if (item.status == 'late') statusColor = Colors.amberAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: themeColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Roll Avatar with glow
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.15),
              border: Border.all(color: statusColor.withValues(alpha: 0.6)),
            ),
            child: Center(
              child: Text(
                item.rollNo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${item.studentNo}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                if (item.remark != null && item.remark!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showRemarkDialog(context, item),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '📝 ${item.remark}',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Remark Icon Button
          IconButton(
            icon: Icon(Icons.edit_note, size: 20, color: item.remark != null ? Colors.amberAccent : Colors.white38),
            tooltip: 'Add/Edit Remark',
            onPressed: () => _showRemarkDialog(context, item),
          ),

          // Interactive Segmented Buttons (P / A / L)
          Container(
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusOption(themeColors, item, 'present', 'P', Colors.greenAccent),
                _buildStatusOption(themeColors, item, 'absent', 'A', Colors.redAccent),
                _buildStatusOption(themeColors, item, 'late', 'L', Colors.amberAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    ThemeColors themeColors,
    AttendanceRecordModel item,
    String statusValue,
    String label,
    Color activeColor,
  ) {
    final isSelected = item.status == statusValue;

    return InkWell(
      onTap: () {
        ref.read(attendanceListControllerProvider.notifier).updateStatus(item.studentId, statusValue);
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: activeColor, width: 1.2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? activeColor : Colors.white54,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Read-Only Student Card (For Students / Parents)
  // ---------------------------------------------------------------------------
  Widget _buildReadOnlyStudentCard(ThemeColors themeColors, AttendanceRecordModel item, {bool isSelf = false}) {
    Color statusColor = Colors.greenAccent;
    String statusLabel = 'PRESENT';
    IconData statusIcon = Icons.check_circle;

    if (item.status == 'absent') {
      statusColor = Colors.redAccent;
      statusLabel = 'ABSENT';
      statusIcon = Icons.cancel;
    } else if (item.status == 'late') {
      statusColor = Colors.amberAccent;
      statusLabel = 'LATE';
      statusIcon = Icons.access_time_filled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isSelf ? themeColors.primary.withValues(alpha: 0.12) : themeColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelf ? themeColors.primary : Colors.white.withValues(alpha: 0.08),
          width: isSelf ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isSelf ? themeColors.primary : Colors.white10,
            child: Text(
              item.rollNo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelf ? Colors.white : Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.studentName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelf ? themeColors.glow : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: themeColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('YOU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                  ],
                ),
                Text('Roll: ${item.rollNo} • ID: ${item.studentNo}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                if (item.remark != null && item.remark!.isNotEmpty)
                  Text('Remark: ${item.remark}', style: const TextStyle(color: Colors.amberAccent, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Read-only status chip badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Student Hero Today Status Card
  // ---------------------------------------------------------------------------
  Widget _buildStudentHeroStatusCard(ThemeColors themeColors, AttendanceRecordModel record, DateTime date) {
    final isPresent = record.status == 'present';
    final isLate = record.status == 'late';
    final Color badgeColor = isPresent ? Colors.greenAccent : (isLate ? Colors.amberAccent : Colors.redAccent);
    final String statusText = isPresent ? 'PRESENT' : (isLate ? 'LATE ARRIVAL' : 'ABSENT');
    final IconData statusIcon = isPresent ? Icons.check_circle : (isLate ? Icons.timer : Icons.cancel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: 0.15),
            themeColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECORD FOR ${DateUtilsHelper.formatDate(date).toUpperCase()}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.studentName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Student ID: ${record.studentNo}  •  Roll: ${record.rollNo}',
            style: TextStyle(fontSize: 12, color: themeColors.glow.withValues(alpha: 0.9)),
          ),
          if (record.remark != null && record.remark!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Instructor Remark: ${record.remark}',
                      style: const TextStyle(fontSize: 11, color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Statistics Bar
  // ---------------------------------------------------------------------------
  Widget _buildStatsBar(ThemeColors themeColors, int total, int present, int absent, int lateCount, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: themeColors.card,
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          _buildStatItem('Total', '$total', Colors.white70),
          _buildStatDivider(),
          _buildStatItem('Present', '$present', Colors.greenAccent),
          _buildStatDivider(),
          _buildStatItem('Absent', '$absent', Colors.redAccent),
          _buildStatDivider(),
          _buildStatItem('Late', '$lateCount', Colors.amberAccent),
          _buildStatDivider(),
          _buildStatItem('Rate', '$rate%', themeColors.glow),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white12,
    );
  }

  // ---------------------------------------------------------------------------
  // Faculty Bottom Bar (Save Action)
  // ---------------------------------------------------------------------------
  Widget _buildFacultyBottomBar(BuildContext context, WidgetRef ref, ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors.card,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: AppButton(
            text: 'SAVE ATTENDANCE SHEET',
            icon: Icons.cloud_upload_outlined,
            isLoading: _isSaving,
            backgroundColor: themeColors.primary,
            onPressed: () async {
              setState(() => _isSaving = true);
              final success = await ref.read(attendanceListControllerProvider.notifier).saveAttendance();
              setState(() => _isSaving = false);

              if (context.mounted) {
                if (success) {
                  UiHelpers.showSnackBar(context, 'Attendance saved successfully!');
                } else {
                  UiHelpers.showSnackBar(context, 'Failed to save attendance. Check permissions.', isError: true);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Role Pill Helper
  // ---------------------------------------------------------------------------
  Widget _buildRolePill(String role, ThemeColors themeColors) {
    Color color = themeColors.primary;
    String text = role.toUpperCase();

    if (role == 'student') {
      color = Colors.greenAccent;
      text = 'STUDENT';
    } else if (role == 'guardian' || role == 'parent') {
      color = Colors.orangeAccent;
      text = 'PARENT';
    } else if (role == 'teacher') {
      color = Colors.purpleAccent;
      text = 'TEACHER';
    } else if (role == 'super_admin') {
      color = Colors.amberAccent;
      text = 'SUPER ADMIN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date Picker & Dialog Helpers
  // ---------------------------------------------------------------------------
  Future<void> _pickDate(BuildContext context, DateTime selectedDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ref.read(attendanceDateProvider.notifier).setDate(picked);
    }
  }

  void _showRemarkDialog(BuildContext context, AttendanceRecordModel item) {
    final controller = TextEditingController(text: item.remark ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remark: ${item.studentName}'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'e.g. Sick leave, late entrance note...',
            labelText: 'Attendance Remark',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(attendanceListControllerProvider.notifier).updateRemark(
                    item.studentId,
                    controller.text.trim().isEmpty ? null : controller.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}
