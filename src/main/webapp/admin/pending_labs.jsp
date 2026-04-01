<%@ page import="java.util.List" %>
<%@ page import="com.smartlab.dao.LabDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"ADMIN".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+admin");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    List<LabDAO.PendingLab> pendingLabs = (List<LabDAO.PendingLab>) request.getAttribute("pendingLabs");
    if (pendingLabs == null) {
        pendingLabs = java.util.Collections.emptyList();
    }
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Pending Labs</title>
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
        .main { padding: 26px 18px 40px; }
        .top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 16px;
        }
        h1 {
            margin: 0;
            font-size: 1.55rem;
        }
        .btn {
            text-decoration: none;
            border-radius: 10px;
            padding: 9px 14px;
            font-weight: 600;
            border: 0;
            cursor: pointer;
        }
        .btn-light {
            background: #e7eef7;
            color: #1e3550;
        }
        .btn-approve {
            background: #0f9d58;
            color: white;
        }
        .btn-reject {
            background: #ca3d2e;
            color: white;
        }
        .flash {
            margin-bottom: 12px;
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 0.92rem;
        }
        .ok {
            background: #eaf8ee;
            color: #116736;
            border: 1px solid #bee8ca;
        }
        .err {
            background: #fdecec;
            color: #8f1e15;
            border: 1px solid #f8c9c4;
        }
        .table-wrap {
            overflow-x: auto;
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 980px;
        }
        th, td {
            text-align: left;
            padding: 12px 10px;
            border-bottom: 1px solid #e6edf6;
            vertical-align: top;
            font-size: 0.92rem;
        }
        th {
            background: #f8fbff;
            color: #415e7b;
            font-weight: 700;
        }
        .actions {
            display: flex;
            gap: 8px;
        }
        .empty {
            background: #fff;
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
            color: #4f6881;
        }
        @media (max-width: 900px) { .layout { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <h2>Admin Panel</h2>
        <p><%= fullName %></p>
        <nav class="nav">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a class="active" href="<%= request.getContextPath() %>/admin/pending-labs">Pending Labs</a>
            <a href="<%= request.getContextPath() %>/admin/manage-labs">Manage Labs</a>
            <a href="<%= request.getContextPath() %>/admin/profile">Admin Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <div class="top">
            <h1>Verification: Pending Lab Accounts</h1>
            <a class="btn btn-light" href="<%= request.getContextPath() %>/admin/dashboard">Back to Dashboard</a>
        </div>

    <% if (success != null) { %>
    <div class="flash ok"><%= success %></div>
    <% } %>
    <% if (error != null) { %>
    <div class="flash err"><%= error %></div>
    <% } %>

    <% if (pendingLabs.isEmpty()) { %>
    <div class="empty">No labs are waiting for verification.</div>
    <% } else { %>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Lab</th>
                <th>Owner</th>
                <th>City</th>
                <th>Address</th>
                <th>Coordinates</th>
                <th>Requested At</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <% for (LabDAO.PendingLab lab : pendingLabs) { %>
            <tr>
                <td><strong><%= lab.labName() %></strong></td>
                <td>
                    <div><%= lab.ownerName() %></div>
                    <div><%= lab.ownerEmail() %></div>
                    <div><%= lab.ownerContact() %></div>
                </td>
                <td><%= lab.city() %></td>
                <td><%= lab.address() %></td>
                <td><%= lab.latitude() %>, <%= lab.longitude() %></td>
                <td><%= lab.requestedAt() %></td>
                <td>
                    <div class="actions">
                        <form action="<%= request.getContextPath() %>/admin/labs/approve" method="post">
                            <input type="hidden" name="labId" value="<%= lab.labId() %>">
                            <button class="btn btn-approve" type="submit">Approve</button>
                        </form>
                        <form action="<%= request.getContextPath() %>/admin/labs/reject" method="post">
                            <input type="hidden" name="labId" value="<%= lab.labId() %>">
                            <button class="btn btn-reject" type="submit">Reject</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <% } %>
    </main>
</div>
</body>
</html>
