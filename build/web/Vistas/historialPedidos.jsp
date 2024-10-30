<%-- 
    Document   : historialPedidos
    Created on : 23 oct 2024, 18:33:23
    Author     : AlanCeballos
--%>

<%@page import="logica.Clases.Pedido"%>
<%@page import="logica.servicios.ClienteServicios"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Pedidos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="Styles/historialPedidos.css">
    <script src="Scripts/historialPedidos.js"></script>
</head>
<body>
    <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
        <div class="encabezado">
            <h1>Historial de Pedidos</h1>
        </div>
        <div class="busqueda-filtros d-flex align-items-center">
            <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
            <label for="filtro" class="me-2">Filtros:</label>
            <select id="filtro" onchange="filtrarTabla()" class="form-select">
                <option value="todos">Ninguno</option>
                <option value="id">ID</option>
                <option value="fecha">Fecha</option>
                <option value="estado">Estado</option>
                <option value="total">Total</option>
                <option value="cliente">Cliente</option>
            </select>
        </div>
    </header>

    <div class="contenido">
        <table id="tablaPedidos" class="table table-striped table-hover table-bordered mx-auto">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Fecha</th>
                    <th>Estado</th>
                    <th>Total</th>
                    <th>Cliente</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <%
                    ArrayList<Pedido> pedidos = (ArrayList<Pedido>) request.getAttribute("pedidos");
                    ClienteServicios clienteServicios = new ClienteServicios();
                    if (pedidos != null) {
                        for (Pedido pedido : pedidos) {
                            String estadoPedido;
                            switch (pedido.getEstado()) {
                                case EN_PREPARACION:
                                    estadoPedido = "En Preparación";
                                    break;
                                case EN_VIAJE:
                                    estadoPedido = "En Viaje";
                                    break;
                                case ENTREGADO:
                                    estadoPedido = "Entregado";
                                    break;
                                case CANCELADO:
                                    estadoPedido = "Cancelado";
                                    break;
                                default:
                                    estadoPedido = "Estado Desconocido"; // por si hay un estado no esperado
                                    break;
                            }

                            // Obtener el nombre del cliente usando el ID
                            String nombreCliente = clienteServicios.getNombreClientePorId(pedido.getIdCliente());
                %>
                            <tr>
                                <td><%= pedido.getIdentificador() %></td>
                                <td><%= pedido.getFechaPedido() %></td>
                                <td class="estadoPedido" data-estado="<%= estadoPedido %>"><%= estadoPedido %></td>
                                <td><%= pedido.getTotal() %></td>
                                <td><%= nombreCliente != null ? nombreCliente : "Desconocido" %></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/verdetalles" method="get" style="display:inline;">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
                                        <button type="submit" class="btn btn-primary">Ver Detalles</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/Vistas/modificarPedido.jsp" method="post" style="display:inline;">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
                                        <button type="submit" class="btn btn-warning">Modificar Pedido</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/cancelarPedido" method="post" style="display:inline;" onsubmit="return confirmarCancelacion();">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
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
            var idPedido = document.querySelector(".idPedido").value;
            // Usar el ID en la alerta de confirmación
            return confirm("¿Es\n\ás seguro de que deseas cancelar el pedido con ID: " + idPedido + "?");
        }
    </script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Obtener todas las filas de la tabla
            var filas = document.querySelectorAll("#tablaPedidos tbody tr");
            // Iterar sobre cada fila
            filas.forEach(function(fila) {
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


    <footer class="text-center mt-4">
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>
</body>
</html>
