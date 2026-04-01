<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=1366, initial-scale=1.0">
    <title>SmartLab | Home</title>
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

        .hero {
            flex: 1;
            padding: 30px 48px 14px;
            display: grid;
            grid-template-columns: 1fr 1.08fr;
            gap: 28px;
            align-items: center;
        }

        .hero-left {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .title {
            font-size: 63px;
            line-height: 1.03;
            font-weight: 800;
            color: #193a70;
            margin-bottom: 9px;
        }

        .blue { color: #3f85eb; }

        .sub {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 25px;
            font-weight: 700;
            color: #2c5186;
            margin-bottom: 12px;
            justify-content: center;
        }

        .sub::before,
        .sub::after {
            content: "";
            width: 56px;
            height: 3px;
            border-radius: 8px;
            background: #6fd4cf;
        }

        .copy {
            font-size: 18px;
            line-height: 1.45;
            color: #60789d;
            font-weight: 600;
            margin-bottom: 16px;
            max-width: 560px;
            text-align: center;
        }

        .copy .blue { font-weight: 800; }

        .features {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 18px;
        }

        .feature {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid #dde8f7;
            border-radius: 18px;
            text-align: center;
            padding: 18px 12px 14px;
            box-shadow: 0 12px 24px rgba(51, 85, 140, 0.09);
        }

        .feature img {
            width: 52px;
            height: 52px;
            object-fit: contain;
            margin-bottom: 10px;
        }

        .feature h3 {
            font-size: 20px;
            line-height: 1.18;
            color: #1f3f72;
            margin-bottom: 6px;
        }

        .feature p {
            font-size: 15px;
            color: #6a82a7;
            font-weight: 700;
            line-height: 1.25;
        }

        .hero-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            justify-content: center;
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

        .hero-right {
            position: relative;
            height: 534px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .visual-shell {
            position: relative;
            z-index: 2;
            width: 670px;
            height: 474px;
            padding: 24px;
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
            <a class="active" href="index.jsp">Home</a>
            <a href="about.jsp">About</a>
            <a class="btn btn-login" href="login.jsp">Login</a>
        </nav>
    </header>

    <main class="hero">
        <section class="hero-left">
            <h1 class="title">Welcome to <span class="blue">SmartLab</span></h1>
            <div class="sub">Medical Lab Management System</div>
            <p class="copy">Manage your lab, patients, staff and reports all in one <span class="blue">smart platform.</span></p>

            <div class="features">
                <article class="feature">
                    <img src="assets/images/Icon/icon2.png" alt="Fast and accurate">
                    <h3>Fast &amp; Accurate</h3>
                    <p>Lab Testing</p>
                </article>
                <article class="feature">
                    <img src="assets/images/Icon/icon1.png" alt="Digital reports">
                    <h3>Digital Reports</h3>
                    <p>&amp; Records</p>
                </article>
                <article class="feature">
                    <img src="assets/images/Icon/icon3.png" alt="Secure and reliable">
                    <h3>Secure &amp; Reliable</h3>
                    <p>System</p>
                </article>
            </div>

            <div class="hero-actions">
                <a class="btn btn-outline" href="RegisterLab.jsp">Lab Staff Signup &nbsp;&#8594;</a>
                <a class="btn btn-mint" href="register.jsp?role=PATIENT">Patient Signup</a>
                <a class="btn" href="about.jsp">&#9432; Learn More</a>
            </div>
        </section>

        <section class="hero-right">
            <div class="visual-shell">
                <div class="hero-image-wrap">
                    <img class="hero-image" src="assets/images/Model/1.png" alt="Lab professional">
                </div>
            </div>
        </section>
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
