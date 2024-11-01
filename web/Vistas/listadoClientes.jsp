<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List" %>
<%@page import="logica.Clases.Cliente" %>
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

    // Aqu� deber�as tener la l�gica para obtener todos los clientes de la base de datos
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");

    // Verificar si clientes es null
    if (clientes == null) {
        clientes = new ArrayList<>(); // Iniciar como lista vac�a si es null
    }

    // Calcular el �ndice de inicio y fin para la paginaci�n
    int totalClientes = (clientes != null) ? clientes.size() : 0; // Aseg�rate de que clientes no sea null
    int totalPaginas = (int) Math.ceil((double) totalClientes / filasPorPagina);
    int inicio = (paginaActual - 1) * filasPorPagina;
    int fin = Math.min(inicio + filasPorPagina, totalClientes);

    // Filtrar la lista de clientes para mostrar solo la p�gina actual
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
                <option value="telefono">Tel�fono</option>
                <option value="direccion">Direcci�n</option>
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
                        <th onclick="ordenarTabla(3)">Tel�fono <span id="iconoOrden3"></span></th>
                        <th onclick="ordenarTabla(4)">Direcci�n <span id="iconoOrden4"></span></th>
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
                    // Rango de p�ginas a mostrar
                    int rango = 1; // N�mero de p�ginas a mostrar a cada lado de la actual
                    int inicioPaginas = Math.max(1, paginaActual - rango); // Primera p�gina a mostrar
                    int finPaginas = Math.min(totalPaginas, paginaActual + rango); // �ltima p�gina a mostrar

                    // Mostrar indicador de p�ginas previas
                    if (inicioPaginas > 1) {
                %>
                    <a href="clientes?page=1" class="btn btn-outline-secondary btn-sm mx-1">1</a>
                    <span class="mx-1">...</span>
                <%
                    }

                    // Mostrar las p�ginas en el rango
                    for (int i = inicioPaginas; i <= finPaginas; i++) {
                        // Verifica si el bot�n es el de la p�gina actual
                        String activeClass = (i == paginaActual) ? "btn-primary" : "btn-outline-secondary"; // Cambiar la clase del bot�n
                %>
                        <a href="clientes?page=<%= i %>" class="btn <%= activeClass %> btn-sm mx-1"><%= i %></a>
                <%
                    }

                    // Mostrar indicador de p�ginas posteriores
                    if (finPaginas < totalPaginas) {
                %>
                    <span class="mx-1">...</span>
                    <a href="clientes?page=<%= totalPaginas %>" class="btn btn-outline-secondary btn-sm mx-1"><%= totalPaginas %></a>
                <%
                    }
                %>
            </div>

    <footer class="text-center mt-4">
        <p>&copy; 2024 Programaci�n de Aplicaciones</p>
    </footer>

    <!-- Incluimos el JavaScript de Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
