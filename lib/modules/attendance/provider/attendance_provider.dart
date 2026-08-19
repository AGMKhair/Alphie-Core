import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/attendance_controller.dart';
import '../model/attendance_model.dart';
import '../repository/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final attendanceDateProvider = NotifierProvider<AttendanceDateNotifier, DateTime>(() {
  return AttendanceDateNotifier();
});

final selectedAttendanceGroupProvider = NotifierProvider<SelectedAttendanceGroupNotifier, int?>(() {
  return SelectedAttendanceGroupNotifier();
});

final attendanceListControllerProvider = AsyncNotifierProvider<AttendanceListController, List<AttendanceRecordModel>>(() {
  return AttendanceListController();
});
