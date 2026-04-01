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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Smart Lab</title>
    <style>
        :root {
            --ink: #203a69;
            --muted: #5d7194;
            --card-border: rgba(255, 255, 255, 0.5);
            --card-bg: rgba(246, 250, 255, 0.4);
            --field-bg: rgba(255, 255, 255, 0.9);
            --field-border: #d4e1f3;
            --blue-1: #2d55d7;
            --blue-2: #58b5ff;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: "Segoe UI", "Trebuchet MS", Tahoma, Geneva, Verdana, sans-serif;
            background:
                linear-gradient(180deg, rgba(220, 235, 255, 0.5) 0%, rgba(198, 221, 255, 0.38) 100%),
                url("assets/images/Model/medical.png") center/cover no-repeat fixed;
            color: var(--ink);
            min-height: 100svh;
            display: grid;
            place-items: center;
            padding: clamp(12px, 3vw, 28px);
        }

        .card {
            width: min(510px, 100%);
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: clamp(18px, 4vw, 34px) clamp(16px, 5vw, 42px) clamp(18px, 4vw, 30px);
            box-shadow: 0 24px 52px rgba(29, 54, 104, 0.24);
            backdrop-filter: blur(8px);
        }

        .brand {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-bottom: 14px;
            font-size: clamp(1.5rem, 4vw, 2.2rem);
            font-weight: 800;
        }

        .brand-logo {
            width: clamp(28px, 6vw, 42px);
            height: clamp(28px, 6vw, 42px);
            object-fit: contain;
        }

        h1 {
            font-size: clamp(1.5rem, 4.7vw, 2.2rem);
            margin-bottom: 8px;
            text-align: center;
            letter-spacing: 0.2px;
        }

        .subtitle {
            color: var(--muted);
            margin-bottom: 22px;
            text-align: center;
            font-size: clamp(0.95rem, 2.2vw, 1.08rem);
        }

        form {
            display: grid;
            gap: 14px;
        }

        .field {
            display: grid;
            gap: 8px;
        }

        label {
            font-size: clamp(0.92rem, 2vw, 1.03rem);
            font-weight: 700;
            color: #2a4475;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap .input-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #7890b8;
            font-size: 1rem;
            pointer-events: none;
        }

        input {
            width: 100%;
            border: 1px solid var(--field-border);
            border-radius: 10px;
            padding: 12px 14px 12px 42px;
            font-size: clamp(0.95rem, 2vw, 1.02rem);
            outline: none;
            background: var(--field-bg);
            color: #2a406d;
        }

        input:focus {
            border-color: #7ea6f6;
            box-shadow: 0 0 0 3px rgba(118, 163, 246, 0.2);
        }

        input::placeholder {
            color: #8699bb;
        }

        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            border: 0;
            background: transparent;
            color: #5f73a0;
            cursor: pointer;
            font-size: 0.92rem;
            font-weight: 700;
            padding: 2px 4px;
        }

        .row-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 2px;
        }

        .remember {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: #3a517f;
            font-size: 0.96rem;
            font-weight: 500;
        }

        .remember input[type="checkbox"] {
            width: 17px;
            height: 17px;
            accent-color: #3a72ea;
            padding: 0;
            border-radius: 4px;
            box-shadow: none;
        }

        .row-meta a {
            color: #3f5f9b;
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .btn {
            border: 0;
            border-radius: 10px;
            padding: 12px 16px;
            font-weight: 700;
            font-size: clamp(1rem, 2.3vw, 1.15rem);
            background: linear-gradient(100deg, var(--blue-1), var(--blue-2));
            color: #fff;
            cursor: pointer;
            box-shadow: 0 12px 18px rgba(48, 88, 211, 0.28);
        }

        .btn:hover { filter: brightness(1.03); }

        .create {
            margin-top: 16px;
            text-align: center;
            color: #4a618b;
            font-size: clamp(0.9rem, 2.1vw, 1rem);
        }

        .create a {
            color: #2f66d8;
            text-decoration: none;
            font-weight: 700;
            margin-left: 5px;
        }

        .flash {
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 0.92rem;
            margin-bottom: 10px;
        }

        .flash.error {
            background: #fdecec;
            color: #8f1e15;
            border: 1px solid #f8c9c4;
        }

        .flash.success {
            background: #eaf8ee;
            color: #106b36;
            border: 1px solid #bee8ca;
        }

        @media (max-height: 820px) and (min-width: 700px) {
            body {
                padding: 8px;
            }

            .card {
                padding-top: 14px;
                padding-bottom: 14px;
                max-width: 480px;
            }

            .brand {
                margin-bottom: 8px;
                font-size: 1.6rem;
            }

            .subtitle {
                margin-bottom: 12px;
            }

            form {
                gap: 10px;
            }

            input {
                padding-top: 9px;
                padding-bottom: 9px;
            }

            .btn {
                padding-top: 10px;
                padding-bottom: 10px;
            }

            .create {
                margin-top: 10px;
            }
        }

        @media (max-width: 700px) {
            body { background-attachment: scroll; }
            .card { border-radius: 16px; }
            .row-meta { align-items: flex-start; }
        }

        @media (max-width: 420px) {
            .btn { width: 100%; }
            .row-meta a { width: 100%; }
        }
    </style>
</head>
<body>
<main class="card">
    <div class="brand">
        <img class="brand-logo" src="assets/images/logo.png" alt="SmartLab logo">
        <span>SmartLab</span>
    </div>
    <h1>Login to your account</h1>
    <p class="subtitle">Sign in to your SmartLab account.</p>
    <% if (error != null && !error.isBlank()) { %>
    <p class="flash error"><%= esc(error) %></p>
    <% } %>
    <% if (success != null && !success.isBlank()) { %>
    <p class="flash success"><%= esc(success) %></p>
    <% } %>

    <form action="LoginServlet" method="post">
        <div class="field">
            <label for="email">Email</label>
            <div class="input-wrap">
                <span class="input-icon">&#9993;</span>
                <input type="email" id="email" name="email" maxlength="120" placeholder="Email" required>
            </div>
        </div>

        <div class="field">
            <label for="password">Password</label>
            <div class="input-wrap">
                <span class="input-icon">&#128273;</span>
                <input type="password" id="password" name="password" placeholder="Password" required>
                <button type="button" class="toggle-password" id="togglePassword" aria-label="Show password">Eye</button>
            </div>
        </div>

        <div class="row-meta">
            <label class="remember">
                <input type="checkbox" name="rememberMe" value="1">
                <span>Remember me</span>
            </label>
            <a href="forgot_password.jsp">Forgot Password?</a>
        </div>

        <button type="submit" class="btn">Login</button>
    </form>

    <div class="create">
        Don't have an account?
        <a href="index.jsp">Create Account</a>
    </div>
</main>

<script>
    (function () {
        var password = document.getElementById("password");
        var togglePassword = document.getElementById("togglePassword");

        togglePassword.addEventListener("click", function () {
            var show = password.type === "password";
            password.type = show ? "text" : "password";
            togglePassword.textContent = show ? "Hide" : "Eye";
        });
    })();
</script>
</body>
</html>

