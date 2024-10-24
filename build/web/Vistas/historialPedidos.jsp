<%-- 
    Document   : historialPedidos
    Created on : 23 oct 2024, 18:33:23
    Author     : AlanCeballos
--%>

<%@page import="logica.Clases.Pedido"%>
<%@page import="logica.servicios.ClienteServicios"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Pedidos</title>
    <link rel="stylesheet" type="text/css" href="Styles/historialPedidos.css">
    <script>
        // Script de filtrado de tabla
        function filtrarTabla() {
            const input = document.getElementById('busqueda');
            const filter = input.value.toLowerCase();
            const filtroSeleccionado = document.getElementById('filtro').value;
            const tabla = document.getElementById("tablaPedidos");
            const tr = tabla.getElementsByTagName("tr");

            for (let i = 1; i < tr.length; i++) { //comenzamos desde 1 para evitar el encabezado
                const tds = tr[i].getElementsByTagName("td");
                let found = false;

                for (let j = 0; j < tds.length; j++) {
                    if (tds[j]) {
                        const textoValor = tds[j].textContent || tds[j].innerText;

                        //filtramos según la opción seleccionada
                        if (filtroSeleccionado === "todos" || 
                            (filtroSeleccionado === "id" && j === 0) ||
                            (filtroSeleccionado === "fecha" && j === 1) ||
                            (filtroSeleccionado === "estado" && j === 2) ||
                            (filtroSeleccionado === "total" && j === 3) || 
                            (filtroSeleccionado === "cliente" && j === 4)) {
                            if (textoValor.toLowerCase().indexOf(filter) > -1) {
                                found = true;
                                break; //salimos del bucle si se encuentra una coincidencia
                            }
                        }
                    }
                }

                tr[i].style.display = found ? "" : "none"; // Mostrar o ocultar la fila
            }
        }
    </script>
</head>
<body>
    <header style="display: flex; align-items: center; justify-content: space-between;">
        <div class="encabezado">
            <h1>Historial de Pedidos</h1>
        </div>
        <div class="busqueda-filtros">
            <input type="text" id="busqueda" onkeyup="filtrarTabla()" placeholder="Buscar..." style="margin-right: 5px;" />
            <label for="filtro" style="margin: 0;">Filtros:</label>
            <select id="filtro" onchange="filtrarTabla()" style="margin-left: 5px;">
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
        <table id="tablaPedidos">
            <thead>
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
                                <td><%= estadoPedido %></td>
                                <td><%= pedido.getTotal() %></td>
                                <td><%= nombreCliente != null ? nombreCliente : "Desconocido" %></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/verdetalles" method="get" style="display:inline;">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
                                        <button type="submit" class="btn">Ver Detalles</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/modificarPedido" method="get" style="display:inline;">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
                                        <button type="submit" class="btn">Modificar Pedido</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/cancelarPedido" method="post" style="display:inline;">
                                        <input type="hidden" name="idPedido" value="<%= pedido.getIdentificador() %>">
                                        <button type="submit" class="btn">Cancelar Pedido</button>
                                    </form>
                                </td>
                            </tr>
                <%
                        }
                    } else {
                %>
                        <tr>
                            <td colspan="6">No hay pedidos disponibles.</td>
                        </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
    <footer>
        <p>&copy; 2024 Programación de Aplicaciones</p>
    </footer>
</body>
</html>