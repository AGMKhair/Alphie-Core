import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/student_model.dart';
import '../provider/student_provider.dart';
import '../repository/student_repository.dart';

class StudentListController extends AsyncNotifier<List<StudentModel>> {
  StudentRepository get _repository => ref.read(studentRepositoryProvider);

  @override
  Future<List<StudentModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getStudents(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> fetchStudents({int? organizationId, int? branchId, int? groupId, String? search}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getStudents(
        organizationId: orgId,
        branchId: branchId,
        groupId: groupId,
        search: search,
      );
    });
  }

  Future<bool> createStudent(CreateStudentRequest request) async {
    try {
      final newStudent = await _repository.createStudent(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newStudent]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStudent(int studentId) async {
    try {
      await _repository.deleteStudent(studentId);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((s) => s.id != studentId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
