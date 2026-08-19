import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/teacher_model.dart';
import '../provider/teacher_provider.dart';
import '../repository/teacher_repository.dart';

class TeacherListController extends AsyncNotifier<List<TeacherModel>> {
  TeacherRepository get _repository => ref.read(teacherRepositoryProvider);

  @override
  Future<List<TeacherModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getTeachers(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> fetchTeachers({int? organizationId, int? branchId, String? search}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getTeachers(
        organizationId: orgId,
        branchId: branchId,
        search: search,
      );
    });
  }

  Future<bool> createTeacher(CreateTeacherRequest request) async {
    try {
      final newTeacher = await _repository.createTeacher(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newTeacher]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTeacher(int teacherId) async {
    try {
      await _repository.deleteTeacher(teacherId);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((t) => t.id != teacherId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
