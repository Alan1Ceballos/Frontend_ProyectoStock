<%@ page import="java.util.List" %>
<%@ page import="logica.Clases.Cliente" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Listado de Clientes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/historialPedidos.css">
    <script src="Scripts/listadoClientes.js"></script>
</head>

<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Listado de Pedidos</h1>
        </div>
        <div class="busqueda-filtros d-flex align-items-center">
            <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
            <label for="filtro" class="me-2">Filtros:</label>
            <select id="filtro" onchange="filtrarTabla()" class="form-select">
                <option value="todos">Todos</option>
                <option value="rut">RUT</option>
                <option value="nombre">Nombre</option>
                <option value="email">Email</option>
                <option value="telefono">Teléfono</option>
                <option value="fecha">Fecha de Registro</option>
            </select>
        </div>
    </header>
    
    <div class="contenido">
        <%
            List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
            if (clientes != null && !clientes.isEmpty()) {
        %>
            <table id="tablaClientes" class="table table-striped table-hover mx-auto">
                <thead class="table-dark">
                    <tr>
                        <th>RUT</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th>Teléfono</th>
                        <th>Fecha de Registro</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Cliente cliente : clientes) {
                    %>
                        <tr>
                            <td><%= cliente.getNum_rut() %></td>
                            <td><%= cliente.getNom_empresa() %></td>
                            <td><%= cliente.getCorreo_electronico() %></td>
                            <td><%= cliente.getTelefono() %></td>
                            <td><%= cliente.getFecha_registro() %></td>
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

    <!-- Incluimos el JavaScript de Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
