# Smart Lab Management - Viva Preparation (Q&A)

Use this file to practice direct answers in viva.

## 1) Project Basics

### Q1. What is your project?
Smart Lab Management is a Java Servlet + JSP based web application for digital lab operations.  
It has three roles: Patient, Lab Staff, and Admin.

### Q2. What problems does it solve?
- Patients can search labs, book tests, track status, and download reports.
- Lab staff can manage tests, appointments, payments, and reports.
- Admin can verify labs before they appear publicly.

### Q3. What technologies did you use?
- Java 17
- JSP/Servlet
- Maven (WAR project)
- MySQL
- BCrypt for password hashing
- Leaflet/OpenStreetMap for map and location picking

## 2) Folder-Wise Viva Questions

### Q4. Why do you have a `dao` folder?
`dao` means Data Access Object.  
This folder separates database logic from UI/business logic.

### Q5. What is stored in `dao`?
Classes that run SQL queries and map results, for example:
- `UserDAO` (users, registration, account updates)
- `AppointmentDAO` (appointments and test mappings)
- `PatientLabDAO` (browse/search/filter labs)
- `PaymentDAO` (payments and statements)
- `LabDAO`, `LabStatsDAO`, `AdminStatsDAO` (lab/admin data and analytics)

### Q6. What is a `servlet` and what is stored in `servlet` folder?
A servlet is a Java controller class that handles HTTP requests/responses.  
`servlet` folder contains endpoint controllers, such as:
- `LoginServlet`, `RegisterServlet`, `LogoutServlet`
- `FindLabsServlet`, `BookAppointmentServlet`
- `UploadResultServlet`, `PaymentServlet`
- `AdminDashboardServlet`, `PendingLabsServlet`

### Q7. What is in the `model` folder?
`model` contains data classes/entities used in app logic.  
Examples: `User`, `Test`.

### Q8. What is in the `util` folder?
Reusable utility helpers:
- `DBConnection` for DB config and JDBC connection
- `PasswordUtil` for BCrypt hash/verify
- `HaversineUtil` for nearest-lab distance calculation

### Q9. What is in `webapp`?
JSP pages and static resources:
- `index.jsp`, `login.jsp`, `register.jsp`, `RegisterLab.jsp`
- role-specific pages under `/patient`, `/lab`, `/admin`
- CSS/JS files and uploads folder

### Q10. Why separate DAO, Servlet, and Model?
To follow separation of concerns:
- Servlet = controller
- DAO = data layer
- Model = data structure
This improves maintainability and testing.

## 3) Architecture and Flow

### Q11. Explain your architecture briefly.
MVC-style structure:
- View: JSP pages
- Controller: Servlets
- Data Layer: DAO + MySQL
- Utility layer for shared functions

### Q12. What happens during login?
1. User submits email/password.
2. `LoginServlet` checks user from DB through DAO.
3. Password verified using BCrypt.
4. Session stores role/user details.
5. User redirected by role.

### Q13. How does registration work?
`RegisterServlet` validates input, hashes password, then stores user data through `UserDAO`.  
For lab staff, location (lat/lng) and lab details are also stored.

### Q14. How is nearest lab calculated?
Using Haversine formula in `HaversineUtil`.  
Distance between patient coordinates and lab coordinates is computed and sorted.

### Q15. How do you ensure lab verification?
Admin approves/rejects lab in pending list.  
Only verified labs are shown in patient browse results.

## 4) Database and Security

### Q16. Which database tables are important?
`users`, `patient_details`, `labs`, `tests`, `appointments`, `appointment_tests`, `payments`, `reports`, `reviews`, `lab_verification_log`.

### Q17. How do you secure passwords?
Passwords are never stored plain.  
They are hashed using BCrypt (`PasswordUtil`).

### Q18. What validation rules did you implement?
- Username cannot start with number; underscore allowed.
- Strong password rules (except admin exception in registration logic).
- DOB cannot be future date.
- Appointment date cannot be past date.

### Q19. How do you protect business rules in DB?
Using constraints and triggers (migration SQL) for role integrity, slot conflicts, and review consistency.

### Q20. What is session used for?
To maintain logged-in state and role access control across pages.

## 5) Feature-Specific Viva Questions

### Q21. Explain patient workflow end-to-end.
Register/Login -> Browse labs -> Filter/search -> Select lab/tests -> Book appointment -> Payment process -> Report download -> Review lab.

### Q22. Explain lab staff workflow.
Login -> Dashboard -> Manage tests -> Manage appointments/payment verification -> Upload reports -> View completed reports/charts -> Manage lab profile.

### Q23. Explain admin workflow.
Login -> Dashboard overview -> Verify pending labs -> Manage labs -> Maintain admin profile.

### Q24. How does payment status work?
App uses statuses like unpaid/verifying/paid.  
Lab verifies online payment; cash is handled manually.  
Result visibility is tied to payment completion rules.

### Q25. What happens when lab uploads report?
Report file is stored and appointment is moved to completed flow.

## 6) Design/Code Quality Questions

### Q26. Why JDBC and DAO instead of writing SQL in JSP?
Better separation, cleaner code, easier maintenance, and less duplication.

### Q27. Why Maven WAR project?
Standard build/dependency management and easy Tomcat deployment.

### Q28. Why did you use JSP?
Simple server-rendered UI integrated with servlet flow for academic project scope.

### Q29. Where can scalability improve?
- Add service layer between servlet and DAO
- Add pagination/caching
- Use connection pooling and API-based frontend in future

### Q30. What are current limitations?
- Forgot password uses fixed demo code.
- Some features are simplified for project phase.
- No automated test suite yet.

## 7) Frequently Asked “Why” Questions

### Q31. Why map integration?
To collect precise lab coordinates and support nearest-lab search.

### Q32. Why reviews?
To improve trust and ranking quality for patients.

### Q33. Why admin verification?
To prevent fake labs from appearing publicly.

### Q34. Why role-based panel?
Each actor has different permissions and workflows.

## 8) Quick 30-Second Viva Summary

My project is Smart Lab Management, a role-based web system built with Java Servlet/JSP, MySQL, and Maven.  
I separated code into DAO (database), Servlet (controller), Model (data classes), and JSP views.  
Patients can search labs (including nearest via Haversine), book tests, handle payments, and download reports.  
Lab staff manage tests/appointments/payments and upload results.  
Admin verifies labs and monitors the system.  
Security includes BCrypt password hashing, input/date validation, session-based access control, and DB-level integrity rules.

