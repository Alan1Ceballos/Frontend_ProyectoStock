<%@page import="logica.Clases.Categoria"%>
<%@page import="java.util.ArrayList"%>
<%@page import="logica.Clases.Cliente"%>
<%@page import="logica.Clases.Producto"%>
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
                    Sesión iniciada por: <strong><%= usuario %></strong>
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
            <!-- Formulario con AJAX para seleccionar cliente y productos -->
            <form id="formularioCrearPedido" action="crearPedido" method="POST">
                <!-- Selección de cliente -->
                <div class="mb-3">
                    <label for="cliente" class="form-label">Seleccione Cliente:</label>
                    <select name="cliente" id="cliente" class="form-select">
                        <%
                            ArrayList<Cliente> clientes = (ArrayList<Cliente>) request.getAttribute("clientes");
                            ArrayList<Integer> idsClientes = (ArrayList<Integer>) request.getAttribute("idsClientes");
                            if (clientes != null && idsClientes != null) {
                                for (int i = 0; i < clientes.size(); i++) {
                                    Cliente cliente = clientes.get(i);
                                    int clienteId = idsClientes.get(i);
                        %>
                        <option value="<%= clienteId %>"><%= cliente.getIdentificador()%> - <%= cliente.getNom_empresa() %> - <%= cliente.getCorreo_electronico() %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>

                <!-- Selección de productos -->
                <div class="mb-4">
                    <h4>Seleccione Productos:</h4>

                    <!-- Barra de búsqueda y filtro -->
                    <div class="busqueda-filtros d-flex align-items-center mb-3">
                        <input type="text" id="busqueda" onkeyup="filtrarProductos()" class="form-control me-2" placeholder="Buscar...">
                        <label for="filtro" class="me-2">Filtrar por:</label>
                        <select id="filtro" onchange="filtrarProductos()" class="form-select me-2">
                            <option value="todos">Ninguno</option>
                            <option value="nombre">Nombre</option>
                            <option value="descripcion">Descripción</option>
                            <option value="precio">Precio</option>
                        </select>

                        <label for="categoriaFiltro" class="me-2">Categoría:</label>
                        <select id="categoriaFiltro" onchange="filtrarProductos()" class="form-select">
                            <option value="todos">Todas</option>
                            <%
                                ArrayList<Categoria> categorias = (ArrayList<Categoria>) request.getAttribute("categorias");
                                if (categorias != null) {
                                    for (Categoria categoria : categorias) {
                            %>
                            <option value="<%= categoria.getNombre()%>"><%= categoria.getNombre()%></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>

                    <div id="productosContainer" class="d-flex overflow-auto">
                        <%
                            ArrayList<Producto> productos = (ArrayList<Producto>) request.getAttribute("productos");
                            if (productos != null) {
                                for (Producto producto : productos) {
                        %>
                        <div class="product-card me-3" data-categoria="<%= producto.getCategoria().getNombre()%>">
                            <div class="card">
                                <div class="card-body">
                                    <h5 class="card-title"><%= producto.getNombre()%></h5>
                                    <p class="card-text">Descripción: <%= producto.getDescripcion()%></p>
                                    <p class="card-text">Precio: $<span class="product-price" data-id="<%= producto.getId()%>"><%= producto.getPrecioVenta()%></span></p>
                                    <p class="card-text">Categoría: <%= producto.getCategoria().getNombre()%></p>
                                    <input type="number" class="form-control mb-2 product-quantity" data-id="<%= producto.getId()%>" min="1" value="1">
                                    <button type="button" class="btn btn-primary btn-add-cart" data-id="<%= producto.getId()%>">Añadir al Carrito</button>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>

                <!-- Total del Carrito -->
                <div class="mt-4">
                    <h5>Total del Carrito: $<span id="totalCarrito">0.00</span></h5>
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
    </body>
</html>