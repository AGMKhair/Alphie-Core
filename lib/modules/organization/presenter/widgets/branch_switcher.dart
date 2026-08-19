import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/organization_provider.dart';

class BranchSwitcher extends ConsumerWidget {
  const BranchSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentBranch = ref.watch(currentBranchProvider);

    if (currentOrg == null || currentOrg.branches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: currentBranch?.id,
          hint: const Text('All Branches / Head Office'),
          isDense: true,
          dropdownColor: Theme.of(context).cardColor,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                '🏢 All Branches (Global)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...currentOrg.branches.map(
              (branch) => DropdownMenuItem<int?>(
                value: branch.id,
                child: Text('📍 ${branch.name} (${branch.city ?? ""})'),
              ),
            ),
          ],
          onChanged: (branchId) {
            if (branchId == null) {
              ref.read(currentBranchProvider.notifier).selectBranch(null);
            } else {
              final branch = currentOrg.branches.firstWhere((b) => b.id == branchId);
              ref.read(currentBranchProvider.notifier).selectBranch(branch);
            }
          },
        ),
      ),
    );
  }
}

class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgsState = ref.watch(organizationListControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return orgsState.when(
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, s) => const SizedBox.shrink(),
      data: (orgs) {
        if (orgs.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentOrg?.id ?? orgs.first.id,
              dropdownColor: Theme.of(context).cardColor,
              isDense: true,
              items: orgs.map((org) {
                IconData icon = Icons.school;
                if (org.type == 'coaching') icon = Icons.menu_book;
                if (org.type == 'training_center') icon = Icons.computer;

                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        org.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (orgId) {
                if (orgId != null) {
                  final org = orgs.firstWhere((o) => o.id == orgId);
                  ref.read(currentOrganizationProvider.notifier).selectOrganization(org);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
