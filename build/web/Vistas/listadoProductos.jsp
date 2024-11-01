<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List" %>
<%@page import="logica.Clases.Producto" %>
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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Listado de Productos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/listadoClientes.css">
    <script src="Scripts/listadoProductos.js"></script>
</head>

<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Listado de Productos</h1>
        </div>
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
    </header>

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
                            <td><%= producto.getNombre() %></td>
                            <td><%= producto.getDescripcion() %></td>
                            <td><%= producto.getSKU() %></td>
                            <td><%= producto.getPrecioVenta() %></td>
                            <td><%= producto.getStock() %></td>
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
                        <a href="listadoProductos?page=<%= i %>" class="btn <%= activeClass %> btn-sm mx-1"><%= i %></a>
                <%
                    }

                    if (finPaginas < totalPaginas) {
                %>
                    <span class="mx-1">...</span>
                    <a href="listadoProductos?page=<%= totalPaginas %>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas %></a>
                <%
                    }
                %>
            </div>

    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
