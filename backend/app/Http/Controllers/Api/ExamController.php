<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Exam;
use App\Models\ExamSchedule;
use App\Models\ExamMark;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExamController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $exams = Exam::with(['schedules.subject', 'schedules.program'])->latest()->get();
        return response()->json([
            'status' => 'success',
            'data' => $exams,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'code' => 'required|string',
            'type' => 'required|in:term,class_test,model_test,final',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
        ]);

        $exam = Exam::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $exam,
        ], 201);
    }

    public function saveMarks(Request $request): JsonResponse
    {
        $request->validate([
            'exam_schedule_id' => 'required|exists:exam_schedules,id',
            'entries' => 'required|array',
            'entries.*.student_id' => 'required|exists:students,id',
            'entries.*.marks_obtained' => 'required|numeric',
        ]);

        DB::transaction(function () use ($request) {
            foreach ($request->entries as $entry) {
                ExamMark::updateOrCreate(
                    [
                        'exam_schedule_id' => $request->exam_schedule_id,
                        'student_id' => $entry['student_id'],
                    ],
                    [
                        'marks_obtained' => $entry['marks_obtained'],
                        'grade' => $entry['grade'] ?? null,
                        'gpa' => $entry['gpa'] ?? null,
                        'remark' => $entry['remark'] ?? null,
                    ]
                );
            }
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Marks recorded successfully',
        ]);
    }
}
