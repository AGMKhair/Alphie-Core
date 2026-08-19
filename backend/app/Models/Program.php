<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Program extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    public function groups(): HasMany
    {
        return $this->hasMany(Group::class);
    }

    public function subjects(): HasMany
    {
        return $this->hasMany(Subject::class);
    }
}
