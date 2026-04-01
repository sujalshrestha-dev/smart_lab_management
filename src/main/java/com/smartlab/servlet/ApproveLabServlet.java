package com.smartlab.servlet;

import com.smartlab.dao.LabDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/labs/approve")
public class ApproveLabServlet extends HttpServlet {
    private final LabDAO labDAO = new LabDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Please+login+as+admin");
            return;
        }

        String labIdRaw = req.getParameter("labId");
        int labId;
        try {
            labId = Integer.parseInt(labIdRaw);
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/admin/pending-labs?error=Invalid+lab+id");
            return;
        }

        Object adminAttr = session.getAttribute("userId");
        if (!(adminAttr instanceof Number)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=Invalid+admin+session");
            return;
        }
        int adminId = ((Number) adminAttr).intValue();
        try {
            boolean ok = labDAO.approveLab(labId, adminId);
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/pending-labs?success=Lab+approved");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/pending-labs?error=Lab+already+processed");
            }
        } catch (SQLException ex) {
            getServletContext().log("Failed to approve lab", ex);
            resp.sendRedirect(req.getContextPath() + "/admin/pending-labs?error=Unable+to+approve+lab");
        }
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        Object role = session.getAttribute("role");
        return role != null && "ADMIN".equalsIgnoreCase(role.toString());
    }
}
