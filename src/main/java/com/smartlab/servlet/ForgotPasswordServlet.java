package com.smartlab.servlet;

import com.smartlab.dao.UserDAO;
import com.smartlab.model.User;
import com.smartlab.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private static final String FIXED_CODE = "1234";
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect("forgot_password.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");

        String email = trim(req.getParameter("email")).toLowerCase();
        String code = trim(req.getParameter("verificationCode"));
        String newPassword = req.getParameter("newPassword") == null ? "" : req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword") == null ? "" : req.getParameter("confirmPassword");

        if (email.isBlank() || code.isBlank() || newPassword.isBlank() || confirmPassword.isBlank()) {
            redirectWithError(resp, "Please complete all fields.");
            return;
        }
        if (!FIXED_CODE.equals(code)) {
            redirectWithError(resp, "Invalid code.");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            redirectWithError(resp, "New password and confirm password do not match.");
            return;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                redirectWithError(resp, "No account found for that email.");
                return;
            }

            String hashed = PasswordUtil.hashPassword(newPassword);
            boolean updated = userDAO.updatePasswordByEmail(email, hashed);
            if (!updated) {
                redirectWithError(resp, "Password reset failed.");
                return;
            }

            resp.sendRedirect("login.jsp?success=" + encode("Password changed successfully. Please login."));
        } catch (SQLException ex) {
            getServletContext().log("Forgot password failed", ex);
            redirectWithError(resp, "Database error: " + ex.getMessage());
        }
    }

    private static void redirectWithError(HttpServletResponse resp, String message) throws IOException {
        resp.sendRedirect("forgot_password.jsp?error=" + encode(message));
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
