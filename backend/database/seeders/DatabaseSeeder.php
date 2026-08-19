<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\Permission;
use App\Models\User;
use App\Models\Organization;
use App\Models\OrganizationUser;
use App\Models\Branch;
use App\Models\AcademicYear;
use App\Models\Program;
use App\Models\Group;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\Student;
use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\FeeHead;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\PaymentTransaction;
use App\Models\Notice;
use App\Models\TimetableSlot;
use App\Models\Exam;
use App\Models\ExamSchedule;
use App\Models\ExamMark;
use App\Models\Homework;
use App\Models\HomeworkSubmission;
use App\Models\AttendanceRecord;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Roles & Permissions Seed
        $superAdminRole = Role::firstOrCreate(['slug' => 'super_admin'], ['name' => 'Super Admin', 'description' => 'Global SaaS Platform Administrator', 'is_system_role' => true]);
        $orgAdminRole = Role::firstOrCreate(['slug' => 'organization_admin'], ['name' => 'Organization Admin', 'description' => 'Institution / School Owner & Principal', 'is_system_role' => true]);
        $branchAdminRole = Role::firstOrCreate(['slug' => 'branch_admin'], ['name' => 'Branch Manager', 'description' => 'Campus / Branch Administrator', 'is_system_role' => true]);
        $teacherRole = Role::firstOrCreate(['slug' => 'teacher'], ['name' => 'Faculty Teacher', 'description' => 'Class and Course Instructor', 'is_system_role' => true]);
        $studentRole = Role::firstOrCreate(['slug' => 'student'], ['name' => 'Student', 'description' => 'Learner / Pupil', 'is_system_role' => true]);
        $guardianRole = Role::firstOrCreate(['slug' => 'guardian'], ['name' => 'Parent / Guardian', 'description' => 'Parent / Emergency Contact', 'is_system_role' => true]);
        $accountantRole = Role::firstOrCreate(['slug' => 'accountant'], ['name' => 'Accountant / Staff', 'description' => 'Finance & Office Staff', 'is_system_role' => true]);

        // 2. Demo Organizations (School, Coaching Chain, Tech Academy)
        $school = Organization::firstOrCreate(
            ['code' => 'SCH-DHAKA-01'],
            [
                'name' => 'Dhaka Model High School & College',
                'type' => 'school',
                'phone' => '+8801700112233',
                'email' => 'contact@dhakamodel.edu.bd',
                'address' => 'Dhanmondi, Dhaka-1205',
            ]
        );

        $coaching = Organization::firstOrCreate(
            ['code' => 'COA-DHAKA-01'],
            [
                'name' => 'Apex Coaching Academy',
                'type' => 'coaching',
                'phone' => '+8801822334455',
                'email' => 'info@apexcoaching.edu',
                'address' => 'Farmgate, Dhaka',
            ]
        );

        $academy = Organization::firstOrCreate(
            ['code' => 'TRN-TECH-01'],
            [
                'name' => 'TechPro Training Center',
                'type' => 'training_center',
                'phone' => '+8801933445566',
                'email' => 'support@techpro.io',
                'address' => 'Banani, Dhaka',
            ]
        );

        // 3. Branches (Campuses)
        $mainBranch = Branch::firstOrCreate(
            ['organization_id' => $school->id, 'code' => 'MAIN'],
            ['name' => 'Main Campus (Dhanmondi)', 'is_main_branch' => true, 'address' => 'Road 27, Dhanmondi, Dhaka']
        );

        $uttaraBranch = Branch::firstOrCreate(
            ['organization_id' => $school->id, 'code' => 'UTTARA'],
            ['name' => 'Uttara Branch (Sector 7)', 'is_main_branch' => false, 'address' => 'Sector 7, Uttara, Dhaka']
        );

        $farmgateBranch = Branch::firstOrCreate(
            ['organization_id' => $coaching->id, 'code' => 'FARM'],
            ['name' => 'Farmgate Central Branch', 'is_main_branch' => true, 'address' => 'Green Road, Farmgate']
        );

        $bananiBranch = Branch::firstOrCreate(
            ['organization_id' => $academy->id, 'code' => 'BANANI'],
            ['name' => 'Banani Tech Hub', 'is_main_branch' => true, 'address' => 'Road 11, Banani, Dhaka']
        );

        // 4. Multi-Role Dedicated Users for Testing
        // A. Super Admin
        $superAdmin = User::firstOrCreate(
            ['email' => 'admin@alphiecore.edu'],
            ['name' => 'Dr. Ahmed Khan (Platform Super Admin)', 'password' => Hash::make('password123')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $superAdmin->id, 'role_id' => $superAdminRole->id],
            ['designation' => 'Global SaaS Platform Admin', 'status' => 'active']
        );

        // B. Org Admin / Principal
        $orgAdmin = User::firstOrCreate(
            ['email' => 'admin@alphiecore.com'],
            ['name' => 'Prof. Anisul Haque (School Principal)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $orgAdmin->id, 'role_id' => $orgAdminRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Principal / School Head', 'status' => 'active']
        );

        // C. Branch Admin / Campus Head
        $branchAdmin = User::firstOrCreate(
            ['email' => 'branch@alphiecore.com'],
            ['name' => 'Engr. Kamal Hossain (Campus Manager)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $branchAdmin->id, 'role_id' => $branchAdminRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Campus Manager', 'status' => 'active']
        );

        // D. Teacher
        $facultyUser = User::firstOrCreate(
            ['email' => 'teacher@alphiecore.com'],
            ['name' => 'Prof. Dr. Anisur Rahman (Senior Faculty)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $facultyUser->id, 'role_id' => $teacherRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Senior Mathematics & Science Instructor', 'status' => 'active']
        );

        // E. Student User
        $studentUser = User::firstOrCreate(
            ['email' => 'student@alphiecore.com'],
            ['name' => 'Ayman Sadik (Class 6 - Roll 01)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $studentUser->id, 'role_id' => $studentRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Regular Student', 'status' => 'active']
        );

        // F. Parent / Guardian User
        $parentUser = User::firstOrCreate(
            ['email' => 'parent@alphiecore.com'],
            ['name' => 'Sadik Hossain (Guardian of Ayman)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $parentUser->id, 'role_id' => $guardianRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Parent / Guardian', 'status' => 'active']
        );

        // G. Accountant / Finance Staff User
        $accountantUser = User::firstOrCreate(
            ['email' => 'staff@alphiecore.com'],
            ['name' => 'Tariqul Islam (Head Accountant)', 'password' => Hash::make('password')]
        );
        OrganizationUser::firstOrCreate(
            ['organization_id' => $school->id, 'user_id' => $accountantUser->id, 'role_id' => $accountantRole->id],
            ['branch_id' => $mainBranch->id, 'designation' => 'Accountant & Bursar', 'status' => 'active']
        );

        // 5. Academic Years
        $academicYear2026 = AcademicYear::firstOrCreate(
            ['organization_id' => $school->id, 'name' => 'Academic Year 2026'],
            ['start_date' => '2026-01-01', 'end_date' => '2026-12-31', 'is_current' => true]
        );

        // 6. Academic Programs (Classes)
        $programsData = [
            ['name' => 'Class 6', 'code' => 'CLS-6', 'desc' => 'Junior Secondary Grade 6'],
            ['name' => 'Class 7', 'code' => 'CLS-7', 'desc' => 'Junior Secondary Grade 7'],
            ['name' => 'Class 8', 'code' => 'CLS-8', 'desc' => 'Junior Secondary Grade 8'],
            ['name' => 'Class 9 (Science)', 'code' => 'CLS-9-SCI', 'desc' => 'Secondary Science Division'],
            ['name' => 'Class 10 (Science)', 'code' => 'CLS-10-SCI', 'desc' => 'SSC Candidate Batch'],
            ['name' => 'HSC Physics Special Batch', 'code' => 'HSC-PHY-01', 'desc' => 'Higher Secondary College Program'],
            ['name' => 'Full Stack Web Development Bootcamp', 'code' => 'TRN-FSWD-01', 'desc' => 'Professional Software Development'],
        ];

        $createdPrograms = [];
        foreach ($programsData as $p) {
            $prog = Program::firstOrCreate(
                ['organization_id' => $school->id, 'code' => $p['code']],
                ['name' => $p['name'], 'branch_id' => $mainBranch->id, 'description' => $p['desc']]
            );
            $createdPrograms[$p['code']] = $prog;

            // Sections / Groups
            Group::firstOrCreate(
                ['organization_id' => $school->id, 'program_id' => $prog->id, 'code' => $p['code'] . '-A'],
                ['name' => 'Section A (Morning)', 'branch_id' => $mainBranch->id, 'capacity' => 40]
            );
            Group::firstOrCreate(
                ['organization_id' => $school->id, 'program_id' => $prog->id, 'code' => $p['code'] . '-B'],
                ['name' => 'Section B (Day)', 'branch_id' => $mainBranch->id, 'capacity' => 40]
            );
        }

        // 7. Subjects
        $subjectsData = [
            ['name' => 'Higher Mathematics', 'code' => 'MATH-101'],
            ['name' => 'Physics & Quantum Mechanics', 'code' => 'PHY-101'],
            ['name' => 'English Language & Literature', 'code' => 'ENG-101'],
        ];
        $firstProgram = Program::where('organization_id', $school->id)->first();
        foreach ($subjectsData as $sub) {
            Subject::firstOrCreate(
                ['organization_id' => $school->id, 'code' => $sub['code']],
                ['name' => $sub['name'], 'program_id' => $firstProgram ? $firstProgram->id : 1]
            );
        }

        // 8. Teachers
        $teachersData = [
            ['name' => 'Prof. Dr. Anisur Rahman', 'emp' => 'TCH-001', 'desig' => 'Senior Math Instructor', 'sub' => ['Higher Mathematics', 'Algebra']],
            ['name' => 'Dr. Nusrat Jahan', 'emp' => 'TCH-002', 'desig' => 'Head of English Dept.', 'sub' => ['English Grammar & Composition']],
            ['name' => 'Engr. Tanvir Ahmed', 'emp' => 'TCH-003', 'desig' => 'Lead ICT & STEM Instructor', 'sub' => ['Computer Science', 'ICT']],
            ['name' => 'Farhana Akter', 'emp' => 'TCH-004', 'desig' => 'Senior Lecturer (Biology)', 'sub' => ['General Science', 'Biology']],
            ['name' => 'Mahmudul Hasan', 'emp' => 'TCH-005', 'desig' => 'Lecturer (Social Studies)', 'sub' => ['Bangladesh & Global Studies']],
        ];

        $createdTeachers = [];
        foreach ($teachersData as $t) {
            $createdTeachers[] = Teacher::firstOrCreate(
                ['organization_id' => $school->id, 'employee_no' => $t['emp']],
                [
                    'branch_id' => $mainBranch->id,
                    'name' => $t['name'],
                    'designation' => $t['desig'],
                    'qualification' => 'Master of Science',
                    'specialization' => $t['sub'][0],
                    'phone' => '+88017' . rand(10000000, 99999999),
                    'email' => strtolower(explode(' ', $t['name'])[1]) . '@alphiecore.edu',
                    'assigned_subjects' => $t['sub'],
                    'status' => 'active',
                ]
            );
        }

        // 9. Fee Heads
        $tuitionHead = FeeHead::firstOrCreate(
            ['organization_id' => $school->id, 'code' => 'FEE-TUITION'],
            ['title' => 'Monthly Tuition Fee', 'type' => 'recurring', 'default_amount' => 2500.0]
        );

        $examFeeHead = FeeHead::firstOrCreate(
            ['organization_id' => $school->id, 'code' => 'FEE-EXAM'],
            ['title' => 'Term Exam & Assessment Fee', 'type' => 'one_time', 'default_amount' => 1000.0]
        );

        // 10. Students, Enrollments, Guardians, Invoices & Attendance
        $studentsData = [
            ['first' => 'Ayman', 'last' => 'Sadik', 'gender' => 'male', 'roll' => '01', 'g_name' => 'Sadik Hossain', 'blood' => 'A+'],
            ['first' => 'Sumaiya', 'last' => 'Khan', 'gender' => 'female', 'roll' => '02', 'g_name' => 'Dr. Rafiqul Khan', 'blood' => 'B+'],
            ['first' => 'Rahim', 'last' => 'Chowdhury', 'gender' => 'male', 'roll' => '03', 'g_name' => 'Alamgir Chowdhury', 'blood' => 'O+'],
            ['first' => 'Nusrat', 'last' => 'Fariha', 'gender' => 'female', 'roll' => '04', 'g_name' => 'Enamul Haque', 'blood' => 'AB+'],
            ['first' => 'Tanvir', 'last' => 'Hasan', 'gender' => 'male', 'roll' => '05', 'g_name' => 'Zakir Hasan', 'blood' => 'A-'],
            ['first' => 'Ishrat', 'last' => 'Jahan', 'gender' => 'female', 'roll' => '06', 'g_name' => 'Md. Jahangir', 'blood' => 'O+'],
            ['first' => 'Zubair', 'last' => 'Ahmed', 'gender' => 'male', 'roll' => '07', 'g_name' => 'Tariqul Ahmed', 'blood' => 'B-'],
            ['first' => 'Maisha', 'last' => 'Tasnim', 'gender' => 'female', 'roll' => '08', 'g_name' => 'Kamal Uddin', 'blood' => 'A+'],
        ];

        $targetGroup = Group::where('code', 'CLS-6-A')->first();
        $createdStudents = [];

        foreach ($studentsData as $idx => $s) {
            $student = Student::firstOrCreate(
                ['organization_id' => $school->id, 'student_no' => 'STD-2026-00' . ($idx + 1)],
                [
                    'branch_id' => $mainBranch->id,
                    'admission_no' => 'ADM-26-0' . ($idx + 1),
                    'first_name' => $s['first'],
                    'last_name' => $s['last'],
                    'gender' => $s['gender'],
                    'blood_group' => $s['blood'],
                    'phone' => '+88018' . rand(10000000, 99999999),
                    'email' => strtolower($s['first']) . '@alphiecore.edu',
                    'status' => 'active',
                ]
            );
            $createdStudents[] = $student;

            Enrollment::firstOrCreate(
                ['student_id' => $student->id, 'group_id' => $targetGroup->id],
                [
                    'organization_id' => $school->id,
                    'branch_id' => $mainBranch->id,
                    'roll_no' => $s['roll'],
                    'status' => 'active',
                ]
            );

            $guardian = Guardian::firstOrCreate(
                ['organization_id' => $school->id, 'phone' => '+88019' . rand(10000000, 99999999)],
                [
                    'name' => $s['g_name'],
                    'relationship' => 'father',
                    'occupation' => 'Business',
                ]
            );
            $student->guardians()->syncWithoutDetaching([$guardian->id => ['is_emergency_contact' => true]]);

            // Invoices & Transactions
            $invoice = Invoice::firstOrCreate(
                ['organization_id' => $school->id, 'invoice_no' => 'INV-2026-00' . ($idx + 1)],
                [
                    'branch_id' => $mainBranch->id,
                    'student_id' => $student->id,
                    'title' => 'Tuition & Admission Fee - January 2026',
                    'total_amount' => 3500.0,
                    'paid_amount' => $idx % 2 == 0 ? 3500.0 : 1500.0,
                    'due_amount' => $idx % 2 == 0 ? 0.0 : 2000.0,
                    'due_date' => now()->addDays(10)->toDateString(),
                    'status' => $idx % 2 == 0 ? 'paid' : 'partial',
                ]
            );

            InvoiceItem::firstOrCreate(
                ['invoice_id' => $invoice->id, 'title' => 'Monthly Tuition Fee'],
                ['amount' => 2500.0]
            );
            InvoiceItem::firstOrCreate(
                ['invoice_id' => $invoice->id, 'title' => 'Laboratory & Campus Facility'],
                ['amount' => 1000.0]
            );

            if ($idx % 2 == 0) {
                PaymentTransaction::firstOrCreate(
                    ['invoice_id' => $invoice->id, 'transaction_no' => 'TRX-BKASH-00' . ($idx + 1)],
                    [
                        'payment_method' => 'bKash',
                        'amount' => 3500.0,
                        'payment_date' => now()->subDays(2),
                        'note' => 'bKash Online Payment Received',
                    ]
                );
            }

            // Attendance Records (Today)
            AttendanceRecord::firstOrCreate(
                [
                    'organization_id' => $school->id,
                    'student_id' => $student->id,
                    'group_id' => $targetGroup->id,
                    'date' => date('Y-m-d'),
                ],
                [
                    'branch_id' => $mainBranch->id,
                    'status' => $idx == 4 ? 'absent' : 'present',
                    'remark' => $idx == 4 ? 'Unexcused Leave' : 'On-Time RFID Check-in',
                ]
            );
        }

        // 11. Timetable Slots
        $mathSubject = Subject::where('code', 'MATH-101')->first();
        $phySubject = Subject::where('code', 'PHY-101')->first();

        TimetableSlot::firstOrCreate(
            ['organization_id' => $school->id, 'group_id' => $targetGroup->id, 'day_of_week' => 'Sunday', 'start_time' => '08:30:00'],
            [
                'branch_id' => $mainBranch->id,
                'subject_id' => $mathSubject ? $mathSubject->id : null,
                'teacher_id' => $createdTeachers[0]->id,
                'end_time' => '09:15:00',
                'room_no' => 'Room 301',
            ]
        );

        TimetableSlot::firstOrCreate(
            ['organization_id' => $school->id, 'group_id' => $targetGroup->id, 'day_of_week' => 'Monday', 'start_time' => '09:15:00'],
            [
                'branch_id' => $mainBranch->id,
                'subject_id' => $phySubject ? $phySubject->id : null,
                'teacher_id' => $createdTeachers[1]->id,
                'end_time' => '10:00:00',
                'room_no' => 'Lab 2',
            ]
        );

        // 12. Exams & Schedules
        $midtermExam = Exam::firstOrCreate(
            ['organization_id' => $school->id, 'title' => 'First Term Midterm Examination 2026'],
            [
                'branch_id' => $mainBranch->id,
                'code' => 'EXAM-TERM-01',
                'type' => 'term',
                'academic_year_id' => $academicYear2026->id,
                'start_date' => now()->addDays(5)->toDateString(),
                'end_date' => now()->addDays(15)->toDateString(),
                'status' => 'upcoming',
            ]
        );

        $firstProg = Program::where('organization_id', $school->id)->first();

        $schedule = ExamSchedule::firstOrCreate(
            ['exam_id' => $midtermExam->id, 'subject_id' => $mathSubject ? $mathSubject->id : 1],
            [
                'program_id' => $firstProg ? $firstProg->id : 1,
                'exam_date' => now()->addDays(6)->toDateString(),
                'start_time' => '09:00 AM',
                'end_time' => '11:00 AM',
                'full_marks' => 100.0,
                'pass_marks' => 40.0,
            ]
        );

        foreach ($createdStudents as $st) {
            ExamMark::firstOrCreate(
                ['exam_schedule_id' => $schedule->id, 'student_id' => $st->id],
                [
                    'marks_obtained' => rand(65, 95),
                    'grade' => 'A+',
                    'gpa' => 5.0,
                    'remark' => 'Excellent Performance',
                ]
            );
        }

        // 13. Homework
        $hw = Homework::firstOrCreate(
            ['organization_id' => $school->id, 'title' => 'Algebra Exercise 3.2 - Equations & Formula Proofs'],
            [
                'branch_id' => $mainBranch->id,
                'group_id' => $targetGroup->id,
                'subject_id' => $mathSubject ? $mathSubject->id : 1,
                'teacher_id' => $createdTeachers[0]->id,
                'description' => 'Complete all exercises from Page 45 to 48. Show complete step-by-step mathematical reasoning.',
                'due_date' => now()->addDays(3)->toDateString(),
                'status' => 'active',
            ]
        );

        HomeworkSubmission::firstOrCreate(
            ['homework_id' => $hw->id, 'student_id' => $createdStudents[0]->id],
            [
                'submission_text' => 'Solved all 10 quadratic and simultaneous equation problems in math notebook.',
                'submitted_at' => now()->subDay(),
                'marks_obtained' => 19.5,
                'feedback' => 'Exceptional clarity and correct method.',
                'status' => 'evaluated',
            ]
        );

        // 14. Notices
        Notice::firstOrCreate(
            ['organization_id' => $school->id, 'title' => 'Annual Cultural Week & Science Olympiad 2026'],
            [
                'branch_id' => $mainBranch->id,
                'content' => 'Registration is now live for all senior and junior students. Please contact your Class Representative or Faculty Advisor by Thursday.',
                'target_audience' => 'all',
                'priority' => 'high',
                'publish_date' => now(),
                'expiry_date' => now()->addDays(20),
            ]
        );

        Notice::firstOrCreate(
            ['organization_id' => $school->id, 'title' => 'Upcoming Holiday: Eid-ul-Fitr Campus Closure'],
            [
                'branch_id' => $mainBranch->id,
                'content' => 'The institute will remain closed from Sunday through the following Saturday for national holidays. Academic activities resume next Sunday.',
                'target_audience' => 'all',
                'priority' => 'urgent',
                'publish_date' => now()->subDays(2),
                'expiry_date' => now()->addDays(10),
            ]
        );
    }
}
