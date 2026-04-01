<%@ page import="com.smartlab.dao.AdminStatsDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"ADMIN".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+admin");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    AdminStatsDAO.DashboardStats stats = (AdminStatsDAO.DashboardStats) request.getAttribute("stats");
    if (stats == null) {
        stats = new AdminStatsDAO.DashboardStats(0, 0, 0, 0);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Dashboard</title>
    <style>
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f8fc;
            color: #1e3550;
        }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 28px 20px 40px; }
        .top {
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 20px;
        }
        .title {
            margin: 0;
            font-size: 1.8rem;
        }
        .subtitle {
            margin-top: 4px;
            color: #5a738d;
        }
        .btn {
            text-decoration: none;
            border-radius: 10px;
            padding: 10px 14px;
            font-weight: 600;
        }
        .btn-primary {
            background: #0b6bcb;
            color: white;
        }
        .btn-danger {
            background: #ca3d2e;
            color: white;
            margin-left: 8px;
        }
        .grid {
            display: grid;
            gap: 14px;
            grid-template-columns: repeat(4, minmax(160px, 1fr));
        }
        .card {
            background: #fff;
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
        }
        .label {
            color: #67809a;
            font-size: 0.9rem;
            margin-bottom: 6px;
        }
        .value {
            font-size: 1.9rem;
            font-weight: 700;
        }
        .section {
            margin-top: 22px;
            background: #fff;
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
        }
        .section h2 {
            margin: 0 0 8px;
            font-size: 1.2rem;
        }
        .section p {
            margin: 0;
            color: #4f6881;
            line-height: 1.45;
        }
        @media (max-width: 900px) {
            .layout { grid-template-columns: 1fr; }
            .grid {
                grid-template-columns: repeat(2, minmax(160px, 1fr));
            }
        }
        @media (max-width: 520px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <h2>Admin Panel</h2>
        <p><%= fullName %></p>
        <nav class="nav">
            <a class="active" href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/pending-labs">Pending Labs</a>
            <a href="<%= request.getContextPath() %>/admin/manage-labs">Manage Labs</a>
            <a href="<%= request.getContextPath() %>/admin/profile">Admin Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <div class="top">
            <div>
                <h1 class="title">Admin Panel</h1>
                <p class="subtitle">Welcome, <strong><%= fullName %></strong>. Dashboard overview and lab verification control</p>
            </div>
            <div>
                <a class="btn btn-primary" href="<%= request.getContextPath() %>/admin/pending-labs">Go To Verification</a>
                <a class="btn btn-danger" href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
            </div>
        </div>

    <div class="grid">
        <div class="card">
            <div class="label">Total Patients</div>
            <div class="value"><%= stats.totalPatients() %></div>
        </div>
        <div class="card">
            <div class="label">Total Labs</div>
            <div class="value"><%= stats.totalLabs() %></div>
        </div>
        <div class="card">
            <div class="label">Total Appointments</div>
            <div class="value"><%= stats.totalAppointments() %></div>
        </div>
        <div class="card">
            <div class="label">Pending Verification</div>
            <div class="value"><%= stats.pendingLabs() %></div>
        </div>
    </div>

        <div class="section">
            <h2>Verification Policy</h2>
            <p>Lab staff registrations stay hidden from Browse Labs until an admin manually approves them.
                Use the verification page to approve or reject each pending lab account.</p>
        </div>
    </main>
</div>
</body>
</html>
