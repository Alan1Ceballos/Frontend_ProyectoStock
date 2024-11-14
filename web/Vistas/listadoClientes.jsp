<%@page import="com.google.gson.JsonArray"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    String pageParam = request.getParameter("page");
    int paginaActual = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int filasPorPagina = 10;

    // Obtén el JsonArray de clientes desde el request
    JsonArray clientes = (JsonArray) request.getAttribute("clientes");
    if (clientes == null) {
        clientes = new JsonArray(); // Inicializa como vacío si es null
    }

    // Calcular total de clientes y de páginas para la paginación
    int totalClientes = clientes.size();
    int totalPaginas = (int) Math.ceil((double) totalClientes / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalClientes);

    // Formateador para la fecha
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // Usuario actual
    String usuario = (String) session.getAttribute("usuario");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Listado de Clientes</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="Styles/listadoClientes.css">
        <script src="Scripts/listadoClientes.js"></script>
    </head>

    <body>
        <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
            <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
            <div class="busqueda-filtros d-flex align-items-center">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
                <label for="filtro" class="me-2">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" class="form-select">
                    <option value="ninguno">Ninguno</option>
                    <option value="identificador">Identificador</option>
                    <option value="nombre">Nombre</option>
                    <option value="email">Email</option>
                    <option value="telefono">Teléfono</option>
                    <option value="direccion">Dirección</option>
                    <option value="fecha">Fecha de Registro</option>
                </select>
            </div>
            <div class="encabezado">
                <h1 class="mb-1 text-decoration-underline">Listado de Clientes</h1>
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
            <a href="clientes" class="active"><span class="material-icons">people</span> Listado de Clientes</a>
            <a href="listadoProductos"><span class="material-icons">inventory</span> Listado de Productos</a>
            <a href="generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>

            <hr>

            <a href="LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
        </div>

        <!-- Overlay de oscurecimiento -->
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>

        <!-- Tabla de clientes -->
        <div class="contenido">
            <%
                if (clientes.size() > 0) {
            %>
            <table id="tablaClientes" class="table table-striped table-hover mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th onclick="ordenarTabla(0)">Identificador</th>
                        <th onclick="ordenarTabla(1)">Nombre</th>
                        <th onclick="ordenarTabla(2)">Email</th>
                        <th onclick="ordenarTabla(3)">Teléfono</th>
                        <th onclick="ordenarTabla(4)">Dirección</th>
                        <th onclick="ordenarTabla(5)">Fecha de Registro</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (int i = inicio; i < fin; i++) {
                            JsonObject clienteJson = clientes.get(i).getAsJsonObject();
                            String identificador = clienteJson.has("identificador") ? clienteJson.get("identificador").getAsString() : "N/A";
                            String nombre = clienteJson.has("nom_empresa") ? clienteJson.get("nom_empresa").getAsString() : "N/A";
                            String email = clienteJson.has("correo_electronico") ? clienteJson.get("correo_electronico").getAsString() : "N/A";
                            String telefono = clienteJson.has("telefono") ? clienteJson.get("telefono").getAsString() : "N/A";
                            String direccion = clienteJson.has("direccion") ? clienteJson.get("direccion").getAsString() : "N/A";
                            String fechaRegistro = clienteJson.has("fecha_registro")
                                    ? dateFormat.format(new java.util.Date(clienteJson.get("fecha_registro").getAsLong()))
                                    : "N/A";
                    %>
                    <tr>
                        <td><%= identificador%></td>
                        <td><%= nombre%></td>
                        <td><%= email%></td>
                        <td><%= telefono%></td>
                        <td><%= direccion%></td>
                        <td><%= fechaRegistro%></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
            <%
            } else {
            %>
            <p class="text-center text-warning">No hay clientes registrados.</p>
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
    </body>
</html>
