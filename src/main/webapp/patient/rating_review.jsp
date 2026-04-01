<%@ page import="com.smartlab.dao.LabReviewDAO" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    List<LabReviewDAO.PatientReviewRow> rows = (List<LabReviewDAO.PatientReviewRow>) request.getAttribute("reviewRows");
    if (rows == null) rows = Collections.emptyList();
    String activePage = "reviews";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | Rating and Review</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .main { padding: 24px; }
        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .card { background: #fff; border-radius: 14px; padding: 14px; box-shadow: 0 10px 20px rgba(15,39,66,.08); margin-bottom: 10px; }
        .top { display: flex; justify-content: space-between; gap: 10px; flex-wrap: wrap; }
        .muted { color: #5a748e; font-size: .9rem; }
        .actions { display: flex; gap: 6px; flex-wrap: wrap; margin-top: 10px; align-items: center; }
        .actions select, .actions input { border: 1px solid #d1deea; border-radius: 8px; padding: 6px 8px; font-size: .84rem; }
        .btn { border: 0; border-radius: 8px; padding: 7px 10px; cursor: pointer; font-weight: 600; font-size: .84rem; }
        .btn-rate { background: #0b6bcb; color: #fff; }
        .btn-ignore { background: #ca3d2e; color: #fff; }
        .stars { color: #f39c12; font-size: 1rem; letter-spacing: 1px; }
        @media (max-width: 900px) { .layout { grid-template-columns: 1fr; } }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>
    <main class="main">
        <h1>Rating and Review</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>

        <% if (rows.isEmpty()) { %>
        <div class="card">No completed labs pending for rating.</div>
        <% } else { %>
        <% for (LabReviewDAO.PatientReviewRow r : rows) { %>
        <div class="card">
            <div class="top">
                <div>
                    <div><strong><%= r.labName() %></strong></div>
                    <div class="muted">Appointment #<%= r.appointmentId() %> | <%= r.appointmentDate() %></div>
                </div>
            </div>

            <% if (r.rating() != null) { %>
            <div style="margin-top:8px;">
                <span class="stars">
                    <% for (int i = 0; i < r.rating(); i++) { %>&#9733;<% } %>
                </span>
                <span> (<%= r.rating() %>/5)</span>
                <div class="muted" style="margin-top:4px;">Thanks for rating.</div>
            </div>
            <% } else { %>
            <div class="actions">
                <form method="post" action="<%= request.getContextPath() %>/SubmitReviewServlet">
                    <input type="hidden" name="action" value="rate">
                    <input type="hidden" name="appointmentId" value="<%= r.appointmentId() %>">
                    <select name="rating" required>
                        <option value="">Rate 1-5</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                    </select>
                    <input type="text" name="comment" placeholder="Optional comment">
                    <button class="btn btn-rate" type="submit">Rate</button>
                </form>
                <form method="post" action="<%= request.getContextPath() %>/SubmitReviewServlet">
                    <input type="hidden" name="action" value="ignore">
                    <input type="hidden" name="appointmentId" value="<%= r.appointmentId() %>">
                    <button class="btn btn-ignore" type="submit">Ignore</button>
                </form>
            </div>
            <% } %>
        </div>
        <% } %>
        <% } %>
    </main>
</div>
</body>
</html>



