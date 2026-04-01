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

@WebServlet("/admin/profile")
public class AdminProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        try {
            req.setAttribute("adminUser", userDAO.findById(((Number) uid).intValue()));
            req.getRequestDispatcher("/admin/admin_profile.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load admin profile failed", ex);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=Unable+to+load+profile");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int userId = ((Number) uid).intValue();
        String action = trim(req.getParameter("action"));
        try {
            if ("changePassword".equalsIgnoreCase(action)) {
                changePassword(req, resp, userId);
            } else {
                updateProfile(req, resp, session, userId);
            }
        } catch (SQLException ex) {
            getServletContext().log("Admin profile update failed", ex);
            String msg = ex.getErrorCode() == 1062 ? "Username or email already exists." : "Unable to save profile.";
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc(msg));
        }
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId) throws IOException, SQLException {
        String fullName = trim(req.getParameter("fullName"));
        String username = trim(req.getParameter("username"));
        String email = trim(req.getParameter("email")).toLowerCase();
        String contactNumber = trim(req.getParameter("contactNumber"));
        if (fullName.isBlank() || username.isBlank() || email.isBlank() || contactNumber.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc("All profile fields are required."));
            return;
        }
        boolean ok = userDAO.updateAdminProfile(new UserDAO.AdminProfileUpdate(userId, fullName, username, email, contactNumber));
        if (!ok) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc("Profile update failed."));
            return;
        }
        session.setAttribute("fullName", fullName);
        session.setAttribute("username", username);
        session.setAttribute("email", email);
        resp.sendRedirect(req.getContextPath() + "/admin/profile?success=" + enc("Profile updated successfully."));
    }

    private void changePassword(HttpServletRequest req, HttpServletResponse resp, int userId) throws IOException, SQLException {
        String current = req.getParameter("currentPassword") == null ? "" : req.getParameter("currentPassword");
        String next = req.getParameter("newPassword") == null ? "" : req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword") == null ? "" : req.getParameter("confirmPassword");
        if (current.isBlank() || next.isBlank() || confirm.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc("Password fields are required."));
            return;
        }
        if (!next.equals(confirm)) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc("Password confirmation does not match."));
            return;
        }
        User user = userDAO.findById(userId);
        if (user == null || !PasswordUtil.verifyPassword(current, user.getPasswordHash())) {
            resp.sendRedirect(req.getContextPath() + "/admin/profile?error=" + enc("Current password is incorrect."));
            return;
        }
        boolean ok = userDAO.updatePasswordByUserId(userId, PasswordUtil.hashPassword(next));
        resp.sendRedirect(req.getContextPath() + "/admin/profile?" + (ok ? "success=Password+changed" : "error=Unable+to+change+password"));
    }

    private static boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "ADMIN".equalsIgnoreCase(role.toString());
    }

    private static String trim(String v) {
        return v == null ? "" : v.trim();
    }

    private static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }
}
