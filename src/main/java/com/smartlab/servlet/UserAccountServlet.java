package com.smartlab.servlet;

import com.smartlab.dao.UserDAO;
import com.smartlab.model.User;
import com.smartlab.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/UserAccountServlet")
public class UserAccountServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+patient");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int userId = ((Number) uid).intValue();
        try {
            req.setAttribute("account", userDAO.getPatientAccountByUserId(userId));
            req.getRequestDispatcher("/patient/user_account.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load user account failed", ex);
            resp.sendRedirect(req.getContextPath() + "/patient/dashboard.jsp?error=" + encode("Unable to load account."));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+patient");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int userId = ((Number) uid).intValue();
        String action = trim(req.getParameter("action"));

        if ("changePassword".equalsIgnoreCase(action)) {
            handleChangePassword(req, resp, userId);
            return;
        }
        handleProfileUpdate(req, resp, session, userId);
    }

    private void handleProfileUpdate(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId) throws IOException {
        String fullName = trim(req.getParameter("fullName"));
        String username = trim(req.getParameter("username"));
        String email = trim(req.getParameter("email")).toLowerCase();
        String contactNumber = trim(req.getParameter("contactNumber"));
        String dateOfBirth = trim(req.getParameter("dateOfBirth"));
        String emergencyContact = trim(req.getParameter("emergencyContact"));
        String address = trim(req.getParameter("address"));

        if (fullName.isBlank() || username.isBlank() || email.isBlank() || contactNumber.isBlank()
                || dateOfBirth.isBlank() || emergencyContact.isBlank() || address.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("All profile fields are required."));
            return;
        }

        try {
            boolean ok = userDAO.updatePatientAccount(new UserDAO.PatientAccountUpdate(
                    userId, fullName, username, email, contactNumber, dateOfBirth, emergencyContact, address
            ));
            if (!ok) {
                resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Unable to update profile."));
                return;
            }
            session.setAttribute("fullName", fullName);
            session.setAttribute("username", username);
            session.setAttribute("email", email);
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?success=" + encode("Profile updated successfully."));
        } catch (SQLException ex) {
            getServletContext().log("Update profile failed", ex);
            String msg = ex.getErrorCode() == 1062
                    ? "Username or email is already in use."
                    : "Unable to update profile.";
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode(msg));
        } catch (IllegalArgumentException ex) {
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Invalid date of birth."));
        }
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp, int userId) throws IOException {
        String currentPassword = req.getParameter("currentPassword") == null ? "" : req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword") == null ? "" : req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword") == null ? "" : req.getParameter("confirmPassword");

        if (currentPassword.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Password fields are required."));
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("New password and confirm password do not match."));
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null || !PasswordUtil.verifyPassword(currentPassword, user.getPasswordHash())) {
                resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Current password is incorrect."));
                return;
            }
            boolean updated = userDAO.updatePasswordByUserId(userId, PasswordUtil.hashPassword(newPassword));
            if (!updated) {
                resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Unable to change password."));
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?success=" + encode("Password changed successfully."));
        } catch (SQLException ex) {
            getServletContext().log("Change password failed", ex);
            resp.sendRedirect(req.getContextPath() + "/UserAccountServlet?error=" + encode("Unable to change password."));
        }
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
