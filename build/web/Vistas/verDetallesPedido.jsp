<%@ page import="java.util.Base64" %>
<%@ page import="java.util.List" %>
<%@ page import="logica.Clases.Pedido" %>
<%@ page import="logica.Clases.DetallePedido" %>
<%@ page import="logica.Clases.Proveedor" %>
<%@ page import="logica.Clases.Producto" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Verifica si hay una sesi�n activa
    if (session == null || session.getAttribute("usuario") == null) {
        // Redirige a Login.jsp si el usuario no est� autenticado
        response.sendRedirect("Login.jsp");
        return;
    }

    // Obtener el n�mero de p�gina desde los par�metros de la solicitud
    String pageParam = request.getParameter("page");
    int paginaActual = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int filasPorPagina = 10;

    // Obtener la lista de detalles
    List<DetallePedido> detalles = (List<DetallePedido>) request.getAttribute("detalles");
    if (detalles == null) {
        detalles = new ArrayList<>(); // Iniciar como lista vac�a si es null
    }

    // Inicializa el total del pedido
    double totalPedido = 0; // Inicializa la variable total

    // Calcular el total de todos los detalles (sin paginaci�n)
    for (DetallePedido detalle : detalles) {
        double cantidad = detalle.getCantidad();
        double precioUnitario = detalle.getPrecioVenta();
        double subtotal = cantidad * precioUnitario; // Calcular subtotal
        totalPedido += subtotal; // Sumar al total del pedido
    }

    // Calcular el �ndice de inicio y fin para la paginaci�n
    int totalDetalles = detalles.size();
    int totalPaginas = (int) Math.ceil((double) totalDetalles / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalDetalles);

    // Filtrar la lista de detalles para mostrar solo la p�gina actual
    List<DetallePedido> detallesPagina = detalles.subList(inicio, fin);
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalles del Pedido</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/verDetallesPedido.css">
    <script src="Scripts/verDetallesPedido.js"></script>
</head>
<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Detalles del Pedido</h1>
        </div>
        <div class="busqueda-filtros d-flex">
            <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
            <label for="filtro" class="me-2 my-auto">Filtros:</label>
            <select id="filtro" onchange="filtrarTabla()" class="form-select my-auto">
                <option value="todos">Ninguno</option>
                <option value="nombre">Nombre</option>
                <option value="descripcion">Descripci�n</option>
                <option value="cantidad">Cantidad</option>
                <option value="precioventa">Precio Unitario</option>
                <option value="subtotal">Subtotal</option>
                <option value="proveedores">Proveedores</option>
            </select>
        </div>
    </header>

    <div class="contenido">
        <table id="tablaDetalles" class="table table-striped table-hover table-bordered mx-auto">
            <thead class="table-dark">
                <tr>
                    <th>Producto</th>
                    <th onclick="ordenarTabla(1)">Nombre <span id="iconoOrden1"></span></th>
                    <th onclick="ordenarTabla(2)">Descripci�n <span id="iconoOrden2"></span></th>
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
                        // Eliminar la �ltima coma y espacio
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
                        <% if (!imagenBase64.isEmpty()) { %>
                            <img src="data:image/png;base64,<%= imagenBase64 %>" alt="Imagen del producto" class="img-thumbnail" style="width: 150px; height: 150px;">
                        <% } else { %>
                            <span class="text-muted">No disponible</span>
                        <% } %>
                    </td>
                    <td><%= detalle.getProducto().getNombre() %></td>
                    <td><%= detalle.getProducto().getDescripcion() %></td>
                    <td><%= cantidad %></td>
                    <td><%= precioUnitario %></td>
                    <td><%= subtotal %></td>
                    <td><%= proveedoresNombres %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
    </div>
    <!-- Paginaci�n -->
    <div class="d-flex justify-content-center align-items-center pagination">
        <%
            // Rango de p�ginas a mostrar
            int rango = 1; // N�mero de p�ginas a mostrar a cada lado de la actual
            int inicioPaginas = Math.max(1, paginaActual - rango); // Primera p�gina a mostrar
            int finPaginas = Math.min(totalPaginas, paginaActual + rango); // �ltima p�gina a mostrar
            int idPedido = request.getParameter("idPedido") != null ? Integer.parseInt(request.getParameter("idPedido")) : 0; // Obtener el idPedido

            // Mostrar indicador de p�ginas previas
            if (inicioPaginas > 1) {
        %>
            <a href="verdetalles?idPedido=<%= idPedido %>&page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
            <span class="mx-1">...</span>
        <%
            }

            // Mostrar las p�ginas en el rango
            for (int i = inicioPaginas; i <= finPaginas; i++) {
                // Verifica si el bot�n es el de la p�gina actual
                String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary"; // Cambiar la clase del bot�n
        %>
                <a href="verdetalles?idPedido=<%= idPedido %>&page=<%= i %>" class="btn <%= activeClass %> btn-sm mx-1"><%= i %></a>
        <%
            }

            // Mostrar indicador de p�ginas posteriores
            if (finPaginas < totalPaginas) {
        %>
            <span class="mx-1">...</span>
            <a href="verdetalles?idPedido=<%= idPedido %>&page=<%= totalPaginas %>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas %></a>
        <%
            }
        %>
    </div>

    <!-- Cuadro que muestra el total del pedido -->
    <div class="alert alert-info text-center mt-4">
        <strong>Total del Pedido: </strong><span id="totalPedido"><%= totalPedido %></span>
    </div>
    
    <footer class="text-center mt-4">
        <p>&copy; 2024 Programaci�n de Aplicaciones</p>
    </footer>

    <!-- Incluye Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
