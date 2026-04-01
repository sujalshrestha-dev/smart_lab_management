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

@WebServlet("/UpdateAppointmentStatusServlet")
public class UpdateAppointmentStatusServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

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

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Invalid+appointment+id");
            return;
        }
        String status = req.getParameter("status");

        try {
            boolean ok = appointmentDAO.updateStatus(labUserId, appointmentId, status);
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?" + (ok ? "success=Status+updated" : "error=Unable+to+update+status"));
        } catch (SQLException ex) {
            getServletContext().log("Status update failed", ex);
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Database+error");
        }
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }
}
