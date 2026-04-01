package com.smartlab.servlet;

import com.smartlab.dao.LabReviewDAO;

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
import java.util.Collections;

@WebServlet("/SubmitReviewServlet")
public class SubmitReviewServlet extends HttpServlet {
    private final LabReviewDAO reviewDAO = new LabReviewDAO();

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
            req.setAttribute("reviewRows", reviewDAO.getPatientReviewRows(patientId));
        } catch (SQLException ex) {
            getServletContext().log("Load review rows failed", ex);
            req.setAttribute("reviewRows", Collections.emptyList());
            req.setAttribute("error", "Unable to load review items.");
        }
        req.getRequestDispatcher("/patient/rating_review.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
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
        String action = trim(req.getParameter("action"));
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?error=" + enc("Invalid appointment."));
            return;
        }

        try {
            if ("ignore".equalsIgnoreCase(action)) {
                boolean ok = reviewDAO.ignoreAppointmentForReview(patientId, appointmentId);
                resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?" + (ok ? "success=Ignored+successfully" : "error=Unable+to+ignore"));
                return;
            }

            int rating;
            try {
                rating = Integer.parseInt(req.getParameter("rating"));
            } catch (Exception ex) {
                resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?error=" + enc("Select rating 1 to 5."));
                return;
            }
            if (rating < 1 || rating > 5) {
                resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?error=" + enc("Rating must be between 1 and 5."));
                return;
            }
            String comment = trim(req.getParameter("comment"));
            boolean ok = reviewDAO.submitRating(patientId, appointmentId, rating, comment);
            resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?" + (ok
                    ? "success=Thanks+for+rating."
                    : "error=Unable+to+submit+rating"));
        } catch (SQLException ex) {
            getServletContext().log("Submit review failed", ex);
            resp.sendRedirect(req.getContextPath() + "/SubmitReviewServlet?error=" + enc("Database error."));
        }
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
