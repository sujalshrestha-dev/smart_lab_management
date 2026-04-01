# All About Project - Smart Lab Management

This document lists the complete set of processes implemented in this project and what each user can do.

## 1) Project Purpose

Smart Lab Management is a role-based web platform where:
- Patients can discover labs, book tests, pay, track status, and download reports.
- Lab Staff can manage tests, manage appointments/payments, and upload reports.
- Admin can verify and control lab accounts and platform data.

## 2) Main Roles

- `PATIENT`
- `LAB_STAFF`
- `ADMIN`

## 3) Common Processes (All Users)

### 3.1 Registration
- Patient registration with personal + patient details.
- Lab staff registration with lab details + map location (latitude/longitude).
- Username and password validation rules are enforced.

### 3.2 Login
- Login using email + password.
- Role-based redirection after login.

### 3.3 Logout
- Session is invalidated.
- User is redirected to login page.

### 3.4 Forgot Password (Current Demo Flow)
- User enters email.
- Verification code is currently fixed as `1234`.
- User sets new password and is redirected to login.

### 3.5 Account Deletion
- Patient and Lab users can delete their own account.
- Password confirmation is required.
- Related data is removed according to DB foreign-key cascade/restrictions.

## 4) Patient Panel - Complete Processes

## 4.1 Dashboard
- Sidebar navigation to all patient modules.
- Quick cards for key actions (Browse Labs, Appointments, History, Rating/Review).

## 4.2 Browse Labs
- Search modes:
  - By city
  - By lab name (partial text supported)
  - By nearest labs using browser location
- Advanced filters:
  - Price sorting (cheapest first)
  - Rating sorting (high to low)
  - Optional multi-test selection filter
- Nearest mode:
  - Uses geolocation latitude/longitude
  - Uses Haversine distance for nearest ordering
- Lab cards show:
  - Patients served
  - Average rating
  - Distance (if nearest mode)
- Visual match indicators:
  - Green border = all selected tests available
  - Red border = some selected tests missing
  - Available and missing tests are shown

## 4.3 Lab Detail + Learn More
- Patient can open selected lab booking page.
- Learn More section shows:
  - Lab description
  - Photo gallery
  - Interactive map location

## 4.4 Book Appointment
- Select one or multiple tests.
- Enter appointment date/time and optional notes.
- Date cannot be in the past.
- Invoice preview is generated before final submission.
- On confirmation:
  - Appointment record is created
  - Appointment-test mapping rows are created
  - Payment row is created (default CASH)

## 4.5 My Appointments
- Shows active/unfinished appointments.
- Displays status, payment method, payment status, and actions.
- Payment method can be selected/updated.
- Online methods show `Pay Now`; cash has no online action.
- Payment status flow shown in UI:
  - Unpaid
  - Verifying
  - Paid

## 4.6 Payment Statement
- Lists payment history/details.
- Supports invoice/bill view and paid statement behavior.

## 4.7 History
- Shows completed appointments.

## 4.8 Result Access
- Patient can download report/result files.
- Access is controlled by payment status (paid-first workflow).

## 4.9 Rating and Review
- Completed appointments can be reviewed.
- User can:
  - Rate lab (1 to 5 stars) and comment
  - Ignore review request
- After rating:
  - “Thanks for rating” state shown
  - Rated stars shown

## 4.10 User Account
- Update profile details.
- Change password.
- Recover password link available.
- Delete account option with red warning flow.

## 5) Lab Staff Panel - Complete Processes

## 5.1 Lab Dashboard
- Real-time cards:
  - Total tests
  - Total appointments
  - Completed today
  - Pending reports
  - Daily earnings
  - Patients rated
  - Average rating

## 5.2 Manage Tests
- Add test.
- Edit test in-row and save.
- Delete test.
- Test data includes name, description, and price.

## 5.3 Upload Report / Appointment Management
- View incoming appointments.
- Manage approval/rejection flow (single decision flow where applicable).
- Verify payment status:
  - Mark payment as paid after checking
- Upload result file.
- On report upload:
  - Appointment auto-moves to `COMPLETED`
  - Upload area changes to result view behavior

## 5.4 Completed Reports
- Completed appointments are shown in separate module.

## 5.5 Lab Chart
- Chart summary widgets:
  - Completed vs Pending
  - Paid vs Not Paid vs Verifying
  - Rating summary
- Circular chart presentation.

## 5.6 Lab Profile
- Update public lab data:
  - Name/city/address/description
  - Map location (lat/lng)
  - Photo uploads

## 5.7 Lab Account Security
- Logout.
- Delete account with password confirmation.

## 6) Admin Panel - Complete Processes

## 6.1 Admin Dashboard
- Platform overview:
  - Total patients
  - Total labs
  - Total appointments
  - Pending lab verifications

## 6.2 Pending Labs (Verification)
- Manually approve or reject lab staff registrations.
- Only verified labs are visible in patient browse labs.

## 6.3 Manage Labs
- Edit lab details.
- Delete lab account/data.
- Focused table fields (owner email/contact and extra fields removed as requested).

## 6.4 Admin Profile
- Update profile fields.
- Change password.

## 6.5 Admin Session
- Logout flow.

## 7) Security, Validation, and Integrity Processes

## 7.1 Password Security
- Passwords are hashed with BCrypt.
- Password verification uses BCrypt check.

## 7.2 Input Validation
- Username:
  - Cannot start with number
  - Only letters, numbers, underscore
- Password (non-admin registration):
  - Uppercase + lowercase + symbol + at least 2 numbers + min length
- Patient DOB:
  - Cannot be future date
- Appointment date:
  - Cannot be past date

## 7.3 Session and Role Authorization
- Role checks in protected servlets/pages.
- Unauthorized users redirected to login.

## 7.4 Database Integrity (Triggers/Constraints)
- Role integrity checks for linked user IDs.
- Review consistency checks (appointment/patient/lab alignment).
- Appointment-test consistency checks (same lab, test available).
- Appointment slot conflict prevention for active time slots.

## 8) Data and Analytics Processes

- Lab average rating and review counts.
- Patients served aggregation per lab.
- Daily earnings calculation for lab dashboard.
- Payment status distribution for charts.

## 9) Map and Location Processes

- Lab registration and profile location selection via Leaflet + OpenStreetMap.
- Search in map for specific place names.
- Pin confirm/back flow for precise coordinates.
- Patient nearest-lab discovery from browser location.

## 10) Files and Reporting Processes

- Result files uploaded by lab staff.
- File path stored in DB reports table.
- Patients can download reports after payment conditions are satisfied.

## 11) Current Known Demo Behavior

- Forgot password verification code is fixed to `1234` (demo mode).
- Some UI parts are intentionally simplified for phase-wise testing.

## 12) What This Project Fully Supports Right Now

- End-to-end user onboarding (register/login/logout)
- Role-based dashboards and workflows
- Lab discovery + smart matching
- Appointment booking + invoice + payment status flow
- Lab report upload and delivery
- Review/rating loop
- Admin verification and management
- Account update, password update, delete account

