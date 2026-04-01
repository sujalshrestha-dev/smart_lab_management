package com.smartlab.servlet;

import com.smartlab.dao.LabDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet("/admin/manage-labs")
public class ManageLabsServlet extends HttpServlet {
    private final LabDAO labDAO = new LabDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        if (!isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }
        try {
            req.setAttribute("labs", labDAO.getAllLabsForAdmin());
            req.getRequestDispatcher("/admin/manage_labs.jsp").forward(req, resp);
        } catch (SQLException ex) {
            getServletContext().log("Load manage labs failed", ex);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=Unable+to+load+labs");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        if (!isAdmin(req.getSession(false))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String action = trim(req.getParameter("action"));
        try {
            if ("delete".equalsIgnoreCase(action)) {
                handleDelete(req, resp);
            } else {
                handleUpdate(req, resp);
            }
        } catch (SQLException ex) {
            getServletContext().log("Manage labs failed", ex);
            String msg = ex.getErrorCode() == 1062 ? "Email already exists." : "Unable to save lab changes.";
            resp.sendRedirect(req.getContextPath() + "/admin/manage-labs?error=" + enc(msg));
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/admin/manage-labs?error=" + enc("Invalid numeric value."));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        int labId = Integer.parseInt(req.getParameter("labId"));
        boolean ok = labDAO.deleteLabAccountByAdmin(labId);
        resp.sendRedirect(req.getContextPath() + "/admin/manage-labs?" + (ok ? "success=Lab+account+deleted" : "error=Unable+to+delete+lab"));
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        int labId = Integer.parseInt(req.getParameter("labId"));
        int userId = Integer.parseInt(req.getParameter("userId"));
        String labName = trim(req.getParameter("labName"));
        String city = trim(req.getParameter("city"));
        String address = trim(req.getParameter("address"));
        BigDecimal latitude = new BigDecimal(trim(req.getParameter("latitude")));
        BigDecimal longitude = new BigDecimal(trim(req.getParameter("longitude")));
        boolean verified = "1".equals(trim(req.getParameter("verified")));
        String ownerName = trim(req.getParameter("ownerName"));
        String ownerEmail = trim(req.getParameter("ownerEmail")).toLowerCase();
        String ownerContact = trim(req.getParameter("ownerContact"));
        String ownerStatus = trim(req.getParameter("ownerStatus")).toUpperCase();

        boolean ok = labDAO.updateLabByAdmin(new LabDAO.AdminLabUpdate(
                labId, userId, labName, city, address, latitude, longitude, verified,
                ownerName, ownerEmail, ownerContact, ownerStatus
        ));
        resp.sendRedirect(req.getContextPath() + "/admin/manage-labs?" + (ok ? "success=Lab+updated" : "error=Lab+update+failed"));
    }

    private static boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object role = session.getAttribute("role");
        return role != null && "ADMIN".equalsIgnoreCase(role.toString());
    }

    private static String trim(String v) {
        return v == null ? "" : v.trim();
    }

    private static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }
}
