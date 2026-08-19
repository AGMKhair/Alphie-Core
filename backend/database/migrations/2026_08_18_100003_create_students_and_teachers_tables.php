<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Students
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('student_no')->unique(); // STD-2026-001
            $table->string('admission_no')->nullable();
            $table->string('first_name');
            $table->string('last_name')->nullable();
            $table->enum('gender', ['male', 'female', 'other'])->default('male');
            $table->date('date_of_birth')->nullable();
            $table->string('blood_group', 10)->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->text('address')->nullable();
            $table->string('photo_url')->nullable();
            $table->enum('status', ['active', 'inactive', 'transferred', 'graduated'])->default('active');
            $table->timestamps();
        });

        // 2. Guardians
        Schema::create('guardians', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name');
            $table->string('relationship')->nullable(); // Father, Mother, Guardian
            $table->string('phone');
            $table->string('email')->nullable();
            $table->string('occupation')->nullable();
            $table->timestamps();
        });

        Schema::create('guardian_student', function (Blueprint $table) {
            $table->foreignId('guardian_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->boolean('is_emergency_contact')->default(true);
            $table->primary(['guardian_id', 'student_id']);
        });

        // 3. Enrollments (Connecting Student to Class/Batch & Academic Year)
        Schema::create('enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete(); // Section / Batch
            $table->foreignId('academic_year_id')->nullable()->constrained()->nullOnDelete();
            $table->string('roll_no')->nullable();
            $table->date('enrollment_date')->default(now());
            $table->enum('status', ['active', 'promoted', 'completed', 'dropped'])->default('active');
            $table->timestamps();
        });

        // 4. Teachers & Faculty
        Schema::create('teachers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('employee_no')->unique(); // TCH-001
            $table->string('name');
            $table->string('designation'); // Senior Lecturer, Headmaster, Lead Instructor
            $table->string('qualification')->nullable();
            $table->string('specialization')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->date('join_date')->nullable();
            $table->json('assigned_subjects')->nullable();
            $table->enum('status', ['active', 'on_leave', 'resigned'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teachers');
        Schema::dropIfExists('enrollments');
        Schema::dropIfExists('guardian_student');
        Schema::dropIfExists('guardians');
        Schema::dropIfExists('students');
    }
};
