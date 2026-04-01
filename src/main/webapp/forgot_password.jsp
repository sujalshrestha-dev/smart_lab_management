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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | Smart Lab</title>
    <style>
        :root {
            --bg: #f3f8ff;
            --card: #ffffff;
            --text: #19324a;
            --muted: #5d7388;
            --primary: #0b6bcb;
            --primary-hover: #0958a7;
            --border: #d8e3ef;
            --danger: #b42318;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(140deg, #f7fbff 0%, var(--bg) 100%);
            color: var(--text);
            min-height: 100vh;
            display: grid;
            place-items: center;
            padding: 24px;
        }

        .card {
            width: 100%;
            max-width: 480px;
            background: var(--card);
            border-radius: 14px;
            padding: 28px;
            box-shadow: 0 14px 28px rgba(25, 50, 74, 0.12);
        }

        h1 {
            font-size: 1.6rem;
            margin-bottom: 8px;
        }

        .subtitle {
            color: var(--muted);
            margin-bottom: 18px;
        }

        form {
            display: grid;
            gap: 14px;
        }

        .field {
            display: grid;
            gap: 6px;
        }

        label {
            font-size: 0.92rem;
            font-weight: 600;
        }

        input {
            width: 100%;
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 0.95rem;
            outline: none;
        }

        .row {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 8px;
            align-items: end;
        }

        .btn {
            border: 0;
            border-radius: 10px;
            padding: 10px 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary);
            color: #fff;
        }

        .btn-primary:hover {
            background: var(--primary-hover);
        }

        .btn-light {
            background: #edf3fa;
            color: var(--text);
        }

        .hint {
            font-size: 0.88rem;
            color: var(--muted);
        }

        .flash {
            border-radius: 10px;
            padding: 10px 12px;
            font-size: 0.92rem;
            background: #fdecec;
            color: #8f1e15;
            border: 1px solid #f8c9c4;
            margin-bottom: 8px;
        }

        .hidden {
            display: none;
        }

        .actions {
            display: flex;
            gap: 10px;
        }
    </style>
</head>
<body>
<main class="card">
    <h1>Forgot Password</h1>
    <p class="subtitle">Reset your password using verification code.</p>
    <% if (error != null && !error.isBlank()) { %>
    <p class="flash"><%= esc(error) %></p>
    <% } %>

    <form action="ForgotPasswordServlet" method="post" id="forgotForm">
        <div class="field">
            <label for="email">Email</label>
            <div class="row">
                <input type="email" id="email" name="email" maxlength="120" required>
                <button type="button" class="btn btn-light" id="sendCodeBtn">Send Code</button>
            </div>
        </div>

        <div class="field hidden" id="codeSection">
            <label for="verificationCode">Enter Code</label>
            <input type="text" id="verificationCode" name="verificationCode" maxlength="10">
            <p class="hint">Demo code for now: 1234</p>
            <button type="button" class="btn btn-light" id="verifyCodeBtn">Verify Code</button>
        </div>

        <div class="field hidden" id="passwordSection">
            <label for="newPassword">New Password</label>
            <input type="password" id="newPassword" name="newPassword">
        </div>

        <div class="field hidden" id="confirmSection">
            <label for="confirmPassword">Confirm Password</label>
            <input type="password" id="confirmPassword" name="confirmPassword">
        </div>

        <div class="actions">
            <button type="submit" class="btn btn-primary hidden" id="submitBtn">Reset Password</button>
            <a href="login.jsp" class="btn btn-light">Back to Login</a>
        </div>
    </form>
</main>

<script>
    (function () {
        var sendCodeBtn = document.getElementById("sendCodeBtn");
        var codeSection = document.getElementById("codeSection");
        var verifyCodeBtn = document.getElementById("verifyCodeBtn");
        var verificationCode = document.getElementById("verificationCode");
        var passwordSection = document.getElementById("passwordSection");
        var confirmSection = document.getElementById("confirmSection");
        var submitBtn = document.getElementById("submitBtn");
        var email = document.getElementById("email");
        var forgotForm = document.getElementById("forgotForm");

        sendCodeBtn.addEventListener("click", function () {
            if (!email.value.trim()) {
                alert("Please enter your email first.");
                email.focus();
                return;
            }
            codeSection.classList.remove("hidden");
            verificationCode.focus();
        });

        verifyCodeBtn.addEventListener("click", function () {
            if (verificationCode.value.trim() === "1234") {
                passwordSection.classList.remove("hidden");
                confirmSection.classList.remove("hidden");
                submitBtn.classList.remove("hidden");
            } else {
                alert("Invalid code. Please use 1234.");
            }
        });

        forgotForm.addEventListener("submit", function (event) {
            var newPassword = document.getElementById("newPassword");
            var confirmPassword = document.getElementById("confirmPassword");
            if (verificationCode.value.trim() !== "1234") {
                event.preventDefault();
                alert("Please verify the correct code first.");
                return;
            }
            if (!newPassword.value || !confirmPassword.value) {
                event.preventDefault();
                alert("Please enter new password and confirm password.");
                return;
            }
            if (newPassword.value !== confirmPassword.value) {
                event.preventDefault();
                alert("New password and confirm password do not match.");
            }
        });
    })();
</script>
</body>
</html>
