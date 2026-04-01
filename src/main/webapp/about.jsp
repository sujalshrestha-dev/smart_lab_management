<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=1366, initial-scale=1.0">
    <title>SmartLab | About</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #e7effb;
            color: #17386e;
            overflow: hidden;
        }

        .stage {
            width: 100vw;
            height: 100vh;
            display: grid;
            place-items: center;
            padding: 6px;
        }

        .viewport {
            width: calc(1366px * var(--page-scale, 1));
            height: calc(768px * var(--page-scale, 1));
            overflow: hidden;
        }

        .page {
            width: 1366px;
            height: 768px;
            border: 1px solid #c8d7ee;
            border-radius: 10px;
            overflow: hidden;
            background:
                radial-gradient(circle at top right, rgba(106, 185, 255, 0.20), transparent 32%),
                linear-gradient(180deg, rgba(245, 249, 255, 0.97) 0%, rgba(233, 242, 255, 0.94) 100%);
            transform: scale(var(--page-scale, 1));
            transform-origin: top left;
            display: flex;
            flex-direction: column;
        }

        .top {
            height: 108px;
            padding: 14px 54px;
            border-bottom: 1px solid #d8e4f4;
            background: rgba(255, 255, 255, 0.7);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            width: 258px;
            height: auto;
            display: block;
        }

        .nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .nav a {
            color: #5f7497;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            padding: 8px 3px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #3d83ea;
            border-bottom-color: #6ab9ff;
        }

        .btn {
            text-decoration: none;
            font-size: 16px;
            font-weight: 700;
            color: #fff;
            border: 1px solid transparent;
            border-radius: 12px;
            background: linear-gradient(120deg, #2f5fd9, #3484ef);
            padding: 10px 18px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            line-height: 1;
            box-shadow: 0 9px 16px rgba(56, 101, 208, 0.22);
        }

        .content {
            flex: 1;
            padding: 34px 48px 24px;
            display: grid;
            grid-template-columns: 1.15fr .85fr;
            gap: 24px;
        }

        .eyebrow {
            color: #3f85eb;
            font-size: 15px;
            font-weight: 800;
            letter-spacing: .14em;
            text-transform: uppercase;
            margin-bottom: 12px;
        }

        .title {
            font-size: 56px;
            line-height: 1.04;
            font-weight: 800;
            color: #193a70;
            margin-bottom: 16px;
        }

        .lead {
            font-size: 21px;
            line-height: 1.5;
            color: #5a7398;
            font-weight: 600;
            margin-bottom: 22px;
            max-width: 710px;
        }

        .panel-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .panel {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #dce7f7;
            border-radius: 18px;
            padding: 18px 18px 16px;
            box-shadow: 0 16px 30px rgba(35, 73, 136, 0.08);
        }

        .panel h3 {
            font-size: 20px;
            color: #1f3f72;
            margin-bottom: 8px;
        }

        .panel p {
            font-size: 16px;
            line-height: 1.45;
            color: #60789d;
            font-weight: 600;
        }

        .right {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .spotlight {
            background: linear-gradient(145deg, #2d68d8, #4ba1ff);
            color: #fff;
            border-radius: 24px;
            padding: 24px 24px 20px;
            box-shadow: 0 20px 36px rgba(34, 82, 155, 0.24);
        }

        .spotlight h2 {
            font-size: 32px;
            line-height: 1.1;
            margin-bottom: 12px;
        }

        .spotlight p {
            font-size: 17px;
            line-height: 1.5;
            color: rgba(255, 255, 255, 0.92);
            font-weight: 600;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .stat {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #dce7f7;
            border-radius: 18px;
            padding: 18px;
            text-align: center;
        }

        .stat strong {
            display: block;
            font-size: 34px;
            color: #1b4278;
            margin-bottom: 4px;
        }

        .stat span {
            font-size: 15px;
            color: #60789d;
            font-weight: 700;
        }

        .actions {
            display: flex;
            gap: 10px;
            margin-top: 4px;
        }

        .btn-light {
            background: rgba(255, 255, 255, 0.94);
            color: #2f4f7c;
            border-color: #cfddf2;
            box-shadow: none;
        }

        .footer {
            height: 40px;
            border-top: 1px solid #dbe6f6;
            background: rgba(255, 255, 255, 0.58);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #516a93;
            font-size: 14px;
            font-weight: 700;
            margin-top: auto;
        }
    </style>
</head>
<body>
<div class="stage">
<div class="viewport">
<div class="page">
    <header class="top">
        <img class="logo" src="assets/images/logo.png" alt="SmartLab logo">
        <nav class="nav">
            <a href="index.jsp">Home</a>
            <a class="active" href="about.jsp">About</a>
            <a class="btn" href="login.jsp">Login</a>
        </nav>
    </header>

    <main class="content">
        <section>
            <div class="eyebrow">About SmartLab</div>
            <h1 class="title">A single platform for patients, labs, appointments and digital reports.</h1>
            <p class="lead">
                SmartLab is a web-based medical lab management system built to reduce manual work across appointment
                booking, lab discovery, payment tracking, report delivery and review handling. It gives patients a
                simpler booking experience while helping lab staff manage operations from one dashboard.
            </p>

            <div class="panel-grid">
                <article class="panel">
                    <h3>For Patients</h3>
                    <p>Search verified labs, compare tests, book appointments, track payment progress and download reports online.</p>
                </article>
                <article class="panel">
                    <h3>For Lab Staff</h3>
                    <p>Manage appointments, maintain test catalogs, upload reports and confirm pending payments with less manual follow-up.</p>
                </article>
                <article class="panel">
                    <h3>Reliable Records</h3>
                    <p>Appointments, payments and test data stay connected, which reduces missing information and repeated data entry.</p>
                </article>
                <article class="panel">
                    <h3>Designed for Growth</h3>
                    <p>The system supports digital workflows today and leaves room for additional services, gateways and admin controls later.</p>
                </article>
            </div>
        </section>

        <aside class="right">
            <div class="spotlight">
                <h2>Built for smarter lab coordination</h2>
                <p>
                    From first booking to final report, SmartLab keeps each step visible so staff and patients can
                    follow the same process without confusion.
                </p>
            </div>

            <div class="stats">
                <div class="stat">
                    <strong>3</strong>
                    <span>Core user roles</span>
                </div>
                <div class="stat">
                    <strong>1</strong>
                    <span>Unified workflow</span>
                </div>
                <div class="stat">
                    <strong>24/7</strong>
                    <span>Online access</span>
                </div>
                <div class="stat">
                    <strong>100%</strong>
                    <span>Digital report flow</span>
                </div>
            </div>

            <div class="actions">
                <a class="btn" href="RegisterLab.jsp">Lab Staff Signup</a>
                <a class="btn btn-light" href="register.jsp?role=PATIENT">Patient Signup</a>
            </div>
        </aside>
    </main>

    <footer class="footer">&copy; 2026 SmartLab | Developed by Sujal Shrestha | BCA 6th Semester | TU Nepal</footer>
</div>
</div>
</div>
<script>
    (function () {
        var designWidth = 1366;
        var designHeight = 768;
        var root = document.documentElement;

        function scalePage() {
            var availableW = window.innerWidth - 12;
            var availableH = window.innerHeight - 12;
            var scale = Math.min(availableW / designWidth, availableH / designHeight);
            if (!isFinite(scale) || scale <= 0) {
                scale = 1;
            }
            root.style.setProperty("--page-scale", String(scale));
        }

        window.addEventListener("resize", scalePage);
        scalePage();
    })();
</script>
</body>
</html>
