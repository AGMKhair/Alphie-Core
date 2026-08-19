<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid email or password credentials provided.'],
            ]);
        }

        $user->load(['memberships.role', 'memberships.organization', 'memberships.branch']);
        $membership = $user->memberships->first();
        $roleSlug = $membership && $membership->role ? $membership->role->slug : 'super_admin';

        $token = $user->createToken('alphiecore-mobile')->plainTextToken;

        $permissions = $this->getRolePermissions($roleSlug);

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $roleSlug,
                    'organization_id' => $membership?->organization_id,
                    'branch_id' => $membership?->branch_id,
                    'organization' => $membership?->organization,
                    'branch' => $membership?->branch,
                    'permissions' => $permissions,
                ],
            ],
        ]);
    }

    public function profile(Request $request): JsonResponse
    {
        $user = $request->user()->load(['memberships.role', 'memberships.organization', 'memberships.branch']);
        $membership = $user->memberships->first();
        $roleSlug = $membership && $membership->role ? $membership->role->slug : 'super_admin';
        $permissions = $this->getRolePermissions($roleSlug);

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $roleSlug,
                'organization_id' => $membership?->organization_id,
                'branch_id' => $membership?->branch_id,
                'organization' => $membership?->organization,
                'branch' => $membership?->branch,
                'permissions' => $permissions,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Get dynamic granular permissions based on role slug
     */
    private function getRolePermissions(string $roleSlug): array
    {
        $matrix = [
            'super_admin' => [
                'attendance:view', 'attendance:manage',
                'students:view', 'students:manage',
                'teachers:view', 'teachers:manage',
                'academics:view', 'academics:manage',
                'fees:view', 'fees:manage', 'fees:collect',
                'exams:view', 'exams:manage',
                'homework:view', 'homework:manage',
                'notices:view', 'notices:manage',
                'reports:view',
                'roles:manage', 'branches:manage',
            ],
            'organization_admin' => [
                'attendance:view', 'attendance:manage',
                'students:view', 'students:manage',
                'teachers:view', 'teachers:manage',
                'academics:view', 'academics:manage',
                'fees:view', 'fees:manage', 'fees:collect',
                'exams:view', 'exams:manage',
                'homework:view', 'homework:manage',
                'notices:view', 'notices:manage',
                'reports:view',
                'roles:manage', 'branches:manage',
            ],
            'branch_admin' => [
                'attendance:view', 'attendance:manage',
                'students:view', 'students:manage',
                'teachers:view', 'teachers:manage',
                'academics:view', 'academics:manage',
                'fees:view', 'fees:manage', 'fees:collect',
                'exams:view', 'exams:manage',
                'homework:view', 'homework:manage',
                'notices:view', 'notices:manage',
                'reports:view',
            ],
            'teacher' => [
                'attendance:view', 'attendance:manage',
                'students:view',
                'academics:view',
                'exams:view', 'exams:manage',
                'homework:view', 'homework:manage',
                'notices:view', 'notices:manage',
            ],
            'accountant' => [
                'attendance:view',
                'students:view',
                'fees:view', 'fees:manage', 'fees:collect',
                'reports:view',
                'notices:view',
            ],
            'student' => [
                'attendance:view',
                'academics:view',
                'exams:view',
                'homework:view', 'homework:submit',
                'fees:view',
                'notices:view',
            ],
            'guardian' => [
                'attendance:view',
                'academics:view',
                'exams:view',
                'homework:view',
                'fees:view', 'fees:pay',
                'notices:view',
            ],
        ];

        return $matrix[$roleSlug] ?? ['attendance:view', 'academics:view', 'notices:view'];
    }
}
