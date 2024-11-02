<%-- 
    Document   : Home
    Created on : 24 oct 2024, 20:55:43
    Author     : AlanCeballos
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        // Redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
    String usuario = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Página Principal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/Home.css">
</head>
<body>
     <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
        <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
        <div class="encabezado">
            <h1 class="mb-1 text-decoration-underline">Página Principal</h1>
            <p id="session-info" class="mb-0">
                Sesión iniciada por: <strong><%= usuario %></strong>
            </p>
        </div>
    </header>

    <!-- Menú lateral -->
    <div id="sidebar" class="sidebar">
        <a href="javascript:void(0)" class="closebtn" onclick="closeMenu()">☰ Cerrar</a>
        <a href="Home.jsp" class="active"><span class="material-icons">home</span> Inicio</a>
        <a href="crearPedido"><span class="material-icons">shopping_cart</span> Crear Pedido</a>
        <a href="historialpedidos"><span class="material-icons">history</span> Historial de Pedidos</a>
        <a href="clientes"><span class="material-icons">people</span> Listado de Clientes</a>
        <a href="listadoProductos"><span class="material-icons">inventory</span> Listado de Productos</a>
        <a href="generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>
        
        <hr>
        
        <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
    </div>

    <!-- Overlay de oscurecimiento -->
    <div id="overlay" class="overlay" onclick="closeMenu()"></div>

    <!-- Contenido principal -->
    <div class="contenido d-flex justify-content-center align-items-center vh-100">
        <div class="row justify-content-center mt-4">
            <h2>Bienvenido a la Página Principal</h2>
            <p>Utiliza el menú lateral para navegar por las diferentes secciones.</p>
        </div>
    </div>

    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>
    <script>
        function openMenu() {
            document.getElementById("sidebar").style.width = "250px";
            document.getElementById("overlay").style.display = "block";
        }
        function closeMenu() {
            document.getElementById("sidebar").style.width = "0";
            document.getElementById("overlay").style.display = "none";
        }
    </script>
</body>
</html>
