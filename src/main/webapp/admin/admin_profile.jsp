<%@ page import="com.smartlab.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"ADMIN".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+admin");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    User adminUser = (User) request.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Unable+to+load+profile");
        return;
    }
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Profile</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .cards { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        label { display: block; margin: 8px 0 4px; font-weight: 600; font-size: .9rem; }
        input { width: 100%; border: 1px solid #d2deea; border-radius: 8px; padding: 9px 10px; box-sizing: border-box; }
        .btn { margin-top: 10px; border: 0; border-radius: 8px; padding: 9px 12px; font-weight: 600; background: #0b6bcb; color: #fff; cursor: pointer; }
        @media (max-width: 960px) { .layout { grid-template-columns: 1fr; } .cards { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <h2>Admin Panel</h2>
        <p><%= fullName %></p>
        <nav class="nav">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/pending-labs">Pending Labs</a>
            <a href="<%= request.getContextPath() %>/admin/manage-labs">Manage Labs</a>
            <a class="active" href="<%= request.getContextPath() %>/admin/profile">Admin Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Admin Profile</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>
        <div class="cards">
            <section class="card">
                <h3 style="margin-top:0;">Update Profile</h3>
                <form method="post" action="<%= request.getContextPath() %>/admin/profile">
                    <input type="hidden" name="action" value="updateProfile">
                    <label>Full Name</label>
                    <input type="text" name="fullName" required value="<%= adminUser.getFullName() %>">
                    <label>Username</label>
                    <input type="text" name="username" required value="<%= adminUser.getUsername() %>">
                    <label>Email</label>
                    <input type="email" name="email" required value="<%= adminUser.getEmail() %>">
                    <label>Contact Number</label>
                    <input type="text" name="contactNumber" required value="<%= adminUser.getContactNumber() %>">
                    <button class="btn" type="submit">Save Profile</button>
                </form>
            </section>
            <section class="card">
                <h3 style="margin-top:0;">Change Password</h3>
                <form method="post" action="<%= request.getContextPath() %>/admin/profile">
                    <input type="hidden" name="action" value="changePassword">
                    <label>Current Password</label>
                    <input type="password" name="currentPassword" required>
                    <label>New Password</label>
                    <input type="password" name="newPassword" required>
                    <label>Confirm New Password</label>
                    <input type="password" name="confirmPassword" required>
                    <button class="btn" type="submit">Change Password</button>
                </form>
            </section>
        </div>
    </main>
</div>
</body>
</html>
