<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Organizations & Branches Indexes
        Schema::table('organizations', function (Blueprint $table) {
            $table->index(['status', 'type'], 'idx_org_status_type');
        });

        Schema::table('branches', function (Blueprint $table) {
            $table->index(['organization_id', 'status'], 'idx_branch_org_status');
        });

        // 2. Organization Users & RBAC Indexes
        Schema::table('organization_users', function (Blueprint $table) {
            $table->index(['organization_id', 'branch_id', 'status'], 'idx_org_users_lookup');
            $table->index(['user_id', 'role_id'], 'idx_org_users_user_role');
        });

        // 3. Academic Structure Indexes
        Schema::table('programs', function (Blueprint $table) {
            $table->index(['organization_id', 'branch_id', 'status'], 'idx_programs_tenant_status');
        });

        Schema::table('groups', function (Blueprint $table) {
            $table->index(['organization_id', 'program_id', 'status'], 'idx_groups_lookup');
        });

        Schema::table('subjects', function (Blueprint $table) {
            $table->index(['organization_id', 'program_id'], 'idx_subjects_tenant_program');
        });

        // 4. Students, Guardians & Enrollments Indexes
        Schema::table('students', function (Blueprint $table) {
            $table->index(['organization_id', 'branch_id', 'status'], 'idx_students_tenant_status');
            $table->index(['first_name', 'last_name'], 'idx_students_name_search');
            $table->index('phone', 'idx_students_phone');
        });

        Schema::table('enrollments', function (Blueprint $table) {
            $table->index(['organization_id', 'group_id', 'status'], 'idx_enrollments_group_status');
            $table->index(['student_id', 'academic_year_id'], 'idx_enrollments_student_year');
        });

        Schema::table('teachers', function (Blueprint $table) {
            $table->index(['organization_id', 'branch_id', 'status'], 'idx_teachers_tenant_status');
            $table->index('name', 'idx_teachers_name_search');
        });

        // 5. Operations & High-Volume Tables Indexes
        Schema::table('attendance_records', function (Blueprint $table) {
            $table->index(['organization_id', 'group_id', 'date', 'status'], 'idx_attendance_fast_query');
            $table->index(['student_id', 'date'], 'idx_attendance_student_date');
        });

        Schema::table('timetable_slots', function (Blueprint $table) {
            $table->index(['organization_id', 'group_id', 'day_of_week'], 'idx_timetable_group_day');
            $table->index(['teacher_id', 'day_of_week'], 'idx_timetable_teacher_day');
        });

        Schema::table('exams', function (Blueprint $table) {
            $table->index(['organization_id', 'status', 'start_date'], 'idx_exams_tenant_status');
        });

        Schema::table('exam_marks', function (Blueprint $table) {
            $table->index(['exam_schedule_id', 'student_id'], 'idx_marks_schedule_student');
        });

        Schema::table('homeworks', function (Blueprint $table) {
            $table->index(['organization_id', 'group_id', 'due_date'], 'idx_homework_group_due');
        });

        Schema::table('invoices', function (Blueprint $table) {
            $table->index(['organization_id', 'branch_id', 'status', 'due_date'], 'idx_invoices_report_fast');
            $table->index(['student_id', 'status'], 'idx_invoices_student_status');
        });

        Schema::table('payment_transactions', function (Blueprint $table) {
            $table->index(['invoice_id', 'payment_date'], 'idx_trx_invoice_date');
        });

        Schema::table('notices', function (Blueprint $table) {
            $table->index(['organization_id', 'target_audience', 'priority'], 'idx_notices_audience_priority');
        });
    }

    public function down(): void
    {
        Schema::table('notices', function (Blueprint $table) { $table->dropIndex('idx_notices_audience_priority'); });
        Schema::table('payment_transactions', function (Blueprint $table) { $table->dropIndex('idx_trx_invoice_date'); });
        Schema::table('invoices', function (Blueprint $table) { $table->dropIndex('idx_invoices_report_fast'); $table->dropIndex('idx_invoices_student_status'); });
        Schema::table('homeworks', function (Blueprint $table) { $table->dropIndex('idx_homework_group_due'); });
        Schema::table('exam_marks', function (Blueprint $table) { $table->dropIndex('idx_marks_schedule_student'); });
        Schema::table('exams', function (Blueprint $table) { $table->dropIndex('idx_exams_tenant_status'); });
        Schema::table('timetable_slots', function (Blueprint $table) { $table->dropIndex('idx_timetable_group_day'); $table->dropIndex('idx_timetable_teacher_day'); });
        Schema::table('attendance_records', function (Blueprint $table) { $table->dropIndex('idx_attendance_fast_query'); $table->dropIndex('idx_attendance_student_date'); });
        Schema::table('teachers', function (Blueprint $table) { $table->dropIndex('idx_teachers_tenant_status'); $table->dropIndex('idx_teachers_name_search'); });
        Schema::table('enrollments', function (Blueprint $table) { $table->dropIndex('idx_enrollments_group_status'); $table->dropIndex('idx_enrollments_student_year'); });
        Schema::table('students', function (Blueprint $table) { $table->dropIndex('idx_students_tenant_status'); $table->dropIndex('idx_students_name_search'); $table->dropIndex('idx_students_phone'); });
        Schema::table('subjects', function (Blueprint $table) { $table->dropIndex('idx_subjects_tenant_program'); });
        Schema::table('groups', function (Blueprint $table) { $table->dropIndex('idx_groups_lookup'); });
        Schema::table('programs', function (Blueprint $table) { $table->dropIndex('idx_programs_tenant_status'); });
        Schema::table('organization_users', function (Blueprint $table) { $table->dropIndex('idx_org_users_lookup'); $table->dropIndex('idx_org_users_user_role'); });
        Schema::table('branches', function (Blueprint $table) { $table->dropIndex('idx_branch_org_status'); });
        Schema::table('organizations', function (Blueprint $table) { $table->dropIndex('idx_org_status_type'); });
    }
};
