package com.smartlab.servlet;

import com.smartlab.dao.TestDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/DeleteTestServlet")
public class DeleteTestServlet extends HttpServlet {
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

        String idRaw = req.getParameter("testId");
        int testId;
        try {
            testId = Integer.parseInt(idRaw);
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Invalid+test+id");
            return;
        }

        try {
            boolean ok = testDAO.deleteTest(labUserId, testId);
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?" + (ok ? "success=Test+deleted" : "error=Unable+to+delete+test"));
        } catch (SQLException ex) {
            getServletContext().log("Delete test failed", ex);
            resp.sendRedirect(req.getContextPath() + "/lab/manage_tests.jsp?error=Database+error");
        }
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }
}
