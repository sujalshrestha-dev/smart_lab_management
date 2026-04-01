package com.smartlab.servlet;

import com.smartlab.dao.PaymentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/MyAppointmentsServlet")
public class MyAppointmentsServlet extends HttpServlet {
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+patient");
            return;
        }
        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+session");
            return;
        }
        int patientId = ((Number) uid).intValue();
        try {
            req.setAttribute("appointments", paymentDAO.getPatientUnfinishedAppointments(patientId));
            req.getRequestDispatcher("/patient/my_appointments.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load patient appointments failed", ex);
            resp.sendRedirect(req.getContextPath() + "/patient/my_appointments.jsp?error=Unable+to+load+appointments");
        }
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }
}
