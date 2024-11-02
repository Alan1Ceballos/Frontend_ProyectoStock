<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
    String usuario = (String) session.getAttribute("usuario");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ver Carrito</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/verCarrito.css">
</head>
<body>
    <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
        <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
        <div class="encabezado">
            <h1 class="mb-1 text-decoration-underline">Carrito de Compras</h1>
            <p id="session-info" class="mb-0">
                Sesión iniciada por: <strong><%= usuario %></strong>
            </p>
        </div>
    </header>
            
    <!-- Menú lateral -->
    <div id="sidebar" class="sidebar">
        <a href="javascript:void(0)" class="closebtn" onclick="closeMenu()">☰ Cerrar</a>
        <a href="Home.jsp"><span class="material-icons">home</span> Inicio</a>
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

    <div class="container mt-4 flex-grow-1">
        <div id="carritoContainer" class="row">
            <!-- Aquí se llenarán las cartas de productos con JavaScript -->
        </div>

        <div class="mt-4">
            <h5>Total del Carrito: $<span id="carritoTotal">0.00</span></h5>
            <button class="btn btn-danger" id="limpiarCarrito">Limpiar Carrito</button>
            <button class="btn btn-success" id="confirmarPedido">Confirmar Pedido</button>
            <a href="crearPedido" class="btn btn-secondary">Regresar</a>
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

    <script src="Scripts/verCarrito.js"></script>
    <!-- Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>