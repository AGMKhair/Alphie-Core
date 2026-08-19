<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Organizations (Multi-Tenant root)
        Schema::create('organizations', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->enum('type', ['school', 'coaching', 'training_center'])->default('school');
            $table->string('domain')->nullable();
            $table->string('logo_url')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->text('address')->nullable();
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active');
            $table->timestamps();
        });

        // 2. Branches (Campuses)
        Schema::create('branches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('code');
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->text('address')->nullable();
            $table->boolean('is_main_branch')->default(false);
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();

            $table->unique(['organization_id', 'code']);
        });

        // 3. Roles & Permissions (RBAC)
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Super Admin, Org Admin, Teacher, Student, Guardian
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_system_role')->default(false);
            $table->timestamps();
        });

        Schema::create('permissions', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('group')->nullable();
            $table->timestamps();
        });

        Schema::create('role_permission', function (Blueprint $table) {
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->foreignId('permission_id')->constrained()->cascadeOnDelete();
            $table->primary(['role_id', 'permission_id']);
        });

        // 4. Organization Memberships
        Schema::create('organization_users', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->string('designation')->nullable();
            $table->enum('status', ['active', 'pending', 'inactive'])->default('active');
            $table->timestamps();

            $table->unique(['organization_id', 'user_id', 'role_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organization_users');
        Schema::dropIfExists('role_permission');
        Schema::dropIfExists('permissions');
        Schema::dropIfExists('roles');
        Schema::dropIfExists('branches');
        Schema::dropIfExists('organizations');
    }
};
