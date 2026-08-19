<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TimetableSlot;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TimetableController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = TimetableSlot::query();

        if ($request->filled('group_id')) {
            $query->where('group_id', $request->group_id);
        }

        if ($request->filled('day_of_week')) {
            $query->where('day_of_week', $request->day_of_week);
        }

        return response()->json([
            'status' => 'success',
            'data' => $query->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'group_id' => 'required|exists:groups,id',
            'subject_id' => 'required|exists:subjects,id',
            'teacher_id' => 'required|exists:teachers,id',
            'day_of_week' => 'required|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'required|string',
            'end_time' => 'required|string',
            'room_no' => 'nullable|string',
        ]);

        $slot = TimetableSlot::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $slot,
        ], 201);
    }
}
