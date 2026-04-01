<%@ page import="com.smartlab.dao.TestDAO" %>
<%@ page import="com.smartlab.model.Test" %>
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
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    List<Test> tests = Collections.emptyList();
    try {
        Object uid = session.getAttribute("userId");
        if (uid instanceof Number) {
            tests = new TestDAO().getByLabUserId(((Number) uid).intValue());
        }
    } catch (Exception ex) {
        error = "Unable to load tests";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Manage Tests</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }

        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); margin-bottom: 12px; }
        .add-grid { display: grid; grid-template-columns: 1.2fr 1.6fr 140px 180px auto; gap: 8px; }
        .add-grid input, .add-grid select { width: 100%; border: 1px solid #d1deea; border-radius: 8px; padding: 9px; font-size: 0.92rem; box-sizing: border-box; }

        .btn { border: 0; border-radius: 8px; padding: 8px 10px; cursor: pointer; font-weight: 600; }
        .btn-primary { background: #0b6bcb; color: #fff; }
        .btn-light { background: #e7eef7; color: #1e3550; }
        .btn-danger { background: #ca3d2e; color: #fff; }
        .btn-save { background: #0f9d58; color: #fff; }

        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }

        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 1100px; border-collapse: collapse; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; font-size: .9rem; vertical-align: middle; }
        th { background: #f8fbff; color: #415e7b; }
        .actions { display: flex; gap: 6px; }

        .view-mode { display: inline; }
        .edit-mode { display: none; }
        tr.editing .view-mode { display: none; }
        tr.editing .edit-mode { display: inline-block; }
        tr.editing .actions .btn-save { display: inline-block; }
        tr.editing .actions .btn-cancel { display: inline-block; }
        .actions .btn-save, .actions .btn-cancel { display: none; }

        .edit-input, .edit-select {
            border: 1px solid #d1deea;
            border-radius: 8px;
            padding: 6px 8px;
            font-size: .86rem;
            width: 100%;
            box-sizing: border-box;
        }

        @media (max-width: 1000px) {
            .add-grid { grid-template-columns: 1fr; }
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
            <a class="active" href="<%= request.getContextPath() %>/lab/manage_tests.jsp">Manage Tests</a>
            <a href="<%= request.getContextPath() %>/LabAppointmentsServlet">Upload Report</a>
            <a href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <h1>Manage Tests</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>

        <div class="card">
            <h3 style="margin-top:0;">Add New Test</h3>
            <form action="<%= request.getContextPath() %>/AddTestServlet" method="post" class="add-grid">
                <input type="hidden" name="action" value="add">
                <input type="text" name="testName" placeholder="Test Name" required>
                <input type="text" name="description" placeholder="Description (optional)">
                <input type="number" step="0.01" min="0" name="price" placeholder="Price" required>
                <select name="availability">
                    <option value="AVAILABLE">Available</option>
                    <option value="NOT_AVAILABLE">Not Available</option>
                </select>
                <button class="btn btn-primary" type="submit">Add Test</button>
            </form>
        </div>

        <div class="card">
            <h3 style="margin-top:0;">Existing Tests</h3>
            <% if (tests.isEmpty()) { %>
            <div>No tests added yet.</div>
            <% } else { %>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>S.N.</th>
                        <th>Test Name</th>
                        <th>Description</th>
                        <th>Price</th>
                        <th>Availability</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% int sn = 1; %>
                    <% for (Test t : tests) { %>
                    <tr id="row_<%= t.getId() %>">
                        <form id="form_<%= t.getId() %>" method="post" action="<%= request.getContextPath() %>/AddTestServlet">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="testId" value="<%= t.getId() %>">
                            <td><%= sn++ %></td>
                            <td>
                                <span class="view-mode"><%= t.getTestName() %></span>
                                <input class="edit-mode edit-input" type="text" name="testName" value="<%= t.getTestName() %>" required>
                            </td>
                            <td>
                                <span class="view-mode"><%= t.getDescription() == null || t.getDescription().isBlank() ? "-" : t.getDescription() %></span>
                                <input class="edit-mode edit-input" type="text" name="description" value="<%= t.getDescription() == null ? "" : t.getDescription() %>">
                            </td>
                            <td>
                                <span class="view-mode">Rs. <%= t.getPrice() %></span>
                                <input class="edit-mode edit-input" type="number" step="0.01" min="0" name="price" value="<%= t.getPrice() %>" required>
                            </td>
                            <td>
                                <span class="view-mode"><%= t.getAvailability() %></span>
                                <select class="edit-mode edit-select" name="availability">
                                    <option value="AVAILABLE" <%= "AVAILABLE".equals(t.getAvailability()) ? "selected" : "" %>>Available</option>
                                    <option value="NOT_AVAILABLE" <%= "NOT_AVAILABLE".equals(t.getAvailability()) ? "selected" : "" %>>Not Available</option>
                                </select>
                            </td>
                        </form>
                        <td>
                            <div class="actions">
                                <button class="btn btn-light" type="button" onclick="startEdit(<%= t.getId() %>)">Edit</button>
                                <button class="btn btn-save" type="submit" form="form_<%= t.getId() %>">Save</button>
                                <button class="btn btn-light btn-cancel" type="button" onclick="cancelEdit(<%= t.getId() %>)">Cancel</button>
                                <form method="post" action="<%= request.getContextPath() %>/DeleteTestServlet" onsubmit="return confirm('Delete this test?');">
                                    <input type="hidden" name="testId" value="<%= t.getId() %>">
                                    <button class="btn btn-danger" type="submit">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </main>
</div>

<script>
    function startEdit(id) {
        document.getElementById('row_' + id).classList.add('editing');
    }
    function cancelEdit(id) {
        var row = document.getElementById('row_' + id);
        var form = document.getElementById('form_' + id);
        if (form) form.reset();
        row.classList.remove('editing');
    }
</script>
</body>
</html>
