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
            margin: 0;
            border: 1px solid #c8d7ee;
            border-radius: 10px;
            overflow: hidden;
            background:
                linear-gradient(180deg, rgba(245, 249, 255, 0.94) 0%, rgba(236, 244, 255, 0.9) 100%),
                url("assets/images/Model/medical.png") center bottom/cover no-repeat;
            transform: scale(var(--page-scale, 1));
            transform-origin: top left;
            display: flex;
            flex-direction: column;
        }

        .top {
            height: 118px;
            padding: 16px 54px;
            border-bottom: 1px solid #d8e4f4;
            background: rgba(255, 255, 255, 0.72);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .brand {
            display: flex;
            align-items: center;
            width: 250px;
            height: 84px;
            overflow: visible;
        }

        .logo {
            width: auto;
            max-width: 100%;
            max-height: 84px;
            display: block;
            object-fit: contain;
        }

        .nav {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .nav a {
            color: #5f7497;
            text-decoration: none;
            font-size: 17px;
            font-weight: 700;
            padding: 10px 3px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #3d83ea;
            border-bottom-color: #6ab9ff;
        }

        .btn {
            text-decoration: none;
            font-size: 17px;
            font-weight: 700;
            color: #2f4f7c;
            border: 1px solid #cfddf2;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.82);
            padding: 12px 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            line-height: 1;
            min-height: 52px;
            transition: transform .18s ease, box-shadow .18s ease, background-color .18s ease, border-color .18s ease, color .18s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 24px rgba(43, 84, 145, 0.16);
        }

        .btn-mint {
            background: #cfecea;
            border-color: #b8dfdc;
            color: #2c7182;
        }

        .btn-mint:hover {
            background: #c1e6e2;
            border-color: #a8d7d3;
        }

        .btn-outline {
            background: rgba(255, 255, 255, 0.92);
            color: #2f4f7c;
            border-color: #cfddf2;
        }

        .btn-outline:hover {
            background: rgba(255, 255, 255, 1);
            border-color: #b9cbe8;
        }

        .btn-login {
            background: linear-gradient(120deg, #2f5fd9, #3484ef);
            color: #ffffff;
            border-color: transparent;
            box-shadow: 0 10px 20px rgba(56, 101, 208, 0.28);
            min-width: 118px;
            padding: 13px 24px;
            font-size: 18px;
        }

        .btn-login:link,
        .btn-login:visited,
        .btn-login:active,
        .btn-login:focus {
            color: #ffffff;
        }

        .btn-login:hover {
            background: linear-gradient(120deg, #2556d4, #2e79e8);
            color: #ffffff;
            box-shadow: 0 16px 28px rgba(44, 92, 188, 0.32);
        }

        .hero {
            flex: 1;
            padding: 30px 48px 16px;
            display: grid;
            grid-template-columns: 1.02fr .98fr;
            gap: 28px;
            align-items: center;
        }

        .hero-left {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .eyebrow {
            display: inline-flex;
            align-self: flex-start;
            align-items: center;
            gap: 10px;
            padding: 10px 16px;
            border-radius: 999px;
            border: 1px solid #dbe7f7;
            background: rgba(255, 255, 255, 0.88);
            color: #3f85eb;
            font-size: 14px;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
            margin-bottom: 16px;
        }

        .eyebrow::before {
            content: "";
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #6fd4cf;
            box-shadow: 0 0 0 6px rgba(111, 212, 207, 0.18);
        }

        .title {
            font-size: 58px;
            line-height: 1.04;
            font-weight: 800;
            color: #193a70;
            margin-bottom: 14px;
        }

        .blue { color: #3f85eb; }

        .lead {
            font-size: 19px;
            line-height: 1.48;
            color: #60789d;
            font-weight: 600;
            margin-bottom: 22px;
            max-width: 620px;
        }

        .panel-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 14px;
        }

        .panel {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid #dde8f7;
            border-radius: 18px;
            padding: 18px 18px 16px;
            box-shadow: 0 12px 24px rgba(51, 85, 140, 0.09);
            transition: transform .18s ease, box-shadow .18s ease;
        }

        .panel:hover,
        .stat:hover {
            transform: translateY(-2px);
            box-shadow: 0 16px 28px rgba(51, 85, 140, 0.14);
        }

        .panel h3 {
            font-size: 21px;
            color: #1f3f72;
            margin-bottom: 6px;
        }

        .panel p {
            font-size: 15px;
            line-height: 1.42;
            color: #60789d;
            font-weight: 600;
        }

        .hero-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 18px;
        }

        .hero-right {
            display: flex;
            flex-direction: column;
            gap: 14px;
            justify-content: center;
        }

        .visual-shell {
            position: relative;
            width: 100%;
            height: 336px;
            padding: 20px;
            border-radius: 42px 120px 42px 120px;
            background:
                linear-gradient(145deg, rgba(255, 255, 255, 0.62), rgba(214, 232, 255, 0.16)),
                linear-gradient(180deg, rgba(74, 152, 233, 0.22), rgba(255, 255, 255, 0.08));
            border: 1px solid rgba(255, 255, 255, 0.62);
            box-shadow:
                0 28px 50px rgba(43, 84, 145, 0.18),
                inset 0 1px 0 rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(8px);
            overflow: hidden;
        }

        .visual-shell::before {
            content: "";
            position: absolute;
            inset: 16px 22px auto auto;
            width: 220px;
            height: 110px;
            border-radius: 999px;
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.34), transparent);
            z-index: 1;
        }

        .visual-shell::after {
            content: "";
            position: absolute;
            left: 24px;
            right: 24px;
            bottom: 20px;
            height: 62px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(62, 123, 198, 0.24), transparent 68%);
            filter: blur(10px);
            z-index: 1;
        }

        .hero-image-wrap {
            position: relative;
            z-index: 2;
            width: 100%;
            height: 100%;
            border-radius: 28px 92px 28px 92px;
            overflow: hidden;
            box-shadow:
                inset 0 0 0 1px rgba(255, 255, 255, 0.28),
                0 18px 30px rgba(31, 66, 118, 0.16);
        }

        .hero-image-wrap::after {
            content: "";
            position: absolute;
            inset: 0;
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.08), transparent 22%),
                linear-gradient(90deg, rgba(218, 235, 255, 0.16), transparent 36%, transparent 70%, rgba(232, 243, 255, 0.14));
            pointer-events: none;
        }

        .hero-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center center;
            display: block;
            filter: saturate(1.02) contrast(1.02) brightness(1.01);
        }

        .spotlight {
            position: absolute;
            left: 28px;
            right: 28px;
            bottom: 26px;
            z-index: 3;
            background: linear-gradient(145deg, rgba(22, 54, 103, 0.92), rgba(45, 104, 216, 0.84));
            color: #fff;
            border-radius: 24px;
            padding: 20px 22px 18px;
            box-shadow: 0 20px 36px rgba(34, 82, 155, 0.24);
            backdrop-filter: blur(10px);
        }

        .spotlight h2 {
            font-size: 28px;
            line-height: 1.1;
            margin-bottom: 10px;
        }

        .spotlight p {
            font-size: 15px;
            line-height: 1.42;
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
            border: 1px solid #dde8f7;
            border-radius: 18px;
            padding: 18px 16px;
            text-align: center;
            box-shadow: 0 12px 24px rgba(51, 85, 140, 0.09);
            transition: transform .18s ease, box-shadow .18s ease;
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
        <div class="brand">
            <img class="logo" src="assets/images/logo.png" alt="SmartLab logo">
        </div>
        <nav class="nav">
            <a href="index.jsp">Home</a>
            <a class="active" href="about.jsp">About</a>
            <a class="btn btn-login" href="login.jsp">Login</a>
        </nav>
    </header>

    <main class="hero">
        <section class="hero-left">
            <div class="eyebrow">About SmartLab</div>
            <h1 class="title">A single platform for <span class="blue">patients, labs, appointments</span> and digital reports.</h1>
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

            <div class="hero-actions">
                <a class="btn btn-outline" href="RegisterLab.jsp">Lab Staff Signup &nbsp;&#8594;</a>
                <a class="btn btn-mint" href="register.jsp?role=PATIENT">Patient Signup</a>
            </div>
        </section>

        <aside class="hero-right">
            <div class="visual-shell">
                <div class="hero-image-wrap">
                    <img class="hero-image" src="assets/images/Model/1.png" alt="Lab professional">
                </div>
                <div class="spotlight">
                    <h2>Built for smarter lab coordination</h2>
                    <p>
                        From first booking to final report, SmartLab keeps each step visible so staff and patients can
                        follow the same process without confusion.
                    </p>
                </div>
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
