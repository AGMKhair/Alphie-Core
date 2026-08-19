import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/teacher_controller.dart';
import '../model/teacher_model.dart';
import '../repository/teacher_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final teacherListControllerProvider = AsyncNotifierProvider<TeacherListController, List<TeacherModel>>(() {
  return TeacherListController();
});
