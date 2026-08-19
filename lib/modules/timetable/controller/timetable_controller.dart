import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/timetable_model.dart';
import '../provider/timetable_provider.dart';
import '../repository/timetable_repository.dart';

class SelectedDayNotifier extends Notifier<String> {
  @override
  String build() => 'Monday';

  void setDay(String day) => state = day;
}

class SelectedTimetableGroupNotifier extends Notifier<int?> {
  @override
  int? build() => 1;

  void setGroup(int? groupId) => state = groupId;
}

class TimetableListController extends AsyncNotifier<List<TimetableSlotModel>> {
  TimetableRepository get _repository => ref.read(timetableRepositoryProvider);

  @override
  Future<List<TimetableSlotModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final selectedGroup = ref.watch(selectedTimetableGroupProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getTimetable(
      organizationId: orgId,
      branchId: branchId,
      groupId: selectedGroup,
      dayOfWeek: selectedDay,
    );
  }

  Future<void> fetchTimetable({
    int? organizationId,
    int? branchId,
    int? groupId,
    String? dayOfWeek,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getTimetable(
        organizationId: orgId,
        branchId: branchId,
        groupId: groupId,
        dayOfWeek: dayOfWeek,
      );
    });
  }

  Future<bool> createSlot(CreateTimetableSlotRequest request) async {
    try {
      final newSlot = await _repository.createSlot(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newSlot]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSlot(int slotId) async {
    try {
      await _repository.deleteSlot(slotId);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((s) => s.id != slotId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
