<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Attendance Records
        Schema::create('attendance_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->enum('status', ['present', 'absent', 'late', 'half_day', 'leave'])->default('present');
            $table->string('remark')->nullable();
            $table->timestamps();

            $table->unique(['student_id', 'group_id', 'date']);
        });

        // 2. Timetable Slots
        Schema::create('timetable_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('teacher_id')->constrained()->cascadeOnDelete();
            $table->enum('day_of_week', ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']);
            $table->string('start_time'); // 09:00 AM
            $table->string('end_time');   // 09:45 AM
            $table->string('room_no')->nullable(); // Room 201
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });

        // 3. Exams & Grading
        Schema::create('exams', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('academic_year_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title'); // 1st Term Exam 2026
            $table->string('code');
            $table->enum('type', ['term', 'class_test', 'model_test', 'final'])->default('term');
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['upcoming', 'ongoing', 'published', 'completed'])->default('upcoming');
            $table->timestamps();
        });

        Schema::create('exam_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('exam_id')->constrained()->cascadeOnDelete();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->date('exam_date');
            $table->string('start_time');
            $table->string('end_time');
            $table->double('full_marks')->default(100.0);
            $table->double('pass_marks')->default(33.0);
            $table->timestamps();
        });

        Schema::create('exam_marks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('exam_schedule_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->double('marks_obtained')->nullable();
            $table->string('grade', 10)->nullable(); // A+, A, B, etc.
            $table->double('gpa')->nullable();       // 5.0, 4.0, etc.
            $table->string('remark')->nullable();
            $table->timestamps();

            $table->unique(['exam_schedule_id', 'student_id']);
        });

        // 4. Homework & Submissions
        Schema::create('homeworks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('teacher_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('description');
            $table->date('assigned_date')->default(now());
            $table->date('due_date');
            $table->string('attachment_url')->nullable();
            $table->enum('status', ['active', 'closed'])->default('active');
            $table->timestamps();
        });

        Schema::create('homework_submissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('homework_id')->constrained('homeworks')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->dateTime('submitted_at')->default(now());
            $table->text('submission_text')->nullable();
            $table->string('file_url')->nullable();
            $table->double('marks_obtained')->nullable();
            $table->string('feedback')->nullable();
            $table->enum('status', ['submitted', 'evaluated', 'resubmit'])->default('submitted');
            $table->timestamps();

            $table->unique(['homework_id', 'student_id']);
        });

        // 5. Fees & Invoices
        Schema::create('fee_heads', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('code');
            $table->enum('type', ['recurring', 'one_time'])->default('recurring');
            $table->double('default_amount')->default(0.0);
            $table->timestamps();
        });

        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->string('invoice_no')->unique();
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->double('total_amount')->default(0.0);
            $table->double('paid_amount')->default(0.0);
            $table->double('due_amount')->default(0.0);
            $table->date('due_date');
            $table->enum('status', ['paid', 'partial', 'unpaid', 'overdue'])->default('unpaid');
            $table->timestamps();
        });

        Schema::create('invoice_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->double('amount');
            $table->timestamps();
        });

        Schema::create('payment_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('invoice_id')->constrained()->cascadeOnDelete();
            $table->string('transaction_no')->unique();
            $table->double('amount');
            $table->string('payment_method'); // cash, bKash, nagad, bank_transfer
            $table->dateTime('payment_date')->default(now());
            $table->string('note')->nullable();
            $table->timestamps();
        });

        // 6. Notices & Announcements
        Schema::create('notices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained()->nullOnDelete();
            $table->string('title');
            $table->text('content');
            $table->enum('target_audience', ['all', 'students', 'teachers', 'guardians', 'staff'])->default('all');
            $table->enum('priority', ['normal', 'high', 'urgent'])->default('normal');
            $table->dateTime('publish_date')->default(now());
            $table->dateTime('expiry_date')->nullable();
            $table->string('attachment_url')->nullable();
            $table->boolean('send_sms')->default(false);
            $table->boolean('send_push')->default(true);
            $table->string('author_name')->default('Admin');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notices');
        Schema::dropIfExists('payment_transactions');
        Schema::dropIfExists('invoice_items');
        Schema::dropIfExists('invoices');
        Schema::dropIfExists('fee_heads');
        Schema::dropIfExists('homework_submissions');
        Schema::dropIfExists('homeworks');
        Schema::dropIfExists('exam_marks');
        Schema::dropIfExists('exam_schedules');
        Schema::dropIfExists('exams');
        Schema::dropIfExists('timetable_slots');
        Schema::dropIfExists('attendance_records');
    }
};
