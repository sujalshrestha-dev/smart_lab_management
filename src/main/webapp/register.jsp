<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    String error = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=1366, initial-scale=1.0">
    <title>Patient Registration | Smart Lab</title>
    <style>
        :root {
            --text: #233f6f;
            --muted: #6077a0;
            --primary: #2f66d8;
            --primary-hover: #2458c5;
            --border: #cfdcf0;
            --danger: #b42318;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background:
                linear-gradient(180deg, rgba(220, 235, 255, 0.5) 0%, rgba(198, 221, 255, 0.38) 100%),
                url("assets/images/Model/medical.png") center/cover no-repeat;
            color: var(--text);
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
            background: rgba(246, 250, 255, 0.46);
            backdrop-filter: blur(3px);
            transform: scale(var(--page-scale, 1));
            transform-origin: top left;
            padding: 14px 26px 10px;
        }

        .brand {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-bottom: 4px;
        }

        .brand-logo { width: 38px; height: 38px; object-fit: contain; }

        .brand-text {
            font-size: 22px;
            font-weight: 800;
            color: #1168bf;
            line-height: 1;
        }

        h1 {
            font-size: 34px;
            text-align: center;
            margin-bottom: 4px;
        }

        .subtitle {
            text-align: center;
            color: var(--muted);
            margin-bottom: 10px;
            font-size: 14px;
        }

        form {
            display: grid;
            gap: 8px;
        }

        .row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }

        .field {
            display: grid;
            gap: 4px;
        }

        label {
            font-size: 14px;
            font-weight: 700;
            color: #2e4a78;
        }

        input,
        textarea {
            width: 100%;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 8px 10px;
            font-size: 14px;
            outline: none;
            background: rgba(255, 255, 255, 0.92);
        }

        textarea {
            min-height: 52px;
            resize: none;
        }

        input:focus,
        textarea:focus {
            border-color: var(--primary);
        }

        .password-wrap { position: relative; }

        .password-wrap input { padding-right: 58px; }

        .toggle-password {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            border: 0;
            background: transparent;
            color: #6077a0;
            cursor: pointer;
            font-size: 12px;
            font-weight: 700;
            padding: 2px 4px;
        }

        .error {
            color: var(--danger);
            font-size: 12px;
            display: none;
        }

        .flash {
            border-radius: 8px;
            padding: 8px 10px;
            font-size: 13px;
            margin-bottom: 4px;
        }

        .flash.error {
            display: block;
            background: #fdecec;
            color: #8f1e15;
            border: 1px solid #f8c9c4;
        }

        .flash.success {
            display: block;
            background: #eaf8ee;
            color: #106b36;
            border: 1px solid #bee8ca;
        }

        .actions {
            display: flex;
            gap: 10px;
            margin-top: 4px;
        }

        .btn {
            border: 0;
            border-radius: 9px;
            padding: 9px 18px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(100deg, var(--primary), #3e8bf0);
            color: #fff;
        }

        .btn-primary:hover { background: var(--primary-hover); }

        .btn-light {
            background: #e8effb;
            color: var(--text);
        }

        .login-note {
            margin-top: 2px;
            font-size: 13px;
            color: var(--muted);
        }

        .login-note a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 700;
        }
    </style>
</head>
<body>
<div class="stage">
    <div class="viewport">
        <main class="page">
            <div class="brand">
                <img class="brand-logo" src="assets/images/logo.png" alt="SmartLab logo">
                <div class="brand-text">SmartLab</div>
            </div>
            <h1>Patient Registration</h1>
            <p class="subtitle">Create your patient account to book lab appointments.</p>

            <% if (error != null && !error.isBlank()) { %>
            <p class="flash error"><%= esc(error) %></p>
            <% } %>
            <% if (success != null && !success.isBlank()) { %>
            <p class="flash success"><%= esc(success) %></p>
            <% } %>

            <form action="RegisterServlet" method="post" id="patientRegisterForm" novalidate>
                <input type="hidden" name="role" value="PATIENT">

                <div class="row">
                    <div class="field">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" maxlength="50" required>
                    </div>
                </div>
                <p class="error" id="usernameError">Username must not start with a number and can only use letters, numbers, and underscore (_).</p>

                <div class="row">
                    <div class="field">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" maxlength="120" required>
                    </div>
                    <div class="field">
                        <label for="contactNumber">Contact Number</label>
                        <input type="text" id="contactNumber" name="contactNumber" maxlength="25" required>
                    </div>
                </div>

                <div class="row">
                    <div class="field">
                        <label for="password">Password</label>
                        <div class="password-wrap">
                            <input type="password" id="password" name="password" required>
                            <button type="button" class="toggle-password" id="togglePasswords" aria-label="Show passwords">Eye</button>
                        </div>
                    </div>
                    <div class="field">
                        <label for="confirmPassword">Confirm Password</label>
                        <div class="password-wrap">
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                        </div>
                    </div>
                </div>
                <p class="error" id="passwordError">Password must include uppercase, lowercase, one symbol, and at least two numbers (min 8 chars).</p>

                <div class="row">
                    <div class="field">
                        <label for="dateOfBirth">Date of Birth</label>
                        <input type="date" id="dateOfBirth" name="dateOfBirth" required>
                    </div>
                    <div class="field">
                        <label for="emergencyContact">Emergency Contact</label>
                        <input type="text" id="emergencyContact" name="emergencyContact" maxlength="25" required>
                    </div>
                </div>

                <div class="field">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" maxlength="255" required></textarea>
                </div>

                <div class="actions">
                    <button type="submit" class="btn btn-primary">Register</button>
                    <a href="index.jsp" class="btn btn-light">Back</a>
                </div>
                <p class="login-note">Already have an account? <a href="login.jsp">Login.</a></p>
            </form>
        </main>
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
            if (!isFinite(scale) || scale <= 0) scale = 1;
            root.style.setProperty("--page-scale", String(scale));
        }

        window.addEventListener("resize", scalePage);
        scalePage();

        var form = document.getElementById("patientRegisterForm");
        var username = document.getElementById("username");
        var password = document.getElementById("password");
        var confirmPassword = document.getElementById("confirmPassword");
        var usernameError = document.getElementById("usernameError");
        var error = document.getElementById("passwordError");
        var togglePasswords = document.getElementById("togglePasswords");
        var dateOfBirth = document.getElementById("dateOfBirth");
        var usernameRegex = /^[A-Za-z_][A-Za-z0-9_]*$/;
        var passwordRegex = /^(?=(?:.*\d){2,})(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/;

        if (dateOfBirth) {
            dateOfBirth.max = new Date().toISOString().split("T")[0];
        }

        togglePasswords.addEventListener("click", function () {
            var show = password.type === "password";
            password.type = show ? "text" : "password";
            confirmPassword.type = show ? "text" : "password";
            togglePasswords.textContent = show ? "Hide" : "Eye";
        });

        form.addEventListener("submit", function (event) {
            var valid = true;

            if (!usernameRegex.test(username.value.trim())) {
                usernameError.style.display = "block";
                valid = false;
            } else {
                usernameError.style.display = "none";
            }

            if (!passwordRegex.test(password.value)) {
                error.style.display = "block";
                password.focus();
                valid = false;
            } else if (password.value !== confirmPassword.value) {
                error.style.display = "block";
                confirmPassword.focus();
                valid = false;
            } else {
                error.style.display = "none";
            }

            if (!valid) {
                event.preventDefault();
            }
        });
    })();
</script>
</body>
</html>
