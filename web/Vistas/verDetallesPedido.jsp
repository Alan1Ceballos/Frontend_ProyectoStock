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

<html>
<head>
    <meta charset="UTF-8">
    <title>Detalles del Pedido</title>
    <link rel="stylesheet" type="text/css" href="Styles/verDetallesPedido.css">
    <script>
        //script de filtrado de tabla
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
                                break; // salimos del bucle si se encuentra una coincidencia
                            }
                        }
                    }
                }

                tr[i].style.display = found ? "" : "none"; // Mostrar o ocultar la fila
            }
        }
    </script>
</head>
<body>
    <header>
        <div class="encabezado">
            <h1>Detalles del Pedido</h1>
            <div class="busqueda-filtros" style="display: flex; align-items: center;">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" placeholder="Buscar..." style="margin-right: 5px;" />
                <label for="filtro" style="margin: 0;">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" style="margin-left: 5px;">
                    <option value="todos">Ninguno</option>
                    <option value="nombre">Nombre</option>
                    <option value="descripcion">Descripción</option>
                    <option value="cantidad">Cantidad</option>
                    <option value="precioventa">Precio Venta</option>
                    <option value="proveedores">Proveedores</option>
                </select>
            </div>
        </div>
    </header>
    <div class="contenido">
        <table id="tablaDetalles" border="1">
            <tr>
                <th>Producto</th>
                <th>Nombre</th>
                <th>Descripción</th>
                <th>Cantidad</th>
                <th>Precio Venta</th>
                <th>Proveedores</th>
            </tr>
            <%
                List<DetallePedido> detalles = (List<DetallePedido>) request.getAttribute("detalles");
                for (DetallePedido detalle : detalles) {
                    //convertimos el byte[] de la imagen a base64
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
                        <img src="data:image/png;base64,<%= imagenBase64 %>" alt="Imagen del producto" style="width: 200px; height: 200px;">
                    <% } else { %>
                        No disponible
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
        </table>
    </div>
    <footer>
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>
</body>
</html>