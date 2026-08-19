import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../organization/provider/organization_provider.dart';
import '../controller/academic_controller.dart';
import '../model/academic_models.dart';
import '../repository/academic_repository.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final academicYearsListProvider = FutureProvider<List<AcademicYearModel>>((ref) async {
  final org = ref.watch(currentOrganizationProvider);
  if (org == null) return [];
  return ref.watch(academicRepositoryProvider).getAcademicYears(org.id);
});

final programsListControllerProvider = AsyncNotifierProvider<AcademicProgramsController, List<ProgramModel>>(() {
  return AcademicProgramsController();
});
