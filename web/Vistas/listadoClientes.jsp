<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List" %>
<%@page import="logica.Clases.Cliente" %>
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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Listado de Clientes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/listadoClientes.css">
    <script src="Scripts/listadoClientes.js"></script>
</head>

<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Listado de Clientes</h1>
        </div>
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
    </header>
    
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

    <!-- Incluimos el JavaScript de Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
