package com.smartlab.servlet;

import com.smartlab.dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/UploadResultServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 20 * 1024 * 1024,
        maxRequestSize = 25 * 1024 * 1024
)
public class UploadResultServlet extends HttpServlet {
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
        int uploaderUserId = ((Number) uid).intValue();

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Invalid+appointment+id");
            return;
        }

        try {
            AppointmentDAO.AppointmentUploadCheck check = appointmentDAO.getUploadCheck(uploaderUserId, appointmentId);
            if (!check.allowed()) {
                resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=" + url(check.reason()));
                return;
            }

            Part filePart = req.getPart("resultFile");
            if (filePart == null || filePart.getSize() <= 0) {
                resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Please+select+a+file");
                return;
            }

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int idx = fileName.lastIndexOf('.');
            if (idx >= 0) {
                ext = fileName.substring(idx);
            }
            String safeName = "report_" + appointmentId + "_" + UUID.randomUUID() + ext;

            String uploadDir = req.getServletContext().getRealPath("/uploads");
            File dir = new File(uploadDir);
            if (!dir.exists() && !dir.mkdirs()) {
                resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Unable+to+create+upload+directory");
                return;
            }

            File saved = new File(dir, safeName);
            filePart.write(saved.getAbsolutePath());
            String relativePath = "uploads/" + safeName;

            boolean savedInDb = appointmentDAO.upsertReport(appointmentId, uploaderUserId, relativePath);
            if (!savedInDb) {
                resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Failed+to+save+report");
                return;
            }
            appointmentDAO.updateStatus(uploaderUserId, appointmentId, "COMPLETED");
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?success=Report+uploaded+and+appointment+completed");
        } catch (SQLException ex) {
            getServletContext().log("Upload report failed", ex);
            resp.sendRedirect(req.getContextPath() + "/LabAppointmentsServlet?error=Database+error");
        }
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }

    private String url(String text) {
        return java.net.URLEncoder.encode(text == null ? "" : text, java.nio.charset.StandardCharsets.UTF_8);
    }
}
