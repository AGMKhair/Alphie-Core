import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/student_controller.dart';
import '../model/student_model.dart';
import '../repository/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final studentListControllerProvider = AsyncNotifierProvider<StudentListController, List<StudentModel>>(() {
  return StudentListController();
});
