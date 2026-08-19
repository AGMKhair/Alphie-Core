SET FOREIGN_KEY_CHECKS = 0;

-- 1. Insert/Update Users (Login Credentials)
INSERT INTO `users` (`id`, `name`, `email`, `password`, `created_at`, `updated_at`) VALUES
(1, 'Dr. Ahmed Khan (Platform Super Admin)', 'admin@alphiecore.edu', '$2y$10$UGVzFlTqT5yWYSH/BKGjEeCnAuPi2LSTSUGrAv2JaEDBtxpSxikpe', NOW(), NOW()),
(2, 'Prof. Anisul Haque (School Principal)', 'admin@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW()),
(3, 'Prof. Dr. Anisur Rahman (Senior Faculty)', 'teacher@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW()),
(4, 'Ayman Sadik (Class 6 - Roll 01)', 'student@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW()),
(5, 'Sadik Hossain (Guardian of Ayman)', 'parent@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW()),
(6, 'Tariqul Islam (Head Accountant)', 'staff@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW()),
(7, 'Engr. Kamal Hossain (Campus Manager)', 'branch@alphiecore.com', '$2y$10$vokijokEr8FNn6V4pFZDCuXCSPDuImLctfiEcv/JgBKLSwFjgQuyq', NOW(), NOW())
ON DUPLICATE KEY UPDATE `password`=VALUES(`password`), `name`=VALUES(`name`);

-- 2. Insert/Update Roles
INSERT INTO `roles` (`id`, `name`, `slug`, `description`, `is_system_role`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'super_admin', 'Global SaaS Platform Administrator', 1, NOW(), NOW()),
(2, 'Organization Admin', 'organization_admin', 'Institution / School Owner & Principal', 1, NOW(), NOW()),
(3, 'Branch Manager', 'branch_admin', 'Campus / Branch Administrator', 1, NOW(), NOW()),
(4, 'Faculty Teacher', 'teacher', 'Class and Course Instructor', 1, NOW(), NOW()),
(5, 'Student', 'student', 'Learner / Pupil', 1, NOW(), NOW()),
(6, 'Parent / Guardian', 'guardian', 'Parent / Emergency Contact', 1, NOW(), NOW()),
(7, 'Accountant / Staff', 'accountant', 'Finance & Office Staff', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `description`=VALUES(`description`);

-- 3. Insert/Update Organizations
INSERT INTO `organizations` (`id`, `name`, `code`, `type`, `domain`, `logo_url`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Dhaka Model High School & College', 'SCH-DHAKA-01', 'school', NULL, NULL, '+8801700112233', 'contact@dhakamodel.edu.bd', 'Dhanmondi, Dhaka-1205', 'active', NOW(), NOW()),
(2, 'Apex Coaching Academy', 'COA-DHAKA-01', 'coaching', NULL, NULL, '+8801822334455', 'info@apexcoaching.edu', 'Farmgate, Dhaka', 'active', NOW(), NOW()),
(3, 'TechPro Training Center', 'TRN-TECH-01', 'training_center', NULL, NULL, '+8801933445566', 'support@techpro.io', 'Banani, Dhaka', 'active', NOW(), NOW())
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `status`='active';

-- 4. Insert/Update Branches
INSERT INTO `branches` (`id`, `organization_id`, `name`, `code`, `phone`, `email`, `address`, `is_main_branch`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Main Campus (Dhanmondi)', 'MAIN', NULL, NULL, 'Road 27, Dhanmondi, Dhaka', 1, 'active', NOW(), NOW()),
(2, 1, 'Uttara Branch (Sector 7)', 'UTTARA', NULL, NULL, 'Sector 7, Uttara, Dhaka', 0, 'active', NOW(), NOW()),
(3, 2, 'Farmgate Central Branch', 'FARM', NULL, NULL, 'Green Road, Farmgate', 1, 'active', NOW(), NOW()),
(4, 3, 'Banani Tech Hub', 'BANANI', NULL, NULL, 'Road 11, Banani, Dhaka', 1, 'active', NOW(), NOW())
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `status`='active';

-- 5. Insert or Replace Organization User Memberships
REPLACE INTO `organization_users` (`organization_id`, `branch_id`, `user_id`, `role_id`, `designation`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Global SaaS Platform Admin', 'active', NOW(), NOW()),
(1, 1, 2, 2, 'Principal / School Head', 'active', NOW(), NOW()),
(1, 1, 3, 4, 'Senior Mathematics & Science Instructor', 'active', NOW(), NOW()),
(1, 1, 4, 5, 'Regular Student', 'active', NOW(), NOW()),
(1, 1, 5, 6, 'Parent / Guardian', 'active', NOW(), NOW()),
(1, 1, 6, 7, 'Accountant & Bursar', 'active', NOW(), NOW()),
(1, 1, 7, 3, 'Campus Manager', 'active', NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;
