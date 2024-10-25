<%-- 
    Document   : verDetallesPedido
    Created on : 23 oct 2024, 21:24:33
    Author     : AlanCeballos
--%>

<%@ page import="java.util.Base64" %>
<%@ page import="java.util.List" %>
<%@ page import="logica.Clases.Pedido" %>
<%@ page import="logica.Clases.DetallePedido" %>
<%@ page import="logica.Clases.Proveedor" %>
<%@ page import="logica.Clases.Producto" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalles del Pedido</title>
    <!-- Incluye Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/verDetallesPedido.css">
    
    <script>
        // Script de filtrado de tabla
        function filtrarTabla() {
            const input = document.getElementById('busqueda');
            const filter = input.value.toLowerCase();
            const filtroSeleccionado = document.getElementById('filtro').value;
            const tabla = document.getElementById("tablaDetalles");
            const tr = tabla.getElementsByTagName("tr");

            for (let i = 1; i < tr.length; i++) { // comenzamos desde 1 para evitar el encabezado
                const tds = tr[i].getElementsByTagName("td");
                let found = false;

                for (let j = 0; j < tds.length; j++) {
                    if (tds[j]) {
                        const textoValor = tds[j].textContent || tds[j].innerText;

                        // Filtramos según la opción seleccionada
                        if (filtroSeleccionado === "todos" || 
                            (filtroSeleccionado === "nombre" && j === 1) ||
                            (filtroSeleccionado === "descripcion" && j === 2) ||
                            (filtroSeleccionado === "cantidad" && j === 3) ||
                            (filtroSeleccionado === "precioventa" && j === 4) ||
                            (filtroSeleccionado === "proveedores" && j === 5)) {
                            if (textoValor.toLowerCase().indexOf(filter) > -1) {
                                found = true;
                                break; // Salimos del bucle si se encuentra una coincidencia
                            }
                        }
                    }
                }

                tr[i].style.display = found ? "" : "none"; // Mostrar u ocultar la fila
            }
        }
    </script>
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
                <option value="descripcion">Descripción</option>
                <option value="cantidad">Cantidad</option>
                <option value="precioventa">Precio Venta</option>
                <option value="proveedores">Proveedores</option>
            </select>
        </div>
    </header>

    <div class="contenido">
        <table id="tablaDetalles" class="table table-striped table-hover table-bordered mx-auto">
            <thead class="table-dark">
                <tr>
                    <th>Producto</th>
                    <th>Nombre</th>
                    <th>Descripción</th>
                    <th>Cantidad</th>
                    <th>Precio Venta</th>
                    <th>Proveedores</th>
                </tr>
            </thead>
            <tbody>
                <%
                    List<DetallePedido> detalles = (List<DetallePedido>) request.getAttribute("detalles");
                    for (DetallePedido detalle : detalles) {
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
                    <td><%= detalle.getCantidad() %></td>
                    <td><%= detalle.getPrecioVenta() %></td>
                    <td><%= proveedoresNombres %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>

    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>

    <!-- Incluye Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
