import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/academic_models.dart';
import '../provider/academic_provider.dart';
import '../repository/academic_repository.dart';

class AcademicProgramsController extends AsyncNotifier<List<ProgramModel>> {
  AcademicRepository get _repository => ref.read(academicRepositoryProvider);

  @override
  Future<List<ProgramModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getPrograms(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> loadPrograms({int? organizationId, int? branchId, int? academicYearId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getPrograms(
        organizationId: orgId,
        branchId: branchId,
        academicYearId: academicYearId,
      );
    });
  }

  Future<bool> createProgram(ProgramRequest request) async {
    try {
      final newProgram = await _repository.createProgram(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newProgram]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createGroup(GroupRequest request) async {
    try {
      final newGroup = await _repository.createGroup(request);
      final currentList = state.value ?? [];
      final updatedList = currentList.map((p) {
        if (p.id == request.programId) {
          return p.copyWith(groups: [...p.groups, newGroup]);
        }
        return p;
      }).toList();
      state = AsyncValue.data(updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }
}
