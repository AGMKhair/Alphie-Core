import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/homework_model.dart';
import '../provider/homework_provider.dart';
import '../repository/homework_repository.dart';

class HomeworkListController extends AsyncNotifier<List<HomeworkModel>> {
  HomeworkRepository get _repository => ref.read(homeworkRepositoryProvider);

  @override
  Future<List<HomeworkModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    return await _repository.getHomeworkList(
      organizationId: orgId,
      branchId: branchId,
    );
  }

  Future<void> fetchHomework({int? organizationId, int? branchId, int? groupId, int? subjectId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      return await _repository.getHomeworkList(
        organizationId: orgId,
        branchId: branchId,
        groupId: groupId,
        subjectId: subjectId,
      );
    });
  }

  Future<bool> createHomework(CreateHomeworkRequest request) async {
    try {
      final newHw = await _repository.createHomework(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newHw]);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class HomeworkSubmissionsController extends Notifier<AsyncValue<List<HomeworkSubmissionModel>>> {
  HomeworkRepository get _repository => ref.read(homeworkRepositoryProvider);

  @override
  AsyncValue<List<HomeworkSubmissionModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> fetchSubmissions(int homeworkId) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getSubmissions(homeworkId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> gradeSubmission(int submissionId, double marks, String? feedback) async {
    try {
      await _repository.gradeSubmission(
        GradeSubmissionRequest(
          submissionId: submissionId,
          marksObtained: marks,
          feedback: feedback,
        ),
      );

      final currentList = state.value ?? [];
      final updatedList = currentList.map((s) {
        if (s.id == submissionId) {
          return HomeworkSubmissionModel(
            id: s.id,
            homeworkId: s.homeworkId,
            studentId: s.studentId,
            studentName: s.studentName,
            rollNo: s.rollNo,
            studentNo: s.studentNo,
            submittedAt: s.submittedAt,
            submissionText: s.submissionText,
            fileUrl: s.fileUrl,
            marksObtained: marks,
            feedback: feedback,
            status: 'evaluated',
          );
        }
        return s;
      }).toList();

      state = AsyncValue.data(updatedList);
      return true;
    } catch (e) {
      return false;
    }
  }
}
