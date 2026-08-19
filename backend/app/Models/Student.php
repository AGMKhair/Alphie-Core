<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Student extends Model
{
    use HasFactory, BelongsToTenant;

    protected $guarded = [];

    public function enrollments(): HasMany
    {
        return $this->hasMany(Enrollment::class);
    }

    public function currentEnrollment(): HasOne
    {
        return $this->hasOne(Enrollment::class)->latestOfMany();
    }

    public function guardians(): BelongsToMany
    {
        return $this->belongsToMany(Guardian::class, 'guardian_student')
                    ->withPivot('is_emergency_contact');
    }
}
