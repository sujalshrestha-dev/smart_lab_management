package com.smartlab.servlet;

import com.smartlab.dao.LabDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/pending-labs")
public class PendingLabsServlet extends HttpServlet {
    private final LabDAO labDAO = new LabDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        if (!isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }
        try {
            req.setAttribute("pendingLabs", labDAO.getPendingLabs());
            req.getRequestDispatcher("/admin/pending_labs.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Failed to load pending labs", ex);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=Unable+to+load+pending+labs");
        }
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object role = session.getAttribute("role");
        return role != null && "ADMIN".equalsIgnoreCase(role.toString());
    }
}
