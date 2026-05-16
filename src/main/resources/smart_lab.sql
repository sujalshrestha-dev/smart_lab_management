-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 15, 2026 at 05:38 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_lab`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `lab_id` int(11) NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `payment_status` enum('UNPAID','PAID') NOT NULL DEFAULT 'UNPAID',
  `notes` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `patient_id`, `lab_id`, `appointment_date`, `appointment_time`, `status`, `payment_status`, `notes`, `created_at`, `updated_at`) VALUES
(8, 2, 6, '0023-12-31', '12:33:00', 'PENDING', 'PAID', '', '2026-02-21 12:20:41', '2026-03-23 18:00:58'),
(9, 2, 3, '0023-12-31', '18:19:00', 'COMPLETED', 'PAID', '', '2026-02-21 12:34:59', '2026-02-21 12:42:45'),
(10, 2, 3, '0023-12-31', '12:33:00', 'COMPLETED', 'PAID', '', '2026-02-21 12:50:50', '2026-02-21 13:03:54'),
(11, 2, 3, '0056-07-06', '18:49:00', 'COMPLETED', 'PAID', '', '2026-02-21 13:05:02', '2026-02-21 13:05:32'),
(12, 16, 3, '3123-12-12', '19:41:00', 'COMPLETED', 'PAID', '', '2026-02-21 13:55:57', '2026-02-21 13:57:19'),
(13, 16, 3, '0023-12-31', '08:02:00', 'COMPLETED', 'PAID', '', '2026-02-21 14:17:49', '2026-02-21 14:19:13'),
(14, 2, 3, '2026-03-02', '10:11:00', 'COMPLETED', 'PAID', '', '2026-02-22 03:24:55', '2026-02-22 03:26:36'),
(15, 2, 3, '2027-02-08', '00:33:00', 'COMPLETED', 'PAID', '', '2026-03-02 03:30:41', '2026-03-23 18:13:43'),
(16, 2, 3, '2027-02-03', '12:53:00', 'COMPLETED', 'PAID', '', '2026-03-23 18:07:34', '2026-03-23 18:13:38'),
(17, 2, 3, '2027-01-23', NULL, 'COMPLETED', 'PAID', '', '2026-03-23 18:09:56', '2026-03-23 18:23:50'),
(18, 2, 3, '2027-06-05', '06:47:00', 'COMPLETED', 'PAID', '', '2026-03-24 01:03:01', '2026-03-24 01:03:32');

--
-- Triggers `appointments`
--
DELIMITER $$
CREATE TRIGGER `trg_appt_patient_role_ins` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.id = NEW.patient_id
      AND u.role = 'PATIENT'
      AND u.status = 'ACTIVE'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'appointments.patient_id must reference an ACTIVE PATIENT user';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_appt_patient_role_upd` BEFORE UPDATE ON `appointments` FOR EACH ROW BEGIN
  IF NEW.patient_id <> OLD.patient_id THEN
    IF NOT EXISTS (
      SELECT 1
      FROM users u
      WHERE u.id = NEW.patient_id
        AND u.role = 'PATIENT'
        AND u.status = 'ACTIVE'
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'appointments.patient_id must reference an ACTIVE PATIENT user';
    END IF;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_appt_slot_conflict_ins` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
  IF NEW.appointment_time IS NOT NULL
     AND NEW.status IN ('PENDING', 'APPROVED')
     AND EXISTS (
       SELECT 1
       FROM appointments a
       WHERE a.lab_id = NEW.lab_id
         AND a.appointment_date = NEW.appointment_date
         AND a.appointment_time = NEW.appointment_time
         AND a.status IN ('PENDING', 'APPROVED')
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Appointment slot already reserved for this lab/date/time';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_appt_slot_conflict_upd` BEFORE UPDATE ON `appointments` FOR EACH ROW BEGIN
  IF NEW.appointment_time IS NOT NULL
     AND NEW.status IN ('PENDING', 'APPROVED')
     AND EXISTS (
       SELECT 1
       FROM appointments a
       WHERE a.lab_id = NEW.lab_id
         AND a.appointment_date = NEW.appointment_date
         AND a.appointment_time = NEW.appointment_time
         AND a.status IN ('PENDING', 'APPROVED')
         AND a.id <> OLD.id
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Appointment slot already reserved for this lab/date/time';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `appointment_tests`
--

CREATE TABLE `appointment_tests` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `test_id` int(11) NOT NULL,
  `price_snapshot` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointment_tests`
--

INSERT INTO `appointment_tests` (`id`, `appointment_id`, `test_id`, `price_snapshot`, `created_at`) VALUES
(14, 8, 16, 580.00, '2026-02-21 12:20:41'),
(15, 8, 18, 1350.00, '2026-02-21 12:20:41'),
(16, 8, 17, 1250.00, '2026-02-21 12:20:41'),
(17, 8, 19, 280.00, '2026-02-21 12:20:41'),
(18, 9, 6, 350.00, '2026-02-21 12:34:59'),
(19, 9, 5, 650.00, '2026-02-21 12:34:59'),
(20, 9, 8, 1400.00, '2026-02-21 12:34:59'),
(21, 9, 7, 1200.00, '2026-02-21 12:34:59'),
(22, 10, 6, 350.00, '2026-02-21 12:50:50'),
(23, 10, 5, 650.00, '2026-02-21 12:50:50'),
(24, 10, 7, 1200.00, '2026-02-21 12:50:50'),
(25, 11, 6, 350.00, '2026-02-21 13:05:02'),
(26, 11, 5, 650.00, '2026-02-21 13:05:02'),
(27, 11, 7, 1200.00, '2026-02-21 13:05:02'),
(28, 12, 6, 350.00, '2026-02-21 13:55:57'),
(29, 12, 5, 650.00, '2026-02-21 13:55:57'),
(30, 13, 6, 350.00, '2026-02-21 14:17:49'),
(31, 13, 5, 650.00, '2026-02-21 14:17:49'),
(32, 14, 6, 350.00, '2026-02-22 03:24:55'),
(33, 14, 5, 650.00, '2026-02-22 03:24:55'),
(34, 14, 40, 200.00, '2026-02-22 03:24:55'),
(35, 15, 6, 350.00, '2026-03-02 03:30:41'),
(36, 15, 40, 200.00, '2026-03-02 03:30:41'),
(37, 16, 6, 350.00, '2026-03-23 18:07:34'),
(38, 16, 5, 650.00, '2026-03-23 18:07:34'),
(39, 16, 40, 200.00, '2026-03-23 18:07:34'),
(40, 17, 6, 350.00, '2026-03-23 18:09:56'),
(41, 17, 5, 650.00, '2026-03-23 18:09:56'),
(42, 18, 6, 350.00, '2026-03-24 01:03:01'),
(43, 18, 5, 650.00, '2026-03-24 01:03:01'),
(44, 18, 40, 200.00, '2026-03-24 01:03:01');

--
-- Triggers `appointment_tests`
--
DELIMITER $$
CREATE TRIGGER `trg_appt_test_available_ins` BEFORE INSERT ON `appointment_tests` FOR EACH ROW BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM tests t
    JOIN appointments a ON a.id = NEW.appointment_id
    WHERE t.id = NEW.test_id
      AND t.availability = 'AVAILABLE'
      AND t.lab_id = a.lab_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'test_id must be AVAILABLE and belong to the same lab as appointment';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_appt_test_available_upd` BEFORE UPDATE ON `appointment_tests` FOR EACH ROW BEGIN
  IF (NEW.appointment_id <> OLD.appointment_id) OR (NEW.test_id <> OLD.test_id) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM tests t
      JOIN appointments a ON a.id = NEW.appointment_id
      WHERE t.id = NEW.test_id
        AND t.availability = 'AVAILABLE'
        AND t.lab_id = a.lab_id
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'test_id must be AVAILABLE and belong to the same lab as appointment';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `labs`
--

CREATE TABLE `labs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `lab_name` varchar(120) NOT NULL,
  `city` varchar(80) NOT NULL,
  `address` varchar(255) NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `description` text DEFAULT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `labs`
--

INSERT INTO `labs` (`id`, `user_id`, `lab_name`, `city`, `address`, `latitude`, `longitude`, `description`, `verified`, `verified_at`, `created_at`, `updated_at`) VALUES
(3, 6, 'Norvic International Hospital - Diagnostic Lab', 'Kathmandu', 'Thapathali, Kathmandu, Nepal', 27.6946000, 85.3188000, 'Multi-specialty diagnostics near Thapathali.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(4, 7, 'Grande International Hospital - Lab Services', 'Kathmandu', 'Dhapasi, Tokha, Kathmandu, Nepal', 27.7421000, 85.3276000, 'General and specialized pathology services.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(5, 8, 'Dhulikhel Hospital (Kathmandu Unit) - Lab', 'Kathmandu', 'Sinamangal, Kathmandu, Nepal', 27.6995000, 85.3542000, 'Outreach diagnostics and routine blood chemistry.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(6, 9, 'B&B Hospital - Laboratory', 'Lalitpur', 'Gwarko, Lalitpur, Nepal', 27.6669000, 85.3360000, 'Routine and emergency lab support.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(7, 10, 'Nepal Mediciti Hospital - Diagnostics', 'Lalitpur', 'Bhaisepati, Lalitpur, Nepal', 27.6587000, 85.3076000, 'Comprehensive diagnostics and advanced panels.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(8, 11, 'Bhaktapur Hospital - Lab Unit', 'Bhaktapur', 'Dudhpati, Bhaktapur, Nepal', 27.6712000, 85.4298000, 'Affordable public-facing lab services.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(9, 12, 'Patan Hospital - Lab Services', 'Lalitpur', 'Lagankhel, Lalitpur, Nepal', 27.6668000, 85.3223000, 'Hospital lab with broad routine testing.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(10, 13, 'Kirtipur Hospital - Diagnostic Lab', 'Kathmandu', 'Kirtipur, Kathmandu, Nepal', 27.6784000, 85.2793000, 'Community diagnostics for nearby areas.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(11, 14, 'HAMS Hospital - Lab Desk', 'Kathmandu', 'Mandikhatar, Kathmandu, Nepal', 27.7311000, 85.3457000, 'Inpatient and outpatient pathology.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(12, 15, 'Civil Service Hospital - Lab', 'Kathmandu', 'Minbhawan, New Baneshwor, Kathmandu, Nepal', 27.6939000, 85.3432000, 'Government-linked diagnostic services.', 1, '2026-02-21 12:09:04', '2026-02-21 12:09:04', '2026-02-21 12:09:04');

--
-- Triggers `labs`
--
DELIMITER $$
CREATE TRIGGER `trg_labs_role_check_ins` BEFORE INSERT ON `labs` FOR EACH ROW BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.id = NEW.user_id
      AND u.role = 'LAB_STAFF'
      AND u.status = 'ACTIVE'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'labs.user_id must reference an ACTIVE LAB_STAFF user';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_labs_role_check_upd` BEFORE UPDATE ON `labs` FOR EACH ROW BEGIN
  IF NEW.user_id <> OLD.user_id THEN
    IF NOT EXISTS (
      SELECT 1
      FROM users u
      WHERE u.id = NEW.user_id
        AND u.role = 'LAB_STAFF'
        AND u.status = 'ACTIVE'
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'labs.user_id must reference an ACTIVE LAB_STAFF user';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `lab_photos`
--

CREATE TABLE `lab_photos` (
  `id` int(11) NOT NULL,
  `lab_id` int(11) NOT NULL,
  `photo_path` varchar(255) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lab_verification_log`
--

CREATE TABLE `lab_verification_log` (
  `id` int(11) NOT NULL,
  `lab_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `action` enum('APPROVED','REJECTED','BLOCKED','UNBLOCKED') NOT NULL,
  `notes` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `lab_verification_log`
--
DELIMITER $$
CREATE TRIGGER `trg_verify_admin_role_ins` BEFORE INSERT ON `lab_verification_log` FOR EACH ROW BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.id = NEW.admin_id
      AND u.role = 'ADMIN'
      AND u.status = 'ACTIVE'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'lab_verification_log.admin_id must reference an ACTIVE ADMIN user';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_verify_admin_role_upd` BEFORE UPDATE ON `lab_verification_log` FOR EACH ROW BEGIN
  IF NEW.admin_id <> OLD.admin_id THEN
    IF NOT EXISTS (
      SELECT 1
      FROM users u
      WHERE u.id = NEW.admin_id
        AND u.role = 'ADMIN'
        AND u.status = 'ACTIVE'
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'lab_verification_log.admin_id must reference an ACTIVE ADMIN user';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `patient_details`
--

CREATE TABLE `patient_details` (
  `user_id` int(11) NOT NULL,
  `date_of_birth` date NOT NULL,
  `emergency_contact` varchar(25) NOT NULL,
  `address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `patient_details`
--

INSERT INTO `patient_details` (`user_id`, `date_of_birth`, `emergency_contact`, `address`) VALUES
(2, '2004-01-10', '981233232', 'Boudha'),
(5, '0023-12-31', '981233232', 'boudha'),
(16, '0023-12-31', '981233232', 'Kathmandu'),
(17, '2004-01-28', '981233232', 'boudha');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `method` enum('CASH','ESEWA','KHALTI','BANK_TRANSFER') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
  `transaction_ref` varchar(120) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `appointment_id`, `method`, `amount`, `status`, `transaction_ref`, `created_at`, `paid_at`) VALUES
(5, 8, 'KHALTI', 3460.00, 'SUCCESS', NULL, '2026-02-21 12:20:41', '2026-03-23 18:00:58'),
(6, 9, 'CASH', 3600.00, 'SUCCESS', NULL, '2026-02-21 12:34:59', '2026-02-21 12:36:48'),
(7, 10, 'ESEWA', 2200.00, 'SUCCESS', NULL, '2026-02-21 12:50:50', '2026-02-21 13:03:40'),
(8, 11, 'ESEWA', 2200.00, 'SUCCESS', NULL, '2026-02-21 13:05:02', '2026-02-21 13:05:26'),
(9, 12, 'ESEWA', 1000.00, 'SUCCESS', NULL, '2026-02-21 13:55:57', '2026-02-21 13:57:09'),
(10, 13, 'BANK_TRANSFER', 1000.00, 'SUCCESS', NULL, '2026-02-21 14:17:49', '2026-02-21 14:19:00'),
(11, 14, 'ESEWA', 1200.00, 'SUCCESS', NULL, '2026-02-22 03:24:55', '2026-02-22 03:26:00'),
(12, 15, 'BANK_TRANSFER', 550.00, 'SUCCESS', NULL, '2026-03-02 03:30:41', '2026-03-23 18:00:52'),
(13, 16, 'KHALTI', 1200.00, 'SUCCESS', NULL, '2026-03-23 18:07:34', '2026-03-23 18:08:34'),
(14, 17, 'KHALTI', 1000.00, 'SUCCESS', NULL, '2026-03-23 18:09:56', '2026-03-23 18:19:40'),
(15, 18, 'KHALTI', 1200.00, 'SUCCESS', NULL, '2026-03-24 01:03:01', '2026-03-24 01:03:26');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `appointment_id`, `file_path`, `uploaded_by`, `uploaded_at`) VALUES
(2, 9, 'uploads/report_9_01f80135-3c5a-4420-8ad6-8830a20086ca.pdf', 6, '2026-02-21 12:42:45'),
(3, 10, 'uploads/report_10_4f4a678a-9684-4d81-a38c-66d09f81d7d2.pdf', 6, '2026-02-21 13:03:54'),
(4, 11, 'uploads/report_11_b58f7579-9a22-46a3-8fd8-a7345bd4d8d4.pdf', 6, '2026-02-21 13:05:32'),
(5, 12, 'uploads/report_12_8ea0eb8e-1da3-49e0-9c4f-d201c7a5023f.pdf', 6, '2026-02-21 13:57:19'),
(6, 13, 'uploads/report_13_c357b192-9645-4a11-98fd-e6e4cc1301a5.pdf', 6, '2026-02-21 14:19:13'),
(7, 14, 'uploads/report_14_99ad9a9b-4fbf-4e26-8a3a-9872aab12c6a.png', 6, '2026-02-22 03:26:36'),
(8, 16, 'uploads/report_16_a3344397-800a-4c14-bc31-307f85030f7d.jpg', 6, '2026-03-23 18:13:38'),
(9, 15, 'uploads/report_15_8afe57b9-49a7-4fd9-a230-f19260ee5d3e.jpg', 6, '2026-03-23 18:13:43'),
(10, 17, 'uploads/report_17_f088889d-2fe2-4ae3-9298-31e4a5d3a1e3.png', 6, '2026-03-23 18:23:50'),
(11, 18, 'uploads/report_18_490fdf91-f2e8-48e0-a53b-31027a93d14f.jpg', 6, '2026-03-24 01:03:32');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `lab_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` varchar(800) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `appointment_id`, `patient_id`, `lab_id`, `rating`, `comment`, `created_at`) VALUES
(1, 11, 2, 3, 5, 'Good Service', '2026-02-21 13:51:09'),
(2, 12, 16, 3, 5, NULL, '2026-02-21 13:58:20'),
(3, 13, 16, 3, 5, 'Good Service', '2026-02-21 14:20:15'),
(4, 18, 2, 3, 5, NULL, '2026-04-09 16:58:13'),
(5, 15, 2, 3, 5, NULL, '2026-04-09 16:58:16'),
(6, 16, 2, 3, 5, NULL, '2026-04-09 16:58:20'),
(7, 17, 2, 3, 5, NULL, '2026-04-09 16:58:23'),
(8, 14, 2, 3, 5, NULL, '2026-04-09 16:58:26');

--
-- Triggers `reviews`
--
DELIMITER $$
CREATE TRIGGER `trg_review_consistency_ins` BEFORE INSERT ON `reviews` FOR EACH ROW BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.id = NEW.appointment_id
      AND a.patient_id = NEW.patient_id
      AND a.lab_id = NEW.lab_id
      AND a.status = 'COMPLETED'
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Review must match appointment patient/lab and appointment must be COMPLETED';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_review_consistency_upd` BEFORE UPDATE ON `reviews` FOR EACH ROW BEGIN
  IF (NEW.appointment_id <> OLD.appointment_id)
     OR (NEW.patient_id <> OLD.patient_id)
     OR (NEW.lab_id <> OLD.lab_id) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM appointments a
      WHERE a.id = NEW.appointment_id
        AND a.patient_id = NEW.patient_id
        AND a.lab_id = NEW.lab_id
        AND a.status = 'COMPLETED'
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Review must match appointment patient/lab and appointment must be COMPLETED';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `review_ignores`
--

CREATE TABLE `review_ignores` (
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `review_ignores`
--

INSERT INTO `review_ignores` (`appointment_id`, `patient_id`, `created_at`) VALUES
(9, 2, '2026-02-21 13:51:15'),
(10, 2, '2026-02-21 13:51:14');

-- --------------------------------------------------------

--
-- Table structure for table `tests`
--

CREATE TABLE `tests` (
  `id` int(11) NOT NULL,
  `lab_id` int(11) NOT NULL,
  `test_name` varchar(120) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `availability` enum('AVAILABLE','NOT_AVAILABLE') NOT NULL DEFAULT 'AVAILABLE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tests`
--

INSERT INTO `tests` (`id`, `lab_id`, `test_name`, `description`, `price`, `availability`, `created_at`, `updated_at`) VALUES
(5, 3, 'CBC', 'Complete Blood Count', 650.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(6, 3, 'Blood Sugar (Fasting)', 'FBS', 350.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(7, 3, 'Lipid Profile', 'Cholesterol panel', 1200.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 14:21:07'),
(8, 3, 'LFT', 'Liver Function Test', 1400.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 14:21:02'),
(9, 4, 'CBC', 'Complete Blood Count', 700.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(10, 4, 'Thyroid Profile (TSH, T3, T4)', 'Thyroid panel', 1600.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(11, 4, 'Vitamin D', '25-OH Vitamin D', 2200.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(12, 4, 'HbA1c', 'Diabetes long-term marker', 1300.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(13, 5, 'CBC', 'Complete Blood Count', 600.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(14, 5, 'Urine R/E', 'Routine urine examination', 300.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(15, 5, 'Blood Sugar (Fasting)', 'FBS', 320.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(16, 6, 'CBC', 'Complete Blood Count', 580.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(17, 6, 'RFT', 'Renal Function Test', 1250.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(18, 6, 'LFT', 'Liver Function Test', 1350.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(19, 6, 'Urine R/E', 'Routine urine examination', 280.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(20, 7, 'CBC', 'Complete Blood Count', 760.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(21, 7, 'Lipid Profile', 'Cholesterol panel', 1450.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(22, 7, 'Thyroid Profile (TSH, T3, T4)', 'Thyroid panel', 1750.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(23, 7, 'Vitamin B12', 'Serum B12', 2100.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(24, 8, 'CBC', 'Complete Blood Count', 500.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(25, 8, 'Blood Sugar (Fasting)', 'FBS', 250.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(26, 8, 'Urine R/E', 'Routine urine examination', 220.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(27, 9, 'CBC', 'Complete Blood Count', 640.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(28, 9, 'RFT', 'Renal Function Test', 1180.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(29, 9, 'HbA1c', 'Diabetes long-term marker', 1150.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(30, 10, 'CBC', 'Complete Blood Count', 540.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(31, 10, 'Blood Sugar (Fasting)', 'FBS', 280.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(32, 10, 'LFT', 'Liver Function Test', 1220.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(33, 11, 'CBC', 'Complete Blood Count', 720.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(34, 11, 'Thyroid Profile (TSH, T3, T4)', 'Thyroid panel', 1650.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(35, 11, 'Vitamin D', '25-OH Vitamin D', 2350.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(36, 11, 'HbA1c', 'Diabetes long-term marker', 1250.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(37, 12, 'CBC', 'Complete Blood Count', 610.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(38, 12, 'Urine R/E', 'Routine urine examination', 260.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(39, 12, 'Lipid Profile', 'Cholesterol panel', 1100.00, 'AVAILABLE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(40, 3, 'Head', 'Head', 200.00, 'AVAILABLE', '2026-02-22 03:23:31', '2026-02-22 03:23:31');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `contact_number` varchar(25) NOT NULL,
  `role` enum('PATIENT','LAB_STAFF','ADMIN') NOT NULL DEFAULT 'PATIENT',
  `status` enum('ACTIVE','PENDING','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `username`, `email`, `password_hash`, `contact_number`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 'System Admin', 'admin', 'admin@gmail.com', '$2a$12$6.dGxo/Ta305mwhcDTl5XOCT2S67NkqzFBWHvnicSwkgl8E6Of9XK', '0000000000', 'ADMIN', 'ACTIVE', '2026-02-21 05:59:45', '2026-02-21 07:21:06'),
(2, 'user', 'user', 'user@gmail.com', '$2a$12$IJ/3BdHypRMOZtXRXmidUudBjc4CBk1m8vUt..wbpQePtIU9jD832', '981233455', 'PATIENT', 'ACTIVE', '2026-02-21 06:56:33', '2026-02-21 07:20:36'),
(5, 'user1', 'user1', 'user1@gmail.com', '$2a$12$L8hgvQKwDOCm6.9wfOOnReKAd1yRN8HvVKkgKxz2qe.5ijb9dcOwq', '981233455', 'PATIENT', 'ACTIVE', '2026-02-21 11:44:06', '2026-02-21 11:44:06'),
(6, 'Norvic Diagnostic Desk', 'lab', 'lab@gmail.com', '$2a$12$9qA5U0gZEYKDrzVKn9XkzuQXcWZzkCXewRnePbr7KGtupcweMpewC', '9801234567', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(7, 'Grande Lab Services', 'lab1', 'lab1@gmail.com', '$2a$12$mthcIffE4XeaL4IArRxnqeWP9UnGjQg1SEkTlVdlE2C5kC/THJ3AS', '9812345678', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(8, 'Dhulikhel Outreach Lab', 'lab2', 'lab2@gmail.com', '$2a$12$S0PuCcFFcl.bdWRB12WCH.Ua88hu0iL3cFT4TFjsTy.KGXNmQvmK2', '9823456789', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(9, 'B&B Lab Unit', 'lab3', 'lab3@gmail.com', '$2a$12$lEfmEgQ3LYntIVW8p.RISOq6Z0.q6L4K/XO0TqDKrN4hZJNPDVG5G', '9834567890', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(10, 'Nepal Mediciti Lab', 'lab4', 'lab4@gmail.com', '$2a$12$yEBI/3PwtPso4w8SdBwrMuCBhKV4hXv.sUh.RTiMbxhT5xrDFLoiC', '9845678901', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(11, 'Bhaktapur Community Lab', 'lab5', 'lab5@gmail.com', '$2a$12$TBNzNe8AvCrVcD3VJDu4aegBHjKcMkccnpEPHCEo2uRa.0RyhYja6', '9856789012', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(12, 'Patan Lab Center', 'lab6', 'lab6@gmail.com', '$2a$12$lfyCn..QSBWInOwe.Ae2aOFWJb04xc6yRWsY4s5ikhhA8tQpzcWky', '9867890123', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(13, 'Kirtipur Metro Lab', 'lab7', 'lab7@gmail.com', '$2a$12$EOAU4RkYb1Xzn6wMiauyNewAS11u4ezz6BZ3/fcHzGA8w4QOSD6aq', '9878901234', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(14, 'HAMS Lab Desk', 'lab8', 'lab8@gmail.com', '$2a$12$CpVU3SJqefbJ2R8Ip0uCEuYMNl7qyNf7j7OSgvIwnZJcY4ad/qeMS', '9889012345', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(15, 'Civil Service Lab', 'lab9', 'lab9@gmail.com', '$2a$12$6lVhXCLb.tSZK1182UFJ2ONNAwOuYMfiGugM1UO9pyxV/gJoq5jf.', '9890123456', 'LAB_STAFF', 'ACTIVE', '2026-02-21 12:09:04', '2026-02-21 12:09:04'),
(16, 'patient', 'patient', 'patient@gmail.com', '$2a$12$Z6WNNoMqVPYfShSOiKXFU.DMuePrHBVaiQXA.d.BG0UxV20ggFOc6', '981233455', 'PATIENT', 'ACTIVE', '2026-02-21 13:54:44', '2026-02-21 13:54:44'),
(17, 'sujal', 'sujal', 'sujal@gmail.com', '$2a$12$Wwyf4ymaqFpiHs4CTJJSG.Z1E/VWz188oSd.6hhqeGwLTrPV5wLqW', '981233455', 'PATIENT', 'ACTIVE', '2026-04-10 06:31:41', '2026-04-10 06:31:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_appt_patient` (`patient_id`),
  ADD KEY `idx_appt_lab` (`lab_id`),
  ADD KEY `idx_appt_date` (`appointment_date`),
  ADD KEY `idx_appt_status` (`status`),
  ADD KEY `idx_appt_payment` (`payment_status`),
  ADD KEY `idx_appt_lab_date_time` (`lab_id`,`appointment_date`,`appointment_time`);

--
-- Indexes for table `appointment_tests`
--
ALTER TABLE `appointment_tests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_appt_test` (`appointment_id`,`test_id`),
  ADD KEY `idx_appt_tests_appt` (`appointment_id`),
  ADD KEY `idx_appt_tests_test` (`test_id`);

--
-- Indexes for table `labs`
--
ALTER TABLE `labs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_labs_user` (`user_id`),
  ADD KEY `idx_labs_city` (`city`),
  ADD KEY `idx_labs_verified` (`verified`);

--
-- Indexes for table `lab_photos`
--
ALTER TABLE `lab_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_lab_photos_lab` (`lab_id`);

--
-- Indexes for table `lab_verification_log`
--
ALTER TABLE `lab_verification_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_verify_lab` (`lab_id`),
  ADD KEY `idx_verify_admin` (`admin_id`);

--
-- Indexes for table `patient_details`
--
ALTER TABLE `patient_details`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_payment_appt` (`appointment_id`),
  ADD KEY `idx_pay_status` (`status`),
  ADD KEY `idx_pay_method` (`method`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_report_appt` (`appointment_id`),
  ADD KEY `idx_reports_uploaded_by` (`uploaded_by`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_review_appt` (`appointment_id`),
  ADD KEY `idx_reviews_lab` (`lab_id`),
  ADD KEY `idx_reviews_patient` (`patient_id`);

--
-- Indexes for table `review_ignores`
--
ALTER TABLE `review_ignores`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `idx_review_ignores_patient` (`patient_id`);

--
-- Indexes for table `tests`
--
ALTER TABLE `tests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tests_lab` (`lab_id`),
  ADD KEY `idx_tests_name` (`test_name`),
  ADD KEY `idx_tests_price` (`price`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD UNIQUE KEY `uq_users_email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `appointment_tests`
--
ALTER TABLE `appointment_tests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `labs`
--
ALTER TABLE `labs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `lab_photos`
--
ALTER TABLE `lab_photos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `lab_verification_log`
--
ALTER TABLE `lab_verification_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tests`
--
ALTER TABLE `tests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `fk_appt_lab` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_appt_patient` FOREIGN KEY (`patient_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `appointment_tests`
--
ALTER TABLE `appointment_tests`
  ADD CONSTRAINT `fk_appt_tests_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_appt_tests_test` FOREIGN KEY (`test_id`) REFERENCES `tests` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `labs`
--
ALTER TABLE `labs`
  ADD CONSTRAINT `fk_labs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `lab_photos`
--
ALTER TABLE `lab_photos`
  ADD CONSTRAINT `fk_lab_photos_lab` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `lab_verification_log`
--
ALTER TABLE `lab_verification_log`
  ADD CONSTRAINT `fk_verify_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_verify_lab` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `patient_details`
--
ALTER TABLE `patient_details`
  ADD CONSTRAINT `fk_patient_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_pay_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `fk_reports_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reports_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_reviews_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reviews_lab` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_reviews_patient` FOREIGN KEY (`patient_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `review_ignores`
--
ALTER TABLE `review_ignores`
  ADD CONSTRAINT `fk_review_ignores_appt` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_review_ignores_patient` FOREIGN KEY (`patient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tests`
--
ALTER TABLE `tests`
  ADD CONSTRAINT `fk_tests_lab` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
