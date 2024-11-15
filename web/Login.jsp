<%-- 
    Document   : Login
    Created on : 10 oct 2024, 19:10:49
    Author     : AlanCeballos
--%>

<%
    // Verifica si hay una sesión activa
    if (session != null && session.getAttribute("usuario") != null) {
        // Redirige a Home.jsp si el usuario ya está autenticado
        response.sendRedirect("Home.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Inicio de Sesión</title>
    <link rel="stylesheet" href="Styles/login.css">
</head>
<body>
    <div class="contenedor-login">
        <h1>Inicio de Sesión</h1>
        <form id="loginForm" action="login" method="POST"> 
            <label for="usuario">Usuario:</label>
            <input type="text" id="usuario" name="usuario" required>

            <label for="password">Contraseña:</label>
            <input type="password" id="password" name="password" required>

            <input type="submit" value="Iniciar sesión">
        </form>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <p class="error-message"><%= errorMessage %></p>
        <%
            }
        %>
    </div>
</body>
</html>
