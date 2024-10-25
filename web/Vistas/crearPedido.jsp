<%@page import="java.util.ArrayList"%>
<%@page import="logica.Clases.Cliente"%>
<%@page import="logica.Clases.Producto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Crear Pedido</title>
        <link rel="stylesheet" type="text/css" href="Styles/crearPedido.css">
    </head>
    <body>
        <h2>Crear Nuevo Pedido</h2>

        <form id="formularioCrearPedido" action="crearPedido" method="POST">

            <!-- Selección de cliente -->

            <label for="cliente">Seleccione Cliente:</label>
            <select name="cliente" id="cliente">
                <%
                    // Obtener la lista de clientes del servlet
                    ArrayList<Cliente> clientes = (ArrayList<Cliente>) request.getAttribute("clientes");
                    if (clientes != null) {
                        for (Cliente cliente : clientes) {
                %>
                    <option value="<%= cliente.getNum_rut() %>"><%= cliente.getNom_empresa() %> - <%= cliente.getCorreo_electronico() %></option>
                <%
                        }
                    }
                %>
            </select>

            <br>
            <br>

            <!-- Selección de productos -->

            <label for="productos">Seleccione Productos:</label>
            <select name="productos[]" id="productos" multiple>
                <%
                    ArrayList<Producto> productos = (ArrayList<Producto>) request.getAttribute("productos");
                    if (productos != null) {
                        for (Producto producto : productos) {
                %>
                <option value="<%= producto.getId()%>"><%= producto.getNombre()%> - $<%= producto.getPrecioVenta()%></option>
                <%
                        }
                    }
                %>
            </select>

            <br>
            <br>

            <!-- Código para productos... -->

            <label for="cantidad">Cantidad:</label>
            <input type="number" name="cantidad" id="cantidad" required>

            <p>Total: $<span id="total">0.00</span></p>

            <button type="submit">Añadir al Carrito</button>
            <a href="verCarrito" class="ver-carrito">Ver Carrito</a>
            <button type="reset">Cancelar</button>
        </form>

        <!--Utilizacion de AJAX para enviar los datos del formulario sin recargar la pagina-->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>
            $(document).ready(function () {
                // Interceptar el envío del formulario
                $("#formularioCrearPedido").on("submit", function (event) {
                    event.preventDefault(); // Evitar el envío normal del formulario

                    // Obtener los datos del formulario
                    var formData = $(this).serialize();

                    // Enviar el formulario con AJAX
                    $.ajax({
                        type: "POST",
                        url: "crearPedido", // URL del servlet
                        data: formData,
                        success: function (response) {
                            alert("Producto añadido al carrito exitosamente");
                        },
                        error: function () {
                            alert("Ocurrió un error al añadir el producto al carrito");
                        }
                    });
                });
            });
        </script>
    </body>
</html>