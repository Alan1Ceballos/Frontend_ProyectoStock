<%@page import="java.util.ArrayList"%>
<%@page import="logica.Clases.DetallePedido"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Carrito</title>
        <link rel="stylesheet" type="text/css" href="Styles/verCarrito.css">
    </head>
    <body>
        <h2>Tu Carrito</h2>

        <table border="1">
            <tr>
                <th>Producto</th>
                <th>Precio</th>
                <th>Cantidad</th>
                <th>Total</th>
                <th>Acciones</th> <!-- Nueva columna para el botón eliminar -->
            </tr>
            <%
                ArrayList<DetallePedido> carrito = (ArrayList<DetallePedido>) session.getAttribute("carrito");
                if (carrito != null && !carrito.isEmpty()) {
                    double totalCarrito = 0;
                    int index = 0; // Para identificar cada producto en el carrito
                    for (DetallePedido detalle : carrito) {
                        double totalProducto = detalle.getProducto().getPrecioVenta() * detalle.getCantidad();
                        totalCarrito += totalProducto;
            %>
            <tr>
                <td><%= detalle.getProducto().getNombre()%></td>
                <td>$<%= detalle.getProducto().getPrecioVenta()%></td>
                <td><%= detalle.getCantidad()%></td>
                <td>$<%= totalProducto%></td>
                <td>
                    <!-- Formulario para eliminar el producto del carrito -->
                    <form action="verCarrito" method="get"> <!-- URL del servlet corregida -->
                        <input type="hidden" name="eliminarIndex" value="<%= index%>">
                        <button type="submit">Eliminar</button>
                    </form>
                </td>

            </tr>
            <%
                    index++;
                }
            %>
            <tr>
                <td colspan="3">Total</td>
                <td>$<%= totalCarrito%></td>
                <td></td>
            </tr>
            <%
            } else {
            %>
            <tr>
                <td colspan="5">El carrito está vacío</td>
            </tr>
            <%
                }
            %>
        </table>

        <a href="crearPedido">Seguir comprando</a>
    </body>
</html>
