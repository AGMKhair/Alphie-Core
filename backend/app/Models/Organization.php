<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Organization extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function branches(): HasMany
    {
        return $this->hasMany(Branch::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(OrganizationUser::class);
    }
}
