<?php

namespace App\Models\Traits;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

trait BelongsToTenant
{
    protected static function bootBelongsToTenant(): void
    {
        static::addGlobalScope('tenant', function (Builder $builder) {
            $orgId = request()->header('X-Organization-Id');
            $branchId = request()->header('X-Branch-Id');

            if ($orgId && !empty($orgId)) {
                $table = $builder->getModel()->getTable();
                if (\Illuminate\Support\Facades\Schema::hasColumn($table, 'organization_id')) {
                    $builder->where($table . '.organization_id', $orgId);
                }
            }

            if ($branchId && !empty($branchId) && $branchId !== 'all') {
                $table = $builder->getModel()->getTable();
                if (\Illuminate\Support\Facades\Schema::hasColumn($table, 'branch_id')) {
                    $builder->where(function ($query) use ($table, $branchId) {
                        $query->where($table . '.branch_id', $branchId)
                              ->orWhereNull($table . '.branch_id');
                    });
                }
            }
        });

        static::creating(function (Model $model) {
            $orgId = request()->header('X-Organization-Id');
            $branchId = request()->header('X-Branch-Id');

            if (!isset($model->organization_id) && $orgId && \Illuminate\Support\Facades\Schema::hasColumn($model->getTable(), 'organization_id')) {
                $model->organization_id = (int)$orgId;
            }

            if (!isset($model->branch_id) && $branchId && $branchId !== 'all' && \Illuminate\Support\Facades\Schema::hasColumn($model->getTable(), 'branch_id')) {
                $model->branch_id = (int)$branchId;
            }
        });
    }

    public function scopeWithoutTenant(Builder $query): Builder
    {
        return $query->withoutGlobalScope('tenant');
    }
}
