<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Teacher::query();

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('employee_no', 'like', "%{$search}%")
                  ->orWhere('designation', 'like', "%{$search}%");
            });
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'employee_no' => 'required|string',
            'name' => 'required|string',
            'designation' => 'required|string',
            'qualification' => 'nullable|string',
            'specialization' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'assigned_subjects' => 'nullable|array',
        ]);

        $teacher = Teacher::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $teacher,
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $teacher = Teacher::findOrFail($id);
        return response()->json([
            'status' => 'success',
            'data' => $teacher,
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $teacher = Teacher::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string',
            'designation' => 'sometimes|required|string',
            'qualification' => 'nullable|string',
            'specialization' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'assigned_subjects' => 'nullable|array',
            'status' => 'nullable|in:active,inactive,on_leave',
        ]);

        $teacher->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Faculty record updated successfully',
            'data' => $teacher->fresh(),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $teacher = Teacher::findOrFail($id);
        $teacher->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Faculty record deleted successfully',
        ]);
    }
}
