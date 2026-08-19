<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\Branch;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrganizationController extends Controller
{
    public function index(): JsonResponse
    {
        $orgs = Organization::with('branches')->get();
        return response()->json([
            'status' => 'success',
            'data' => $orgs,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'code' => 'required|string|unique:organizations,code',
            'type' => 'required|in:school,coaching,training_center',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'address' => 'nullable|string',
        ]);

        $org = Organization::create($validated);

        // Auto-create Main Campus branch
        $org->branches()->create([
            'name' => 'Main Campus',
            'code' => 'MAIN',
            'is_main_branch' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Organization registered successfully',
            'data' => $org->load('branches'),
        ], 201);
    }

    public function getBranches(Request $request, $organizationId): JsonResponse
    {
        $branches = Branch::where('organization_id', $organizationId)->get();
        return response()->json([
            'status' => 'success',
            'data' => $branches,
        ]);
    }

    public function storeBranch(Request $request, $organizationId): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'code' => 'required|string',
            'address' => 'nullable|string',
            'phone' => 'nullable|string',
            'city' => 'nullable|string',
            'country' => 'nullable|string',
            'is_main_branch' => 'nullable|boolean',
        ]);

        $validated['organization_id'] = (int)$organizationId;

        $branch = Branch::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Branch created successfully',
            'data' => $branch,
        ], 201);
    }
}
