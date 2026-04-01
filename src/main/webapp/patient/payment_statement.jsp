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
    List<PaymentDAO.PatientPaymentRow> rows = (List<PaymentDAO.PatientPaymentRow>) request.getAttribute("payments");
    if (rows == null) rows = Collections.emptyList();
    String activePage = "payments";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Statement</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; overflow-x: hidden; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        .table-wrap { width: 100%; overflow-x: hidden; }
        table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; font-size: .92rem; word-break: break-word; }
        .btn { text-decoration: none; border-radius: 8px; padding: 6px 10px; font-size: .85rem; font-weight: 600; background: #e7eef7; color: #1e3550; }
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
        <h1>Payment Statement (Paid Only)</h1>
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead><tr><th>Appointment</th><th>Lab</th><th>Method</th><th>Amount</th><th>Status</th><th>Statement</th></tr></thead>
                    <tbody>
                    <% if (rows.isEmpty()) { %>
                    <tr><td colspan="6">No paid payment records found.</td></tr>
                    <% } else { %>
                    <% for (PaymentDAO.PatientPaymentRow r : rows) { %>
                    <tr>
                        <td>#<%= r.appointmentId() %></td>
                        <td><%= r.labName() %></td>
                        <td><%= r.method() %></td>
                        <td>Rs. <%= r.amount() %></td>
                        <td><%= r.paymentStatus() %> / <%= r.paymentTxStatus() %></td>
                        <td><a class="btn" target="_blank" href="<%= request.getContextPath() %>/PaymentServlet?action=statement&appointmentId=<%= r.appointmentId() %>">View</a></td>
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





