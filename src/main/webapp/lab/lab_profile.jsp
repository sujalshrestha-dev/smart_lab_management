<%@ page import="com.smartlab.dao.LabDAO" %>
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
    LabDAO.LabProfile profile = (LabDAO.LabProfile) request.getAttribute("profile");
    List<LabDAO.LabPhoto> photos = (List<LabDAO.LabPhoto>) request.getAttribute("photos");
    if (photos == null) photos = Collections.emptyList();
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab Panel | Lab Profile</title>
    <link
            rel="stylesheet"
            href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
            integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
            crossorigin=""
    />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
            crossorigin=""></script>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; }
        .layout { min-height: 100vh; display: grid; grid-template-columns: 260px 1fr; }
        .sidebar { background: #0f2742; color: #e8f0f8; padding: 22px 14px; }
        .sidebar h2 { margin: 0 0 6px; font-size: 1.2rem; }
        .sidebar p { margin: 0 0 14px; color: #b9cadb; font-size: 0.9rem; }
        .nav a { display: block; color: #dbe8f5; text-decoration: none; padding: 10px 12px; border-radius: 10px; margin-bottom: 6px; font-size: 0.95rem; }
        .nav a.active { background: #1a4674; font-weight: 700; }
        .main { padding: 24px; }
        .wrap { max-width: 1180px; margin: 0; padding: 0; }
        .grid { display: grid; grid-template-columns: 1.2fr .8fr; gap: 12px; }
        .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 10px 20px rgba(15,39,66,.08); margin-bottom: 12px; }
        .ok { background: #eaf8ee; color: #116736; border: 1px solid #bee8ca; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .err { background: #fdecec; color: #8f1e15; border: 1px solid #f8c9c4; border-radius: 8px; padding: 8px 10px; margin-bottom: 8px; }
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 8px; }
        input, textarea { width: 100%; border: 1px solid #d2deea; border-radius: 10px; padding: 10px 12px; font-size: 0.94rem; }
        textarea { min-height: 85px; resize: vertical; }
        .btn { border: 0; border-radius: 10px; padding: 10px 14px; font-weight: 600; cursor: pointer; }
        .btn-primary { background: #0b6bcb; color: #fff; }
        .btn-danger { background: #ca3d2e; color: #fff; }
        .map { width: 100%; height: 280px; border-radius: 10px; border: 1px solid #d2deea; }
        .photo-grid { display: grid; grid-template-columns: repeat(2,minmax(120px,1fr)); gap: 8px; }
        .photo-grid img { width: 100%; height: 120px; object-fit: cover; border-radius: 8px; border: 1px solid #dbe6f2; }
        .danger { border: 1px solid #f2b6b0; background: #fff2f1; }
        .danger h3 { color: #a32117; }
        .danger-note { color: #7e1e17; font-size: .92rem; margin-bottom: 8px; }
        .btn-back { display: inline-block; margin-top: 10px; color: #6b1f18; text-decoration: none; font-weight: 600; }
        @media (max-width: 980px) { .grid { grid-template-columns: 1fr; } .row { grid-template-columns: 1fr; } }
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
            <a href="<%= request.getContextPath() %>/LabAppointmentsServlet">Upload Report</a>
            <a href="<%= request.getContextPath() %>/LabCompletedReportsServlet">Completed Reports</a>
            <a href="<%= request.getContextPath() %>/LabChartServlet">Lab Chart</a>
            <a class="active" href="<%= request.getContextPath() %>/LabProfileServlet">Lab Profile</a>
            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </nav>
    </aside>
    <main class="main">
        <div class="wrap">
            <h1>Lab Profile</h1>
            <% if (success != null) { %><div class="ok"><%= success %></div><% } %>
            <% if (error != null) { %><div class="err"><%= error %></div><% } %>

    <div class="grid">
        <div>
            <div class="card">
                <h3 style="margin-top:0;">Public Information</h3>
                <form method="post" action="<%= request.getContextPath() %>/LabProfileServlet" id="profileForm">
                    <input type="hidden" name="action" value="updateProfile">
                    <div class="row">
                        <input type="text" name="labName" placeholder="Lab Name" value="<%= profile == null ? "" : profile.labName() %>" required>
                        <input type="text" name="city" placeholder="City" value="<%= profile == null ? "" : profile.city() %>" required>
                    </div>
                    <input type="text" name="address" placeholder="Address" value="<%= profile == null ? "" : profile.address() %>" required>
                    <div style="margin-top:8px;"></div>
                    <textarea name="description" placeholder="Description"><%= profile == null || profile.description() == null ? "" : profile.description() %></textarea>
                    <div style="margin-top:8px;"></div>
                    <div class="row">
                        <input type="text" id="latitude" name="latitude" value="<%= profile == null ? "" : profile.latitude() %>" required readonly>
                        <input type="text" id="longitude" name="longitude" value="<%= profile == null ? "" : profile.longitude() %>" required readonly>
                    </div>
                    <div id="map" class="map"></div>
                    <p style="font-size:.9rem;color:#56708a;">Click map to update location pin.</p>
                    <button class="btn btn-primary" type="submit">Save Profile</button>
                </form>
            </div>
        </div>
        <div>
            <div class="card">
                <h3 style="margin-top:0;">Upload Photo</h3>
                <form method="post" action="<%= request.getContextPath() %>/LabProfileServlet" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="uploadPhoto">
                    <input type="file" name="photo" accept="image/*" required>
                    <div style="margin-top:8px;"></div>
                    <button class="btn btn-primary" type="submit">Upload Photo</button>
                </form>
            </div>
            <div class="card">
                <h3 style="margin-top:0;">Gallery</h3>
                <% if (photos.isEmpty()) { %>
                <div>No photos uploaded yet.</div>
                <% } else { %>
                <div class="photo-grid">
                    <% for (LabDAO.LabPhoto p : photos) { %>
                    <a href="<%= request.getContextPath() + "/" + p.photoPath() %>" target="_blank">
                        <img src="<%= request.getContextPath() + "/" + p.photoPath() %>" alt="Lab Photo">
                    </a>
                    <% } %>
                </div>
                <% } %>
            </div>
            <div class="card danger">
                <h3 style="margin-top:0;">Delete Account</h3>
                <div class="danger-note">
                    Your account and all the data will be permanently deleted.<br>
                    Enter your password to confirm.
                </div>
                <form method="post" action="<%= request.getContextPath() %>/DeleteAccountServlet">
                    <input type="password" name="confirmPassword" placeholder="Confirm Password" required>
                    <div style="margin-top:8px;"></div>
                    <button class="btn btn-danger" type="submit">Confirm Delete</button>
                </form>
                <a class="btn-back" href="<%= request.getContextPath() %>/LabProfileServlet">Back</a>
            </div>
        </div>
    </div>
        </div>
    </main>
</div>

<script>
    (function () {
        var latInput = document.getElementById("latitude");
        var lngInput = document.getElementById("longitude");
        var lat = parseFloat(latInput.value) || 27.7172;
        var lng = parseFloat(lngInput.value) || 85.3240;
        var map = L.map("map").setView([lat, lng], 13);
        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map);

        var marker = L.marker([lat, lng], {draggable: true}).addTo(map);

        function sync(latLng) {
            latInput.value = latLng.lat.toFixed(7);
            lngInput.value = latLng.lng.toFixed(7);
        }

        marker.on("dragend", function () {
            sync(marker.getLatLng());
        });
        map.on("click", function (e) {
            marker.setLatLng(e.latlng);
            sync(e.latlng);
        });
    })();
</script>
</body>
</html>

