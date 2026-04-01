<%@ page import="com.smartlab.dao.LabDAO" %>
<%@ page import="com.smartlab.model.Test" %>
<%@ page import="com.smartlab.model.User" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    LabDAO.PublicLabProfile lab = (LabDAO.PublicLabProfile) request.getAttribute("lab");
    User patient = (User) request.getAttribute("patient");
    List<Test> tests = (List<Test>) request.getAttribute("tests");
    if (tests == null) tests = Collections.emptyList();
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="">
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #eef4fa; color: #1e3550; }
        .wrap { max-width: 1180px; margin: 0 auto; padding: 24px; }
        .top { margin-bottom: 14px; }
        .top-row { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
        .title { margin: 0; font-size: 1.8rem; }
        .subtitle { margin: 4px 0 0; color: #5a738d; }

        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 10px; padding: 10px 12px; margin-bottom: 10px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 10px; padding: 10px 12px; margin-bottom: 10px; }

        .layout { display: grid; grid-template-columns: 2fr 1fr; gap: 14px; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); }

        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; }
        .field { margin-bottom: 10px; }
        label { display: block; font-size: .9rem; font-weight: 600; color: #35506b; margin-bottom: 5px; }
        input, select, textarea { width: 100%; border: 1px solid #d2deea; border-radius: 10px; padding: 10px 12px; font-size: 0.94rem; box-sizing: border-box; }
        textarea { min-height: 76px; resize: vertical; }

        .table-wrap { border: 1px solid #dbe6f2; border-radius: 12px; overflow: hidden; background: #fff; }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; border-bottom: 1px solid #edf2f7; padding: 10px 8px; font-size: .92rem; vertical-align: top; }
        th { background: #f6f9fd; font-size: .86rem; letter-spacing: .02em; text-transform: uppercase; color: #4e6a86; }
        tr:last-child td { border-bottom: 0; }
        .col-check { width: 56px; text-align: center; }
        .price { font-weight: 700; color: #143c64; white-space: nowrap; }
        .muted { color: #5a748e; }

        .btn { border: 0; border-radius: 10px; padding: 10px 14px; font-weight: 600; cursor: pointer; text-decoration: none; }
        .btn-primary { background: #0b6bcb; color: #fff; }
        .btn-light { background: #e7eef7; color: #1e3550; }

        .invoice { display: none; margin-top: 12px; border: 1px solid #dbe6f2; border-radius: 10px; padding: 12px; background: #f8fbff; }
        .invoice table { margin-top: 8px; }
        .invoice th { background: #eef4fc; }

        .learn-content { display: none; margin-top: 10px; }
        .meta div { margin-bottom: 6px; }
        .photos { display: grid; grid-template-columns: repeat(2, minmax(120px,1fr)); gap: 8px; margin-top: 8px; }
        .photos img { width: 100%; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #dbe6f2; }
        .map { width: 100%; height: 250px; border: 1px solid #d2deea; border-radius: 10px; margin-top: 8px; }

        @media (max-width: 980px) { .layout { grid-template-columns: 1fr; } }
        @media (max-width: 720px) {
            .row { grid-template-columns: 1fr; }
            th:nth-child(3), td:nth-child(3) { display: none; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <% if (lab == null) { %>
    <div class="card">Lab not found or not available.</div>
    <% } else { %>
    <div class="top">
        <div class="top-row">
            <h1 class="title">Book Appointment</h1>
            <a class="btn btn-light" href="<%= request.getContextPath() %>/patient/dashboard.jsp">Back to Dashboard</a>
        </div>
        <p class="subtitle">Lab: <strong><%= lab.labName() %></strong> | <%= lab.city() %></p>
    </div>

    <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
    <% if (error != null) { %><div class="err"><%= error %></div><% } %>

    <div class="layout">
        <div class="card">
            <h3 style="margin-top:0;">Select Tests and Confirm Booking</h3>
            <form method="post" action="<%= request.getContextPath() %>/BookAppointmentServlet">
                <input type="hidden" name="labId" value="<%= lab.id() %>">

                <div class="row">
                    <div class="field">
                        <label>Appointment Date</label>
                        <input type="date" id="appointmentDate" name="appointmentDate" required>
                    </div>
                    <div class="field">
                        <label>Appointment Time (Optional)</label>
                        <input type="time" name="appointmentTime">
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th class="col-check">Select</th>
                            <th>Test Name</th>
                            <th>Description</th>
                            <th>Price</th>
                        </tr>
                        </thead>
                        <tbody id="testsTableBody">
                        <% for (Test t : tests) { %>
                        <tr class="test-row" data-test-name="<%= t.getTestName().toLowerCase() %>">
                            <td class="col-check">
                                <input type="checkbox" name="testIds" value="<%= t.getId() %>" class="test-check">
                                <input type="hidden" class="test-price" value="<%= t.getPrice() %>">
                            </td>
                            <td class="test-name"><strong><%= t.getTestName() %></strong></td>
                            <td class="muted"><%= t.getDescription() == null ? "-" : t.getDescription() %></td>
                            <td class="price">Rs. <%= t.getPrice() %></td>
                        </tr>
                        <% } %>
                        <% if (tests.isEmpty()) { %>
                        <tr><td colspan="4">No available tests found for this lab.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="field" style="margin-top:10px;">
                    <label>Notes (Optional)</label>
                    <textarea name="notes" placeholder="Add any notes for the lab"></textarea>
                </div>

                <button class="btn btn-light" id="viewPaymentBtn" type="button">View Payment</button>

                <div class="invoice" id="invoiceBox">
                    <h4 style="margin:0 0 6px;">Invoice Preview</h4>
                    <div><strong>Patient:</strong> <%= patient == null ? String.valueOf(session.getAttribute("fullName")) : patient.getFullName() %> | <%= patient == null ? "" : patient.getContactNumber() %></div>
                    <div><strong>Lab:</strong> <%= lab.labName() %> | <%= lab.contactNumber() == null ? "" : lab.contactNumber() %></div>
                    <table>
                        <thead><tr><th>Test</th><th>Price</th></tr></thead>
                        <tbody id="invoiceItems"></tbody>
                    </table>
                    <div style="margin-top:6px;"><strong>Total: Rs. <span id="invoiceTotal">0.00</span></strong></div>
                    <button class="btn btn-primary" type="submit" style="margin-top:8px;">Confirm Booking and Payment</button>
                </div>
            </form>
        </div>

        <div class="card">
            <button id="learnMoreBtn" class="btn btn-light" type="button">Learn More about <%= lab.labName() %></button>
            <div id="learnMoreContent" class="learn-content">
                <h3 style="margin:10px 0 6px;"><%= lab.labName() %></h3>
                <div class="meta">
                    <div><strong>City:</strong> <%= lab.city() %></div>
                    <div><strong>Address:</strong> <%= lab.address() %></div>
                    <div><strong>Rating:</strong> <%= String.format("%.1f", lab.avgRating()) %> (<%= lab.totalReviews() %> reviews)</div>
                </div>
                <p><strong>Description:</strong> <%= lab.description() == null ? "N/A" : lab.description() %></p>

                <% if (lab.photos() != null && !lab.photos().isEmpty()) { %>
                <div class="photos">
                    <% for (String p : lab.photos()) { %>
                    <a href="<%= request.getContextPath() + "/" + p %>" target="_blank">
                        <img src="<%= request.getContextPath() + "/" + p %>" alt="Lab Photo">
                    </a>
                    <% } %>
                </div>
                <% } %>

                <div id="labMap" class="map"></div>
            </div>
        </div>
    </div>
    <% } %>
</div>

<script>
    (function () {
        var btn = document.getElementById("learnMoreBtn");
        var content = document.getElementById("learnMoreContent");
        var viewPaymentBtn = document.getElementById("viewPaymentBtn");
        var invoiceBox = document.getElementById("invoiceBox");
        var invoiceItems = document.getElementById("invoiceItems");
        var invoiceTotal = document.getElementById("invoiceTotal");
        var appointmentDate = document.getElementById("appointmentDate");
        var mapInitialized = false;

        if (appointmentDate) {
            appointmentDate.min = new Date().toISOString().split("T")[0];
        }

        if (viewPaymentBtn) {
            viewPaymentBtn.addEventListener("click", function () {
                var selected = document.querySelectorAll("input[name='testIds']:checked");
                if (!selected.length) {
                    alert("Please select at least one test.");
                    return;
                }
                invoiceItems.innerHTML = "";
                var total = 0;
                selected.forEach(function (cb) {
                    var row = cb.closest(".test-row");
                    var name = row.querySelector(".test-name").textContent.trim();
                    var price = parseFloat(row.querySelector(".test-price").value || "0");
                    total += price;
                    var tr = document.createElement("tr");
                    tr.innerHTML = "<td>" + name + "</td><td>Rs. " + price.toFixed(2) + "</td>";
                    invoiceItems.appendChild(tr);
                });
                invoiceTotal.textContent = total.toFixed(2);
                invoiceBox.style.display = "block";
                invoiceBox.scrollIntoView({behavior: "smooth", block: "start"});
            });
        }

        if (btn) {
            btn.addEventListener("click", function () {
                var hidden = content.style.display !== "block";
                content.style.display = hidden ? "block" : "none";
                if (hidden && !mapInitialized) {
                    var lat = <%= lab == null || lab.latitude() == null ? "27.7172" : lab.latitude() %>;
                    var lng = <%= lab == null || lab.longitude() == null ? "85.3240" : lab.longitude() %>;
                    var map = L.map("labMap").setView([lat, lng], 14);
                    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                        maxZoom: 19,
                        attribution: "&copy; OpenStreetMap contributors"
                    }).addTo(map);
                    L.marker([lat, lng]).addTo(map);
                    mapInitialized = true;
                }
            });
        }
    })();
</script>
</body>
</html>



