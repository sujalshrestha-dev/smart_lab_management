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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");

        String email = trim(req.getParameter("email")).toLowerCase();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");

        if (email.isBlank() || password.isBlank()) {
            resp.sendRedirect("login.jsp?error=" + encode("Email and password are required."));
            return;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user == null || !PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
                resp.sendRedirect("login.jsp?error=" + encode("Invalid email or password."));
                return;
            }

            if ("BLOCKED".equalsIgnoreCase(user.getStatus())) {
                resp.sendRedirect("login.jsp?error=" + encode("Your account is blocked. Please contact support."));
                return;
            }

            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("role", user.getRole());

            String role = user.getRole() == null ? "" : user.getRole();
            if ("ADMIN".equalsIgnoreCase(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else if ("LAB_STAFF".equalsIgnoreCase(role)) {
                resp.sendRedirect("lab/dashboard.jsp");
            } else {
                resp.sendRedirect("patient/dashboard.jsp");
            }
        } catch (SQLException ex) {
            getServletContext().log("Login failed", ex);
            resp.sendRedirect("login.jsp?error=" + encode(mapSqlError(ex)));
        }
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String mapSqlError(SQLException ex) {
        if (ex.getErrorCode() == 1045) {
            return "Database access denied. Check DB_USER/DB_PASSWORD.";
        }
        if (ex.getErrorCode() == 1049) {
            return "Database 'smart_lab' not found.";
        }
        if (ex.getSQLState() != null && ex.getSQLState().startsWith("08")) {
            return "Cannot connect to database: " + ex.getMessage();
        }
        return "Unable to login right now: " + ex.getMessage();
    }
}
