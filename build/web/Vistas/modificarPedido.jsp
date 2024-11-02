<%@page import="logica.Clases.Pedido.Estado"%>
<%@page import="java.util.List"%>
<%@page import="logica.Clases.Categoria"%>
<%@page import="logica.Clases.Pedido"%>
<%@page import="logica.Clases.DetallePedido"%>
<%@page import="logica.servicios.DetallePedidoServicios"%>
<%@page import="logica.servicios.PedidosServicios"%>
<%@page import="logica.servicios.CategoriaServicios"%>
<%@page import="logica.Clases.Producto"%>
<%@page import="logica.servicios.ProductoServicios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    //verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        //redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }
    String usuario = (String) session.getAttribute("usuario");
%>

<%
    int idPedido = Integer.parseInt(request.getParameter("idPedido"));
    double total = 0.0;

    PedidosServicios pedidoServicios = new PedidosServicios();
    Pedido pedido = pedidoServicios.obtenerPedidoPorId(idPedido);

    CategoriaServicios categoriaServicios = new CategoriaServicios();
    List<Categoria> categorias = categoriaServicios.listarCategorias();

    ProductoServicios productoServicios = new ProductoServicios();
    List<Producto> productos = productoServicios.listarProductos();

    Object[] pedidoInfo = {pedido.getFechaPedido(), pedido.getEstado(), pedido.getTotal(), pedido.getIdVendedor(), pedido.getIdCliente()};
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Modificar Pedido</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="../Styles/crearPedido.css">
</head>
<body>
    <header class="p-3 bg-dark text-white d-flex justify-content-between align-items-center">
        <button id="openMenuBtn" onclick="openMenu()" class="btn btn-light">☰ Menú</button>
        <div class="encabezado">
            <h1 class="mb-1 text-decoration-underline">Modificar Pedido</h1>
            <p id="session-info" class="mb-0">
                Sesión iniciada por: <strong><%= usuario %></strong>
            </p>
        </div>
    </header>
            
    <!-- Menú lateral -->
    <div id="sidebar" class="sidebar">
        <a href="javascript:void(0)" class="closebtn" onclick="closeMenu()">☰ Cerrar</a>
        <a href="../Home.jsp"><span class="material-icons">home</span> Inicio</a>
        <a href="../crearPedido"><span class="material-icons">shopping_cart</span> Crear Pedido</a>
        <a href="../historialpedidos"><span class="material-icons">history</span> Historial de Pedidos</a>
        <a href="../clientes"><span class="material-icons">people</span> Listado de Clientes</a>
        <a href="../listadoProductos"><span class="material-icons">inventory</span> Listado de Productos</a>
        <a href="../generarInforme"><span class="material-icons">insert_chart</span> Generar Informe</a>
        
        <hr>
        
        <a href="../LogoutServlet"><span class="material-icons">logout</span> Cerrar Sesión</a>
    </div>

    <!-- Overlay de oscurecimiento -->
    <div id="overlay" class="overlay" onclick="closeMenu()"></div>
            
    <div class="container mt-4">
        <form id="formulario" action="${pageContext.request.contextPath}/modificarPedido" method="POST">
            <input type="hidden" name="idPedido" value="<%= idPedido%>">
            <input type="hidden" name="idVendedor" value="<%= pedidoInfo[3]%>">
            <input type="hidden" name="idCliente" value="<%= pedidoInfo[4]%>">
            
            <div class="mb-3">
                <label for="fechaPedido" class="form-label">Fecha del Pedido</label>
                <input type="text" id="fechaPedido" name="fechaPedido" class="form-control" value="<%= pedidoInfo[0]%>" readonly>
            </div>

            <%
                String estadoActual = pedido.getEstado().name();
            %>

            <div class="mb-3">
                <label for="estadoPedido" class="form-label">Estado del Pedido</label>
                <select id="estadoPedido" name="estadoPedido" class="form-select">
                    <%
                        out.println("<option value='" + estadoActual + "' selected>" + estadoActual.replace("_", " ") + "</option>");
                        for (Estado estado : Estado.values()) {
                            if (!estado.name().equals(estadoActual)) {
                                out.println("<option value='" + estado.name() + "'>" + estado.name().replace("_", " ") + "</option>");
                            }
                        }
                    %>
                </select>
            </div>
                
            <h2 class="mb-4 text-center">¿Agregar un nuevo producto?</h2>   

            <div class="form-group mb-3">
                <label for="selectCategoria">Selecciona una Categoría:</label>
                <select id="selectCategoria" name="categoriaSeleccionada" class="form-control" onchange="cargarProductos(this.value)">
                    <option value="">Categorías</option>
                    <% for (Categoria categoria : categorias) {%>
                    <option value="<%= categoria.getId()%>"><%= categoria.getNombre()%></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group mb-3">
                <label for="selectProducto">Selecciona un Producto:</label>
                <select id="selectProducto" class="form-control" name="idProducto">
                    <option value="">Productos</option>
                    <% for (Producto producto : productos) {%>
                    <option value="<%= producto.getId()%>" data-precio="<%= producto.getPrecioVenta()%>" data-categoria="<%= producto.getCategoria().getId()%>">
                        <%= producto.getNombre()%>
                    </option>
                    <% }%>
                </select>
            </div>

            <div class="form-group mb-3">
                <label for="cantidadProducto">Cantidad:</label>
                <input type="number" id="cantidadProducto" name="cantidadProducto" class="form-control" min="1" placeholder="Ingrese la cantidad">
            </div>

            <button type="button" class="btn btn-primary" onclick="agregarProducto()">Agregar Producto</button>

            <h2 class="mb-4 text-center">Carrito</h2>                    

            <div class="contenido">
                <label for="productos" class="form-label">Productos del Pedido</label>
                <table class="table table-striped table-hover table-bordered mx-auto" id="productosTable">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Precio</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            DetallePedidoServicios detallePedidosServicios = new DetallePedidoServicios();
                            List<DetallePedido> detalles = detallePedidosServicios.obtenerDetallesPedido(idPedido);
                            for (DetallePedido detalle : detalles) {
                                int idProducto = detalle.getProducto().getId();
                                String nombreProducto = detalle.getProducto().getNombre();
                                int cantidadProducto = detalle.getCantidad();
                                double precioVentaProducto = detalle.getPrecioVenta();
                                total += cantidadProducto * precioVentaProducto;
                        %>
                        <tr>
                            <td><input type="hidden" name="idProducto[]" value="<%= idProducto%>"><%= nombreProducto%></td>
                            <td><input type="number" name="cantidadProducto[]" class="form-control" value="<%= cantidadProducto%>" oninput="actualizarTotal()"></td>
                            <td><input type="text" class="form-control" name="" value="$<%= precioVentaProducto%>" disabled data-precio="<%= precioVentaProducto%>"></td>
                            <input type="hidden" name="precioVenta[]" value="<%= precioVentaProducto%>">
                            <td><button type="button" class="btn btn-danger" onclick="eliminarProducto(this)">Eliminar</button></td>
                        </tr>
                        <% }%>
                    </tbody>
                </table>
            </div>

            <div class="mb-3">
                <label for="totalPedido" class="form-label">Total del Pedido</label>
                <input type="number" id="totalPedido" class="form-control" value="<%= total%>" disabled>
                <input type="hidden" id="totalPedidoHidden" name="totalPedido" value="<%= total%>"> <!-- Campo oculto -->
            </div>

            <button type="submit" class="btn btn-success" style="margin-bottom: 20px;">Guardar Cambios</button>
        </form>
    </div>
    
    <footer class="text-center mt-4" style="background-color: #212529; color: white; padding: 10px; font-family: Arial, sans-serif">
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

    <script src="../Scripts/modificarPedidos.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
