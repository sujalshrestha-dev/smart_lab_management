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

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login");
            return;
        }
        Object uid = session.getAttribute("userId");
        Object roleObj = session.getAttribute("role");
        if (!(uid instanceof Number) || roleObj == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int userId = ((Number) uid).intValue();
        String role = roleObj.toString().toUpperCase();
        String password = req.getParameter("confirmPassword") == null ? "" : req.getParameter("confirmPassword");
        String backPath = "LAB_STAFF".equals(role) ? "/LabProfileServlet" : "/UserAccountServlet";

        if (password.isBlank()) {
            resp.sendRedirect(req.getContextPath() + backPath + "?error=" + enc("Password is required to delete account."));
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null || !PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
                resp.sendRedirect(req.getContextPath() + backPath + "?error=" + enc("Incorrect password."));
                return;
            }

            boolean deleted;
            if ("LAB_STAFF".equals(role)) {
                deleted = userDAO.deleteLabStaffAccountByUserId(userId);
            } else if ("PATIENT".equals(role)) {
                deleted = userDAO.deletePatientAccountByUserId(userId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Unsupported+role");
                return;
            }

            if (!deleted) {
                resp.sendRedirect(req.getContextPath() + backPath + "?error=" + enc("Unable to delete account."));
                return;
            }

            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login.jsp?success=" + enc("Account deleted successfully."));
        } catch (SQLException ex) {
            getServletContext().log("Delete account failed", ex);
            resp.sendRedirect(req.getContextPath() + backPath + "?error=" + enc("Database error while deleting account."));
        }
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
