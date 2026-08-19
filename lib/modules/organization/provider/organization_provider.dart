import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../model/organization_model.dart';
import '../repository/organization_repository.dart';
import '../controller/organization_controller.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final organizationListControllerProvider = AsyncNotifierProvider<OrganizationListController, List<OrganizationModel>>(() {
  return OrganizationListController();
});

final currentOrganizationProvider = NotifierProvider<CurrentOrganizationNotifier, OrganizationModel?>(() {
  return CurrentOrganizationNotifier();
});

final currentBranchProvider = NotifierProvider<CurrentBranchNotifier, BranchModel?>(() {
  return CurrentBranchNotifier();
});

class CurrentOrganizationNotifier extends Notifier<OrganizationModel?> {
  @override
  OrganizationModel? build() {
    // Automatically trigger organizations fetch and initialize current organization
    final orgsState = ref.watch(organizationListControllerProvider);
    return orgsState.when(
      data: (orgs) => orgs.isNotEmpty ? orgs.first : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void selectOrganization(OrganizationModel org) {
    state = org;
    ref.read(organizationRepositoryProvider).switchTenantContext(
          organizationId: org.id,
          branchId: org.branches.isNotEmpty ? org.branches.first.id : null,
        );
    if (org.branches.isNotEmpty) {
      ref.read(currentBranchProvider.notifier).selectBranch(org.branches.first);
    } else {
      ref.read(currentBranchProvider.notifier).selectBranch(null);
    }
  }
}

class CurrentBranchNotifier extends Notifier<BranchModel?> {
  @override
  BranchModel? build() {
    final currentOrg = ref.watch(currentOrganizationProvider);
    if (currentOrg != null && currentOrg.branches.isNotEmpty) {
      return currentOrg.branches.first;
    }
    return null;
  }

  void selectBranch(BranchModel? branch) {
    state = branch;
    final org = ref.read(currentOrganizationProvider);
    if (org != null) {
      ref.read(organizationRepositoryProvider).switchTenantContext(
            organizationId: org.id,
            branchId: branch?.id,
          );
    }
  }
}
