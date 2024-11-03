<%@ page import="java.util.Base64" %>
<%@ page import="java.util.List" %>
<%@ page import="logica.Clases.Pedido" %>
<%@ page import="logica.Clases.DetallePedido" %>
<%@ page import="logica.Clases.Proveedor" %>
<%@ page import="logica.Clases.Producto" %>
<%@ page import="java.util.ArrayList" %>
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

    // Obtener la lista de detalles
    List<DetallePedido> detalles = (List<DetallePedido>) request.getAttribute("detalles");
    if (detalles == null) {
        detalles = new ArrayList<>(); // Iniciar como lista vacía si es null
    }

    // Inicializa el total del pedido
    double totalPedido = 0; // Inicializa la variable total

    // Calcular el total de todos los detalles (sin paginación)
    for (DetallePedido detalle : detalles) {
        double cantidad = detalle.getCantidad();
        double precioUnitario = detalle.getPrecioVenta();
        double subtotal = cantidad * precioUnitario; // Calcular subtotal
        totalPedido += subtotal; // Sumar al total del pedido
    }

    // Calcular el índice de inicio y fin para la paginación
    int totalDetalles = detalles.size();
    int totalPaginas = (int) Math.ceil((double) totalDetalles / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalDetalles);

    // Filtrar la lista de detalles para mostrar solo la página actual
    List<DetallePedido> detallesPagina = detalles.subList(inicio, fin);

    String usuario = (String) session.getAttribute("usuario");
    Pedido pedido = (Pedido) request.getAttribute("pedido");
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
            <!-- Dropdown de Acceso Rápido -->
            <div class="dropdown mx-2 ms-auto">
                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-expanded="false">
                    Accesos Rápido
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButton">
                    <!-- Formulario para modificar pedido -->
                    <li>
                        <form action="${pageContext.request.contextPath}/Vistas/modificarPedido.jsp" method="post" style="margin: 0;">
                            <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador()%>">
                            <button type="submit" class="dropdown-item">Modificar Pedido</button>
                        </form>
                    </li>
                    <li>
                        <form action="${pageContext.request.contextPath}/generarInformeProductos" method="post" style="margin: 0;">
                            <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador()%>">
                            <button type="submit" class="dropdown-item">Generar Informe</button>
                        </form>
                    </li>
                </ul>
            </div>


            <table id="tablaDetalles" class="table table-striped table-hover table-bordered mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th>Producto</th>
                        <th onclick="ordenarTabla(1)">Nombre <span id="iconoOrden1"></span></th>
                        <th onclick="ordenarTabla(2)">Descripción <span id="iconoOrden2"></span></th>
                        <th onclick="ordenarTabla(3)">Cantidad <span id="iconoOrden3"></span></th>
                        <th onclick="ordenarTabla(4)">Precio Unitario <span id="iconoOrden4"></span></th>
                        <th onclick="ordenarTabla(5)">Subtotal <span id="iconoOrden5"></span></th>
                        <th onclick="ordenarTabla(6)">Proveedores <span id="iconoOrden6"></span></th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (DetallePedido detalle : detallesPagina) {
                            // Convertimos el byte[] de la imagen a base64
                            byte[] imagenProducto = detalle.getProducto().getImagen();
                            String imagenBase64 = "";
                            if (imagenProducto != null && imagenProducto.length > 0) {
                                imagenBase64 = Base64.getEncoder().encodeToString(imagenProducto);
                            }

                            String proveedoresNombres = "";
                            List<Proveedor> proveedores = detalle.getProveedores();
                            for (Proveedor proveedor : proveedores) {
                                proveedoresNombres += proveedor.getNombre() + ", ";
                            }
                            // Eliminar la última coma y espacio
                            if (!proveedoresNombres.isEmpty()) {
                                proveedoresNombres = proveedoresNombres.substring(0, proveedoresNombres.length() - 2);
                            }

                            // Calcular el subtotal
                            double cantidad = detalle.getCantidad();
                            double precioUnitario = detalle.getPrecioVenta();
                            double subtotal = cantidad * precioUnitario; // Calcular subtotal
                    %>
                    <tr>
                        <td>
                            <% if (!imagenBase64.isEmpty()) {%>
                            <img src="data:image/png;base64,<%= imagenBase64%>" alt="Imagen del producto" class="img-thumbnail" style="width: 150px; height: 150px;">
                            <% } else { %>
                            <span class="text-muted">No disponible</span>
                            <% }%>
                        </td>
                        <td><%= detalle.getProducto().getNombre()%></td>
                        <td><%= detalle.getProducto().getDescripcion()%></td>
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
