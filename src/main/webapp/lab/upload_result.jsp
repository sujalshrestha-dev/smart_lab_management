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
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    List<AppointmentDAO.LabAppointmentRow> appointments =
            (List<AppointmentDAO.LabAppointmentRow>) request.getAttribute("appointments");
    if (appointments == null) appointments = Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Upload Report</title>
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
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08); }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; min-width: 1180px; border-collapse: collapse; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; vertical-align: top; font-size: 0.9rem; }
        th { color: #415e7b; background: #f8fbff; }
        .actions { display: flex; gap: 6px; flex-wrap: wrap; }
        .btn { border: 0; border-radius: 8px; padding: 7px 10px; cursor: pointer; font-weight: 600; font-size: 0.85rem; }
        .btn-approve { background: #0f9d58; color: #fff; }
        .btn-reject { background: #ca3d2e; color: #fff; }
        .btn-upload { background: #364f6b; color: #fff; }
        .pill { border-radius: 999px; padding: 3px 9px; font-size: 0.78rem; font-weight: 700; display: inline-block; }
        .status-PENDING { background: #fff3cd; color: #8a6d1d; }
        .status-APPROVED { background: #d7f2e3; color: #145c35; }
        .status-REJECTED { background: #fde2e0; color: #8c1f15; }
        .status-COMPLETED { background: #d8e9fb; color: #124d82; }
        .pay-UNPAID { background: #fde2e0; color: #8c1f15; }
        .pay-PAID { background: #d7f2e3; color: #145c35; }
        .pay-VERIFYING { background: #fff3cd; color: #8a6d1d; }
        .upload-form { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; }
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
            <a class="active" href="<%= request.getContextPath() %>/LabAppointmentsServlet">Upload Report</a>
            <a href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>

    <main class="main">
        <h1>Upload Report & Manage Appointments</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
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
                    <th>Approval</th>
                    <th>Payment Verify</th>
                    <th>Report</th>
                </tr>
                </thead>
                <tbody>
                <% if (appointments.isEmpty()) { %>
                <tr><td colspan="8">No appointments found.</td></tr>
                <% } else { %>
                <% for (AppointmentDAO.LabAppointmentRow a : appointments) { %>
                <tr>
                    <td>#<%= a.appointmentId() %></td>
                    <td><strong><%= a.patientName() %></strong><br><%= a.notes() == null ? "" : a.notes() %></td>
                    <td><%= a.appointmentDate() %> <%= a.appointmentTime() == null ? "" : a.appointmentTime() %></td>
                    <td><span class="pill status-<%= a.status() %>"><%= a.status() %></span></td>
                    <td>
                        <%
                            boolean isPaid = "PAID".equalsIgnoreCase(a.paymentStatus());
                            boolean isOnline = !"CASH".equalsIgnoreCase(a.paymentMethod());
                            boolean txFailed = "FAILED".equalsIgnoreCase(a.paymentTxStatus());
                            String payView = isPaid ? "PAID" : ((isOnline && !txFailed) ? "VERIFYING" : "UNPAID");
                        %>
                        <span class="pill pay-<%= payView %>"><%= payView %></span><br>
                        Method: <%= a.paymentMethod() %>
                    </td>
                    <td>
                        <% if ("PENDING".equalsIgnoreCase(a.status())) { %>
                        <div class="actions">
                            <form method="post" action="<%= request.getContextPath() %>/UpdateAppointmentStatusServlet">
                                <input type="hidden" name="appointmentId" value="<%= a.appointmentId() %>">
                                <input type="hidden" name="status" value="APPROVED">
                                <button class="btn btn-approve" type="submit">Approve</button>
                            </form>
                            <form method="post" action="<%= request.getContextPath() %>/UpdateAppointmentStatusServlet">
                                <input type="hidden" name="appointmentId" value="<%= a.appointmentId() %>">
                                <input type="hidden" name="status" value="REJECTED">
                                <button class="btn btn-reject" type="submit">Reject</button>
                            </form>
                        </div>
                        <% } else { %>
                        <span style="color:#5a748e;font-size:.85rem;">Decision taken</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (!"PAID".equalsIgnoreCase(a.paymentStatus())) { %>
                        <form method="post" action="<%= request.getContextPath() %>/PaymentServlet">
                            <input type="hidden" name="appointmentId" value="<%= a.appointmentId() %>">
                            <button class="btn btn-approve" type="submit"><%= "CASH".equalsIgnoreCase(a.paymentMethod()) ? "Mark Paid" : "Verify & Mark Paid" %></button>
                        </form>
                        <% } else { %>
                        <span class="pill pay-PAID">PAID</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (a.reportPath() != null && !a.reportPath().isBlank()) { %>
                        <a href="<%= request.getContextPath() + "/" + a.reportPath() %>" target="_blank">View Result</a>
                        <% } else { %>
                        <form class="upload-form" method="post" action="<%= request.getContextPath() %>/UploadResultServlet" enctype="multipart/form-data">
                            <input type="hidden" name="appointmentId" value="<%= a.appointmentId() %>">
                            <input type="file" name="resultFile" required>
                            <button class="btn btn-upload" type="submit">Upload</button>
                        </form>
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

