<%@ page import="com.smartlab.dao.PaymentDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    PaymentDAO.InvoiceData i = (PaymentDAO.InvoiceData) request.getAttribute("invoice");
    String paymentStatus = i == null || i.paymentStatus() == null ? "UNPAID" : i.paymentStatus();
    String badgeClass = "PAID".equalsIgnoreCase(paymentStatus) ? "paid" : "unpaid";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice Statement</title>
    <style>
        body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #edf3f9; color: #1f3247; margin: 0; }
        .wrap { max-width: 980px; margin: 24px auto; padding: 0 14px; }
        .invoice { background: #fff; border-radius: 16px; box-shadow: 0 14px 30px rgba(15,39,66,.12); overflow: hidden; }
        .header { background: linear-gradient(120deg, #0b6bcb, #174a92); color: #fff; padding: 20px 22px; display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
        .header h1 { margin: 0; font-size: 1.5rem; letter-spacing: .03em; }
        .sub { margin-top: 4px; font-size: .92rem; opacity: .92; }
        .badge { border-radius: 999px; padding: 6px 12px; font-size: .78rem; font-weight: 700; letter-spacing: .04em; text-transform: uppercase; }
        .badge.paid { background: #daf6e6; color: #145c35; }
        .badge.unpaid { background: #ffe6e3; color: #8c1f15; }
        .content { padding: 18px 22px 22px; }
        .toolbar { display: flex; justify-content: flex-end; margin-bottom: 14px; }
        .btn { border: 0; border-radius: 10px; padding: 9px 12px; font-weight: 600; background: #0b6bcb; color: #fff; cursor: pointer; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px; }
        .card { background: #f8fbff; border: 1px solid #dde9f5; border-radius: 12px; padding: 12px; }
        .card h3 { margin: 0 0 8px; font-size: .92rem; color: #4a6784; text-transform: uppercase; letter-spacing: .03em; }
        .line { margin: 4px 0; font-size: .93rem; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border-bottom: 1px solid #e4edf6; padding: 10px 8px; text-align: left; font-size: .93rem; }
        th { background: #f4f8fd; font-size: .84rem; text-transform: uppercase; letter-spacing: .02em; color: #4c6884; }
        .num { text-align: right; white-space: nowrap; }
        .total { margin-top: 12px; display: flex; justify-content: flex-end; }
        .total-box { min-width: 270px; background: #f6faff; border: 1px solid #d9e7f5; border-radius: 12px; padding: 10px 12px; }
        .total-row { display: flex; justify-content: space-between; padding: 4px 0; }
        .grand { font-size: 1.08rem; font-weight: 700; color: #0f3b64; border-top: 1px dashed #c7d9ea; margin-top: 4px; padding-top: 8px; }
        .paid-note { margin-top: 10px; color: #116736; font-weight: 700; }
        @media print {
            body { background: #fff; }
            .wrap { margin: 0; max-width: 100%; padding: 0; }
            .invoice { box-shadow: none; border-radius: 0; }
            .toolbar { display: none; }
        }
        @media (max-width: 760px) {
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <% if (i == null) { %>
    <div class="invoice">
        <div class="content">Statement not found.</div>
    </div>
    <% } else { %>
    <div class="invoice">
        <div class="header">
            <div>
                <h1>Invoice</h1>
                <div class="sub">Appointment #<%= i.appointmentId() %> | <%= i.appointmentDate() %> <%= i.appointmentTime() == null ? "" : i.appointmentTime() %></div>
            </div>
            <span class="badge <%= badgeClass %>"><%= paymentStatus %></span>
        </div>

        <div class="content">
            <div class="toolbar">
                <button class="btn" onclick="window.print()">Print / Save PDF</button>
            </div>

            <div class="grid">
                <div class="card">
                    <h3>Patient Details</h3>
                    <div class="line"><strong>Name:</strong> <%= i.patientName() %></div>
                    <div class="line"><strong>Contact:</strong> <%= i.patientContact() %></div>
                </div>
                <div class="card">
                    <h3>Lab Details</h3>
                    <div class="line"><strong>Lab:</strong> <%= i.labName() %></div>
                    <div class="line"><strong>Contact:</strong> <%= i.labContact() %></div>
                </div>
                <div class="card">
                    <h3>Appointment Info</h3>
                    <div class="line"><strong>Status:</strong> <%= i.appointmentStatus() %></div>
                    <div class="line"><strong>Payment Status:</strong> <%= i.paymentStatus() %></div>
                </div>
                <div class="card">
                    <h3>Payment Info</h3>
                    <div class="line"><strong>Method:</strong> <%= i.method() == null ? "N/A" : i.method() %></div>
                    <div class="line"><strong>Transaction:</strong> <%= i.paymentTxStatus() == null ? "PENDING" : i.paymentTxStatus() %></div>
                    <div class="line"><strong>Reference:</strong> <%= i.transactionRef() == null ? "-" : i.transactionRef() %></div>
                </div>
            </div>

            <table>
                <thead><tr><th>Test</th><th class="num">Price</th></tr></thead>
                <tbody>
                <% for (PaymentDAO.InvoiceItem item : i.items()) { %>
                <tr><td><%= item.testName() %></td><td class="num">Rs. <%= item.price() %></td></tr>
                <% } %>
                </tbody>
            </table>

            <div class="total">
                <div class="total-box">
                    <div class="total-row"><span>Sub Total</span><strong>Rs. <%= i.total() %></strong></div>
                    <div class="total-row"><span>Tax</span><span>Rs. 0.00</span></div>
                    <div class="total-row grand"><span>Total</span><span>Rs. <%= i.total() %></span></div>
                </div>
            </div>

            <% if ("PAID".equalsIgnoreCase(i.paymentStatus())) { %>
            <div class="paid-note">PAID - Final statement ready.</div>
            <% } %>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>



