import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/homework_controller.dart';
import '../model/homework_model.dart';
import '../repository/homework_repository.dart';

final homeworkRepositoryProvider = Provider<HomeworkRepository>((ref) {
  return HomeworkRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final homeworkListControllerProvider = AsyncNotifierProvider<HomeworkListController, List<HomeworkModel>>(() {
  return HomeworkListController();
});

final homeworkSubmissionsControllerProvider = NotifierProvider<HomeworkSubmissionsController, AsyncValue<List<HomeworkSubmissionModel>>>(() {
  return HomeworkSubmissionsController();
});
