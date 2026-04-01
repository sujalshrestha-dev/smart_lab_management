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
    String success = request.getParameter("success");
    List<PaymentDAO.PatientPaymentRow> rows = (List<PaymentDAO.PatientPaymentRow>) request.getAttribute("appointments");
    if (rows == null) rows = Collections.emptyList();
    String activePage = "appointments";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | My Appointments</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; overflow-x: hidden; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }
        .table-wrap { width: 100%; overflow-x: hidden; }
        table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        th, td { text-align: left; border-bottom: 1px solid #e6edf6; padding: 10px 8px; font-size: .92rem; vertical-align: top; word-break: break-word; }
        .pill { border-radius: 999px; padding: 3px 9px; font-size: .78rem; font-weight: 700; display: inline-block; }
        .pay-PAID { background: #d7f2e3; color: #145c35; }
        .pay-UNPAID { background: #fde2e0; color: #8c1f15; }
        .pay-VERIFYING { background: #fff3cd; color: #8a6d1d; }
        .btn { text-decoration: none; border-radius: 8px; padding: 6px 10px; font-size: .85rem; font-weight: 600; background: #e7eef7; color: #1e3550; display: inline-block; margin-right: 6px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .pay-form { margin: 0; display: inline; }
        .pay-method { border: 1px solid #d1deea; border-radius: 8px; padding: 6px 8px; font-size: .82rem; min-width: 145px; }
        .pay-action-btn { border: 0; border-radius: 8px; padding: 6px 10px; font-size: .82rem; font-weight: 700; background: #0b6bcb; color: #fff; cursor: pointer; }
        .muted { color: #5a748e; font-size: .84rem; }
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
        <h1>My Appointments</h1>
        <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
        <% if (error != null) { %><div class="err"><%= error %></div><% } %>
        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>Lab</th><th>Date/Time</th><th>Status</th><th>Payment Method</th><th>Payment Status</th><th>Action</th></tr></thead>
                    <tbody>
                    <% if (rows.isEmpty()) { %>
                    <tr><td colspan="7">No unfinished appointments found.</td></tr>
                    <% } else { %>
                    <% for (PaymentDAO.PatientPaymentRow r : rows) { %>
                    <%
                        boolean paid = "PAID".equalsIgnoreCase(r.paymentStatus());
                        boolean hasResult = r.reportPath() != null && !r.reportPath().isBlank();
                        boolean isEsewa = "ESEWA".equalsIgnoreCase(r.method());
                        boolean isKhalti = "KHALTI".equalsIgnoreCase(r.method());
                        boolean isBankTransfer = "BANK_TRANSFER".equalsIgnoreCase(r.method());
                        boolean onlineMethod = !"CASH".equalsIgnoreCase(r.method());
                        boolean txFailed = "FAILED".equalsIgnoreCase(r.paymentTxStatus());
                        boolean showPaymentForm = !paid && (!onlineMethod || isEsewa || txFailed);
                        String paymentViewStatus = paid ? "PAID" : ((onlineMethod && !txFailed) ? "VERIFYING" : "UNPAID");
                        String formId = "payForm_" + r.appointmentId();
                        String actionId = "payAction_" + r.appointmentId();
                    %>
                    <tr>
                        <td>#<%= r.appointmentId() %></td>
                        <td><%= r.labName() %></td>
                        <td><%= r.appointmentDate() %> <%= r.appointmentTime() == null ? "" : r.appointmentTime() %></td>
                        <td><%= r.appointmentStatus() %></td>
                        <td>
                            <% if (!showPaymentForm) { %>
                            <span><%= r.method() %></span>
                            <% } else { %>
                            <form class="pay-form" method="post" action="<%= request.getContextPath() %>/PaymentServlet" id="<%= formId %>">
                                <input type="hidden" name="action" value="payNow">
                                <input type="hidden" name="appointmentId" value="<%= r.appointmentId() %>">
                                <select name="paymentMethod" class="pay-method" data-action-id="<%= actionId %>" required>
                                    <option value="CASH" <%= (!isEsewa && !onlineMethod) ? "selected" : "" %>>Cash</option>
                                    <option value="ESEWA" <%= isEsewa ? "selected" : "" %>>eSewa</option>
                                    <option value="KHALTI" <%= isKhalti ? "selected" : "" %>>Khalti</option>
                                    <option value="BANK_TRANSFER" <%= isBankTransfer ? "selected" : "" %>>Bank Transfer</option>
                                </select>
                            </form>
                            <% } %>
                        </td>
                        <td><span class="pill pay-<%= paymentViewStatus %>"><%= paymentViewStatus %></span></td>
                        <td>
                            <a class="btn" target="_blank" href="<%= request.getContextPath() %>/PaymentServlet?action=statement&appointmentId=<%= r.appointmentId() %>">View Statement</a>
                            <% if (hasResult) { %>
                            <a class="btn" href="<%= request.getContextPath() %>/ResultPreviewServlet?appointmentId=<%= r.appointmentId() %>&from=appointments">Download Result</a>
                            <% } else if (paid) { %>
                            <span class="muted">Result not uploaded yet</span>
                            <% } else if (showPaymentForm) { %>
                            <button type="submit" class="pay-action-btn" id="<%= actionId %>" form="<%= formId %>" style="display:none;"><%= isEsewa ? "Pay with eSewa" : (isKhalti ? "Pay with Khalti" : "Pay Now") %></button>
                            <% } else if (onlineMethod) { %>
                            <span class="muted">Waiting for <%= isEsewa ? "eSewa" : (isKhalti ? "Khalti" : "payment") %> confirmation</span>
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
<script>
    (function () {
        var selects = document.querySelectorAll(".pay-method");
        selects.forEach(function (sel) {
            function sync() {
                var actionId = sel.getAttribute("data-action-id");
                var btn = document.getElementById(actionId);
                if (!btn) return;
                btn.style.display = sel.value === "CASH" ? "none" : "inline-block";
                if (sel.value === "ESEWA") {
                    btn.textContent = "Pay with eSewa";
                } else if (sel.value === "KHALTI") {
                    btn.textContent = "Pay with Khalti";
                } else {
                    btn.textContent = "Pay Now";
                }
            }
            sel.addEventListener("change", sync);
            sync();
        });
    })();
</script>
</body>
</html>



