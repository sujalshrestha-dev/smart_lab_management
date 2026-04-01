package com.smartlab.servlet;

import com.smartlab.dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;

@WebServlet("/LabAppointmentsServlet")
public class LabAppointmentsServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

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
            req.setAttribute("appointments", appointmentDAO.getLabActiveAppointments(labUserId));
        } catch (SQLException ex) {
            getServletContext().log("Load lab appointments failed", ex);
            req.setAttribute("appointments", Collections.emptyList());
            req.setAttribute("error", "Unable to load appointments.");
        }
        req.getRequestDispatcher("/lab/upload_result.jsp").forward(req, resp);
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }
}
