<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List" %>
<%@page import="logica.Clases.Cliente" %>
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

    // Aquí deberías tener la lógica para obtener todos los clientes de la base de datos
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");

    // Verificar si clientes es null
    if (clientes == null) {
        clientes = new ArrayList<>(); // Iniciar como lista vacía si es null
    }

    // Calcular el índice de inicio y fin para la paginación
    int totalClientes = (clientes != null) ? clientes.size() : 0; // Asegúrate de que clientes no sea null
    int totalPaginas = (int) Math.ceil((double) totalClientes / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalClientes);

    // Filtrar la lista de clientes para mostrar solo la página actual
    List<Cliente> clientesPagina = clientes.subList(inicio, fin);
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    
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
                Sesión iniciada por: <strong><%= usuario %></strong>
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
    
    <div class="contenido">
        <%
            if (clientesPagina != null && !clientesPagina.isEmpty()) {
        %>
            <table id="tablaClientes" class="table table-striped table-hover mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th onclick="ordenarTabla(0)">Identificador <span id="iconoOrden0"></span></th>
                        <th onclick="ordenarTabla(1)">Nombre <span id="iconoOrden1"></span></th>
                        <th onclick="ordenarTabla(2)">Email <span id="iconoOrden2"></span></th>
                        <th onclick="ordenarTabla(3)">Teléfono <span id="iconoOrden3"></span></th>
                        <th onclick="ordenarTabla(4)">Dirección <span id="iconoOrden4"></span></th>
                        <th onclick="ordenarTabla(5)">Fecha de Registro <span id="iconoOrden5"></span></th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Cliente cliente : clientesPagina) {
                            String fechaRegistro = cliente.getFecha_registro() != null 
                                ? dateFormat.format(cliente.getFecha_registro()) 
                                : "N/A";
                    %>
                        <tr>
                            <td><%= cliente.getIdentificador() %></td>
                            <td><%= cliente.getNom_empresa() %></td>
                            <td><%= cliente.getCorreo_electronico() %></td>
                            <td><%= cliente.getTelefono() %></td>
                            <td><%= cliente.getDireccion() %></td>
                            <td><%= fechaRegistro %></td>
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
    <div class="d-flex justify-content-center align-items-center pagination">
                <%
                    // Rango de páginas a mostrar
                    int rango = 1; // Número de páginas a mostrar a cada lado de la actual
                    int inicioPaginas = Math.max(1, paginaActual - rango); // Primera página a mostrar
                    int finPaginas = Math.min(totalPaginas, paginaActual + rango); // Última página a mostrar

                    // Mostrar indicador de páginas previas
                    if (inicioPaginas > 1) {
                %>
                    <a href="clientes?page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
                    <span class="mx-1">...</span>
                <%
                    }

                    // Mostrar las páginas en el rango
                    for (int i = inicioPaginas; i <= finPaginas; i++) {
                        // Verifica si el botón es el de la página actual
                        String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary"; // Cambiar la clase del botón
                %>
                        <a href="clientes?page=<%= i %>" class="btn <%= activeClass %> btn-sm mx-1"><%= i %></a>
                <%
                    }

                    // Mostrar indicador de páginas posteriores
                    if (finPaginas < totalPaginas) {
                %>
                    <span class="mx-1">...</span>
                    <a href="clientes?page=<%= totalPaginas %>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas %></a>
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

    <!-- Incluimos el JavaScript de Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
