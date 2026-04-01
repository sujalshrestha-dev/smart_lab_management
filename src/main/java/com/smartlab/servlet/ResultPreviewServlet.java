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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.sql.SQLException;
import java.util.Locale;

@WebServlet("/ResultPreviewServlet")
public class ResultPreviewServlet extends HttpServlet {
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
        String source = normalizeSource(req.getParameter("from"));

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            redirectToSource(req, resp, source, "Invalid appointment id");
            return;
        }

        try {
            PaymentDAO.PatientResultAccess result = paymentDAO.getPatientResultAccess(patientId, appointmentId);
            if (result == null) {
                redirectToSource(req, resp, source, "Appointment not found");
                return;
            }
            if (!"PAID".equalsIgnoreCase(result.paymentStatus())) {
                redirectToSource(req, resp, source, "Result is hidden until payment is PAID");
                return;
            }
            if (result.reportPath() == null || result.reportPath().isBlank()) {
                redirectToSource(req, resp, source, "Result not uploaded yet");
                return;
            }

            File file = resolveResultFile(req, result.reportPath());
            if (!file.exists()) {
                redirectToSource(req, resp, source, "Result file is missing");
                return;
            }

            String mimeType = resolveMimeType(req, file);
            req.setAttribute("resultInfo", result);
            req.setAttribute("previewType", determinePreviewType(mimeType, file.getName()));
            req.setAttribute("downloadUrl", req.getContextPath() + "/DownloadResultServlet?appointmentId=" + appointmentId + "&mode=download");
            req.setAttribute("inlineUrl", req.getContextPath() + "/DownloadResultServlet?appointmentId=" + appointmentId + "&mode=inline");
            req.setAttribute("backUrl", req.getContextPath() + ("history".equals(source) ? "/HistoryServlet" : "/MyAppointmentsServlet"));
            req.setAttribute("backLabel", "history".equals(source) ? "Back to History" : "Back to Appointments");
            req.setAttribute("activePage", source);
            req.setAttribute("displayFileName", buildDisplayName(appointmentId, file.getName()));
            req.getRequestDispatcher("/patient/result_preview.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load result preview failed", ex);
            redirectToSource(req, resp, source, "Unable to load result preview");
        }
    }

    private void redirectToSource(HttpServletRequest req, HttpServletResponse resp, String source, String message) throws IOException {
        String target = "history".equals(source) ? "/HistoryServlet" : "/MyAppointmentsServlet";
        resp.sendRedirect(req.getContextPath() + target + "?error=" + url(message));
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

    private String determinePreviewType(String mimeType, String fileName) {
        String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        if ("application/pdf".equalsIgnoreCase(mimeType) || lowerName.endsWith(".pdf")) {
            return "pdf";
        }
        if (mimeType != null && mimeType.toLowerCase(Locale.ROOT).startsWith("image/")) {
            return "image";
        }
        if (mimeType != null && mimeType.toLowerCase(Locale.ROOT).startsWith("text/")) {
            return "text";
        }
        if (lowerName.endsWith(".png") || lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".gif") || lowerName.endsWith(".bmp") || lowerName.endsWith(".webp")) {
            return "image";
        }
        if (lowerName.endsWith(".txt") || lowerName.endsWith(".csv") || lowerName.endsWith(".json")
                || lowerName.endsWith(".xml") || lowerName.endsWith(".log")) {
            return "text";
        }
        return "unsupported";
    }

    private String buildDisplayName(int appointmentId, String sourceName) {
        String extension = "";
        int idx = sourceName.lastIndexOf('.');
        if (idx >= 0) {
            extension = sourceName.substring(idx).toLowerCase(Locale.ROOT);
        }
        return "Appointment-" + appointmentId + "-Result" + extension;
    }

    private String normalizeSource(String source) {
        return "history".equalsIgnoreCase(source) ? "history" : "appointments";
    }

    private String url(String text) {
        return URLEncoder.encode(text == null ? "" : text, StandardCharsets.UTF_8);
    }

    private boolean isPatient(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "PATIENT".equalsIgnoreCase(role.toString());
    }
}
