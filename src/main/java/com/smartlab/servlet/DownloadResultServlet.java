package com.smartlab.servlet;

import com.smartlab.dao.PaymentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.sql.SQLException;
import java.util.Locale;

@WebServlet("/DownloadResultServlet")
public class DownloadResultServlet extends HttpServlet {
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

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid appointment id");
            return;
        }

        try {
            PaymentDAO.PatientResultAccess result = paymentDAO.getPatientResultAccess(patientId, appointmentId);
            if (result == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found");
                return;
            }
            if (!"PAID".equalsIgnoreCase(result.paymentStatus())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Result is hidden until payment is PAID");
                return;
            }
            if (result.reportPath() == null || result.reportPath().isBlank()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Result not uploaded yet");
                return;
            }

            File file = resolveResultFile(req, result.reportPath());
            if (!file.exists()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Result file missing");
                return;
            }

            String mimeType = resolveMimeType(req, file);
            String fileName = buildDownloadName(appointmentId, file.getName());
            String dispositionType = "inline".equalsIgnoreCase(req.getParameter("mode")) ? "inline" : "attachment";

            resp.setContentType(mimeType);
            resp.setContentLengthLong(file.length());
            resp.setHeader("X-Content-Type-Options", "nosniff");
            resp.setHeader("Content-Disposition", dispositionType + "; filename=\"" + fileName + "\"");
            Files.copy(file.toPath(), resp.getOutputStream());
        } catch (SQLException ex) {
            getServletContext().log("Download result failed", ex);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to download result");
        }
    }

    private File resolveResultFile(HttpServletRequest req, String reportPath) {
        return new File(req.getServletContext().getRealPath("/"), reportPath.replace("/", File.separator));
    }

    private String resolveMimeType(HttpServletRequest req, File file) throws IOException {
        String mimeType = req.getServletContext().getMimeType(file.getName());
        if (mimeType == null || mimeType.isBlank()) {
            mimeType = Files.probeContentType(file.toPath());
        }
        return (mimeType == null || mimeType.isBlank()) ? "application/octet-stream" : mimeType;
    }

    private String buildDownloadName(int appointmentId, String sourceName) {
        String extension = "";
        int idx = sourceName.lastIndexOf('.');
        if (idx >= 0) {
            extension = sourceName.substring(idx).toLowerCase(Locale.ROOT);
        }
        return "lab-result-appointment-" + appointmentId + extension;
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }
}
