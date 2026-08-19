<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Academic Years
        Schema::create('academic_years', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Academic Year 2026, Summer 2026
            $table->date('start_date');
            $table->date('end_date');
            $table->boolean('is_current')->default(false);
            $table->timestamps();
        });

        // 2. Programs (Class in School / Course in Coaching & Training)
        Schema::create('programs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name'); // Class 6, HSC Physics, Web Development Bootcamp
            $table->string('code');
            $table->text('description')->nullable();
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });

        // 3. Groups (Section in School / Batch in Coaching & Training)
        Schema::create('groups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Section A, Lotus, Batch 01, Weekend Morning
            $table->string('code');
            $table->integer('capacity')->default(40);
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });

        // 4. Subjects
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Mathematics, Physics, Flutter & Dart
            $table->string('code');
            $table->enum('type', ['theory', 'practical', 'both'])->default('theory');
            $table->double('credit_or_hours')->default(1.0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
        Schema::dropIfExists('groups');
        Schema::dropIfExists('programs');
        Schema::dropIfExists('academic_years');
    }
};
