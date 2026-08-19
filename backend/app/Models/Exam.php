<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Exam extends Model
{
    use HasFactory, BelongsToTenant;
    protected $guarded = [];

    public function schedules(): HasMany
    {
        return $this->hasMany(ExamSchedule::class);
    }
}
