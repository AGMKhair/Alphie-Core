import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../controller/timetable_controller.dart';
import '../model/timetable_model.dart';
import '../repository/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, String>(() {
  return SelectedDayNotifier();
});

final selectedTimetableGroupProvider = NotifierProvider<SelectedTimetableGroupNotifier, int?>(() {
  return SelectedTimetableGroupNotifier();
});

final timetableListControllerProvider = AsyncNotifierProvider<TimetableListController, List<TimetableSlotModel>>(() {
  return TimetableListController();
});
