<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Guardian;
use App\Models\Enrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StudentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Student::with(['guardians', 'currentEnrollment']);

        if ($request->filled('group_id')) {
            $query->whereHas('enrollments', function ($q) use ($request) {
                $q->where('group_id', $request->group_id);
            });
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('student_no', 'like', "%{$search}%");
            });
        }

        $students = $query->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $students->items(),
            'meta' => [
                'current_page' => $students->currentPage(),
                'total' => $students->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => 'required|string',
            'last_name' => 'nullable|string',
            'gender' => 'required|in:male,female,other',
            'blood_group' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'group_id' => 'nullable|exists:groups,id',
            'roll_no' => 'nullable|string',
            'guardian_name' => 'nullable|string',
            'guardian_phone' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated) {
            $studentNo = 'STD-' . date('Y') . '-' . str_pad(Student::withoutGlobalScope('tenant')->count() + 1, 4, '0', STR_PAD_LEFT);

            $student = Student::create([
                'student_no' => $studentNo,
                'admission_no' => 'ADM-' . date('y') . rand(100, 999),
                'first_name' => $validated['first_name'],
                'last_name' => $validated['last_name'] ?? '',
                'gender' => $validated['gender'],
                'blood_group' => $validated['blood_group'] ?? null,
                'phone' => $validated['phone'] ?? null,
                'email' => $validated['email'] ?? null,
            ]);

            // Assign Group/Batch enrollment
            if (!empty($validated['group_id'])) {
                Enrollment::create([
                    'student_id' => $student->id,
                    'group_id' => $validated['group_id'],
                    'roll_no' => $validated['roll_no'] ?? '01',
                ]);
            }

            // Map Guardian
            if (!empty($validated['guardian_name']) && !empty($validated['guardian_phone'])) {
                $guardian = Guardian::create([
                    'name' => $validated['guardian_name'],
                    'phone' => $validated['guardian_phone'],
                ]);
                $student->guardians()->attach($guardian->id);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Student admitted successfully',
                'data' => $student->load(['guardians', 'currentEnrollment']),
            ], 201);
        });
    }

    public function show(int $id): JsonResponse
    {
        $student = Student::with(['guardians', 'currentEnrollment'])->findOrFail($id);
        return response()->json([
            'status' => 'success',
            'data' => $student,
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $student = Student::findOrFail($id);

        $validated = $request->validate([
            'first_name' => 'sometimes|required|string',
            'last_name' => 'nullable|string',
            'gender' => 'sometimes|required|in:male,female,other',
            'blood_group' => 'nullable|string',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'status' => 'nullable|in:active,inactive,transferred,graduated',
        ]);

        $student->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Student record updated successfully',
            'data' => $student->fresh(['guardians', 'currentEnrollment']),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $student = Student::findOrFail($id);
        
        DB::transaction(function () use ($student) {
            $student->guardians()->detach();
            $student->enrollments()->delete();
            $student->delete();
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Student record deleted successfully',
        ]);
    }
}
