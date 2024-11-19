<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List" %>
<%@page import="com.google.gson.JsonArray" %>
<%@page import="com.google.gson.JsonObject" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //verificamos si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirigimos a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    //obtenemos el número de página desde los parámetros de la solicitud
    String pageParam = request.getParameter("page");
    int paginaActual = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int filasPorPagina = 10;

    //obtenemos el listado de pedidos desde el request (proviene del servlet)
    JsonArray pedidosJson = (JsonArray) request.getAttribute("pedidos");

    //verificamos si pedidosJson es null
    if (pedidosJson == null) {
        pedidosJson = new JsonArray(); //inciamos como lista vacía si es null
    }

    //convertimos JsonArray a una lista de pedidos para manejo en la JSP
    List<JsonObject> pedidos = new ArrayList<>();
    for (int i = 0; i < pedidosJson.size(); i++) {
        pedidos.add(pedidosJson.get(i).getAsJsonObject());
    }

    //calculamos el índice de inicio y fin para la paginación
    int totalPedidos = pedidos.size();
    int totalPaginas = (int) Math.ceil((double) totalPedidos / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalPedidos);

    //filtramos la lista de pedidos para mostrar solo la página actual
    List<JsonObject> pedidosPagina = pedidos.subList(inicio, fin);

    String usuario = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Historial de Pedidos</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/historialPedidos.css">
        <script src="Scripts/historialPedidos.js"></script>
    </head>
    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="busqueda-filtros d-flex align-items-center justify-content-between p-3 bg-dark text-white">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
                <label for="filtro" class="me-2">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" class="form-select">
                    <option value="ninguno">Ninguno</option>
                    <option value="fecha">Fecha</option>
                    <option value="estado">Estado</option>
                    <option value="total">Total</option>
                    <option value="cliente">Cliente</option>
                </select>
            </div>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Historial de Pedidos</h1>
                <p id="session-info" class="mb-0">
                    Sesión iniciada por: <strong><%= usuario%></strong>
                </p>
            </div>
        </header>

        <%-- Mostrar mensaje de éxito o error --%>
        <%
            String mensaje = (String) request.getAttribute("mensaje");
            if (mensaje != null && !mensaje.isEmpty()) {
        %>
        <div class="alert alert-info" role="alert">
            <%= mensaje%>
        </div>
        <%
            }
        %>


        <!-- Menú lateral -->
        <div id="sidebar" class="sidebar">
            <a href="javascript:void(0)" class="closebtn" onclick="closeMenu()">☰ Cerrar</a>
            <a href="Home.jsp"><span class="material-icons">home</span> Inicio</a>
            <a href="crearPedido"><span class="material-icons">shopping_cart</span> Crear Pedido</a>
            <a href="historialpedidos" class="active"><span class="material-icons">history</span> Historial de Pedidos</a>
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
                    <li>
                        <form action="${pageContext.request.contextPath}/crearPedido" method="get" style="margin: 0;">
                            <button type="submit" class="dropdown-item">Nuevo Pedido</button>
                        </form>
                    </li>
                </ul>
            </div>

            <table id="tablaPedidos" class="table table-striped table-hover table-bordered mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th onclick="ordenarTabla(0)">Fecha <span id="iconoOrden0"></span></th>
                        <th onclick="ordenarTabla(1)">Estado <span id="iconoOrden1"></span></th>
                        <th onclick="ordenarTabla(2)">Total <span id="iconoOrden2"></span></th>
                        <th onclick="ordenarTabla(3)">Cliente <span id="iconoOrden3"></span></th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (pedidosPagina != null && !pedidosPagina.isEmpty()) {
                            for (JsonObject pedidoJson : pedidosPagina) {
                                String estadoPedido;
                                String estadoJson = pedidoJson.get("estado").getAsString();

                                switch (estadoJson) {
                                    case "EN_PREPARACION":
                                        estadoPedido = "En Preparación";
                                        break;
                                    case "EN_VIAJE":
                                        estadoPedido = "En Viaje";
                                        break;
                                    case "ENTREGADO":
                                        estadoPedido = "Entregado";
                                        break;
                                    case "CANCELADO":
                                        estadoPedido = "Cancelado";
                                        break;
                                    default:
                                        estadoPedido = "Estado Desconocido"; // por si hay un estado no esperado
                                        break;
                                }

                                //obtenemos el nombre del cliente desde el JSON
                                String nombreCliente = pedidoJson.has("nombreCliente") ? pedidoJson.get("nombreCliente").getAsString() : "Desconocido";
                    %>
                    <tr>
                        <td><%= dateFormat.format(new java.util.Date(pedidoJson.get("fechaPedido").getAsLong()))%></td>
                        <td class="estadoPedido" data-estado="<%= estadoPedido%>"><%= estadoPedido%></td>
                        <td>$<%= String.format("%.2f", pedidoJson.get("total").getAsDouble())%></td>
                        <td><%= nombreCliente%></td>
                        <td>
                            <form action="${pageContext.request.contextPath}/verdetalles" method="get" style="display:inline;">
                                <input type="hidden" name="idPedido" value="<%= pedidoJson.get("identificador").getAsInt()%>">
                                <button type="submit" class="btn btn-primary">Ver Detalles</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/modificarPedido" method="get" style="display:inline;">
                                <input type="hidden" name="idPedido" value="<%= pedidoJson.get("identificador").getAsInt()%>">
                                <button type="submit" class="btn btn-warning">Modificar Pedido</button>
                            </form>

                            <form action="${pageContext.request.contextPath}/cancelarPedido" method="post" style="display:inline;" onsubmit="return confirmarCancelacion();">
                                <input type="hidden" name="idPedido" value="<%= pedidoJson.get("identificador").getAsInt()%>">
                                <button type="submit" class="btn btn-danger">Cancelar Pedido</button>
                            </form>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="6" class="text-center">No hay pedidos disponibles.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>


        <script>
            function confirmarCancelacion() {
                var idPedido = document.querySelector("input[name='idPedido']").value; // Obtener el ID del formulario
                return confirm("¿Estás seguro de que deseas cancelar el pedido?");
            }
        </script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Obtener todas las filas de la tabla
                var filas = document.querySelectorAll("#tablaPedidos tbody tr");
                // Iterar sobre cada fila
                filas.forEach(function (fila) {
                    // Obtener la celda de estado en la fila actual
                    var estadoCelda = fila.querySelector(".estadoPedido");
                    var estadoPedido = estadoCelda.getAttribute("data-estado");

                    // Si el estado es "Cancelado", deshabilitar el botón y cambiar el color de la celda de estado
                    if (estadoPedido === "Cancelado") {
                        // Cambiar el color de la celda de estado a rojo claro
                        estadoCelda.style.backgroundColor = "#ffcccc";

                        // Deshabilitar el botón de cancelar en esa fila
                        var cancelarBtn = fila.querySelector(".btn-danger");
                        if (cancelarBtn) {
                            cancelarBtn.disabled = true;
                            cancelarBtn.style.backgroundColor = "#d3d3d3"; // Fondo gris para el botón
                            cancelarBtn.style.cursor = "not-allowed"; // Cambia el cursor
                        }
                    }
                });
            });
        </script>

        <div class="d-flex justify-content-center align-items-center pagination">
            <%
                // Rango de páginas a mostrar
                int rango = 1; // Número de páginas a mostrar a cada lado de la actual
                int inicioPaginas = Math.max(1, paginaActual - rango); // Primera página a mostrar
                int finPaginas = Math.min(totalPaginas, paginaActual + rango); // Última página a mostrar

                // Mostrar indicador de páginas previas
                if (inicioPaginas > 1) {
            %>
            <a href="historialpedidos?page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
            <span class="mx-1">...</span>
            <%
                }

                // Mostrar las páginas en el rango
                for (int i = inicioPaginas; i <= finPaginas; i++) {
                    // Verifica si el botón es el de la página actual
                    String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary"; // Cambiar la clase del botón
            %>
            <a href="historialpedidos?page=<%= i%>" class="btn <%= activeClass%> btn-sm mx-1"><%= i%></a>
            <%
                }

                // Mostrar indicador de páginas posteriores
                if (finPaginas < totalPaginas) {
            %>
            <span class="mx-1">...</span>
            <a href="historialpedidos?page=<%= totalPaginas%>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas%></a>
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
