import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/provider/organization_provider.dart';
import '../model/exam_model.dart';
import '../provider/exam_provider.dart';
import '../repository/exam_repository.dart';

class SelectedExamNotifier extends Notifier<ExamModel?> {
  @override
  ExamModel? build() => null;

  void selectExam(ExamModel? exam) => state = exam;
}

class ExamListController extends AsyncNotifier<List<ExamModel>> {
  ExamRepository get _repository => ref.read(examRepositoryProvider);

  @override
  Future<List<ExamModel>> build() async {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    final orgId = currentOrg?.id ?? 1;
    final branchId = currentBranch?.id;

    final exams = await _repository.getExams(
      organizationId: orgId,
      branchId: branchId,
    );

    if (exams.isNotEmpty && ref.read(selectedExamProvider) == null) {
      Future.microtask(() {
        ref.read(selectedExamProvider.notifier).selectExam(exams.first);
      });
    }

    return exams;
  }

  Future<void> fetchExams({int? organizationId, int? branchId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentOrg = ref.read(currentOrganizationProvider);
      final orgId = organizationId ?? currentOrg?.id ?? 1;
      final exams = await _repository.getExams(
        organizationId: orgId,
        branchId: branchId,
      );
      if (exams.isNotEmpty && ref.read(selectedExamProvider) == null) {
        ref.read(selectedExamProvider.notifier).selectExam(exams.first);
      }
      return exams;
    });
  }

  Future<bool> createExam(CreateExamRequest request) async {
    try {
      final newExam = await _repository.createExam(request);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newExam]);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class MarksEntryController extends Notifier<AsyncValue<List<StudentMarkEntryModel>>> {
  ExamRepository get _repository => ref.read(examRepositoryProvider);

  @override
  AsyncValue<List<StudentMarkEntryModel>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadMarksForSchedule({required int scheduleId, required int groupId}) async {
    state = const AsyncValue.loading();
    try {
      final marks = await _repository.getMarksForSchedule(
        examScheduleId: scheduleId,
        groupId: groupId,
      );
      state = AsyncValue.data(marks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateMark(int studentId, double marks) {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((m) {
      if (m.studentId == studentId) {
        String grade = 'F';
        double gpa = 0.0;
        if (marks >= 80) {
          grade = 'A+';
          gpa = 5.0;
        } else if (marks >= 70) {
          grade = 'A';
          gpa = 4.0;
        } else if (marks >= 60) {
          grade = 'A-';
          gpa = 3.5;
        } else if (marks >= 50) {
          grade = 'B';
          gpa = 3.0;
        } else if (marks >= 40) {
          grade = 'C';
          gpa = 2.0;
        } else if (marks >= 33) {
          grade = 'D';
          gpa = 1.0;
        }

        return m.copyWith(
          marksObtained: marks,
          grade: grade,
          gpa: gpa,
        );
      }
      return m;
    }).toList();
    state = AsyncValue.data(updatedList);
  }

  Future<bool> saveMarks(int scheduleId) async {
    final currentMarks = state.value ?? [];
    if (currentMarks.isEmpty) return false;

    try {
      await _repository.saveMarks(
        SaveMarksRequest(
          examScheduleId: scheduleId,
          entries: currentMarks,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
