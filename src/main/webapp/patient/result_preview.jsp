<%@ page import="com.smartlab.dao.PaymentDAO" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    PaymentDAO.PatientResultAccess resultInfo = (PaymentDAO.PatientResultAccess) request.getAttribute("resultInfo");
    if (resultInfo == null) {
        response.sendRedirect(request.getContextPath() + "/MyAppointmentsServlet?error=Unable+to+load+result");
        return;
    }
    String previewType = (String) request.getAttribute("previewType");
    if (previewType == null) previewType = "unsupported";
    boolean canPrintPreview = !"unsupported".equals(previewType);
    String inlineUrl = (String) request.getAttribute("inlineUrl");
    String downloadUrl = (String) request.getAttribute("downloadUrl");
    String backUrl = (String) request.getAttribute("backUrl");
    String backLabel = (String) request.getAttribute("backLabel");
    String displayFileName = (String) request.getAttribute("displayFileName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | Result Preview</title>
    <style>
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: #f4f8fc; color: #1e3550; overflow-x: hidden; }
        .preview-shell { background: #fff; border-radius: 18px; box-shadow: 0 16px 36px rgba(15, 39, 66, 0.12); overflow: hidden; }
        .preview-header { padding: 22px 24px 16px; border-bottom: 1px solid #e6edf6; }
        .preview-header h1 { margin: 0 0 8px; font-size: 1.8rem; }
        .preview-meta { display: flex; flex-wrap: wrap; gap: 10px 18px; color: #5a748e; font-size: 0.92rem; }
        .toolbar { display: flex; flex-wrap: wrap; gap: 10px; padding: 18px 24px; background: #f8fbff; border-bottom: 1px solid #e6edf6; }
        .btn { text-decoration: none; border: 0; border-radius: 10px; padding: 10px 14px; font-size: 0.92rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; }
        .btn-back { background: #e7eef7; color: #1e3550; }
        .btn-primary { background: #0b6bcb; color: #fff; }
        .btn-secondary { background: #1d3e63; color: #fff; }
        .viewer-wrap { padding: 20px 24px 24px; }
        .viewer-note { margin: 0 0 16px; color: #5a748e; font-size: 0.92rem; }
        .viewer-frame { width: 100%; min-height: 78vh; border: 1px solid #d7e4f1; border-radius: 14px; background: #f8fbff; }
        .viewer-image { display: block; width: 100%; max-width: 100%; border: 1px solid #d7e4f1; border-radius: 14px; background: #fff; }
        .fallback { border: 1px dashed #c6d6e7; border-radius: 14px; padding: 20px; background: #fbfdff; color: #49647f; }
        @media (max-width: 900px) {
            .preview-header, .toolbar, .viewer-wrap { padding-left: 16px; padding-right: 16px; }
            .viewer-frame { min-height: 62vh; }
        }
        @media print {
            .sidebar, .toolbar { display: none !important; }
            .layout { grid-template-columns: 1fr !important; }
            .main { padding: 0 !important; }
            .preview-shell { box-shadow: none; border-radius: 0; }
            .preview-header { border-bottom: 0; }
        }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>
    <main class="main">
        <div class="preview-shell">
            <section class="preview-header">
                <h1>Lab Result Preview</h1>
                <div class="preview-meta">
                    <span>Appointment #<%= resultInfo.appointmentId() %></span>
                    <span>Lab: <%= resultInfo.labName() %></span>
                    <span>Date: <%= resultInfo.appointmentDate() %> <%= resultInfo.appointmentTime() == null ? "" : resultInfo.appointmentTime() %></span>
                    <span>File: <%= displayFileName %></span>
                </div>
            </section>

            <section class="toolbar">
                <a class="btn btn-back" href="<%= backUrl %>"><%= backLabel %></a>
                <a class="btn btn-primary" href="<%= downloadUrl %>">Save Result</a>
                <% if (canPrintPreview) { %>
                <button class="btn btn-secondary" type="button" onclick="printResult()">Print Result</button>
                <% } %>
            </section>

            <section class="viewer-wrap">
                <p class="viewer-note">Review the uploaded result below. Use Save Result to download a copy or Print Result for a hard copy.</p>

                <% if ("image".equals(previewType)) { %>
                <img class="viewer-image" id="resultImage" src="<%= inlineUrl %>" alt="Lab result preview">
                <% } else if ("pdf".equals(previewType) || "text".equals(previewType)) { %>
                <iframe class="viewer-frame" id="resultFrame" src="<%= inlineUrl %>" title="Lab result preview"></iframe>
                <% } else { %>
                <div class="fallback">
                    <p>This file type cannot be embedded in the browser preview.</p>
                    <p>Use Save Result to download the file, then open it locally to view or print it.</p>
                </div>
                <% } %>
            </section>
        </div>
    </main>
</div>
<script>
    function printResult() {
        var frame = document.getElementById("resultFrame");
        if (frame && frame.contentWindow) {
            try {
                frame.contentWindow.focus();
                frame.contentWindow.print();
                return;
            } catch (err) {
                // Fall back to printing the page shell when iframe printing is unavailable.
            }
        }
        window.print();
    }
</script>
</body>
</html>
