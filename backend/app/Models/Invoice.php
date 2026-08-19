<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Invoice extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    protected $casts = [
        'due_date' => 'date',
        'total_amount' => 'double',
        'paid_amount' => 'double',
        'due_amount' => 'double',
    ];

    public function items(): HasMany
    {
        return $this->hasMany(InvoiceItem::class);
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(PaymentTransaction::class);
    }
}
