<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Branch extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }
}
