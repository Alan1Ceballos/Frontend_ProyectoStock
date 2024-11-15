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
        <link rel="stylesheet" type="text/css" href="Styles/home.css">
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <a href="LogoutServlet" class="btn btn-light">Cerrar Sesión</a>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Página Principal</h1>
                <p id="session-info" class="mb-0">
                    Sesión iniciada por: <strong><%= usuario%></strong>
                </p>
            </div>
        </header>

        <!-- Contenido principal -->
        <div class="contenido d-flex justify-content-center align-items-center vh-100">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="card" data-icon="pedido">
                            <div class="card-body">
                                <h5 class="card-title">Crear Pedido</h5>
                                <p class="card-text">Accede a la sección para crear un nuevo pedido.</p>
                                <a href="crearPedido" class="btn btn-primary">Ir a Crear Pedido</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-4">
                        <div class="card" data-icon="historial">
                            <div class="card-body">
                                <h5 class="card-title">Historial de Pedidos</h5>
                                <p class="card-text">Consulta el historial de pedidos realizados.</p>
                                <a href="historialpedidos" class="btn btn-primary">Ir a Historial</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-4">
                        <div class="card" data-icon="clientes">
                            <div class="card-body">
                                <h5 class="card-title">Listado de Clientes</h5>
                                <p class="card-text">Visualiza la lista de clientes registrados.</p>
                                <a href="clientes" class="btn btn-primary">Ir a Clientes</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-4">
                        <div class="card" data-icon="productos">
                            <div class="card-body">
                                <h5 class="card-title">Listado de Productos</h5>
                                <p class="card-text">Consulta la lista de productos disponibles.</p>
                                <a href="listadoProductos" class="btn btn-primary">Ir a Productos</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 mb-4">
                        <div class="card" data-icon="informe">
                            <div class="card-body">
                                <h5 class="card-title">Generar Informe</h5>
                                <p class="card-text">Crea informes en tus pedidos usando parámetros.</p>
                                <a href="generarInforme" class="btn btn-primary">Ir a Generar Informe</a>
                            </div>
                        </div>
                    </div>
                </div>
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
