<%@ page import="com.smartlab.dao.UserDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    UserDAO.PatientAccountData account = (UserDAO.PatientAccountData) request.getAttribute("account");
    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/UserAccountServlet");
        return;
    }
    String activePage = "account";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | User Account</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .main { padding: 24px; }
        .cards { display: grid; gap: 16px; grid-template-columns: 1fr 1fr; }
        .card { background: #fff; border-radius: 14px; padding: 18px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); }
        .title { margin: 0 0 12px; }
        label { display: block; font-weight: 600; margin: 8px 0 4px; }
        input, textarea { width: 100%; padding: 9px 10px; border-radius: 8px; border: 1px solid #d0dbe8; box-sizing: border-box; }
        textarea { min-height: 76px; resize: vertical; }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .btn { margin-top: 12px; border: 0; border-radius: 10px; padding: 10px 14px; cursor: pointer; font-weight: 700; background: #0b6bcb; color: #fff; }
        .link-btn { display: inline-block; margin-top: 10px; color: #0b6bcb; text-decoration: none; font-weight: 600; }
        .msg { border-radius: 8px; padding: 10px 12px; margin-bottom: 10px; }
        .msg.error { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; }
        .msg.success { background: #e7f7ed; color: #125229; border: 1px solid #c6ebd3; }
        .danger { border: 1px solid #f2b6b0; background: #fff2f1; }
        .danger h2 { color: #a32117; }
        .danger-note { color: #7e1e17; font-size: .92rem; margin-bottom: 8px; }
        .btn-danger { background: #ca3d2e; color: #fff; }
        .btn-back { display: inline-block; margin-top: 10px; color: #6b1f18; text-decoration: none; font-weight: 600; }
        @media (max-width: 1000px) { .layout { grid-template-columns: 1fr; } .cards { grid-template-columns: 1fr; } }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <h1>User Account</h1>
        <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
        <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

        <div class="cards">
            <section class="card">
                <h2 class="title">Update Details</h2>
                <form method="post" action="<%= request.getContextPath() %>/UserAccountServlet">
                    <input type="hidden" name="action" value="updateProfile">

                    <label>Full Name</label>
                    <input type="text" name="fullName" required value="<%= account.fullName() %>">

                    <div class="row">
                        <div>
                            <label>Username</label>
                            <input type="text" name="username" required value="<%= account.username() %>">
                        </div>
                        <div>
                            <label>Email</label>
                            <input type="email" name="email" required value="<%= account.email() %>">
                        </div>
                    </div>

                    <div class="row">
                        <div>
                            <label>Contact Number</label>
                            <input type="text" name="contactNumber" required value="<%= account.contactNumber() %>">
                        </div>
                        <div>
                            <label>Date of Birth</label>
                            <input type="date" name="dateOfBirth" required value="<%= account.dateOfBirth() == null ? "" : account.dateOfBirth() %>">
                        </div>
                    </div>

                    <div class="row">
                        <div>
                            <label>Emergency Contact</label>
                            <input type="text" name="emergencyContact" required value="<%= account.emergencyContact() == null ? "" : account.emergencyContact() %>">
                        </div>
                        <div>
                            <label>Address</label>
                            <textarea name="address" required><%= account.address() == null ? "" : account.address() %></textarea>
                        </div>
                    </div>

                    <button class="btn" type="submit">Save Changes</button>
                </form>
            </section>

            <section class="card">
                <h2 class="title">Change Password</h2>
                <form method="post" action="<%= request.getContextPath() %>/UserAccountServlet">
                    <input type="hidden" name="action" value="changePassword">

                    <label>Current Password</label>
                    <input type="password" name="currentPassword" required>

                    <label>New Password</label>
                    <input type="password" name="newPassword" required>

                    <label>Confirm Password</label>
                    <input type="password" name="confirmPassword" required>

                    <button class="btn" type="submit">Change Password</button>
                </form>

                <a class="link-btn" href="<%= request.getContextPath() %>/forgot_password.jsp">Recover Password (Forgot Password)</a>
            </section>

            <section class="card danger">
                <h2 class="title">Delete Account</h2>
                <div class="danger-note">
                    Your account and all the data will be permanently deleted.<br>
                    Enter your password to confirm.
                </div>
                <form method="post" action="<%= request.getContextPath() %>/DeleteAccountServlet">
                    <label>Confirm Password</label>
                    <input type="password" name="confirmPassword" required>
                    <button class="btn btn-danger" type="submit">Confirm Delete</button>
                </form>
                <a class="btn-back" href="<%= request.getContextPath() %>/UserAccountServlet">Back</a>
            </section>
        </div>
    </main>
</div>
</body>
</html>



