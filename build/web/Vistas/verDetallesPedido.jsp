<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.List" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        // Redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }

    // Obtener el número de página desde los parámetros de la solicitud
    String pageParam = request.getParameter("page");
    int paginaActual = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int filasPorPagina = 10;

    // Obtener el parámetro "detalles" como un JsonArray
    JsonArray detallesArray = (JsonArray) request.getAttribute("detalles");
    if (detallesArray == null) {
        detallesArray = new JsonArray(); // Inicializar como un JsonArray vacío si es null
    }

    // Inicializa el total del pedido
    double totalPedido = 0;

    // Calcular el total de todos los detalles (sin paginación)
    for (int i = 0; i < detallesArray.size(); i++) {
        JsonObject detalle = detallesArray.get(i).getAsJsonObject();

        double cantidad = detalle.has("cantidad") && !detalle.get("cantidad").isJsonNull() ? detalle.get("cantidad").getAsDouble() : 0;
        double precioUnitario = detalle.has("precioVenta") && !detalle.get("precioVenta").isJsonNull() ? detalle.get("precioVenta").getAsDouble() : 0;
        double subtotal = cantidad * precioUnitario;
        totalPedido += subtotal;
    }

    // Calcular el índice de inicio y fin para la paginación
    int totalDetalles = detallesArray.size();
    int totalPaginas = (int) Math.ceil((double) totalDetalles / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalDetalles);

    String usuario = (String) session.getAttribute("usuario");
    int pedido = (int) request.getAttribute("pedido");
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Detalles del Pedido</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/verDetallesPedido.css">
        <script src="Scripts/verDetallesPedido.js"></script>
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <!-- Boton del menu lateral -->
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <!-- Barra de busqueda y Filtros -->
            <div class="busqueda-filtros d-flex">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
                <label for="filtro" class="me-2 my-auto">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" class="form-select my-auto">
                    <option value="todos">Ninguno</option>
                    <option value="nombre">Nombre</option>
                    <option value="descripcion">Descripción</option>
                    <option value="cantidad">Cantidad</option>
                    <option value="precioventa">Precio Unitario</option>
                    <option value="subtotal">Subtotal</option>
                    <option value="proveedores">Proveedores</option>
                </select>
            </div>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Detalles del Pedido</h1>
                <p id="session-info" class="mb-0">
                    Sesión iniciada por: <strong><%= usuario%></strong>
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

        <div class="contenido">
            <%-- Dropdown de Acceso Rápido --%>
            <div class="dropdown mx-2 ms-auto">
                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false">
                    Accesos Rápido
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButton">
                    <!-- Formulario para modificar pedido -->
                    <li>
                        <form action="${pageContext.request.contextPath}/actualizarPedido" method="get" style="margin: 0;">
                            <input type="hidden" name="idPedido" value="<%= pedido%>">
                            <button type="submit" class="dropdown-item">Modificar Pedido</button>
                        </form>
                    </li>
                    <li>
                        <form action="${pageContext.request.contextPath}/generarBoleta" method="get" style="margin: 0;">
                            <input type="hidden" name="idPedido" value="<%= pedido%>">
                            <button type="submit" class="dropdown-item">Generar Informe</button>
                        </form>

                    </li>
                </ul>
            </div>


            <table id="tablaDetalles" class="table table-striped table-hover table-bordered mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th>Producto</th>
                        <th>Nombre</th>
                        <th>Descripción</th>
                        <th>Cantidad</th>
                        <th>Precio Unitario</th>
                        <th>Subtotal</th>
                        <th>Proveedores</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (int i = inicio; i < fin; i++) {
                            JsonObject detalle = detallesArray.get(i).getAsJsonObject();

                            // Datos del producto con verificación
                            JsonObject producto = detalle.getAsJsonObject("producto");
                            String nombre = (producto.has("nombre") && !producto.get("nombre").isJsonNull()) ? producto.get("nombre").getAsString() : "N/A";
                            String descripcion = (producto.has("descripcion") && !producto.get("descripcion").isJsonNull()) ? producto.get("descripcion").getAsString() : "N/A";
                            double cantidad = (detalle.has("cantidad") && !detalle.get("cantidad").isJsonNull()) ? detalle.get("cantidad").getAsDouble() : 0;
                            double precioUnitario = (detalle.has("precioVenta") && !detalle.get("precioVenta").isJsonNull()) ? detalle.get("precioVenta").getAsDouble() : 0;
                            double subtotal = cantidad * precioUnitario;

                            // Procesar imagen si está presente
                            String imagenBase64 = (producto.has("imagen") && !producto.get("imagen").isJsonNull()) ? producto.get("imagen").getAsString() : "";

                            // Obtener proveedores desde un JsonArray en el detalle, con manejo de tipo adecuado
                            JsonArray proveedoresArray = (detalle.has("proveedores") && !detalle.get("proveedores").isJsonNull()) ? detalle.getAsJsonArray("proveedores") : new JsonArray();
                            String proveedoresNombres = "";
                            for (int j = 0; j < proveedoresArray.size(); j++) {
                                JsonObject proveedorObj = proveedoresArray.get(j).getAsJsonObject();
                                String proveedorNombre = (proveedorObj.has("nombre") && !proveedorObj.get("nombre").isJsonNull()) ? proveedorObj.get("nombre").getAsString() : "Desconocido";
                                proveedoresNombres += proveedorNombre + ", ";
                            }
                            if (!proveedoresNombres.isEmpty()) {
                                proveedoresNombres = proveedoresNombres.substring(0, proveedoresNombres.length() - 2); // Eliminar la última coma
                            }
                    %>
                    <tr>
                        <td>
                            <% if (!imagenBase64.isEmpty()) {%>
                            <img src="data:image/png;base64,<%= imagenBase64%>" alt="Imagen del producto" class="img-thumbnail" style="width: 150px; height: 150px;">
                            <% } else { %>
                            <span class="text-muted">No disponible</span>
                            <% }%>
                        </td>
                        <td><%= nombre%></td>
                        <td><%= descripcion%></td>
                        <td><%= cantidad%></td>
                        <td>$<%= String.format("%.2f", precioUnitario)%></td>
                        <td>$<%= String.format("%.2f", subtotal)%></td>
                        <td><%= proveedoresNombres%></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>


        </div>
        <!-- Paginación -->
        <div class="d-flex justify-content-center align-items-center pagination">
            <%
                // Rango de páginas a mostrar
                int rango = 1; // Número de páginas a mostrar a cada lado de la actual
                int inicioPaginas = Math.max(1, paginaActual - rango); // Primera página a mostrar
                int finPaginas = Math.min(totalPaginas, paginaActual + rango); // Última página a mostrar
                int idPedido = request.getParameter("idPedido") != null ? Integer.parseInt(request.getParameter("idPedido")) : 0; // Obtener el idPedido

                // Mostrar indicador de páginas previas
                if (inicioPaginas > 1) {
            %>
            <a href="verdetalles?idPedido=<%= idPedido%>&page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
            <span class="mx-1">...</span>
            <%
                }

                // Mostrar las páginas en el rango
                for (int i = inicioPaginas; i <= finPaginas; i++) {
                    // Verifica si el botón es el de la página actual
                    String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary"; // Cambiar la clase del botón
%>
            <a href="verdetalles?idPedido=<%= idPedido%>&page=<%= i%>" class="btn <%= activeClass%> btn-sm mx-1"><%= i%></a>
            <%
                }

                // Mostrar indicador de páginas posteriores
                if (finPaginas < totalPaginas) {
            %>
            <span class="mx-1">...</span>
            <a href="verdetalles?idPedido=<%= idPedido%>&page=<%= totalPaginas%>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas%></a>
            <%
                }
            %>
        </div>

        <!-- Cuadro que muestra el total del pedido -->
        <div class="alert alert-info text-center mt-4">
            <strong>Total del Pedido: </strong><span id="totalPedido"><%= totalPedido%></span>
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
        <!-- Incluye Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
