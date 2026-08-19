<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NoticeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Notice::latest();

        if ($request->filled('audience') && $request->audience !== 'all') {
            $query->where(function ($q) use ($request) {
                $q->where('target_audience', $request->audience)
                  ->orWhere('target_audience', 'all');
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
            'title' => 'required|string',
            'content' => 'required|string',
            'target_audience' => 'required|in:all,students,teachers,guardians,staff',
            'priority' => 'required|in:normal,high,urgent',
            'send_sms' => 'nullable|boolean',
            'send_push' => 'nullable|boolean',
        ]);

        $notice = Notice::create($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Notice broadcasted successfully',
            'data' => $notice,
        ], 201);
    }

    public function destroy(int $id): JsonResponse
    {
        $notice = Notice::findOrFail($id);
        $notice->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Notice deleted successfully',
        ]);
    }
}
