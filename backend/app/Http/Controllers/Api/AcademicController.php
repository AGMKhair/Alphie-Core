<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Program;
use App\Models\Group;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademicController extends Controller
{
    public function getPrograms(Request $request): JsonResponse
    {
        $programs = Program::with(['groups', 'subjects'])->get();
        return response()->json([
            'status' => 'success',
            'data' => $programs,
        ]);
    }

    public function createProgram(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'code' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $program = Program::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $program,
        ], 201);
    }

    public function createGroup(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'program_id' => 'required|exists:programs,id',
            'name' => 'required|string',
            'code' => 'required|string',
            'capacity' => 'nullable|integer',
        ]);

        $group = Group::create($validated);

        return response()->json([
            'status' => 'success',
            'data' => $group,
        ], 201);
    }
}
