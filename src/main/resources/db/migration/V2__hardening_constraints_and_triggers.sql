-- V2 hardening migration for smart_lab schema
-- Assumes V1 schema/tables already exist.

USE smart_lab;

-- -------------------------
-- Indexes for conflict checks
-- -------------------------
CREATE INDEX idx_appt_lab_date_time ON appointments (lab_id, appointment_date, appointment_time);

-- -------------------------
-- Trigger cleanup (idempotent)
-- -------------------------
DROP TRIGGER IF EXISTS trg_labs_role_check_ins;
DROP TRIGGER IF EXISTS trg_labs_role_check_upd;

DROP TRIGGER IF EXISTS trg_appt_patient_role_ins;
DROP TRIGGER IF EXISTS trg_appt_patient_role_upd;

DROP TRIGGER IF EXISTS trg_verify_admin_role_ins;
DROP TRIGGER IF EXISTS trg_verify_admin_role_upd;

DROP TRIGGER IF EXISTS trg_review_consistency_ins;
DROP TRIGGER IF EXISTS trg_review_consistency_upd;

DROP TRIGGER IF EXISTS trg_appt_test_available_ins;
DROP TRIGGER IF EXISTS trg_appt_test_available_upd;

DROP TRIGGER IF EXISTS trg_appt_slot_conflict_ins;
DROP TRIGGER IF EXISTS trg_appt_slot_conflict_upd;

-- -------------------------
-- Role integrity: labs.user_id must be LAB_STAFF
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_labs_role_check_ins
BEFORE INSERT ON labs
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_labs_role_check_upd
BEFORE UPDATE ON labs
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Role integrity: appointments.patient_id must be PATIENT
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_appt_patient_role_ins
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_appt_patient_role_upd
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Role integrity: verification admin must be ADMIN
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_verify_admin_role_ins
BEFORE INSERT ON lab_verification_log
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_verify_admin_role_upd
BEFORE UPDATE ON lab_verification_log
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Review consistency: appointment + patient + lab must align
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_review_consistency_ins
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_review_consistency_upd
BEFORE UPDATE ON reviews
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Appointment tests must be AVAILABLE and belong to appointment lab
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_appt_test_available_ins
BEFORE INSERT ON appointment_tests
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_appt_test_available_upd
BEFORE UPDATE ON appointment_tests
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Appointment slot conflict control
-- Blocks duplicate active bookings at same lab/date/time.
-- -------------------------
DELIMITER $$
CREATE TRIGGER trg_appt_slot_conflict_ins
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_appt_slot_conflict_upd
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
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
END$$
DELIMITER ;

-- -------------------------
-- Seed admin safeguard example (replace hash before production use)
-- -------------------------
-- UPDATE users
-- SET password_hash = '$2a$10$<real-bcrypt-hash>'
-- WHERE username = 'admin';
