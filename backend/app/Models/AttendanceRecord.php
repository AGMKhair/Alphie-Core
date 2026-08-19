<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AttendanceRecord extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    protected $casts = [
        'date' => 'date',
    ];
}
