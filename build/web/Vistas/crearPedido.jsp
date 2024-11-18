<%@page import="com.google.gson.JsonObject"%>
<%@page import="com.google.gson.JsonArray"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
    String usuario = (String) session.getAttribute("usuario");
    JsonArray clientes = (JsonArray) request.getAttribute("clientes");
    JsonArray productos = (JsonArray) request.getAttribute("productos");
    JsonArray categorias = (JsonArray) request.getAttribute("categorias");
%>


<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Nuevo Pedido</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet"> 
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/crearPedido.css">
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Crear Pedido</h1>
                <p id="session-info" class="mb-0">
                    Sesión iniciada por: <strong><%= usuario%></strong>
                </p>
            </div>
        </header>

        <!-- Menú lateral -->
        <div id="sidebar" class="sidebar">
            <a href="javascript:void(0)" class="closebtn" onclick="closeMenu()">☰ Cerrar</a>
            <a href="Home.jsp"><span class="material-icons">home</span> Inicio</a>
            <a href="crearPedido" class="active"><span class="material-icons">shopping_cart</span> Crear Pedido</a>
            <a href="historialpedidos"><span class="material-icons">history</span> Historial de Pedidos</a>
            <a href="clientes"><span class="material-icons">people</span> Listado de Clientes</a>
            <a href="listadoProductos"><span class="material-icons">inventory</span> Listado de Productos</a>
            <a href="generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>

            <hr>

            <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
        </div>

        <!-- Overlay de oscurecimiento -->
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>

        <div class="container mt-4">

            <!-- Sección de búsqueda de productos -->
            <div class="form-group mb-3">
                <label for="buscarPorSKU">Buscar Producto por SKU:</label>
                <input type="text" id="buscarPorSKU" class="form-control" placeholder="Ingrese SKU">
            </div>
            <div class="form-group mb-3">
                <label for="buscarPorNombre">Buscar Producto por Nombre:</label>
                <input type="text" id="buscarPorNombre" class="form-control" placeholder="Ingrese Nombre">
            </div>

            <!-- Botón de búsqueda -->
            <button type="button" id="btnBuscarProducto" class="btn btn-primary">Buscar Producto</button>

            <!-- Contenedor para mostrar los resultados -->
            <div id="resultadoBusqueda"></div><br><br>


            <!-- Formulario con AJAX para seleccionar cliente y productos -->
            <form id="formularioCrearPedido" action="crearPedido" method="POST">
                <!-- Selección de cliente -->
                <div class="mb-3">
                    <label for="cliente" class="form-label">Seleccione Cliente:</label>
                    <select name="cliente" id="cliente" class="form-select">
                        <option value="">Seleccionar un cliente</option>
                        <%
                            if (clientes != null) {
                                for (int i = 0; i < clientes.size(); i++) {
                                    JsonObject cliente = clientes.get(i).getAsJsonObject();
                                    String id = cliente.get("identificador").getAsString();
                                    String nombre = cliente.get("nom_empresa").getAsString();
                                    String email = cliente.get("correo_electronico").getAsString();
                        %>
                        <option value="<%= id%>"><%= nombre%> - <%= email%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>


                <!-- Selección de Categoría -->
                <div class="form-group mb-3">
                    <label for="selectCategoria">Selecciona una Categoría:</label>
                    <select id="selectCategoria" name="categoriaSeleccionada" class="form-control" onchange="cargarProductos(this.value)">
                        <option value="">Seleccionar una categoria</option>
                        <%
                            if (categorias != null) {
                                for (int i = 0; i < categorias.size(); i++) {
                                    JsonObject categoria = categorias.get(i).getAsJsonObject();
                                    String categoriaId = categoria.get("id").getAsString();
                                    String categoriaNombre = categoria.get("nombre").getAsString();
                        %>
                        <option value="<%= categoriaId%>"><%= categoriaNombre%></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>


                <!-- Selección de Producto -->
                <div class="form-group mb-3">
                    <label for="selectProducto">Selecciona un Producto:</label>
                    <select id="selectProducto" class="form-control" name="idProducto">
                        <option value="">Seleccionar un producto</option>
                        <%
                            if (productos != null) {
                                for (int i = 0; i < productos.size(); i++) {
                                    JsonObject producto = productos.get(i).getAsJsonObject();
                                    String productoId = producto.get("id").getAsString();
                                    String nombreProducto = producto.get("nombre").getAsString();
                                    String precio = producto.get("precioVenta").getAsString();
                                    String categoriaId = producto.getAsJsonObject("categoria").get("id").getAsString();
                        %>
                        <option value="<%= productoId%>" data-precio="<%= precio%>" data-categoria="<%= categoriaId%>">
                            <%= nombreProducto%>
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>



                <!-- Selección de Cantidad -->
                <div class="form-group mb-3">
                    <label for="cantidadProducto">Cantidad:</label>
                    <input type="number" id="cantidadProducto" name="cantidadProducto" class="form-control" min="1" placeholder="Ingrese la cantidad">
                </div>

                <!-- Botón Agregar Producto -->
                <button type="button" class="btn btn-primary btn-add-cart" data-id="">Añadir al carrito</button>

                <!-- Total del Carrito -->
                <div class="mt-4">
                    <h5>Total del Carrito: <span id="totalCarrito">0.00</span></h5>
                    <a id="verCarrito" href="verCarrito" class="btn btn-success">Ver Carrito</a>
                    <button type="button" class="btn btn-danger" id="limpiarCarrito">Limpiar Carrito</button>
                </div>
            </form>
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

        <!-- Bootstrap JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="Scripts/crearPedido.js"></script>
        <!-- Incluir SweetAlert2 desde CDN -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </body>
</html>