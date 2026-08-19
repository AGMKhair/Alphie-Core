<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\PaymentTransaction;
use App\Models\Student;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FeeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Invoice::with(['items', 'transactions']);

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        $invoices = $query->latest()->get();

        return response()->json([
            'status' => 'success',
            'data' => $invoices,
        ]);
    }

    public function collectPayment(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'invoice_id' => 'required|exists:invoices,id',
            'amount' => 'required|numeric|min:1',
            'payment_method' => 'required|string',
            'note' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated) {
            $invoice = Invoice::findOrFail($validated['invoice_id']);

            PaymentTransaction::create([
                'invoice_id' => $invoice->id,
                'transaction_no' => 'TRX-' . strtoupper(uniqid()),
                'amount' => $validated['amount'],
                'payment_method' => $validated['payment_method'],
                'note' => $validated['note'] ?? null,
            ]);

            $newPaid = $invoice->paid_amount + $validated['amount'];
            $newDue = max(0, $invoice->total_amount - $newPaid);
            $newStatus = $newDue <= 0 ? 'paid' : 'partial';

            $invoice->update([
                'paid_amount' => $newPaid,
                'due_amount' => $newDue,
                'status' => $newStatus,
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Payment collected successfully',
                'data' => $invoice->fresh(['items', 'transactions']),
            ]);
        });
    }
}
