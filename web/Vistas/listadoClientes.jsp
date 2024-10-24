<%@ page import="java.util.List" %>
<%@ page import="logica.Clases.Cliente" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Listado de Clientes</title>
    <!-- Incluimos el CSS de Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
        <style>
        /* Centrar todo el contenido de las celdas de la tabla */
        td, th {
            text-align: center;
            vertical-align: middle; /* Opcional: para centrar también verticalmente */
        }
    </style>
    
    <div class="container mt-5">
        <h1 class="text-center mb-4">Listado de Clientes</h1>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div class="alert alert-danger" role="alert">
                <%= errorMessage %>
            </div>
        <%
            }
        %>

        <%
            List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
            if (clientes != null && !clientes.isEmpty()) {
        %>
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>RUT</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th >Teléfono</th> <!-- Columna verde -->
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
                            <td><%= cliente.getTelefono() %></td> <!-- Columna verde -->
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
    

    <!-- Incluimos el JavaScript de Bootstrap -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
