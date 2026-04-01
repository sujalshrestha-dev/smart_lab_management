package com.smartlab.servlet;

import com.smartlab.dao.UserDAO;
import com.smartlab.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.regex.Pattern;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z_][A-Za-z0-9_]*$");
    private static final boolean ENFORCE_STRONG_PASSWORD = true;
    private static final Pattern STRONG_PASSWORD_PATTERN =
            Pattern.compile("^(?=(?:.*\\d){2,})(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$");

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect("index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");

        String role = trim(req.getParameter("role")).toUpperCase();
        String fullName = trim(req.getParameter("fullName"));
        String username = trim(req.getParameter("username"));
        String email = trim(req.getParameter("email")).toLowerCase();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword") == null ? "" : req.getParameter("confirmPassword");
        String contactNumber = trim(req.getParameter("contactNumber"));

        if (!isSupportedRole(role)) {
            redirectWithError(resp, "index.jsp", "Invalid role selected.");
            return;
        }
        if (fullName.isBlank() || username.isBlank() || email.isBlank() || password.isBlank() || contactNumber.isBlank()) {
            redirectWithError(resp, targetPageByRole(role), "All required fields must be filled.");
            return;
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            redirectWithError(resp, targetPageByRole(role),
                    "Username must not start with number and may only include letters, numbers, underscore.");
            return;
        }
        if (ENFORCE_STRONG_PASSWORD && !"ADMIN".equals(role) && !STRONG_PASSWORD_PATTERN.matcher(password).matches()) {
            redirectWithError(resp, targetPageByRole(role),
                    "Password must have uppercase, lowercase, symbol, and at least two numbers.");
            return;
        }
        if (!password.equals(confirmPassword)) {
            redirectWithError(resp, targetPageByRole(role), "Password and confirm password do not match.");
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(password);

        try {
            if ("PATIENT".equals(role)) {
                String dob = trim(req.getParameter("dateOfBirth"));
                String emergencyContact = trim(req.getParameter("emergencyContact"));
                String address = trim(req.getParameter("address"));
                if (dob.isBlank() || emergencyContact.isBlank() || address.isBlank()) {
                    redirectWithError(resp, "register.jsp", "Please complete patient details.");
                    return;
                }
                try {
                    LocalDate dateOfBirth = LocalDate.parse(dob);
                    if (dateOfBirth.isAfter(LocalDate.now())) {
                        redirectWithError(resp, "register.jsp", "Date of birth cannot be in the future.");
                        return;
                    }
                } catch (Exception ex) {
                    redirectWithError(resp, "register.jsp", "Invalid date of birth.");
                    return;
                }

                userDAO.registerPatient(new UserDAO.RegisterRequest(
                        fullName, username, email, hashedPassword, contactNumber,
                        dob, emergencyContact, address, null, null, null, null
                ));
            } else if ("LAB_STAFF".equals(role)) {
                String labName = trim(req.getParameter("labName"));
                String city = trim(req.getParameter("city"));
                String address = trim(req.getParameter("address"));
                String latitudeRaw = trim(req.getParameter("latitude"));
                String longitudeRaw = trim(req.getParameter("longitude"));

                if (labName.isBlank() || city.isBlank() || address.isBlank() || latitudeRaw.isBlank() || longitudeRaw.isBlank()) {
                    redirectWithError(resp, "RegisterLab.jsp", "Please complete lab details and confirm location.");
                    return;
                }

                BigDecimal latitude;
                BigDecimal longitude;
                try {
                    latitude = new BigDecimal(latitudeRaw);
                    longitude = new BigDecimal(longitudeRaw);
                } catch (NumberFormatException ex) {
                    redirectWithError(resp, "RegisterLab.jsp", "Invalid map coordinates.");
                    return;
                }

                userDAO.registerLabStaff(new UserDAO.RegisterRequest(
                        fullName, username, email, hashedPassword, contactNumber,
                        null, null, address, labName, city, latitude, longitude
                ));
            } else {
                userDAO.registerAdmin(new UserDAO.RegisterRequest(
                        fullName, username, email, hashedPassword, contactNumber,
                        null, null, null, null, null, null, null
                ));
            }

            resp.sendRedirect("login.jsp?success=" + encode("Registration successful. Please login."));
        } catch (SQLException ex) {
            getServletContext().log("Registration failed", ex);
            String errorMessage = mapSqlError(ex);
            redirectWithError(resp, targetPageByRole(role), errorMessage);
        }
    }

    private static String targetPageByRole(String role) {
        if ("LAB_STAFF".equals(role)) {
            return "RegisterLab.jsp";
        }
        if ("ADMIN".equals(role)) {
            return "index.jsp";
        }
        return "register.jsp";
    }

    private static boolean isSupportedRole(String role) {
        return "PATIENT".equals(role) || "LAB_STAFF".equals(role) || "ADMIN".equals(role);
    }

    private static void redirectWithError(HttpServletResponse resp, String page, String message) throws IOException {
        resp.sendRedirect(page + "?error=" + encode(message));
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String mapSqlError(SQLException ex) {
        if (ex.getErrorCode() == 1062) {
            return "Username or email already exists.";
        }
        if (ex.getErrorCode() == 1045) {
            return "Database access denied. Check DB_USER/DB_PASSWORD.";
        }
        if (ex.getErrorCode() == 1049) {
            return "Database 'smart_lab' not found. Create database first.";
        }
        if (ex.getSQLState() != null && ex.getSQLState().startsWith("08")) {
            return "Cannot connect to database: " + ex.getMessage();
        }
        return "Registration failed: " + ex.getMessage();
    }
}
