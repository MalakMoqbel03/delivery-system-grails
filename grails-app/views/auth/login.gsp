<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Login — Delivery System</title>
    <asset:stylesheet src="dashboard.css"/>
    <style>

        .login-wrap {
            min-height: 70vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
        }
        .login-card {
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.10);
            padding: 40px 36px 36px;
            width: 100%;
            max-width: 420px;
        }
        .login-logo {
            text-align: center;
            margin-bottom: 28px;
        }
        .login-logo .login-icon {
            font-size: 40px;
            display: block;
            margin-bottom: 8px;
        }
        .login-logo h1 {
            font-size: 22px;
            font-weight: 900;
            color: #111;
            margin: 0 0 4px;
        }
        .login-logo p {
            font-size: 13px;
            color: rgba(0,0,0,0.45);
            margin: 0;
        }
        .login-error {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 10px;
            color: #dc2626;
            font-size: 13px;
            font-weight: 700;
            padding: 10px 14px;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .login-success {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            color: #15803d;
            font-size: 13px;
            font-weight: 700;
            padding: 10px 14px;
            margin-bottom: 18px;
        }
        .login-field { margin-bottom: 16px; }
        .login-label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: rgba(0,0,0,0.65);
            margin-bottom: 6px;
        }
        .login-input {
            width: 100%;
            padding: 10px 14px;
            border: 1.5px solid rgba(0,0,0,0.14);
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            background: #fafafa;
            transition: border-color 120ms, box-shadow 120ms;
            box-sizing: border-box;
        }
        .login-input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
            background: #fff;
        }
        .login-btn {
            width: 100%;
            padding: 12px;
            background: #2563eb;
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 800;
            cursor: pointer;
            transition: background 120ms, transform 80ms;
            margin-top: 8px;
        }
        .login-btn:hover  { background: #1d4ed8; }
        .login-btn:active { transform: scale(0.98); }
        .login-hint {
            text-align: center;
            font-size: 12px;
            color: rgba(0,0,0,0.38);
            margin-top: 20px;
        }
    </style>
</head>
<body>


<div class="login-wrap">
    <div class="login-card">

        <div class="login-logo">
            <span class="login-icon">🚚</span>
            <h1>Delivery System</h1>
            <p>Sign in to your account</p>
        </div>

        <%-- Show error if login failed --%>
        <g:if test="${error}">
            <div class="login-error">
                <i class="bi bi-exclamation-circle-fill"></i>
                ${error}
            </div>
        </g:if>

        <%-- Show success message (e.g. after logout) --%>
        <g:if test="${flash.message}">
            <div class="login-success">${flash.message}</div>
        </g:if>

        <g:form controller="auth" action="doLogin" method="post">

            <div class="login-field">
                <label class="login-label" for="username">Username</label>
                <%-- value="${params.username}" re-fills the username if login failed --%>
                <input class="login-input" type="text" id="username" name="username"
                       value="${params.username ?: ''}"
                       placeholder="Enter your username"
                       autocomplete="username"
                       autofocus/>
            </div>

            <div class="login-field">
                <label class="login-label" for="password">Password</label>
                <%-- type="password" makes the browser show dots instead of characters --%>
                <input class="login-input" type="password" id="password" name="password"
                       placeholder="Enter your password"
                       autocomplete="current-password"/>
            </div>

            <button class="login-btn" type="submit">Sign In →</button>

        </g:form>

        <p class="login-hint">Contact your administrator to get an account.</p>
    </div>
</div>

</body>
</html>
