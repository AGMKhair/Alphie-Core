<?php

namespace App\Models;

use App\Models\Traits\BelongsToTenant;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeeHead extends Model
{
    use HasFactory, BelongsToTenant;
    protected $guarded = [];
}
