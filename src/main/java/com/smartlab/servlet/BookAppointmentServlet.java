package com.smartlab.servlet;

import com.smartlab.dao.AppointmentDAO;
import com.smartlab.dao.LabDAO;
import com.smartlab.dao.TestDAO;
import com.smartlab.dao.UserDAO;
import com.smartlab.dao.PaymentDAO;
import com.smartlab.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@WebServlet("/BookAppointmentServlet")
public class BookAppointmentServlet extends HttpServlet {
    private final LabDAO labDAO = new LabDAO();
    private final TestDAO testDAO = new TestDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isPatient(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+patient");
            return;
        }
        int labId;
        try {
            labId = Integer.parseInt(req.getParameter("labId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/FindLabsServlet?error=Invalid+lab+selection");
            return;
        }

        try {
            req.setAttribute("lab", labDAO.getPublicLabProfile(labId));
            req.setAttribute("tests", testDAO.getAvailableByLabId(labId));
            User patient = userDAO.findById(((Number) session.getAttribute("userId")).intValue());
            req.setAttribute("patient", patient);
        } catch (SQLException ex) {
            getServletContext().log("Load book appointment page failed", ex);
            req.setAttribute("lab", null);
            req.setAttribute("tests", Collections.emptyList());
            req.setAttribute("error", "Unable to load lab details.");
        }
        req.getRequestDispatcher("/patient/book_appointment.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
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

        int labId;
        try {
            labId = Integer.parseInt(req.getParameter("labId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/FindLabsServlet?error=Invalid+lab+selection");
            return;
        }

        String dateRaw = req.getParameter("appointmentDate");
        String timeRaw = req.getParameter("appointmentTime");
        String notes = req.getParameter("notes");
        String[] testRaw = req.getParameterValues("testIds");

        if (dateRaw == null || dateRaw.isBlank() || testRaw == null || testRaw.length == 0) {
            resp.sendRedirect(req.getContextPath() + "/BookAppointmentServlet?labId=" + labId + "&error="
                    + url("Date and at least one test are required."));
            return;
        }

        List<Integer> testIds = new ArrayList<>();
        try {
            for (String id : testRaw) {
                testIds.add(Integer.parseInt(id));
            }
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/BookAppointmentServlet?labId=" + labId + "&error="
                    + url("Invalid test selection."));
            return;
        }

        try {
            Date appointmentDate = Date.valueOf(dateRaw);
            if (appointmentDate.toLocalDate().isBefore(LocalDate.now())) {
                resp.sendRedirect(req.getContextPath() + "/BookAppointmentServlet?labId=" + labId + "&error="
                        + url("Appointment date cannot be in the past."));
                return;
            }
            Time appointmentTime = (timeRaw == null || timeRaw.isBlank()) ? null : Time.valueOf(timeRaw + ":00");
            int appointmentId = appointmentDAO.createAppointmentWithTests(patientId, labId, appointmentDate, appointmentTime, notes, testIds);
            java.math.BigDecimal total = testDAO.getAvailableByLabId(labId).stream()
                    .filter(t -> testIds.contains(t.getId()))
                    .map(com.smartlab.model.Test::getPrice)
                    .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);
            paymentDAO.createPaymentForAppointment(appointmentId, "CASH", total, null);
            resp.sendRedirect(req.getContextPath() + "/BookAppointmentServlet?labId=" + labId + "&success="
                    + url("Appointment booked successfully."));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/BookAppointmentServlet?labId=" + labId + "&error="
                    + url("Unable to book appointment. " + ex.getMessage()));
        }
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }

    private String url(String text) {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }
}
