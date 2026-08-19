class DashboardAnalyticsModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final double todayAttendancePercentage;
  final int todayPresentCount;
  final int todayAbsentCount;
  final double totalRevenue;
  final double collectedFees;
  final double dueFees;
  final List<BranchMetricModel> branchMetrics;
  final List<MonthlyRevenueTrendModel> revenueTrends;
  final List<AttendanceTrendModel> weeklyAttendanceTrends;

  DashboardAnalyticsModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.todayAttendancePercentage,
    required this.todayPresentCount,
    required this.todayAbsentCount,
    required this.totalRevenue,
    required this.collectedFees,
    required this.dueFees,
    required this.branchMetrics,
    required this.revenueTrends,
    required this.weeklyAttendanceTrends,
  });

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsModel(
      totalStudents: json['total_students'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
      totalClasses: json['total_classes'] as int? ?? 0,
      todayAttendancePercentage: (json['today_attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      todayPresentCount: json['today_present_count'] as int? ?? 0,
      todayAbsentCount: json['today_absent_count'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      collectedFees: (json['collected_fees'] as num?)?.toDouble() ?? 0.0,
      dueFees: (json['due_fees'] as num?)?.toDouble() ?? 0.0,
      branchMetrics: (json['branch_metrics'] as List<dynamic>?)
              ?.map((e) => BranchMetricModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      revenueTrends: (json['revenue_trends'] as List<dynamic>?)
              ?.map((e) => MonthlyRevenueTrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weeklyAttendanceTrends: (json['weekly_attendance_trends'] as List<dynamic>?)
              ?.map((e) => AttendanceTrendModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_classes': totalClasses,
      'today_attendance_percentage': todayAttendancePercentage,
      'today_present_count': todayPresentCount,
      'today_absent_count': todayAbsentCount,
      'total_revenue': totalRevenue,
      'collected_fees': collectedFees,
      'due_fees': dueFees,
      'branch_metrics': branchMetrics.map((b) => b.toJson()).toList(),
      'revenue_trends': revenueTrends.map((r) => r.toJson()).toList(),
      'weekly_attendance_trends': weeklyAttendanceTrends.map((w) => w.toJson()).toList(),
    };
  }
}

class BranchMetricModel {
  final int branchId;
  final String branchName;
  final int studentsCount;
  final double collectionAmount;
  final double attendanceRate;

  BranchMetricModel({
    required this.branchId,
    required this.branchName,
    required this.studentsCount,
    required this.collectionAmount,
    required this.attendanceRate,
  });

  factory BranchMetricModel.fromJson(Map<String, dynamic> json) {
    return BranchMetricModel(
      branchId: json['branch_id'] as int,
      branchName: json['branch_name'] as String? ?? '',
      studentsCount: json['students_count'] as int? ?? 0,
      collectionAmount: (json['collection_amount'] as num?)?.toDouble() ?? 0.0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'branch_name': branchName,
      'students_count': studentsCount,
      'collection_amount': collectionAmount,
      'attendance_rate': attendanceRate,
    };
  }
}

class MonthlyRevenueTrendModel {
  final String month; // Jan, Feb, Mar, Apr
  final double collected;
  final double due;

  MonthlyRevenueTrendModel({
    required this.month,
    required this.collected,
    required this.due,
  });

  factory MonthlyRevenueTrendModel.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueTrendModel(
      month: json['month'] as String? ?? '',
      collected: (json['collected'] as num?)?.toDouble() ?? 0.0,
      due: (json['due'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'collected': collected,
      'due': due,
    };
  }
}

class AttendanceTrendModel {
  final String day; // Mon, Tue, Wed, Thu, Fri
  final double presentPercentage;

  AttendanceTrendModel({
    required this.day,
    required this.presentPercentage,
  });

  factory AttendanceTrendModel.fromJson(Map<String, dynamic> json) {
    return AttendanceTrendModel(
      day: json['day'] as String? ?? '',
      presentPercentage: (json['present_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'present_percentage': presentPercentage,
    };
  }
}
