import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/exam_controller.dart';
import '../model/exam_model.dart';
import '../repository/exam_repository.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final selectedExamProvider = NotifierProvider<SelectedExamNotifier, ExamModel?>(() {
  return SelectedExamNotifier();
});

final examListControllerProvider = AsyncNotifierProvider<ExamListController, List<ExamModel>>(() {
  return ExamListController();
});

final marksEntryControllerProvider = NotifierProvider<MarksEntryController, AsyncValue<List<StudentMarkEntryModel>>>(() {
  return MarksEntryController();
});
