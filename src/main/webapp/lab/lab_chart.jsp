<%@ page import="com.smartlab.dao.LabDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"LAB_STAFF".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+lab+staff");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    LabDAO.LabChartSummary c = (LabDAO.LabChartSummary) request.getAttribute("chart");
    if (c == null) c = new LabDAO.LabChartSummary(0, 0, 0, 0, 0, java.math.BigDecimal.ZERO, 0.0, 0, 0, 0, 0, 0);
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Lab Chart</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        .charts { display: grid; grid-template-columns: repeat(3, minmax(250px, 1fr)); gap: 12px; align-items: stretch; }
        .card h3 { margin-top: 0; margin-bottom: 8px; font-size: 1rem; }
        .chart-wrap { width: 100%; max-width: 280px; margin: 0 auto; aspect-ratio: 1 / 1; }
        .chart-wrap canvas { width: 100% !important; height: 100% !important; }
        @media (max-width: 980px) {
            .charts { grid-template-columns: 1fr; }
        }
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
            <a href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a class="active" href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Lab Chart</h1>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>

    <div class="charts">
        <div class="card">
            <h3 style="margin-top:0;">Completed vs Pending</h3>
            <div class="chart-wrap"><canvas id="statusChart"></canvas></div>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">Paid vs Not Paid vs Verifying</h3>
            <div class="chart-wrap"><canvas id="paymentChart"></canvas></div>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">Ratings Summary</h3>
            <div class="chart-wrap"><canvas id="ratingChart"></canvas></div>
        </div>
    </div>
    </main>
</div>

<script>
    const commonPieOptions = {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 1
    };

    new Chart(document.getElementById('statusChart'), {
        type: 'doughnut',
        data: {
            labels: ['Completed', 'Pending'],
            datasets: [{
                data: [<%= c.completedCount() %>, <%= c.pendingCount() %>],
                backgroundColor: ['#0f9d58', '#f5b942']
            }]
        },
        options: commonPieOptions
    });

    new Chart(document.getElementById('paymentChart'), {
        type: 'doughnut',
        data: {
            labels: ['Paid', 'Not Paid', 'Verifying'],
            datasets: [{
                data: [<%= c.paidCount() %>, <%= c.unpaidCount() %>, <%= c.verifyingCount() %>],
                backgroundColor: ['#0f9d58', '#ca3d2e', '#f5b942']
            }]
        },
        options: commonPieOptions
    });

    new Chart(document.getElementById('ratingChart'), {
        type: 'pie',
        data: {
            labels: ['1-2 Star', '3 Star', '4-5 Star'],
            datasets: [{
                data: [<%= c.rating1() + c.rating2() %>, <%= c.rating3() %>, <%= c.rating4And5() %>],
                backgroundColor: ['#ca3d2e', '#f5b942', '#0b6bcb']
            }]
        },
        options: commonPieOptions
    });
</script>
</body>
</html>

