<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Homework;
use App\Models\HomeworkSubmission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeworkController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Homework::withCount('submissions');

        if ($request->filled('group_id')) {
            $query->where('group_id', $request->group_id);
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->latest()->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'group_id' => 'required|exists:groups,id',
            'subject_id' => 'required|exists:subjects,id',
            'title' => 'required|string',
            'description' => 'required|string',
            'due_date' => 'required|date',
            'attachment_url' => 'nullable|string',
        ]);

        $hw = Homework::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $hw,
        ], 201);
    }

    public function getSubmissions(Request $request, $homeworkId): JsonResponse
    {
        $submissions = HomeworkSubmission::where('homework_id', $homeworkId)->get();
        return response()->json([
            'status' => 'success',
            'data' => $submissions,
        ]);
    }

    public function gradeSubmission(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'submission_id' => 'required|exists:homework_submissions,id',
            'marks_obtained' => 'required|numeric',
            'feedback' => 'nullable|string',
        ]);

        $sub = HomeworkSubmission::findOrFail($validated['submission_id']);
        $sub->update([
            'marks_obtained' => $validated['marks_obtained'],
            'feedback' => $validated['feedback'] ?? null,
            'status' => 'evaluated',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Graded successfully',
            'data' => $sub,
        ]);
    }
}
