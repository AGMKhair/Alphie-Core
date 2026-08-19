import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../organization/provider/organization_provider.dart';
import '../../provider/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Analytics (${currentOrg?.name ?? ""})',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: state.when(
        loading: () => const AppLoader(message: 'Compiling analytics...'),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () {
            if (currentOrg != null) {
              ref.read(reportsControllerProvider.notifier).fetchAnalytics(organizationId: currentOrg.id);
            }
          },
        ),
        data: (analytics) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            children: [
              // Compact 2x2 Highlights Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _buildCompactMetricCard(context, 'Students', analytics.totalStudents.toString(), Icons.school, Colors.blueAccent),
                  _buildCompactMetricCard(context, 'Faculty Staff', analytics.totalTeachers.toString(), Icons.person_pin, Colors.orangeAccent),
                  _buildCompactMetricCard(context, 'Attendance', '${analytics.todayAttendancePercentage}%', Icons.co_present, Colors.greenAccent, subtext: '${analytics.todayPresentCount} P / ${analytics.todayAbsentCount} A'),
                  _buildCompactMetricCard(context, 'Fees Collected', CurrencyUtils.format(analytics.collectedFees), Icons.account_balance_wallet, Colors.purpleAccent, subtext: 'Due: ${CurrencyUtils.format(analytics.dueFees)}'),
                ],
              ),
              const SizedBox(height: 18),

              // Multi-Branch Comparative Performance
              const Text('Branch Performance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 8),
              ...analytics.branchMetrics.map((b) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(b.branchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amberAccent)),
                          Text('${b.studentsCount} Students', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Collection: ${CurrencyUtils.format(b.collectionAmount)}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
                          Text('Avg: ${b.attendanceRate}%', style: const TextStyle(fontSize: 11, color: Colors.blueAccent)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: b.attendanceRate / 100.0,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Weekly Attendance Trend
              const Text('Weekly Attendance (%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: analytics.weeklyAttendanceTrends.map((trend) {
                    return Column(
                      children: [
                        Text('${trend.presentPercentage}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.greenAccent)),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          width: 18,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Container(
                            height: (48.0 * (trend.presentPercentage / 100.0)).toDouble(),
                            width: 18,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(trend.day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Revenue Collection Trend
              const Text('Monthly Revenue (৳)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: analytics.revenueTrends.map((rev) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          SizedBox(width: 32, child: Text(rev.month, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Coll: ${CurrencyUtils.format(rev.collected)}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
                                    Text('Due: ${CurrencyUtils.format(rev.due)}', style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: rev.collected / (rev.collected + rev.due),
                                    minHeight: 4,
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactMetricCard(BuildContext context, String title, String value, IconData icon, Color color, {String? subtext}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              if (subtext != null)
                Text(subtext, style: const TextStyle(fontSize: 9.5, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}
