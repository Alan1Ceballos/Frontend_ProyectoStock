<%-- 
    Document   : home
    Created on : 10 oct 2024, 18:46:06
    Author     : AlanCeballos
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Página Principal</title>
    <link rel="stylesheet" href="Styles/home.css">
</head>
<body>
    <h1>Bienvenido a la página principal</h1>

    <%
        String usuario = (String) session.getAttribute("usuario");
    %>

    <p id="welcome-message">
        <% if (usuario != null) { %>
            ¡Hola, <%= usuario %>! Has iniciado sesión correctamente.
        <% } %>
    </p>

    <form action="historialpedidos" method="GET">
        <button type="submit">Ver Historial de Pedidos</button>
    </form>

    <!-- Enlace para cerrar sesión -->
    <a href="LogoutServlet">Cerrar sesión</a>
</body>
</html>