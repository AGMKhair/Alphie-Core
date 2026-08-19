<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrganizationController;
use App\Http\Controllers\Api\AcademicController;
use App\Http\Controllers\Api\StudentController;
use App\Http\Controllers\Api\TeacherController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\TimetableController;
use App\Http\Controllers\Api\ExamController;
use App\Http\Controllers\Api\HomeworkController;
use App\Http\Controllers\Api\FeeController;
use App\Http\Controllers\Api\NoticeController;
use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

// Public Authentication & Tenant Discovery
Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::get('/organizations', [OrganizationController::class, 'index']);
    Route::post('/organizations', [OrganizationController::class, 'store']);
    Route::get('/organizations/{organizationId}/branches', [OrganizationController::class, 'getBranches']);
    Route::post('/organizations/{organizationId}/branches', [OrganizationController::class, 'storeBranch']);
    
    // Developer helper route to inspect and seed all users in DB
    Route::get('/debug/users', function () {
        $dbConnection = config('database.default');
        $dbConfig = config("database.connections.{$dbConnection}");
        
        // Auto-seed demo users directly via Eloquent if not present
        $demoUsers = [
            [
                'id' => 1,
                'email' => 'admin@alphiecore.edu',
                'name' => 'Dr. Ahmed Khan (Platform Super Admin)',
                'password' => \Illuminate\Support\Facades\Hash::make('password123'),
                'role' => 'super_admin',
                'role_name' => 'Super Admin',
            ],
            [
                'id' => 2,
                'email' => 'admin@alphiecore.com',
                'name' => 'Prof. Anisul Haque (School Principal)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'organization_admin',
                'role_name' => 'Organization Admin',
            ],
            [
                'id' => 3,
                'email' => 'teacher@alphiecore.com',
                'name' => 'Prof. Dr. Anisur Rahman (Senior Faculty)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'teacher',
                'role_name' => 'Faculty Teacher',
            ],
            [
                'id' => 4,
                'email' => 'student@alphiecore.com',
                'name' => 'Ayman Sadik (Class 6 - Roll 01)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'student',
                'role_name' => 'Student',
            ],
            [
                'id' => 5,
                'email' => 'parent@alphiecore.com',
                'name' => 'Sadik Hossain (Guardian of Ayman)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'guardian',
                'role_name' => 'Parent / Guardian',
            ],
            [
                'id' => 6,
                'email' => 'staff@alphiecore.com',
                'name' => 'Tariqul Islam (Head Accountant)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'accountant',
                'role_name' => 'Accountant / Staff',
            ],
            [
                'id' => 7,
                'email' => 'branch@alphiecore.com',
                'name' => 'Engr. Kamal Hossain (Campus Manager)',
                'password' => \Illuminate\Support\Facades\Hash::make('password'),
                'role' => 'branch_admin',
                'role_name' => 'Branch Manager',
            ],
        ];

        $results = [];
        $school = \App\Models\Organization::first();
        $branch = \App\Models\Branch::first();

        foreach ($demoUsers as $du) {
            $user = \App\Models\User::where('email', $du['email'])->first();
            if (!$user) {
                $user = \App\Models\User::create([
                    'email' => $du['email'],
                    'name' => $du['name'],
                    'password' => $du['password'],
                ]);
            } else {
                $user->update([
                    'name' => $du['name'],
                    'password' => $du['password'],
                ]);
            }

            // Ensure role exists
            $role = \App\Models\Role::firstOrCreate(
                ['slug' => $du['role']],
                ['name' => $du['role_name'], 'is_system_role' => true]
            );

            // Ensure membership exists
            if ($school) {
                \App\Models\OrganizationUser::updateOrCreate(
                    [
                        'organization_id' => $school->id,
                        'user_id' => $user->id,
                        'role_id' => $role->id,
                    ],
                    [
                        'branch_id' => $branch?->id,
                        'designation' => $du['name'],
                        'status' => 'active',
                    ]
                );
            }

            $results[] = [
                'id' => $user->id,
                'email' => $user->email,
                'name' => $user->name,
                'role' => $du['role'],
            ];
        }

        $allUsers = \App\Models\User::with(['memberships.role', 'memberships.organization'])->get();

        return response()->json([
            'status' => 'success',
            'database_driver' => $dbConnection,
            'database_name' => $dbConfig['database'] ?? null,
            'count' => $allUsers->count(),
            'users' => $allUsers,
        ]);
    });

    // Developer helper route to seed demo users on production
    Route::get('/setup-demo-users', function () {
        try {
            \Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
            $migrateOutput = \Illuminate\Support\Facades\Artisan::output();

            \Illuminate\Support\Facades\Artisan::call('db:seed', ['--force' => true]);
            $seedOutput = \Illuminate\Support\Facades\Artisan::output();

            return response()->json([
                'status' => 'success',
                'message' => 'Database successfully migrated and seeded with all demo users!',
                'migrate_output' => $migrateOutput,
                'seed_output' => $seedOutput,
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ], 500);
        }
    });

    // Protected Multi-Tenant API Routes
    Route::middleware(['auth:sanctum', \App\Http\Middleware\TenantContextMiddleware::class])->group(function () {
        Route::get('/auth/profile', [AuthController::class, 'profile']);
        Route::get('/auth/me', [AuthController::class, 'profile']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // Academic Programs & Classes
        Route::get('/academic/programs', [AcademicController::class, 'getPrograms']);
        Route::post('/academic/programs', [AcademicController::class, 'createProgram']);
        Route::post('/academic/groups', [AcademicController::class, 'createGroup']);

        // Students & Admissions
        Route::get('/students', [StudentController::class, 'index']);
        Route::post('/students', [StudentController::class, 'store']);
        Route::get('/students/{id}', [StudentController::class, 'show']);
        Route::put('/students/{id}', [StudentController::class, 'update']);
        Route::delete('/students/{id}', [StudentController::class, 'destroy']);

        // Teachers & Faculty
        Route::get('/teachers', [TeacherController::class, 'index']);
        Route::post('/teachers', [TeacherController::class, 'store']);
        Route::get('/teachers/{id}', [TeacherController::class, 'show']);
        Route::put('/teachers/{id}', [TeacherController::class, 'update']);
        Route::delete('/teachers/{id}', [TeacherController::class, 'destroy']);

        // Attendance
        Route::get('/attendance/sheet', [AttendanceController::class, 'getGroupAttendance']);
        Route::post('/attendance/bulk-save', [AttendanceController::class, 'bulkSave']);

        // Timetable & Routine
        Route::get('/timetable', [TimetableController::class, 'index']);
        Route::post('/timetable', [TimetableController::class, 'store']);

        // Exams & Marks
        Route::get('/exams', [ExamController::class, 'index']);
        Route::post('/exams', [ExamController::class, 'store']);
        Route::post('/exams/save-marks', [ExamController::class, 'saveMarks']);

        // Homework & Submissions
        Route::get('/homework', [HomeworkController::class, 'index']);
        Route::post('/homework', [HomeworkController::class, 'store']);
        Route::get('/homework/{homeworkId}/submissions', [HomeworkController::class, 'getSubmissions']);
        Route::post('/homework/grade-submission', [HomeworkController::class, 'gradeSubmission']);

        // Fees & Invoicing
        Route::get('/fees/invoices', [FeeController::class, 'index']);
        Route::post('/fees/collect-payment', [FeeController::class, 'collectPayment']);

        // Notices & Announcements
        Route::get('/notices', [NoticeController::class, 'index']);
        Route::post('/notices', [NoticeController::class, 'store']);
        Route::delete('/notices/{id}', [NoticeController::class, 'destroy']);

        // Analytics & Campus Reports
        Route::get('/reports/analytics', [ReportController::class, 'getAnalytics']);
    });
});
