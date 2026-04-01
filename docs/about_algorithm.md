# About Algorithms Used in Smart Lab Management

This file includes the **actual algorithm logic** (formula/pseudocode) used in the project.

## 1) Haversine Distance (Nearest Lab)

### Formula
Given two points `(lat1, lon1)` and `(lat2, lon2)`:

```text
dLat = radians(lat2 - lat1)
dLon = radians(lon2 - lon1)
a = sin(dLat/2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon/2)^2
c = 2 * atan2(sqrt(a), sqrt(1-a))
distanceKm = R * c
```

Where `R = 6371.0 km` (Earth radius).

### Pseudocode
```text
FUNCTION distanceKm(lat1, lon1, lat2, lon2):
    R <- 6371.0
    dLat <- toRadians(lat2 - lat1)
    dLon <- toRadians(lon2 - lon1)
    a <- sin(dLat/2)^2 + cos(toRadians(lat1)) * cos(toRadians(lat2)) * sin(dLon/2)^2
    c <- 2 * atan2(sqrt(a), sqrt(1-a))
    RETURN R * c
END FUNCTION
```

Used in:
- `src/main/java/com/smartlab/util/HaversineUtil.java`
- `src/main/java/com/smartlab/dao/PatientLabDAO.java`

## 2) Nearest-First Sorting

### Pseudocode
```text
IF sort = "NEAREST" AND userLatitude,userLongitude exist:
    FOR each lab in result:
        lab.distance <- Haversine(userLat, userLng, lab.lat, lab.lng)
    SORT labs by distance ascending (null distances at end)
END IF
```

Used in:
- `src/main/java/com/smartlab/dao/PatientLabDAO.java`

## 3) Multi-Criteria Lab Filtering

### Pseudocode
```text
QUERY starts with verified labs that have at least one available test

IF city is provided:
    add condition city LIKE %city%

IF labName is provided:
    add condition lab_name LIKE %labName%

IF maxPrice is provided:
    add condition MIN(available_test_price) <= maxPrice

IF minRating is provided:
    add condition AVG(rating) >= minRating

ORDER BY:
    PRICE_ASC -> min_price ascending
    RATING_DESC -> avg_rating descending
    otherwise -> lab_name ascending
```

Used in:
- `src/main/java/com/smartlab/dao/PatientLabDAO.java`
- `src/main/java/com/smartlab/servlet/FindLabsServlet.java`

## 4) Complete vs Partial Test Match Prioritization

### Pseudocode
```text
INPUT: labs, selectedTests
complete <- []
partial <- []

FOR each lab in labs:
    IF selectedTests subset_of lab.availableTests:
        add lab to complete
    ELSE:
        add lab to partial

RETURN complete + partial
```

Used in:
- `src/main/java/com/smartlab/servlet/FindLabsServlet.java`

## 5) CSV Test Parsing / Normalization

### Pseudocode
```text
FUNCTION splitTests(csv):
    IF csv is null/blank: return empty list
    parts <- split csv by ","
    trim each part
    keep non-empty values
    return list
```

Used in:
- `src/main/java/com/smartlab/dao/PatientLabDAO.java`

## 6) Password Security (BCrypt)

### Pseudocode
```text
FUNCTION hashPassword(plain):
    return BCrypt.hashpw(plain, gensalt(12))

FUNCTION verifyPassword(plain, hash):
    IF plain/hash is null or blank: return false
    TRY:
        return BCrypt.checkpw(plain, hash)
    CATCH invalid-hash-format:
        return false
```

Used in:
- `src/main/java/com/smartlab/util/PasswordUtil.java`

## 7) Username + Strong Password Validation

### Regex Rules
- Username regex: `^[A-Za-z_][A-Za-z0-9_]*$`
- Strong password regex: `^(?=(?:.*\\d){2,})(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$`

### Pseudocode
```text
IF username does not match usernameRegex:
    reject

IF role != ADMIN AND password does not match strongPasswordRegex:
    reject

IF password != confirmPassword:
    reject
```

Used in:
- `src/main/java/com/smartlab/servlet/RegisterServlet.java`
- `src/main/webapp/register.jsp`
- `src/main/webapp/RegisterLab.jsp`

## 8) Date Validation (DOB and Appointment Date)

### Pseudocode
```text
DOB validation:
    parse DOB as LocalDate
    IF DOB > today: reject

Appointment date validation:
    parse appointmentDate
    IF appointmentDate < today: reject
```

Used in:
- `src/main/java/com/smartlab/servlet/RegisterServlet.java`
- `src/main/java/com/smartlab/servlet/BookAppointmentServlet.java`

## 9) Invoice Total Aggregation

### Pseudocode
```text
total <- 0
FOR each selected testId:
    total <- total + test.price
create payment record with amount = total
```

Used in:
- `src/main/java/com/smartlab/servlet/BookAppointmentServlet.java`
- `src/main/webapp/patient/book_appointment.jsp`

## 10) SQL Trigger-Based Integrity Algorithms

### 10.1 Role Integrity
```text
Before INSERT/UPDATE on labs:
    user_id must reference ACTIVE LAB_STAFF

Before INSERT/UPDATE on appointments:
    patient_id must reference ACTIVE PATIENT

Before INSERT/UPDATE on lab_verification_log:
    admin_id must reference ACTIVE ADMIN
```

### 10.2 Review Consistency
```text
Before INSERT/UPDATE on reviews:
    appointment must exist
    appointment.patient_id == review.patient_id
    appointment.lab_id == review.lab_id
    appointment.status == COMPLETED
```

### 10.3 Appointment-Test Consistency
```text
Before INSERT/UPDATE on appointment_tests:
    selected test must be AVAILABLE
    selected test must belong to same lab as appointment
```

### 10.4 Slot Conflict Prevention
```text
Before INSERT/UPDATE on appointments:
    IF same lab + same date + same time already has status in (PENDING, APPROVED):
        reject operation
```

Used in:
- `src/main/resources/db/migration/V2__hardening_constraints_and_triggers.sql`
