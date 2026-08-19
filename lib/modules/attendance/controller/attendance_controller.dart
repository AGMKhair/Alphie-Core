import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/attendance_model.dart';
import '../provider/attendance_provider.dart';
import '../repository/attendance_repository.dart';

class AttendanceDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

class SelectedAttendanceGroupNotifier extends Notifier<int?> {
  @override
  int? build() => 1;

  void setGroup(int? groupId) => state = groupId;
}

class AttendanceListController extends AsyncNotifier<List<AttendanceRecordModel>> {
  AttendanceRepository get _repository => ref.read(attendanceRepositoryProvider);

  @override
  Future<List<AttendanceRecordModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final selectedDate = ref.watch(attendanceDateProvider);
    final selectedGroup = ref.watch(selectedAttendanceGroupProvider);

    final orgId = currentOrg?.id ?? 1;
    final groupId = selectedGroup ?? 1;

    return await _repository.getGroupAttendance(
      organizationId: orgId,
      groupId: groupId,
      date: selectedDate,
    );
  }

  Future<void> fetchAttendance({int? organizationId, required int groupId, required DateTime date}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getGroupAttendance(
        organizationId: orgId,
        groupId: groupId,
        date: date,
      );
    });
  }

  void updateStatus(int studentId, String newStatus, {String? remark}) {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((r) {
      if (r.studentId == studentId) {
        return r.copyWith(
          status: newStatus,
          remark: remark ?? r.remark,
        );
      }
      return r;
    }).toList();
    state = AsyncValue.data(updatedList);
  }

  void updateRemark(int studentId, String? remark) {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((r) {
      if (r.studentId == studentId) {
        return r.copyWith(remark: remark);
      }
      return r;
    }).toList();
    state = AsyncValue.data(updatedList);
  }

  void markAll(String status) {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((r) => r.copyWith(status: status)).toList();
    state = AsyncValue.data(updatedList);
  }

  Future<bool> saveAttendance() async {
    try {
      final currentList = state.value ?? [];
      final currentOrg = ref.read(currentOrganizationProvider);
      final selectedGroup = ref.read(selectedAttendanceGroupProvider) ?? 1;
      final selectedDate = ref.read(attendanceDateProvider);

      final entries = currentList.map((r) {
        return AttendanceEntry(
          studentId: r.studentId,
          status: r.status,
          remark: r.remark,
        );
      }).toList();

      await _repository.saveAttendance(
        SaveAttendanceRequest(
          organizationId: currentOrg?.id ?? 1,
          groupId: selectedGroup,
          date: selectedDate,
          entries: entries,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
