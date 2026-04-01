<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object roleObj = session.getAttribute("role");
    if (roleObj == null || !"PATIENT".equalsIgnoreCase(roleObj.toString())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+login+as+patient");
        return;
    }
    String fullName = String.valueOf(session.getAttribute("fullName"));
    String activePage = "dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Panel | Dashboard</title>
    <style>
        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f8fc;
            color: #1e3550;
        }
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 12px;
        }
        .btn {
            text-decoration: none;
            border-radius: 10px;
            padding: 10px 14px;
            font-weight: 600;
            background: #ca3d2e;
            color: #fff;
        }
        .card {
            background: #fff;
            border-radius: 14px;
            padding: 18px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(170px, 1fr));
            gap: 16px;
            margin-top: 16px;
        }
        .quick-card {
            background: #fff;
            border-radius: 16px;
            min-height: 210px;
            padding: 20px;
            box-shadow: 0 10px 20px rgba(15, 39, 66, 0.08);
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .icon {
            font-size: 2rem;
            line-height: 1;
            font-family: "Segoe UI Emoji", "Apple Color Emoji", "Noto Color Emoji", sans-serif;
        }
        .quick-card h3 {
            margin: 10px 0 6px;
            font-size: 1.05rem;
        }
        .quick-card p {
            margin: 0;
            color: #58728d;
            font-size: 0.92rem;
            line-height: 1.35;
        }
        .quick-card:hover {
            transform: translateY(-2px);
            transition: transform 0.15s ease;
        }
        @media (min-width: 1800px) {
            .grid {
                grid-template-columns: repeat(4, minmax(220px, 1fr));
                gap: 18px;
            }
            .quick-card {
                min-height: 230px;
                padding: 22px;
            }
            .quick-card h3 {
                font-size: 1.12rem;
            }
            .quick-card p {
                font-size: 0.95rem;
            }
        }
        @media (max-width: 900px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    <%@ include file="includes/sidebar_styles.jspf" %>
</head>
<body>
<div class="layout">
    <%@ include file="includes/sidebar.jspf" %>
    <main class="main">
        <div class="topbar">
            <h1>Dashboard</h1>
            <a class="btn" href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        </div>
        <div class="card">
            Session active. You are logged in as <strong>PATIENT</strong>. Use quick actions below.
        </div>
        <div class="grid">
            <a class="quick-card" href="<%= request.getContextPath() %>/FindLabsServlet">
                <div class="icon">&#128300;</div>
                <div>
                    <h3>Browse Labs</h3>
                    <p>Search and explore verified labs available for booking tests.</p>
                </div>
            </a>
            <a class="quick-card" href="<%= request.getContextPath() %>/MyAppointmentsServlet">
                <div class="icon">&#128197;</div>
                <div>
                    <h3>My Appointments</h3>
                    <p>View upcoming bookings and track appointment status updates.</p>
                </div>
            </a>
            <a class="quick-card" href="<%= request.getContextPath() %>/HistoryServlet">
                <div class="icon">&#128220;</div>
                <div>
                    <h3>History</h3>
                    <p>Review completed appointments, previous tests, and results timeline.</p>
                </div>
            </a>
            <a class="quick-card" href="<%= request.getContextPath() %>/SubmitReviewServlet">
                <div class="icon">&#11088;</div>
                <div>
                    <h3>Rating and Review</h3>
                    <p>Rate completed lab services and manage your review decisions.</p>
                </div>
            </a>
        </div>
    </main>
</div>
</body>
</html>




