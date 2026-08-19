<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notice extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    protected $casts = [
        'publish_date' => 'datetime',
        'expiry_date' => 'datetime',
        'send_sms' => 'boolean',
        'send_push' => 'boolean',
    ];
}
