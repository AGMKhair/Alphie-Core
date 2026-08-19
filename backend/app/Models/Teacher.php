<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    protected $casts = [
        'assigned_subjects' => 'array',
        'join_date' => 'date',
    ];
}
