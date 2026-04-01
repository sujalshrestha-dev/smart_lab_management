<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.smartlab.dao.LabDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"ADMIN".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+admin");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    List<LabDAO.AdminLabRow> labs = (List<LabDAO.AdminLabRow>) request.getAttribute("labs");
    if (labs == null) labs = Collections.emptyList();
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Manage Labs</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .table-wrap { overflow-x: auto; background: #fff; border-radius: 14px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        table { width: 100%; min-width: 1400px; border-collapse: collapse; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; vertical-align: top; font-size: .9rem; }
        th { background: #f8fbff; color: #415e7b; }
        input, select { width: 100%; border: 1px solid #d1deea; border-radius: 8px; padding: 7px; font-size: .86rem; box-sizing: border-box; }
        .btn { border: 0; border-radius: 8px; padding: 8px 10px; cursor: pointer; font-weight: 600; font-size: .84rem; }
        .btn-save { background: #0b6bcb; color: #fff; }
        .btn-edit { background: #e7eef7; color: #1e3550; }
        .btn-del { background: #ca3d2e; color: #fff; }
        .btn-cancel { background: #e7eef7; color: #1e3550; display: none; }
        .btn-save { display: none; }
        tr.editing .btn-save { display: inline-block; }
        tr.editing .btn-cancel { display: inline-block; }
        tr.editing .btn-edit { display: none; }
        .empty { background: #fff; border-radius: 14px; padding: 20px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
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
            <a href="<%= request.getContextPath() %>/admin/pending-labs">Pending Labs</a>
            <a class="active" href="<%= request.getContextPath() %>/admin/manage-labs">Manage Labs</a>
            <a href="<%= request.getContextPath() %>/admin/profile">Admin Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Manage Labs</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>

        <% if (labs.isEmpty()) { %>
        <div class="empty">No labs found.</div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Lab</th><th>Owner</th><th>City</th><th>Address</th>
                    <th>Verified</th><th>Owner Status</th><th>Save</th><th>Delete</th>
                </tr>
                </thead>
                <tbody>
                <% for (LabDAO.AdminLabRow r : labs) { %>
                <tr id="row_<%= r.labId() %>">
                    <form id="form_<%= r.labId() %>" method="post" action="<%= request.getContextPath() %>/admin/manage-labs">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="labId" value="<%= r.labId() %>">
                        <input type="hidden" name="userId" value="<%= r.userId() %>">
                        <input type="hidden" name="latitude" value="<%= r.latitude() %>">
                        <input type="hidden" name="longitude" value="<%= r.longitude() %>">
                        <input type="hidden" name="ownerEmail" value="<%= r.ownerEmail() %>">
                        <input type="hidden" name="ownerContact" value="<%= r.ownerContact() %>">
                        <td><input class="edit-field" type="text" name="labName" value="<%= r.labName() %>" required disabled></td>
                        <td>
                            <input class="edit-field" type="text" name="ownerName" value="<%= r.ownerName() %>" required disabled>
                        </td>
                        <td><input class="edit-field" type="text" name="city" value="<%= r.city() %>" required disabled></td>
                        <td><input class="edit-field" type="text" name="address" value="<%= r.address() %>" required disabled></td>
                        <td>
                            <select class="edit-field" name="verified" disabled>
                                <option value="1" <%= r.verified() ? "selected" : "" %>>Verified</option>
                                <option value="0" <%= r.verified() ? "" : "selected" %>>Pending</option>
                            </select>
                        </td>
                        <td>
                            <select class="edit-field" name="ownerStatus" disabled>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(r.ownerStatus()) ? "selected" : "" %>>ACTIVE</option>
                                <option value="PENDING" <%= "PENDING".equalsIgnoreCase(r.ownerStatus()) ? "selected" : "" %>>PENDING</option>
                                <option value="BLOCKED" <%= "BLOCKED".equalsIgnoreCase(r.ownerStatus()) ? "selected" : "" %>>BLOCKED</option>
                            </select>
                        </td>
                        <td>
                            <button class="btn btn-edit" type="button" onclick="startEdit(<%= r.labId() %>)">Edit</button>
                            <button class="btn btn-save" type="submit">Save</button>
                            <button class="btn btn-cancel" type="button" onclick="cancelEdit(<%= r.labId() %>)">Cancel</button>
                        </td>
                    </form>
                    <td>
                        <form method="post" action="<%= request.getContextPath() %>/admin/manage-labs"
                              onsubmit="return confirm('Delete this lab account and related data?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="labId" value="<%= r.labId() %>">
                            <button class="btn btn-del" type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </main>
</div>
<script>
    function startEdit(labId) {
        var row = document.getElementById("row_" + labId);
        if (!row) return;
        row.classList.add("editing");
        row.querySelectorAll(".edit-field").forEach(function (el) { el.disabled = false; });
    }
    function cancelEdit(labId) {
        var row = document.getElementById("row_" + labId);
        var form = document.getElementById("form_" + labId);
        if (!row || !form) return;
        form.reset();
        row.classList.remove("editing");
        row.querySelectorAll(".edit-field").forEach(function (el) { el.disabled = true; });
    }
</script>
</body>
</html>
