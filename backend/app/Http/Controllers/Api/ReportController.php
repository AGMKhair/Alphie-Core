<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\Program;
use App\Models\Invoice;
use App\Models\AttendanceRecord;
use App\Models\Branch;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function getAnalytics(Request $request): JsonResponse
    {
        $orgId = $request->header('X-Organization-Id') ?? $request->query('organization_id');
        $branchId = $request->header('X-Branch-Id') ?? $request->query('branch_id');

        // Scoped Queries (BelongsToTenant applies automatically when header is present)
        $totalStudents = Student::count();
        $totalTeachers = Teacher::count();
        $totalClasses = Program::count();

        $today = date('Y-m-d');
        $presentToday = AttendanceRecord::whereDate('date', $today)->where('status', 'present')->count();
        $absentToday = AttendanceRecord::whereDate('date', $today)->where('status', 'absent')->count();
        $totalAttendanceToday = $presentToday + $absentToday;
        $attendanceRate = $totalAttendanceToday > 0 ? round(($presentToday / $totalAttendanceToday) * 100, 1) : 0.0;

        $collectedFees = (double)Invoice::sum('paid_amount');
        $dueFees = (double)Invoice::sum('due_amount');
        $totalRevenue = $collectedFees + $dueFees;

        // Scoped Branches Metrics
        $branchQuery = Branch::query();
        if ($orgId) {
            $branchQuery->where('organization_id', $orgId);
        }
        if ($branchId && $branchId !== 'all') {
            $branchQuery->where('id', $branchId);
        }

        $branches = $branchQuery->get()->map(function ($b) use ($today) {
            $stCount = Student::where('branch_id', $b->id)->count();
            $coll = (double)Invoice::where('branch_id', $b->id)->sum('paid_amount');
            
            $bPresent = AttendanceRecord::where('branch_id', $b->id)->whereDate('date', $today)->where('status', 'present')->count();
            $bAbsent = AttendanceRecord::where('branch_id', $b->id)->whereDate('date', $today)->where('status', 'absent')->count();
            $bTotal = $bPresent + $bAbsent;
            $bRate = $bTotal > 0 ? round(($bPresent / $bTotal) * 100, 1) : 0.0;

            return [
                'branch_id' => $b->id,
                'branch_name' => $b->name,
                'students_count' => $stCount,
                'collection_amount' => $coll,
                'attendance_rate' => $bRate,
            ];
        });

        // Dynamic Real Monthly Revenue Trends (Past 4 Months)
        $revenueTrends = [];
        for ($i = 3; $i >= 0; $i--) {
            $monthDate = Carbon::now()->subMonths($i);
            $mName = $monthDate->format('M');
            $mYear = $monthDate->year;
            $mMonth = $monthDate->month;

            $mCollected = (double)Invoice::whereYear('created_at', $mYear)
                ->whereMonth('created_at', $mMonth)
                ->sum('paid_amount');

            $mDue = (double)Invoice::whereYear('created_at', $mYear)
                ->whereMonth('created_at', $mMonth)
                ->sum('due_amount');

            $revenueTrends[] = [
                'month' => $mName,
                'collected' => $mCollected,
                'due' => $mDue,
            ];
        }

        // Dynamic Real Weekly Attendance Trends (Last 5 Active Days)
        $daysOfWeek = [
            'Sun' => Carbon::now()->startOfWeek(Carbon::SUNDAY),
            'Mon' => Carbon::now()->startOfWeek(Carbon::SUNDAY)->addDays(1),
            'Tue' => Carbon::now()->startOfWeek(Carbon::SUNDAY)->addDays(2),
            'Wed' => Carbon::now()->startOfWeek(Carbon::SUNDAY)->addDays(3),
            'Thu' => Carbon::now()->startOfWeek(Carbon::SUNDAY)->addDays(4),
        ];

        $weeklyAttendanceTrends = [];
        foreach ($daysOfWeek as $dayName => $dateObj) {
            $dStr = $dateObj->toDateString();
            $dPresent = AttendanceRecord::whereDate('date', $dStr)->where('status', 'present')->count();
            $dAbsent = AttendanceRecord::whereDate('date', $dStr)->where('status', 'absent')->count();
            $dTotal = $dPresent + $dAbsent;
            $dRate = $dTotal > 0 ? round(($dPresent / $dTotal) * 100, 1) : 0.0;

            $weeklyAttendanceTrends[] = [
                'day' => $dayName,
                'present_percentage' => $dRate,
            ];
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'total_students' => $totalStudents,
                'total_teachers' => $totalTeachers,
                'total_classes' => $totalClasses,
                'today_attendance_percentage' => $attendanceRate,
                'today_present_count' => $presentToday,
                'today_absent_count' => $absentToday,
                'total_revenue' => $totalRevenue,
                'collected_fees' => $collectedFees,
                'due_fees' => $dueFees,
                'branch_metrics' => $branches,
                'revenue_trends' => $revenueTrends,
                'weekly_attendance_trends' => $weeklyAttendanceTrends,
            ],
        ]);
    }
}
