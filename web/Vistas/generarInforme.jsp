<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Generar Informe de Ventas</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/generarInforme.css">
    </head>
    <body>

        <%-- Verificar si hay sesión activa --%>
        <%
            if (session == null || session.getAttribute("usuario") == null) {
                response.sendRedirect("Login.jsp");
                return;
            }
            String usuario = (String) session.getAttribute("usuario");
        %>

        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Generar Informe</h1>
                <p id="session-info" class="mb-0">Sesión iniciada por: <strong><%= usuario%></strong></p>
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
            <a href="generarInforme" class="active"><span class="material-icons">insert_chart</span> Generar Informe</a>

            <hr>

            <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
        </div>

        <!-- Overlay de oscurecimiento -->
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>

        <div class="contenido">
            <form action="verInforme" method="POST">
                <div class="mb-4">
                    <h3 class="text-center border-bottom">Seleccione un mes</h3>
                    <div class="col-md-12 mb-3">
                        <select name="mes" id="mes" class="form-select" required>
                            <option value="">Seleccione un mes</option>
                            <option value="01">Enero</option>
                            <option value="02">Febrero</option>
                            <option value="03">Marzo</option>
                            <option value="04">Abril</option>
                            <option value="05">Mayo</option>
                            <option value="06">Junio</option>
                            <option value="07">Julio</option>
                            <option value="08">Agosto</option>
                            <option value="09">Septiembre</option>
                            <option value="10">Octubre</option>
                            <option value="11">Noviembre</option>
                            <option value="12">Diciembre</option>
                        </select>
                    </div>
                </div>

                <div class="mb-4">
                    <h3 class="text-center border-bottom">Seleccione el año</h3>
                    <div class="col-md-12">
                        <select name="anio" id="anio" class="form-select" required>
                            <option value="">Seleccione un año</option>
                            <%
                                for (int year = 2000; year <= 2100; year++) {
                            %>
                            <option value="<%= year%>"><%= year%></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                </div>

                <div class="mb-4">
                    <h3 class="text-center border-bottom">Seleccione un Cliente</h3>
                    <div class="col-md-12 mb-3">
                        <select name="nombreCliente" id="cliente" class="form-select">
                            <option value="">Seleccione un cliente</option>
                            <%
                                JsonArray clientes = (JsonArray) request.getAttribute("clientes");
                                for (int i = 0; i < clientes.size(); i++) {
                                    JsonObject cliente = clientes.get(i).getAsJsonObject();
                                    String nombre = cliente.get("nom_empresa").getAsString();
                            %>
                            <option value="<%= nombre%>"><%= nombre%></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                </div>

                <div class="mb-4">
                    <h3 class="text-center border-bottom">Seleccione una Categoría</h3>
                    <div class="col-md-12 mb-3">
                        <select name="nombreCategoria" id="categoria" class="form-select">
                            <option value="">Seleccione una categoría</option>
                            <%
                                JsonArray categorias = (JsonArray) request.getAttribute("categorias");
                                for (int i = 0; i < categorias.size(); i++) {
                                    JsonObject categoria = categorias.get(i).getAsJsonObject();
                                    String nombreCategoria = categoria.get("nombre").getAsString();
                            %>
                            <option value="<%= nombreCategoria%>"><%= nombreCategoria%></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                </div>

                <div class="text-center">
                    <button type="submit" class="btn btn-primary">Generar Informe</button>
                </div>
            </form>
        </div>

        <footer>
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
