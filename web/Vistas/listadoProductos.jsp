<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List" %>
<%@page import="logica.Clases.Producto" %>
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

    // Lógica para obtener todos los productos de la base de datos
    List<Producto> productos = (List<Producto>) request.getAttribute("productos");

    // Verificar si productos es null
    if (productos == null) {
        productos = new ArrayList<>(); // Iniciar como lista vacía si es null
    }

    // Calcular el índice de inicio y fin para la paginación
    int totalProductos = productos.size();
    int totalPaginas = (int) Math.ceil((double) totalProductos / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalProductos);

    // Filtrar la lista de productos para mostrar solo la página actual
    List<Producto> productosPagina = productos.subList(inicio, fin);

    String usuario = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Listado de Productos</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/listadoClientes.css">
        <script src="Scripts/listadoProductos.js"></script>
    </head>

    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="busqueda-filtros d-flex align-items-center">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
                <label for="filtro" class="me-2">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" class="form-select">
                    <option value="ninguno">Ninguno</option>
                    <option value="nombre">Nombre</option>
                    <option value="descripcion">Descripción</option>
                    <option value="SKU">SKU</option>
                    <option value="precio">Precio de Venta</option>
                    <option value="stock">Stock</option>
                </select>
            </div>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Listado de Productos</h1>
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
            <a href="listadoProductos" class="active"><span class="material-icons">inventory</span> Listado de Productos</a>
            <a href="generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>

            <hr>

            <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
        </div>

        <!-- Overlay de oscurecimiento -->
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>

        <div class="contenido">
            <%
                if (productosPagina != null && !productosPagina.isEmpty()) {
            %>
            <table id="tablaProductos" class="table table-striped table-hover mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th onclick="ordenarTabla(0)">Nombre <span id="iconoOrden0"></span></th>
                        <th onclick="ordenarTabla(1)">Descripción <span id="iconoOrden1"></span></th>
                        <th onclick="ordenarTabla(2)">SKU <span id="iconoOrden2"></span></th>
                        <th onclick="ordenarTabla(3)">Precio de Venta <span id="iconoOrden3"></span></th>
                        <th onclick="ordenarTabla(4)">Stock <span id="iconoOrden4"></span></th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Producto producto : productosPagina) {
                    %>
                    <tr>
                        <td><%= producto.getNombre()%></td>
                        <td><%= producto.getDescripcion()%></td>
                        <td><%= producto.getSKU()%></td>
                        <td>$<%= String.format("%.2f", producto.getPrecioVenta())%></td>
                        <td><%= producto.getStock()%></td>
                    </tr>

                    <%
                        }
                    %>
                </tbody>
            </table>
            <%
            } else {
            %>
            <p class="text-center text-warning">No hay productos registrados.</p>
            <%
                }
            %>
        </div>
        <div class="d-flex justify-content-center align-items-center pagination">
            <%
                int rango = 1;
                int inicioPaginas = Math.max(1, paginaActual - rango);
                int finPaginas = Math.min(totalPaginas, paginaActual + rango);

                if (inicioPaginas > 1) {
            %>
            <a href="listadoProductos?page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
            <span class="mx-1">...</span>
            <%
                }

                for (int i = inicioPaginas; i <= finPaginas; i++) {
                    String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary";
            %>
            <a href="listadoProductos?page=<%= i%>" class="btn <%= activeClass%> btn-sm mx-1"><%= i%></a>
            <%
                }

                if (finPaginas < totalPaginas) {
            %>
            <span class="mx-1">...</span>
            <a href="listadoProductos?page=<%= totalPaginas%>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas%></a>
            <%
                }
            %>
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
