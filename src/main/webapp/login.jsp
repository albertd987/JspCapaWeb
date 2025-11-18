<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - AutoFactory</title>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #ffffff;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #2c5282;
        }
        
        .login-container {
            max-width: 450px;
            width: 100%;
            padding: 20px;
        }
        
        .login-card {
            background: white;
            border-radius: 15px;
            border: 2px solid #2c5282;
            box-shadow: 0 10px 40px rgba(44, 82, 130, 0.15);
            overflow: hidden;
        }
        
        .login-header {
            background-image: url('media/logoempresa.png');
            background-size: 80%;
            background-repeat: no-repeat;
            background-position: center;
            padding: 40px 30px;
            text-align: center;
            min-height: 150px;
        }
        
        .login-header h1 {
            font-size: 2rem;
            margin: 0;
            font-weight: 600;
        }
        
        .login-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        
        .login-body {
            padding: 40px 30px;
        }
        
        .form-label {
            font-weight: 600;
            color: #2c5282;
            margin-bottom: 8px;
            display: block;
        }
        
        .input-group {
            display: flex;
            width: 100%;
        }
        
        .form-control {
            border-radius: 8px;
            padding: 12px 15px;
            border: 2px solid #2c5282;
            transition: all 0.3s;
            width: 100%;
            font-size: 1rem;
            color: #2c5282;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #1a365d;
            box-shadow: 0 0 0 3px rgba(44, 82, 130, 0.1);
        }
        
        .form-control::placeholder {
            color: rgba(44, 82, 130, 0.5);
        }
        
        .input-group-text {
            background: #f7fafc;
            border: 2px solid #2c5282;
            border-right: none;
            border-radius: 8px 0 0 8px;
            padding: 12px 15px;
            color: #2c5282;
        }
        
        .input-group .form-control {
            border-left: none;
            border-radius: 0 8px 8px 0;
        }
        
        .btn-login {
            background: #2c5282;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s;
            width: 100%;
            cursor: pointer;
        }
        
        .btn-login:hover {
            background: #1a365d;
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(44, 82, 130, 0.3);
        }
        
        .alert {
            border-radius: 8px;
            border: 2px solid #e53e3e;
            background: #fff5f5;
            color: #c53030;
            padding: 12px 15px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .login-footer {
            text-align: center;
            padding: 20px;
            background: #f7fafc;
            color: #2c5282;
            font-size: 0.9rem;
            border-top: 1px solid #e2e8f0;
        }
        
        .login-footer p {
            margin: 0;
        }
        
        .login-footer .mt-2 {
            margin-top: 0.5rem;
        }
        
        .login-footer small {
            font-size: 0.85em;
            opacity: 0.8;
        }
        
        .mb-0 {
            margin-bottom: 0;
        }
        
        .mb-3 {
            margin-bottom: 1rem;
        }
        
        .mb-4 {
            margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <!-- Header -->
        <div class="login-header">
        </div>
        
        <!-- Body -->
        <div class="login-body">
            <!-- Missatge d'error -->
            <c:if test="${not empty error}">
                <div class="alert" role="alert">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>
            
            <!-- Formulari de login -->
            <form method="post" action="LoginServlet">
                <input type="hidden" name="action" value="login">
                
                <!-- Username -->
                <div class="mb-3">
                    <label for="username" class="form-label">
                        <i class="fas fa-user"></i> Usuari
                    </label>
                    <div class="input-group">
                        <span class="input-group-text">
                            <i class="fas fa-user"></i>
                        </span>
                        <input type="text" 
                               class="form-control" 
                               id="username" 
                               name="username" 
                               placeholder="Introdueix el teu usuari"
                               required
                               autofocus>
                    </div>
                </div>
                
                <!-- Password -->
                <div class="mb-4">
                    <label for="password" class="form-label">
                        <i class="fas fa-lock"></i> Contrasenya
                    </label>
                    <div class="input-group">
                        <span class="input-group-text">
                            <i class="fas fa-lock"></i>
                        </span>
                        <input type="password" 
                               class="form-control" 
                               id="password" 
                               name="password" 
                               placeholder="Introdueix la teva contrasenya"
                               required>
                    </div>
                </div>
                
                <!-- Botó login -->
                <button type="submit" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Iniciar Sessió
                </button>
            </form>
        </div>
        
        <!-- Footer -->
        <div class="login-footer">
            <p class="mb-0">
                <i class="fas fa-info-circle"></i> 
                <strong>Usuari de prova:</strong> admin / admin123
            </p>
            <p class="mb-0 mt-2">
                <small>© 2025 Tallers Manolo - Tots els drets reservats</small>
            </p>
        </div>
    </div>
</div>

</body>
</html>