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

@WebServlet("/LabChartServlet")
public class LabChartServlet extends HttpServlet {
    private final LabDAO labDAO = new LabDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
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
        try {
            req.setAttribute("chart", labDAO.getChartSummaryByUserId(labUserId));
        } catch (SQLException ex) {
            getServletContext().log("Load lab chart failed", ex);
            req.setAttribute("error", "Unable to load chart data.");
        }
        req.getRequestDispatcher("/lab/lab_chart.jsp").forward(req, resp);
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }
}
