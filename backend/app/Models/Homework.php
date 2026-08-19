<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Homework extends Model
{
    use HasFactory, BelongsToTenant;
    protected $table = 'homeworks';
    protected $guarded = [];

    public function submissions(): HasMany
    {
        return $this->hasMany(HomeworkSubmission::class);
    }
}
