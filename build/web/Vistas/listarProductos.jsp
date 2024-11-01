<%@page import="logica.Clases.Producto"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="logica.Clases.Categoria" %>
<%
    // Verifica si hay una sesión activa
    if (session == null || session.getAttribute("usuario") == null) {
        // Redirige a Login.jsp si el usuario no está autenticado
        response.sendRedirect("Login.jsp");
        return;
    }

    // Obtener la categoría seleccionada
    String nombreCategoriaSeleccionada = (String) request.getAttribute("nombreCategoriaSeleccionada");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Listado de Productos</title>
        <link rel="stylesheet" type="text/css" href="Styles/listarPedidos.css">
        <script src="Scripts/listarProductos.js"></script>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            /* Estilo para el encabezado */
            .table-dark th {
                background-color: #000; /* Fondo negro para el encabezado */
                color: #fff; /* Texto blanco */
            }
            /* Estilo para centrar texto en las celdas de la tabla */
            .table td, .table th {
                text-align: center; /* Centrar contenido de las celdas */
            }
        </style>
    </head>
    <body>
        <header class="d-flex align-items-center justify-content-between p-3 bg-dark text-white">
            <div class="encabezado">
                <h1>Listado de Productos</h1>
            </div>
            <div class="d-flex justify-content-center flex-grow-1">
                <a href="Home.jsp" class="btn btn-light mx-2">
                    <i class="fas fa-home"></i> Inicio
                </a>
                <a href="crearPedido" class="btn btn-light mx-2">
                    <i class="fas fa-plus"></i> Crear Pedido
                </a>
                <a href="historialpedidos" class="btn btn-light mx-2">
                    <i class="fas fa-history"></i> Historial de Pedidos
                </a>
                <a href="generarInforme" class="btn btn-light mx-2">
                    <i class="fas fa-file-alt"></i> Generar Informe
                </a>
            </div>

            <div class="busqueda-filtros d-flex align-items-center">
                <input type="text" id="busqueda" onkeyup="filtrarTabla()" class="form-control me-2" placeholder="Buscar...">
                <label for="filtro" class="me-2">Filtros:</label>
                <select id="filtro" onchange="filtrarTabla()" class="form-select">
                    <option value="todos">Ninguno</option>
                    <option value="nombre">Nombre</option>
                    <option value="descripcion">Descripción</option>
                    <option value="sku">SKU</option>
                </select>
            </div>
        </header>

        <div class="container mt-5">
            <div class="form-group mt-4">
                <label for="categoriaSelect">SELECCIONAR UNA CATEGORIA:</label>
                <select class="form-control" id="categoriaSelect" onchange="cargarProductos()">
                    <option value="todos" <%= nombreCategoriaSeleccionada == null ? "selected" : ""%>>Todos</option>
                    <%
                        ArrayList<Categoria> categorias = (ArrayList<Categoria>) request.getAttribute("categorias");
                        for (Categoria categoria : categorias) {
                            String selected = categoria.getNombre().equals(nombreCategoriaSeleccionada) ? "selected" : "";
                    %>
                    <option value="<%= categoria.getNombre()%>" <%= selected%>><%= categoria.getNombre()%></option>
                    <%
                        }
                    %>
                </select>
            </div>

            <table class="table table-striped table-dark" id="tablaProductos">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Descripción</th>
                        <th>SKU</th>
                        <th>Precio de Venta</th>
                        <th>Stock</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        ArrayList<Producto> productos = (ArrayList<Producto>) request.getAttribute("productos");
                        for (Producto producto : productos) {
                    %>
                    <tr>
                        <td><%= producto.getNombre()%></td>
                        <td><%= producto.getDescripcion()%></td>
                        <td><%= producto.getSKU()%></td>
                        <td><%= producto.getPrecioVenta()%></td>
                        <td><%= producto.getStock()%></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <div id="paginacion" class="d-flex justify-content-center mt-4" style="display:none;"></div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', () => {
                actualizarPaginacion();
            });
        </script>
    </body>
</html>
