<%@ page import="com.smartlab.dao.AppointmentDAO" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"LAB_STAFF".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+lab+staff");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String error = (String) request.getAttribute("error");
    List<AppointmentDAO.LabAppointmentRow> appointments =
            (List<AppointmentDAO.LabAppointmentRow>) request.getAttribute("appointments");
    if (appointments == null) appointments = Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Completed Reports</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 980px; border-collapse: collapse; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; font-size: .9rem; vertical-align: top; }
        th { color: #415e7b; background: #f8fbff; }
        .pill { border-radius: 999px; padding: 3px 9px; font-size: 0.78rem; font-weight: 700; display: inline-block; }
        .status-COMPLETED { background: #d8e9fb; color: #124d82; }
        .pay-PAID { background: #d7f2e3; color: #145c35; }
        .pay-VERIFYING { background: #fff3cd; color: #8a6d1d; }
        .pay-UNPAID { background: #fde2e0; color: #8c1f15; }
        @media (max-width: 900px) { .layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <h2>Lab Staff Panel</h2>
        <p><%= fullName %></p>
        <nav class="nav">
            <a href="<%= request.getContextPath() %>/lab/dashboard.jsp">Dashboard</a>
            <a href="<%= request.getContextPath() %>/lab/manage_tests.jsp">Manage Tests</a>
            <a href="<%= request.getContextPath() %>/LabAppointmentsServlet">Upload Report</a>
            <a class="active" href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Completed Reports</h1>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Appointment</th>
                        <th>Patient</th>
                        <th>Date/Time</th>
                        <th>Status</th>
                        <th>Payment</th>
                        <th>Result</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (appointments.isEmpty()) { %>
                    <tr><td colspan="6">No completed reports found.</td></tr>
                    <% } else { %>
                    <% for (AppointmentDAO.LabAppointmentRow a : appointments) { %>
                    <%
                        boolean paid = "PAID".equalsIgnoreCase(a.paymentStatus());
                        boolean online = !"CASH".equalsIgnoreCase(a.paymentMethod());
                        String payView = paid ? "PAID" : (online ? "VERIFYING" : "UNPAID");
                    %>
                    <tr>
                        <td>#<%= a.appointmentId() %></td>
                        <td><strong><%= a.patientName() %></strong><br><%= a.notes() == null ? "" : a.notes() %></td>
                        <td><%= a.appointmentDate() %> <%= a.appointmentTime() == null ? "" : a.appointmentTime() %></td>
                        <td><span class="pill status-COMPLETED">COMPLETED</span></td>
                        <td><span class="pill pay-<%= payView %>"><%= payView %></span></td>
                        <td>
                            <% if (a.reportPath() != null && !a.reportPath().isBlank()) { %>
                            <a href="<%= request.getContextPath() + "/" + a.reportPath() %>" target="_blank">View Result</a>
                            <% } else { %>
                            <span>-</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>
