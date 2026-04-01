package com.smartlab.servlet;

import com.smartlab.dao.TestDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet("/AddTestServlet")
public class AddTestServlet extends HttpServlet {
    private final TestDAO testDAO = new TestDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isLabStaff(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+lab+staff");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int labUserId = ((Number) uid).intValue();

        String action = trim(req.getParameter("action"));
        try {
            if ("update".equalsIgnoreCase(action)) {
                handleUpdate(req, resp, labUserId);
            } else if ("toggle".equalsIgnoreCase(action)) {
                handleToggle(req, resp, labUserId);
            } else {
                handleAdd(req, resp, labUserId);
            }
        } catch (SQLException ex) {
            getServletContext().log("Manage tests failed", ex);
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Database+error");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, int labUserId) throws IOException, SQLException {
        String name = trim(req.getParameter("testName"));
        String description = trim(req.getParameter("description"));
        String priceRaw = trim(req.getParameter("price"));
        String availability = trim(req.getParameter("availability"));

        if (name.isBlank() || priceRaw.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Name+and+price+are+required");
            return;
        }
        BigDecimal price;
        try {
            price = new BigDecimal(priceRaw);
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Invalid+price");
            return;
        }

        boolean ok = testDAO.addTest(labUserId, name, description, price, availability);
        resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?" + (ok ? "success=Test+added" : "error=Unable+to+add+test"));
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, int labUserId) throws IOException, SQLException {
        String idRaw = trim(req.getParameter("testId"));
        String name = trim(req.getParameter("testName"));
        String description = trim(req.getParameter("description"));
        String priceRaw = trim(req.getParameter("price"));
        String availability = trim(req.getParameter("availability"));

        int testId;
        BigDecimal price;
        try {
            testId = Integer.parseInt(idRaw);
            price = new BigDecimal(priceRaw);
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Invalid+test+data");
            return;
        }
        boolean ok = testDAO.updateTest(labUserId, testId, name, description, price, availability);
        resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?" + (ok ? "success=Test+updated" : "error=Unable+to+update+test"));
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp, int labUserId) throws IOException, SQLException {
        String idRaw = trim(req.getParameter("testId"));
        int testId;
        try {
            testId = Integer.parseInt(idRaw);
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Invalid+test+id");
            return;
        }
        boolean ok = testDAO.toggleAvailability(labUserId, testId);
        resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?" + (ok ? "success=Availability+updated" : "error=Unable+to+toggle+availability"));
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
