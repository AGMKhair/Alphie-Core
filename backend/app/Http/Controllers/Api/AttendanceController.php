<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AttendanceRecord;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AttendanceController extends Controller
{
    public function getGroupAttendance(Request $request): JsonResponse
    {
        $request->validate([
            'group_id' => 'required|exists:groups,id',
            'date' => 'nullable|date',
        ]);

        $targetDate = $request->date ?? date('Y-m-d');

        $students = Student::whereHas('enrollments', function ($q) use ($request) {
            $q->where('group_id', $request->group_id);
        })->get();

        $records = AttendanceRecord::where('group_id', $request->group_id)
            ->whereDate('date', $targetDate)
            ->get()
            ->keyBy('student_id');

        $result = $students->map(function ($student) use ($records, $request, $targetDate) {
            $record = $records->get($student->id);
            return [
                'id' => $record?->id ?? 0,
                'student_id' => $student->id,
                'student_name' => $student->first_name . ' ' . $student->last_name,
                'student_no' => $student->student_no,
                'roll_no' => $student->currentEnrollment?->roll_no ?? 'N/A',
                'group_id' => (int)$request->group_id,
                'date' => $targetDate,
                'status' => $record?->status ?? 'present',
                'remark' => $record?->remark,
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $result,
        ]);
    }

    public function bulkSave(Request $request): JsonResponse
    {
        $user = $request->user();
        $membership = $user?->memberships?->first();
        $role = $membership?->role?->slug ?? 'super_admin';

        // Only faculty and administrators can mark or edit attendance
        if (in_array($role, ['student', 'guardian', 'parent'])) {
            return response()->json([
                'status' => 'error',
                'message' => 'Forbidden. Students and Guardians have view-only access to attendance.',
            ], 403);
        }

        $rawEntries = $request->input('entries') ?? $request->input('records') ?? [];

        $request->merge(['entries' => $rawEntries]);

        $request->validate([
            'group_id' => 'required|exists:groups,id',
            'date' => 'nullable|date',
            'entries' => 'required|array',
            'entries.*.student_id' => 'required|exists:students,id',
            'entries.*.status' => 'required|in:present,absent,late,half_day,leave',
        ]);

        $targetDate = $request->date ?? date('Y-m-d');

        DB::transaction(function () use ($request, $targetDate, $rawEntries) {
            foreach ($rawEntries as $entry) {
                AttendanceRecord::updateOrCreate(
                    [
                        'student_id' => $entry['student_id'],
                        'group_id' => $request->group_id,
                        'date' => $targetDate,
                    ],
                    [
                        'status' => $entry['status'],
                        'remark' => $entry['remark'] ?? null,
                    ]
                );
            }
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Attendance saved successfully',
        ]);
    }
}
