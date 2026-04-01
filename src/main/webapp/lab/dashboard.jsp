<%@ page import="com.smartlab.dao.LabStatsDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"LAB_STAFF".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+lab+staff");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    LabStatsDAO.DashboardStats stats = new LabStatsDAO.DashboardStats(0, 0, 0, 0, java.math.BigDecimal.ZERO, 0, 0.0);
    try {
        Object uid = session.getAttribute("userId");
        if (uid instanceof Number) {
            stats = new LabStatsDAO().fetchByLabUserId(((Number) uid).intValue());
        }
    } catch (Exception ignored) {
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Dashboard</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .card { background: #fff; border-radius: 14px; padding: 18px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); }
        .stats { display: grid; grid-template-columns: repeat(7, minmax(150px, 1fr)); gap: 12px; margin-top: 12px; }
        .stat { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); }
        .stat .label { color: #56708a; font-size: 0.9rem; }
        .stat .value { font-size: 1.6rem; font-weight: 700; margin-top: 6px; }
        @media (max-width: 900px) { .layout { grid-template-columns: 1fr; } }
        @media (max-width: 1000px) { .stats { grid-template-columns: repeat(2, minmax(150px, 1fr)); } }
        @media (max-width: 600px) { .stats { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <h2>Lab Staff Panel</h2>
        <p><%= fullName %></p>
        <nav class="nav">
            <a class="active" href="<%= request.getContextPath() %>/lab/dashboard.jsp">Dashboard</a>
            <a href="<%= request.getContextPath() %>/lab/manage_tests.jsp">Manage Tests</a>
            <a href="<%= request.getContextPath() %>/LabAppointmentsServlet">Upload Report</a>
            <a href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Lab Dashboard</h1>
        <div class="card">Welcome, <strong><%= fullName %></strong>. Real-time overview of your lab.</div>
        <div class="stats">
            <div class="stat"><div class="label">Total Tests</div><div class="value"><%= stats.totalTests() %></div></div>
            <div class="stat"><div class="label">Total Appointments</div><div class="value"><%= stats.totalAppointments() %></div></div>
            <div class="stat"><div class="label">Completed Today</div><div class="value"><%= stats.completedToday() %></div></div>
            <div class="stat"><div class="label">Pending Reports</div><div class="value"><%= stats.pendingReports() %></div></div>
            <div class="stat"><div class="label">Daily Earnings</div><div class="value">Rs. <%= stats.dailyEarnings() %></div></div>
            <div class="stat"><div class="label">Patients Rated</div><div class="value"><%= stats.ratedPatients() %></div></div>
            <div class="stat"><div class="label">Average Rating</div><div class="value"><%= String.format("%.1f", stats.averageRating()) %></div></div>
        </div>
    </main>
</div>
</body>
</html>

