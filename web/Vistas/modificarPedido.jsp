<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.google.gson.JsonArray"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="java.util.Iterator"%>

<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        // Redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }

    String usuario = (String) session.getAttribute("usuario");

    // Recupera los datos JSON pasados desde el servlet
    JsonObject pedidoJson = (JsonObject) request.getAttribute("pedido");
    JsonArray categoriasJson = (JsonArray) request.getAttribute("categorias");
    JsonArray productosJson = (JsonArray) request.getAttribute("productos");
    JsonArray detallesJson = (JsonArray) request.getAttribute("detalles");

    // Extrae la información del pedido desde el JSON
    String fechaPedido = pedidoJson.get("fechaPedido").getAsString();
    String estadoPedido = pedidoJson.get("estado").getAsString();
    float total = pedidoJson.get("total").getAsFloat();
    int idVendedor = pedidoJson.get("idVendedor").getAsInt();
    int idCliente = pedidoJson.get("idCliente").getAsInt();

    // Prepara el objeto de información del pedido
    Object[] pedidoInfo = {fechaPedido, estadoPedido, total, idVendedor, idCliente};
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Modificar Pedido</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/crearPedido.css">
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Modificar Pedido</h1>
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

        <div class="container mt-4">
            <form id="formulario" action="${pageContext.request.contextPath}/actualizarPedido" method="POST">
                <input type="hidden" name="idPedido" value="<%= request.getAttribute("idPedido")%>">
                <input type="hidden" name="idVendedor" value="<%= pedidoInfo[3]%>">
                <input type="hidden" name="idCliente" value="<%= pedidoInfo[4]%>">

                <div class="mb-3">
                    <label for="fechaPedido" class="form-label">Fecha del Pedido</label>
                    <input type="text" id="fechaPedido" name="fechaPedido" class="form-control" value="<%= pedidoInfo[0]%>" readonly>
                </div>

                <script>
                    document.addEventListener("DOMContentLoaded", function () {
                        var fechaInput = document.getElementById("fechaPedido");
                        var fecha = new Date(fechaInput.value); // Convertimos la cadena a un objeto Date

                        // Formateamos la fecha como día/mes/año
                        var dia = String(fecha.getDate()).padStart(2, '0'); // Asegura que el día tenga 2 dígitos
                        var mes = String(fecha.getMonth() + 1).padStart(2, '0'); // Los meses son 0-indexed, así que sumamos 1
                        var año = fecha.getFullYear();

                        // Establecemos el valor formateado en el input
                        fechaInput.value = dia + "/" + mes + "/" + año;
                    });
                </script>


                <div class="mb-3">
                    <label for="estadoPedido" class="form-label">Estado del Pedido</label>
                    <select id="estadoPedido" name="estadoPedido" class="form-select">
                        <!-- Estado actual seleccionado, capitalizado para mostrar -->
                        <option value="<%= estadoPedido%>" selected><%= capitalize(estadoPedido.replace("_", " "))%></option>
                        <%
                            // Enumerar los estados posibles desde el JSON
                            String[] estados = {"ENTREGADO", "EN_VIAJE", "EN_PREPARACION", "CANCELADO"};
                            for (String estado : estados) {
                                if (!estado.equals(estadoPedido)) {
                                    out.println("<option value='" + estado + "'>" + capitalize(estado.replace("_", " ")) + "</option>");
                                }
                            }
                        %>
                    </select>
                </div>

                <%!
                    // Función para capitalizar la primera letra de cada palabra
                    public String capitalize(String str) {
                        String[] words = str.split(" ");
                        StringBuilder capitalized = new StringBuilder();
                        for (String word : words) {
                            if (word.length() > 0) {
                                capitalized.append(word.substring(0, 1).toUpperCase())
                                        .append(word.substring(1).toLowerCase())
                                        .append(" ");
                            }
                        }
                        return capitalized.toString().trim();
                    }
                %>


                <h2 class="mb-4 text-center">¿Agregar un nuevo producto?</h2>   

                <div class="form-group mb-3">
                    <label for="selectCategoria">Selecciona una Categoría:</label>
                    <select id="selectCategoria" name="categoriaSeleccionada" class="form-control" onchange="cargarProductos(this.value)">
                        <option value="">Categorías</option>
                        <% for (int i = 0; i < categoriasJson.size(); i++) {
                                JsonObject categoria = categoriasJson.get(i).getAsJsonObject();
                                String categoriaId = categoria.get("id").getAsString();
                                String categoriaNombre = categoria.get("nombre").getAsString();
                        %>
                        <option value="<%= categoriaId%>"><%= categoriaNombre%></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group mb-3">
                    <label for="selectProducto">Selecciona un Producto:</label>
                    <select id="selectProducto" class="form-control" name="idProducto">
                        <option value="">Productos</option>
                        <%
                            // Iterar sobre los productos JSON
                            for (int i = 0; i < productosJson.size(); i++) {
                                JsonObject producto = productosJson.get(i).getAsJsonObject();
                                String productoId = producto.get("id").getAsString();
                                String productoNombre = producto.get("nombre").getAsString();
                                double precio = producto.get("precioVenta").getAsDouble();

                                JsonObject categoria = producto.getAsJsonObject("categoria");
                                String categoriaId = categoria != null ? categoria.get("id").getAsString() : "";
                        %>
                        <option value="<%= productoId%>" data-precio="<%= precio%>" data-categoria="<%= categoriaId%>">
                            <%= productoNombre%>
                        </option>

                        <% } %>
                    </select>
                </div>

                <div class="form-group mb-3">
                    <label for="cantidadProducto">Cantidad:</label>
                    <input type="number" id="cantidadProducto" name="cantidadProducto" class="form-control" min="1" placeholder="Ingrese la cantidad">
                </div>

                <button type="button" class="btn btn-primary" onclick="agregarProducto()">Agregar Producto</button>

                <h2 class="mb-4 text-center">Carrito</h2>                    

                <div class="contenido">
                    <label for="productos" class="form-label">Productos del Pedido</label>
                    <table class="table table-striped table-hover table-bordered mx-auto" id="productosTable">
                        <thead>
                            <tr>
                                <th>Producto</th>
                                <th>Cantidad</th>
                                <th>Precio</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < detallesJson.size(); i++) {
                                    JsonObject detalle = detallesJson.get(i).getAsJsonObject();
                                    // Accediendo a los datos dentro del objeto 'producto' que está dentro de 'detalle'
                                    JsonObject producto = detalle.getAsJsonObject("producto");
                                    String idProducto = producto.get("id").getAsString();  // Obtener el id del producto
                                    String nombreProducto = producto.get("nombre").getAsString();  // Obtener el nombre del producto
                                    int cantidadProducto = detalle.get("cantidad").getAsInt();  // Obtener la cantidad del producto
                                    double precioProducto = detalle.get("precioVenta").getAsDouble();  // Obtener el precio del producto
                            %>
                            <tr>
                                <!-- Campo oculto para almacenar el id del producto -->
                                <td>
                                    <input type="hidden" name="idProducto[]" value="<%= idProducto%>">
                                    <%= nombreProducto%>
                                </td>
                                <td>
                                    <input type="number" name="cantidadProducto[]" class="form-control" value="<%= cantidadProducto%>" oninput="actualizarTotal()">
                                </td>
                                <td>
                                    <input type="text" class="form-control" value="$<%= precioProducto%>" disabled>
                                    <input type="hidden" name="precioVenta[]" value="<%= precioProducto%>">
                                </td>

                                <td>
                                    <button type="button" class="btn btn-danger" onclick="eliminarProducto(this)">Eliminar</button>
                                </td>
                            </tr>
                            <% }%>
                        </tbody>


                    </table>
                </div>

                <div class="mb-3">
                    <label for="totalPedido" class="form-label">Total del Pedido</label>
                    <input type="number" id="totalPedido" class="form-control" value="<%= total%>" disabled>
                    <input type="hidden" id="totalPedidoHidden" name="totalPedido" value="<%= total%>"> <!-- Campo oculto -->
                </div>

                <button type="submit" class="btn btn-success" style="margin-bottom: 20px;">Guardar Cambios</button>
            </form>
        </div>

        <footer class="text-center mt-4" style="background-color: #212529; color: white; padding: 10px; font-family: Arial, sans-serif">
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

        <script src="Scripts/modificarPedidos.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>