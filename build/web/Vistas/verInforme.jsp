<%@page import="com.google.gson.JsonElement"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>

<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String usuario = (String) session.getAttribute("usuario");

    // Obtener los datos enviados desde el servlet
    JsonArray pedidosJson = (JsonArray) request.getAttribute("pedidos");
    JsonArray detallesJson = (JsonArray) request.getAttribute("detalles");
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Informe de Pedidos</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/historialPedidos.css">
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Informe de Pedidos</h1>
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
            <a href="generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>

            <hr>

            <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
        </div>

        <!-- Overlay de oscurecimiento -->
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>
        
        <div class="contenido">
            <!-- Tabla de Pedidos -->
            <div class="text-center mt-4 p-3 border border-dark rounded" style="background-color: #f8f9fa;">
                <h2>Pedidos Hechos</h2>
            </div>

            <table id="tablaPedidos" class="table table-striped table-hover table-bordered mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Fecha</th>
                        <th>Estado</th>
                        <th>Total</th>
                        <th>Cliente</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (pedidosJson != null && pedidosJson.size() > 0) {
                            for (int i = 0; i < pedidosJson.size(); i++) {
                                JsonObject pedido = pedidosJson.get(i).getAsJsonObject();
                                String estadoPedido = pedido.has("estado") && !pedido.get("estado").isJsonNull()
                                        ? pedido.get("estado").getAsString()
                                        : "Desconocido";
                                String nombreCliente = pedido.has("nombreCliente") && !pedido.get("nombreCliente").isJsonNull()
                                        ? pedido.get("nombreCliente").getAsString()
                                        : "Desconocido";
                                double total = pedido.has("total") && !pedido.get("total").isJsonNull()
                                        ? pedido.get("total").getAsDouble()
                                        : 0.0;
                                String fechaPedido = pedido.has("fechaPedido") && !pedido.get("fechaPedido").isJsonNull()
                                        ? pedido.get("fechaPedido").getAsString()
                                        : "Desconocida";

                                // Capitalizar la fecha
                                String fechaCapitalizada = StringUtils.capitalize(fechaPedido.toLowerCase());
                                // Ajustar el estado para mostrarlo correctamente
                                String estadoMostrar = estadoPedido.equalsIgnoreCase("ENTREGADO") ? "Entregado" : estadoPedido;
                    %>
                    <tr>
                        <td><%= pedido.has("identificador") ? pedido.get("identificador").getAsString() : "Desconocido"%></td>
                        <td><%= fechaCapitalizada%></td>
                        <td><%= estadoMostrar%></td>
                        <td>$<%= String.format("%.2f", total)%></td>
                        <td><%= nombreCliente%></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="5" class="text-center">No hay pedidos disponibles.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <!-- Tabla de Productos Vendidos -->
            <div class="text-center mt-4 p-3 border border-dark rounded" style="background-color: #f8f9fa;">
                <h2>Productos Vendidos</h2>
            </div>

            <table id="tablaProductos" class="table table-striped table-hover table-bordered mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th>Producto</th>
                        <th>Nombre</th>
                        <th>Descripción</th>
                        <th>Cantidad</th>
                        <th>Precio Unitario</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        double totalIngresos = 0.0;
                        if (detallesJson != null && detallesJson.size() > 0) {
                            for (int i = 0; i < detallesJson.size(); i++) {
                                JsonObject detalle = detallesJson.get(i).getAsJsonObject();

                                // Manejo seguro del campo "producto" y dentro de él "id", "nombre" y "descripcion"
                                String idProducto = "Desconocido";
                                String nombreProducto = "Desconocido";
                                String descripcion = "Sin descripción";

                                if (detalle.has("producto") && !detalle.get("producto").isJsonNull()) {
                                    JsonObject producto = detalle.getAsJsonObject("producto");

                                    // Manejo seguro del campo "id" dentro de "producto"
                                    if (producto.has("id") && !producto.get("id").isJsonNull()) {
                                        idProducto = producto.get("id").getAsString();
                                    }

                                    // Manejo seguro del campo "nombre" dentro de "producto"
                                    if (producto.has("nombre") && !producto.get("nombre").isJsonNull()) {
                                        nombreProducto = producto.get("nombre").getAsString();
                                    }

                                    // Manejo seguro del campo "descripcion" dentro de "producto"
                                    if (producto.has("descripcion") && !producto.get("descripcion").isJsonNull()) {
                                        descripcion = producto.get("descripcion").getAsString();
                                    }
                                }

                                // Manejo seguro del campo "cantidad"
                                double cantidad = 0.0;
                                if (detalle.has("cantidad") && !detalle.get("cantidad").isJsonNull()) {
                                    JsonElement cantidadElement = detalle.get("cantidad");
                                    if (cantidadElement.isJsonPrimitive()) {
                                        cantidad = cantidadElement.getAsDouble();
                                    }
                                }

                                // Manejo seguro del campo "precio"
                                double precio = 0.0;
                                if (detalle.has("precioVenta") && !detalle.get("precioVenta").isJsonNull()) {
                                    JsonElement precioElement = detalle.get("precioVenta");
                                    if (precioElement.isJsonPrimitive()) {
                                        precio = precioElement.getAsDouble();
                                    }
                                }

                                double subtotal = cantidad * precio;
                                totalIngresos += subtotal;
                    %>
                    <tr>
                        <td><%= idProducto%></td>
                        <td><%= nombreProducto%></td>
                        <td><%= descripcion%></td>
                        <td><%= cantidad%></td>
                        <td>$<%= String.format("%.2f", precio)%></td>
                        <td>$<%= String.format("%.2f", subtotal)%></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="6" class="text-center">No hay productos vendidos disponibles.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>

            </table>

            <!-- Total Ingresos -->
            <div class="text-center mt-4 p-3 border border-dark rounded" style="background-color: #f8f9fa;">
                <h3>Ingresos Generados: $<%= totalIngresos%></h3>
            </div>

            <!-- Botón para Descargar PDF -->
            <div class="descargar-pdf-container text-end mt-4">
                <a href="<%= request.getContextPath()%>/descargarPDF?mes=<%= request.getParameter("mes")%>&anio=<%= request.getParameter("anio")%>&nombreCliente=<%= request.getParameter("nombreCliente")%>&nombreCategoria=<%= request.getParameter("nombreCategoria")%>" 
                   class="btn btn-primary btn-lg shadow-sm text-center">
                    <i class="fas fa-file-pdf me-2"></i> Descargar PDF
                </a>
            </div>

        </div>

        <footer class="text-center mt-4" style="background-color: #212529; color: white; padding: 10px 0;">
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
    </body>
</html>
