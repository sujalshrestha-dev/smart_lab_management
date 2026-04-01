<%@ page import="com.smartlab.dao.PaymentDAO" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String error = request.getParameter("error");
    List<PaymentDAO.PatientPaymentRow> rows = (List<PaymentDAO.PatientPaymentRow>) request.getAttribute("historyRows");
    if (rows == null) rows = Collections.emptyList();
    String activePage = "history";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | History</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; overflow-x: hidden; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        .table-wrap { width: 100%; overflow-x: hidden; }
        table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; font-size: .92rem; word-break: break-word; }
        .pill { border-radius: 999px; padding: 3px 9px; font-size: .78rem; font-weight: 700; display: inline-block; }
        .pay-PAID { background: #d7f2e3; color: #145c35; }
        .pay-UNPAID { background: #fde2e0; color: #8c1f15; }
        .btn { text-decoration: none; border-radius: 8px; padding: 6px 10px; font-size: .85rem; font-weight: 600; background: #e7eef7; color: #1e3550; display: inline-block; margin-right: 6px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        td:last-child {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            align-items: flex-start;
        }
        @media (max-width: 1200px) {
            table { table-layout: auto; }
        }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>
    <main class="main">
        <h1>History (Completed Appointments)</h1>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>Lab</th><th>Date/Time</th><th>Status</th><th>Payment</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% if (rows.isEmpty()) { %>
                    <tr><td colspan="6">No completed appointments found.</td></tr>
                    <% } else { %>
                    <% for (PaymentDAO.PatientPaymentRow r : rows) { %>
                    <%
                        boolean hasResult = r.reportPath() != null && !r.reportPath().isBlank();
                    %>
                    <tr>
                        <td>#<%= r.appointmentId() %></td>
                        <td><%= r.labName() %></td>
                        <td><%= r.appointmentDate() %> <%= r.appointmentTime() == null ? "" : r.appointmentTime() %></td>
                        <td><%= r.appointmentStatus() %></td>
                        <td><span class="pill pay-<%= r.paymentStatus() %>"><%= r.paymentStatus() %></span> / <%= r.method() %></td>
                        <td>
                            <a class="btn" target="_blank" href="<%= request.getContextPath() %>/PaymentServlet?action=statement&appointmentId=<%= r.appointmentId() %>">View Statement</a>
                            <% if ("PAID".equalsIgnoreCase(r.paymentStatus()) && hasResult) { %>
                            <a class="btn" href="<%= request.getContextPath() %>/ResultPreviewServlet?appointmentId=<%= r.appointmentId() %>&from=history">Download Result</a>
                            <% } else if ("PAID".equalsIgnoreCase(r.paymentStatus())) { %>
                            <span style="color:#5a748e;font-size:.84rem;">Result not uploaded yet</span>
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



