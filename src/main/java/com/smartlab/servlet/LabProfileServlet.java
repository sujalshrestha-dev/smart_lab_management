package com.smartlab.servlet;

import com.smartlab.dao.LabDAO;

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
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/LabProfileServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024
)
public class LabProfileServlet extends HttpServlet {
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
            req.setAttribute("profile", labDAO.getProfileByUserId(labUserId));
            req.setAttribute("photos", labDAO.getPhotosByUserId(labUserId));
        } catch (SQLException ex) {
            getServletContext().log("Load lab profile failed", ex);
            req.setAttribute("error", "Unable to load lab profile.");
        }
        req.getRequestDispatcher("/lab/lab_profile.jsp").forward(req, resp);
    }

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

        String action = trim(req.getParameter("action"));
        try {
            if ("uploadPhoto".equalsIgnoreCase(action)) {
                uploadPhoto(req, resp, labUserId);
            } else {
                updateProfile(req, resp, labUserId);
            }
        } catch (SQLException ex) {
            getServletContext().log("Update lab profile failed", ex);
            resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?error=Database+error");
        }
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, int labUserId) throws IOException, SQLException {
        String labName = trim(req.getParameter("labName"));
        String city = trim(req.getParameter("city"));
        String address = trim(req.getParameter("address"));
        String description = trim(req.getParameter("description"));
        BigDecimal lat;
        BigDecimal lng;
        try {
            lat = new BigDecimal(trim(req.getParameter("latitude")));
            lng = new BigDecimal(trim(req.getParameter("longitude")));
        } catch (Exception ex) {
            resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?error=Invalid+map+coordinates");
            return;
        }
        if (labName.isBlank() || city.isBlank() || address.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?error=Lab+name,+city,+address+required");
            return;
        }
        boolean ok = labDAO.updateProfileByUserId(labUserId, labName, city, address, description, lat, lng);
        resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?" + (ok ? "success=Profile+updated" : "error=Unable+to+update+profile"));
    }

    private void uploadPhoto(HttpServletRequest req, HttpServletResponse resp, int labUserId) throws IOException, ServletException, SQLException {
        Part photo = req.getPart("photo");
        if (photo == null || photo.getSize() <= 0) {
            resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?error=Please+select+a+photo");
            return;
        }
        String original = Paths.get(photo.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int idx = original.lastIndexOf('.');
        if (idx >= 0) ext = original.substring(idx);
        String fileName = "lab_photo_" + labUserId + "_" + UUID.randomUUID() + ext;

        String uploadDir = req.getServletContext().getRealPath("/uploads/lab_photos");
        File dir = new File(uploadDir);
        if (!dir.exists() && !dir.mkdirs()) {
            resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?error=Cannot+create+photo+directory");
            return;
        }
        File saved = new File(dir, fileName);
        photo.write(saved.getAbsolutePath());
        String relativePath = "uploads/lab_photos/" + fileName;

        boolean ok = labDAO.addLabPhotoByUserId(labUserId, relativePath);
        resp.sendRedirect(req.getContextPath() + "/LabProfileServlet?" + (ok ? "success=Photo+uploaded" : "error=Unable+to+save+photo"));
    }

    private boolean isLabStaff(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "LAB_STAFF".equalsIgnoreCase(role.toString());
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
